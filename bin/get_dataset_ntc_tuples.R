#!/usr/bin/env Rscript

# Get CL args
args <- commandArgs(trailingOnly = TRUE)
one_ntc <- as.logical(args[1])
datasets <- args[seq(2, length(args))]
sceptre2_offsite_dir <- paste0(.get_config_path("LOCAL_SCEPTRE2_DATA_DIR"), "data/")
library(ondisc)

out <- NULL
for (dataset_name in datasets) {
  grna_dataset_name <- paste0(sub('/[^/]*$', '', dataset_name), "/grna")
  gRNA_feature_covariates <- lowmoi::load_dataset_modality(grna_dataset_name) |> get_feature_covariates()
 
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
  if (one_ntc) ntc_names <- ntc_names[1]
  out <- c(out, paste(dataset_name, ntc_names))
}

# write to disk
file_con <- file("dataset_names_raw.txt")
writeLines(out, file_con)
close(file_con)
