params.one_neg_control = "FALSE"
params.max_retries = 1

// STEP 0: Determine the dataset-method pairs; put the dataset method pairs into a map, and put the datasets into an array
GroovyShell shell = new GroovyShell()
evaluate(new File(params.data_method_pair_file))
def data_method_pairs_list = []
data_list_str = ""
  for (entry in data_method_pairs) {
    data_list_str = data_list_str + " " + entry.key
    for (value in entry.value) {
      data_method_pairs_list << [entry.key, value]
    }
}
// Create data_ch and data_method_pairs_ch
data_method_pairs_ch = Channel.from(data_method_pairs_list)
// Define the get_matrix_entry function
def get_matrix_entry(data_method_ram_matrix, row_names, col_names, my_row_name, my_col_name) {
  row_idx = row_names.findIndexOf{ it == my_row_name }
  col_idx = col_names.findIndexOf{ it == my_col_name }
  return data_method_ram_matrix[row_idx][col_idx]
}


// PROCESS 1: Obain tuples of datastes and NTC pairs
process obtain_dataset_ntc_tuples {
  clusterOptions "-q short.q -l m_mem_free=2G -o \$HOME/output/\'\$JOB_NAME-\$JOB_ID-\$TASK_ID.log\'"

  output:
  path "dataset_names_raw.txt" into dataset_names_raw_ch

  """
  get_dataset_ntc_tuples.R ${params.one_neg_control} $data_list_str
  """
}

dataset_ntc_pairs = dataset_names_raw_ch.splitText().map{it.trim().split(" ")}.map{[it[0], it[1]]}


// STEP 2: Combine the methods and NTCs, then filter
dataset_ntc_method_tuples = dataset_ntc_pairs.combine(data_method_pairs_ch, by: 0)


// PROCESS 2: Run methods on undercover gRNAs
process run_method {
  clusterOptions "-l m_mem_free=${task.attempt * get_matrix_entry(data_method_ram_matrix, row_names, col_names, dataset, method)}G -o \$HOME/output/\'\$JOB_NAME-\$JOB_ID-\$TASK_ID.log\' -q short.q"
  errorStrategy { task.exitStatus == 137 ? 'retry' : 'terminate' }
  maxRetries params.max_retries

  tag "$dataset+$method+$ntc"

  output:
  file 'raw_result.rds' into raw_results_ch

  input:
  tuple val(dataset), val(ntc), val(method) from dataset_ntc_method_tuples

  """
  run_method.R $dataset $ntc $method ${task.attempt * get_matrix_entry(data_method_ram_matrix, row_names, col_names, dataset, method)}
  """
}


// PROCESS 3: Combine results
params.result_file_name = "undercover_gRNA_check_results.rds"
process combine_results {
  clusterOptions "-o \$HOME/output/\'\$JOB_NAME-\$JOB_ID-\$TASK_ID.log\' -q short.q"
  publishDir params.result_dir, mode: "copy"

  output:
  file "$params.result_file_name" into collected_results_ch
  val "flag" into flag_ch

  input:
  file 'raw_result' from raw_results_ch.collect()

  """
  collect_results.R $params.result_file_name raw_result*
  """
}


// PROCESS 4: Add RAM and CPU information to results
start_time = params.time.toString()
if (start_time.length() == 7) start_time = "0" + start_time
process get_ram_cpu_info {
  clusterOptions "-o \$HOME/output/\'\$JOB_NAME-\$JOB_ID-\$TASK_ID.log\' -q short.q"

  when:
  params.machine_name == "hpcc"

  input:
  val flag from flag_ch

  output:
  file "ram_cpu_info" into ram_cpu_ch

  """
  qacct -j -o timbar -b $start_time | awk '/jobname|ru_maxrss|ru_wallclock/ {print \$1","\$2}' > ram_cpu_info
  """
}


process append_ram_clock_info {
  publishDir params.result_dir, mode: "copy"
  clusterOptions "-o \$HOME/output/\'\$JOB_NAME-\$JOB_ID-\$TASK_ID.log\' -q short.q"

  when:
  params.machine_name == "hpcc"

  output:
  file "$params.result_file_name" into collected_results_ch_appended

  input:
  file "collected_results" from collected_results_ch
  file "ram_cpu_info" from ram_cpu_ch

  """
  append_ram_cpu.R ram_cpu_info collected_results $params.result_file_name
  """
}
