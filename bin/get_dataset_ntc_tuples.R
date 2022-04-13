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
  gRNA_feature_covariates <- x[["feature_covariates"]]
  
  # some basic correctness checks
  if (!("target_type" %in% colnames(gRNA_feature_covariates))) {
    stop("The column `target_type` must be present in the feature covariates data frame of the gRNA ondisc matrix.")
  }
  if (!("non-targeting" %in% gRNA_feature_covariates$target_type)) {
    stop("The `target_type` column of the gRNA feature covariates data frame must have at least one entry `non-targeting`.")
  }
  
  # get NTC names
  ntc_names <- gRNA_feature_covariates |>
    dplyr::filter(target_type == "non-targeting") |>
    row.names()
  out <- c(out, paste(dataset_name, ntc_names))
}

cat(paste0(out, collapse = "\n"))
