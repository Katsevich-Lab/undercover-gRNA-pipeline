// Pipeline arguments
// i. data_file
// ii. method_data_pair_file


// STEP 0: Determine the dataset-method pairs
evaluate(new File(params.data_method_pair_file))
def data_method_pairs_list = []
  for (entry in data_method_pairs) {
    for (value in entry.value) {
      data_method_pairs_list << [entry.key, value]
    }
}
data_method_pairs_ch = Channel.from(data_method_pairs_list)


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

  clusterOptions "-l m_mem_free=${(8 * Math.pow(2, task.attempt - 1)).toInteger()}G -o \$HOME/output/\'\$JOB_NAME-\$JOB_ID-\$TASK_ID.log\' "
  errorStrategy { task.exitStatus == 137 ? 'retry' : 'terminate' }
  maxRetries 4

  output:
  file 'raw_result.rds' into raw_results_ch

  input:
  path data_file from params.data_file
  tuple val(dataset), val(ntc), val(method) from dataset_ntc_method_tuples

  """
  run_method.R $data_file $dataset $ntc $method ${(8 * Math.pow(2, task.attempt - 1)).toInteger()}
  """
}


// PROCESS 4: Combine results
params.result_file_name = "undercover_gRNA_check_results.rds"
process combine_results {
  publishDir params.result_dir, mode: "copy"

  output:
  file "$params.result_file_name" into collected_results_ch

  input:
  file 'raw_result' from raw_results_ch.collect()

  """
  collect_results.R $params.result_file_name raw_result*
  """
}
