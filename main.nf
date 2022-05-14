// Pipeline arguments
// i. data_file
// ii. method_data_pair_file

// STEP 0: Determine the dataset-method pairs
GroovyShell shell = new GroovyShell()
def tools = shell.parse(new File(params.data_method_pair_file))
evaluate(new File(params.data_method_pair_file))
def data_method_pairs_list = []
  for (entry in data_method_pairs) {
    for (value in entry.value) {
      data_method_pairs_list << [entry.key, value]
    }
}
data_method_pairs_ch = Channel.from(data_method_pairs_list)
data_method_pairs_ch.view()


/*
// PROCESS 1: Obain tuples of datastes and NTC pairs
process obtain_dataset_ntc_tuples {

output:
path "dataset_names_raw.txt" into dataset_names_raw_ch

input:
path data_file from params.data_file

"""
get_dataset_ntc_tuples.R $data_file
"""
}
dataset_ntc_pairs = dataset_names_raw_ch.splitText().map{it.trim().split(" ")}.map{[it[0], it[1]]}


// STEP 2: Combine the methods and NTCs, then filter
dataset_ntc_method_tuples = dataset_ntc_pairs.combine(data_method_pairs_ch, by: 0)


// PROCESS 3: Run methods on undercover gRNAs
process run_method {
  clusterOptions "-l m_mem_free=${task.attempt * tools.get_matrix_entry(data_method_ram_matrix, row_names, col_names, dataset, method)}G -o \$HOME/output/\'\$JOB_NAME-\$JOB_ID-\$TASK_ID.log\' "
  errorStrategy { task.exitStatus == 137 ? 'retry' : 'terminate' }
  maxRetries 1

  tag "$dataset+$method+$ntc"

  output:
  file 'raw_result.rds' into raw_results_ch

  input:
  path data_file from params.data_file
  tuple val(dataset), val(ntc), val(method) from dataset_ntc_method_tuples

  """
  run_method.R $data_file $dataset $ntc $method ${task.attempt * tools.get_matrix_entry(data_method_ram_matrix, row_names, col_names, dataset, method)}
  """
}


// PROCESS 4: Combine results
params.result_file_name = "undercover_gRNA_check_results.rds"
process combine_results {
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


start_time = params.time.toString()
if (start_time.length() == 7) start_time = "0" + start_time

// PROCESS 5: Add RAM and CPU information to results
process get_ram_cpu_info {
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
*/
