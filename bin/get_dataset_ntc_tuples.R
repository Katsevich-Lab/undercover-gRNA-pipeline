#!/usr/bin/env Rscript

# Get CL args
args <- commandArgs(trailingOnly = TRUE)
data_file <- args[1]

source(data_file)
library(ondisc)

out <- NULL
for (dataset_name in names(data_list)) {
  gRNA_metadata <- data_list[[dataset_name]][["gRNA_metadata_fp"]]
  x <- readRDS(gRNA_metadata)
  ntc_names <- x[["feature_covariates"]] |>
    dplyr::filter(target_type == "non-targeting") |>
    row.names()
  out <- c(out, paste(dataset_name, ntc_names))
}
cat(paste0(out, collapse = "\n"))
