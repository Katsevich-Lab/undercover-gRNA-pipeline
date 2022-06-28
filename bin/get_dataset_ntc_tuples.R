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
  # load gRNA odm and feature covariates
  grna_dataset_name <- lowmoi::get_gRNA_dataset_name(dataset_name, grna_modality)
  gRNA_feature_covariates <- lowmoi::load_dataset_modality(grna_dataset_name) |> get_feature_covariates()
 
  # some basic correctness checks: check for the presence of column "target" and ensure that "non-targeting" is an entry of this column.
  if (!("target" %in% colnames(gRNA_feature_covariates))) {
    stop("The column `target` must be present in the feature covariates data frame of the gRNA ondisc matrix.")
  }
  if (!("non-targeting" %in% gRNA_feature_covariates$target)) {
    stop("The `target` column of the gRNA feature covariates data frame must have at least one entry `non-targeting`.")
  }

  # get NTC names and NTC count
  ntc_names <- gRNA_feature_covariates |>
    dplyr::filter(target_type == "non-targeting") |>
    row.names()
  n_ntcs <- length(ntc_names)
  
  # compute curr_group size and curr_partition_count
  group_size <- if (is_group_size_frac) floor(group_size_in * n_ntcs) else group_size_in
  partition_count <- if (is_partition_count_frac) floor(partition_count_in * n_ntcs) else partition_count_in
  
  # get the undercover groups
  my_grps <- lowmoi::get_undercover_groups(ntc_names, group_size, partition_count)
  
  # append to out
  out <- c(out, paste(dataset_name, my_grps))
}

# write to disk
file_con <- file("dataset_names_raw.txt")
writeLines(out, file_con)
close(file_con)

get_undercover_groups <- function(ntc_names, group_size, partition_count) {
  set.seed(4)
  n_ntcs <- length(ntc_names)
  total_possible_paritions <- choose(n_ntcs, group_size)
  if (partition_count > total_possible_paritions) stop("partition_count exceeds the total number of possible partitions.")
  my_undercover_groups <- character()
  ntc_names_copy <- ntc_names
  repeat {
    while (length(ntc_names_copy) >= group_size) {
      curr_grp <- sample(x = ntc_names_copy,
                         size = group_size,
                         replace = FALSE)
      curr_grp_string <- curr_grp |> sort() |> paste0(collapse = ",")
      if (!(curr_grp_string %in% my_undercover_groups)) {
        my_undercover_groups <- c(my_undercover_groups, curr_grp_string)
      }
      ntc_names_copy <- ntc_names_copy[!(ntc_names_copy %in% curr_grp)]
    }
    if (length (my_undercover_groups) >= partition_count) break()
    ntc_names_copy <- ntc_names
  }
  return(my_undercover_groups[seq(1, partition_count)])
}
