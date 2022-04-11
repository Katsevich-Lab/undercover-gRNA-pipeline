#!/usr/bin/env Rscript

# Get CL args
args <- commandArgs(trailingOnly = TRUE)
data_file <- args[1]
dataset_name <- args[2]
undercover_ntc_name <- args[3]
method_name <- args[4]

# load the data fps
source(data_file)

# Load packages
library(ondisc)

# read gene expression matrix and gRNA expression matrix
curr_fps <- data_list[[dataset_name]] 
response_odm <- read_odm(odm_fp = curr_fps[["response_odm_fp"]],
                     metadata_fp = curr_fps[["response_metadata_fp"]])
gRNA_odm <- read_odm(odm_fp = curr_fps[["gRNA_odm_fp"]],
                     metadata_fp = curr_fps[["gRNA_metadata_fp"]])

# some basic correctness checks
gRNA_feature_covariates <- gRNA_odm |> get_feature_covariates()
if (!("target_type" %in% colnames(gRNA_feature_covariates))) {
  stop("The column `target_type` must be present in the feature covariates data frame of the gRNA ondisc matrix.")
}
if (!("non-targeting" %in% gRNA_feature_covariates$target_type)) {
  stop("The `target_type` column of the gRNA feature covariates data frame must have at least one entry `non-targeting`.")
}

# perform the label swap
tab_target_types <- sort(table(gRNA_feature_covariates$target_type), decreasing = TRUE)
new_label <- (tab_target_types[names(tab_target_types) != "non-targeting"] |> names())[1]
gRNA_feature_covariates[undercover_ntc_name, "target_type"] <- new_label
gRNA_odm_swapped <- gRNA_odm |> mutate_feature_covariates(target_type = gRNA_feature_covariates$target_type)

# obtain the (response, gRNA) pairs to analyze
pairs_df <- data.frame(response_id = get_feature_ids(response_odm),
                       gRNA_id = undercover_ntc_name)

# call the method (UPDATE; pass gRNA ODM, response ODM, and gRNA-response pairs; return the gRNA-response pairs data frame with a column "p_value" appended)
result_df <- pairs_df

# add columns indicating the undercover gRNA, dataset name, and method name
out <- result_df |>
  dplyr::mutate(undercover_gRNA = gRNA_id, gRNA_id = NULL, dataset = dataset_name, method = method_name) |>
  dplyr::mutate_all(factor)

# save result
saveRDS(object = out, file = "raw_result.rds")
