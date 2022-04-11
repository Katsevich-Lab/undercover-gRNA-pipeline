// All arguments
params.methods = ["MAST", "mixscape"]

// define a channel for the methods
methods_ch = Channel.from(params.methods)

// Get a simple channel with the dataset names
process obtain_dataset_names {

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

process print_ex {
  echo true

  input:
  path data_file from params.data_file
  tuple val(dataset_ntc), val(method) from dataset_ntc_method_tuples

  """
  run_method.R $data_file $dataset_ntc $method
  """
}
