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
library(lowmoi)

# read response matrix and gRNA expression matrix
if (!dataset_name %in% names(data_list)) {
  stop(paste0("The dataset `", dataset_name, "` is not present within the `data_list`. Ensure your `data_file.R` and `data_method_pair_file.groovy` files match and try again."))
}
curr_fps <- data_list[[dataset_name]]
response_odm <- read_odm(odm_fp = curr_fps[["response_odm_fp"]],
                     metadata_fp = curr_fps[["response_metadata_fp"]])
gRNA_odm <- read_odm(odm_fp = curr_fps[["gRNA_odm_fp"]],
                     metadata_fp = curr_fps[["gRNA_metadata_fp"]])

# perform the label swap
gRNA_feature_covariates <- gRNA_odm |> get_feature_covariates()
tab_target_types <- sort(table(gRNA_feature_covariates$target_type), decreasing = TRUE)
new_label <- (tab_target_types[names(tab_target_types) != "non-targeting"] |> names())[1]
gRNA_feature_covariates[undercover_ntc_name, "target_type"] <- new_label
gRNA_odm_swapped <- gRNA_odm |> mutate_feature_covariates(target_type = gRNA_feature_covariates$target_type)

# obtain the (response, gRNA) pairs to analyze
response_gRNA_group_pairs <- data.frame(response_id = get_feature_ids(response_odm),
                                        gRNA_group = undercover_ntc_name)

# verify that "method" is a function within the lowmoi package
if (!exists(x = method_name, where = "package:lowmoi", mode = "function")) {
  stop(paste0("The method `", method_name, "` is not present in the `lowmoi` package. Either add this method to the package or update the `data_method_pair_file.groovy` file."))
}
# verify that the formal arguments of "method" are correct
formal_args <- names(formals(method_name))
if (!all(c("response_odm", "gRNA_odm", "response_gRNA_group_pairs") %in% formal_args)) {
  stop(paste0("The formal arguments of `", method_name, "` must include `response_odm`, `gRNA_odm`, and `response_gRNA_group_pairs`."))
}

result_df <- do.call(what = method_name, args = list(response_odm = response_odm,
                                                     gRNA_odm = gRNA_odm,
                                                     response_gRNA_group_pairs = response_gRNA_group_pairs))

if (!identical(sort(colnames(result_df)), c("gRNA_group", "p_value", "response_id"))) {
  stop(paste0("The output of `", method_name, "` must be a data frame with columns `response_id`, `gRNA_group`, and `p_value`."))
}

# add columns indicating the undercover gRNA, dataset name, and method name
out <- result_df |>
  dplyr::mutate(undercover_gRNA = gRNA_group, gRNA_group = NULL, dataset = dataset_name, method = method_name) |>
  dplyr::mutate_all(factor)

# save result
saveRDS(object = out, file = "raw_result.rds")
