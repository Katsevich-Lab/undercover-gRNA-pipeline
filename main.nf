// Pipeline arguments
params.methods = ["MAST", "mixscape"]
params.result_file_name = "undercover_gRNA_check_results.rds"

// define a channel for the methods
methods_ch = Channel.from(params.methods)

/************************************************
PROCESS 1: Obain tuples of datastes and NTC pairs
*************************************************/
process obtain_dataset_ntc_tuples {

output:
stdout dataset_names_raw

input:
path data_file from params.data_file

"""
Rscript -e '
source("$data_file");
library(ondisc);

out <- NULL;
for (dataset_name in names(data_list)) {
  gRNA_metadata <- data_list[[dataset_name]][["gRNA_metadata_fp"]];
  x <- readRDS(gRNA_metadata);
  ntc_names <- x[["feature_covariates"]] |>
    dplyr::filter(target_type == "non-targeting") |>
    row.names();
  out <- c(out, paste(dataset_name, ntc_names));
}
cat(paste0(out, collapse = "\n"));
'
"""
}

dataset_ntc_pairs = dataset_names_raw.splitText().map{it.trim()}
dataset_ntc_method_tuples = dataset_ntc_pairs.combine(methods_ch)

/******************************************
PROCESS 2: Run methods on undercover gRNAs
******************************************/
process run_method {
  output:
  file 'raw_result.rds' into raw_results_ch

  input:
  path data_file from params.data_file
  tuple val(dataset_ntc), val(method) from dataset_ntc_method_tuples

  """
  run_method.R $data_file $dataset_ntc $method
  """
}


/*************************
PROCESS 3: Combine results
**************************/
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
