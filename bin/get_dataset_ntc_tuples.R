#!/usr/bin/env Rscript

# Get CL args
args <- commandArgs(trailingOnly = TRUE)
grna_modality <- args[1]
group_size_in <- as.numeric(args[2])
is_group_size_frac <- as.logical(args[3])
partition_count_in <- as.numeric(args[4])
is_partition_count_frac <- as.logical(args[5])
datasets <- args[seq(6, length(args))]

sceptre2_offsite_dir <- paste0(.get_config_path("LOCAL_SCEPTRE2_DATA_DIR"), "data/")
library(ondisc)

out <- NULL
for (dataset_name in datasets) {
  # load grna odm and feature covariates
  grna_dataset_name <- lowmoi::get_grna_dataset_name(dataset_name, grna_modality)
  grna_odm <- lowmoi::load_dataset_modality(grna_dataset_name)
  grna_feature_covariates <- grna_odm |> get_feature_covariates()

  # some basic correctness checks: check for the presence of column "target" and ensure that "non-targeting" is an entry of this column.
  if (!("target" %in% colnames(grna_feature_covariates))) {
    stop("The column `target` must be present in the feature covariates data frame of the grna ondisc matrix.")
  }
  if (!("non-targeting" %in% grna_feature_covariates$target)) {
    stop("The `target` column of the grna feature covariates data frame must have at least one entry `non-targeting`.")
  }

  # get NTC names and NTC count
  ntc_names <- grna_feature_covariates |>
    dplyr::filter(target_type == "non-targeting",
                  n_nonzero >= 10) |> # NTC should be expressed in at least 10 cells
    row.names()
  n_ntcs <- length(ntc_names)

  # compute curr_group size and curr_partition_count
  group_size <- if (is_group_size_frac) floor(group_size_in * n_ntcs) else group_size_in
  
  if (group_size < n_ntcs) {
    partition_count <- if (is_partition_count_frac) floor(partition_count_in * n_ntcs) else partition_count_in
    
    # get the undercover groups
    my_grps <- lowmoi::get_undercover_groups(ntc_names, group_size, partition_count)
    
    # append to out
    out <- c(out, paste(dataset_name, my_grps))
  }
}

# write to disk
file_con <- file("dataset_names_raw.txt")
writeLines(out, file_con)
close(file_con)
