#!/usr/bin/env Rscript

# Get CL args
args <- commandArgs(trailingOnly = TRUE)
sceptre2_offsite_dir <- paste0(.get_config_path("LOCAL_SCEPTRE2_DATA_DIR"), "data/")
library(ondisc)

out <- NULL
for (dataset_modality_name in args) {
  modality_fp <- paste0(sceptre2_offsite_dir, dataset_modality_name)
  data_dir <- sub('/[^/]*$', '', modality_fp)
  grna_metadata_fp <- paste0(data_dir, "/grna/metadata_qc.rds")
  gRNA_metadata <- readRDS(grna_metadata_fp)
  gRNA_feature_covariates <- gRNA_metadata[["feature_covariates"]]

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
  out <- c(out, paste(dataset_modality_name, ntc_names))
}

# write to disk
file_con <- file("dataset_names_raw.txt")
writeLines(out, file_con)
close(file_con)
