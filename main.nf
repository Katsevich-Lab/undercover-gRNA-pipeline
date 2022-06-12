params.one_neg_control = "FALSE"
params.max_retries = 1
params.grna_modality = "assignment" // ("assignment" vs "expression")

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
// Define the get_vector_entry function
def get_vector_entry(vector, col_names, my_col_name) {
  idx = col_names.findIndexOf{ it == my_col_name }
  return vector[idx]
}


// PROCESS 1: Obain tuples of datastes and NTC pairs
process obtain_dataset_ntc_tuples {
  clusterOptions "-q short.q -l m_mem_free=2G -o \$HOME/output/\'\$JOB_NAME-\$JOB_ID-\$TASK_ID.log\'"

  output:
  path "dataset_names_raw.txt" into dataset_names_raw_ch

  """
  get_dataset_ntc_tuples.R ${params.one_neg_control} ${params.grna_modality} $data_list_str
  """
}
dataset_ntc_pairs = dataset_names_raw_ch.splitText().map{it.trim().split(" ")}.map{[it[0], it[1]]}


// STEP 2: Combine the methods and NTCs, resulting in dataset-NTC-method tuples.
// Additionally, append to each tuple: (i) the amount of RAM requested, (ii) the queue (short or long), and (iii) any additional arguments.
dataset_ntc_method_tuples = dataset_ntc_pairs.combine(data_method_pairs_ch, by: 0).map{
  [it[0], // dataset
  it[1], // NTC
  it[2], // method
  get_matrix_entry(data_method_queue_matrix, row_names, col_names, it[0], it[2]), // queue
  get_matrix_entry(data_method_ram_matrix, row_names, col_names, it[0], it[2]), // RAM
  get_vector_entry(optional_args, col_names, it[2])] // optional args
}


// PROCESS 2: Run methods on undercover gRNAs
process run_method {
  clusterOptions "-q $queue -l m_mem_free=${ram}G -o \$HOME/output/\'\$JOB_NAME-\$JOB_ID-\$TASK_ID.log\'"
  errorStrategy { task.exitStatus == 137 ? 'retry' : 'ignore' }
  maxRetries params.max_retries

  tag "$dataset+$method+$ntc"

  output:
  file 'raw_result.rds' into raw_results_ch

  input:
  tuple val(dataset), val(ntc), val(method), val(queue), val(ram), val(opt_args) from dataset_ntc_method_tuples

  """
  run_method.R $dataset $ntc $method ${params.grna_modality} $opt_args
  """
}


// PROCESS 3: Combine results
params.result_file_name = "undercover_gRNA_check_results.rds"
process combine_results {
  clusterOptions "-q short.q -o \$HOME/output/\'\$JOB_NAME-\$JOB_ID-\$TASK_ID.log\'"
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
  clusterOptions "-q short.q -o \$HOME/output/\'\$JOB_NAME-\$JOB_ID-\$TASK_ID.log\'"

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
  clusterOptions "-q short.q -o \$HOME/output/\'\$JOB_NAME-\$JOB_ID-\$TASK_ID.log\'"

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
