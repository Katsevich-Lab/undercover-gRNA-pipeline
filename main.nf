params.max_retries = 1 // max number of retries upon process failure
params.grna_modality = "assignment" // ("assignment" vs "expression")
params.group_size = 3 // number of grnas per grna group
params.is_group_size_frac = "false" // is "group_size" a fraction? If so, group_size = group_size * (n NTCs); else group_size = group_size
params.partition_count = 1 // number of NTC partitions (or "configurations") to iterate over
params.is_partition_count_frac = "true" // is "partition_count" a fraction? If so, partition_count = group_size = group_size  * (n NTCs); else, partition_count = partition_count
params.genes_to_subsample = 0 // number of genes to sample; 0 corresponds to no downsampling, i.e., use all genes
params.pair_restriction = "/"

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
  queue "short.q"
  memory "2 GB"

  output:
  path "dataset_names_raw.txt" into dataset_names_raw_ch

  """
  get_dataset_ntc_tuples.R ${params.grna_modality} ${params.group_size} ${params.is_group_size_frac} ${params.partition_count} ${params.is_partition_count_frac} $data_list_str
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


// PROCESS 2: Run methods on undercover grnas
process run_method {
  queue "$queue"
  memory "$ram GB"
  debug true

  tag "$dataset+$method"

  output:
  file 'raw_result.rds' into raw_results_ch

  input:
  tuple val(dataset), val(ntc), val(method), val(queue), val(ram), val(opt_args) from dataset_ntc_method_tuples
  path pair_restriction_fp from params.pair_restriction

  """
  run_method.R $dataset $ntc $method ${params.grna_modality} ${params.genes_to_subsample} $pair_restriction_fp $opt_args
  """
}


// PROCESS 3: Combine results
params.result_file_name = "undercover_grna_check_results.rds"
process combine_results {
  queue "short.q"
  publishDir params.result_dir, mode: "copy"
  memory "35 GB"

  output:
  file "$params.result_file_name" into collected_results_ch
  val "flag" into flag_ch

  input:
  file 'raw_result' from raw_results_ch.collect()

  """
  collect_results.R $params.result_file_name raw_result*
  """
}
