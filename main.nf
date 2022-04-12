// Pipeline arguments
// i. data_file
// ii. method_data_pair_file

evaluate(new File(params.data_method_pair_file))
println(data_method_pairs)


/*
// PROCESS 1: Obain tuples of datastes and NTC pairs
process obtain_dataset_ntc_tuples {

output:
stdout dataset_names_raw

input:
path param_file from params.param_file

"""
get_dataset_ntc_tuples.R $param_file
"""
}
dataset_ntc_pairs = dataset_names_raw.splitText().map{it.trim()}


// PROCESS 2: Obain methods to apply to data
process obtain_methods {

output:
stdout method_names_raw

input:
path param_file from params.param_file

"""
get_methods.R $param_file
"""
}
methods_ch = method_names_raw.splitText().map{it.trim()}


// Mix the methods and NTCs.
dataset_ntc_method_tuples = dataset_ntc_pairs.combine(methods_ch)


// PROCESS 3: Run methods on undercover gRNAs
process run_method {
  output:
  file 'raw_result.rds' into raw_results_ch

  input:
  path param_file from params.param_file
  tuple val(dataset_ntc), val(method) from dataset_ntc_method_tuples

  """
  run_method.R $param_file $dataset_ntc $method
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
*/
