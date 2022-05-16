#!/usr/bin/env Rscript

# Get CL args; set sceptre2 offsite dir
args <- commandArgs(trailingOnly = TRUE)
dataset_name <- args[1]
undercover_ntc_name <- args[2]
method_name <- args[3]
ram_req <- args[4]
sceptre2_offsite_dir <- paste0(.get_config_path("LOCAL_SCEPTRE2_DATA_DIR"), "data/")

# Load packages
library(ondisc)
library(lowmoi)

# read response matrix and gRNA expression matrix
modality_fp <- paste0(sceptre2_offsite_dir, dataset_name)
data_dir <- sub('/[^/]*$', '', modality_fp)
gRNA_fp <- paste0(data_dir, "/grna")
response_odm <- read_odm(odm_fp = paste0(modality_fp, "/matrix.odm"),
                         metadata_fp = paste0(modality_fp, "/metadata_qc.rds"))
gRNA_odm <- read_odm(odm_fp = paste0(gRNA_fp, "/matrix.odm"),
                     metadata_fp = paste0(gRNA_fp, "/metadata_qc.rds"))

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
                                                     gRNA_odm = gRNA_odm_swapped,
                                                     response_gRNA_group_pairs = response_gRNA_group_pairs))

if (!identical(sort(colnames(result_df)), c("gRNA_group", "p_value", "response_id"))) {
  stop(paste0("The output of `", method_name, "` must be a data frame with columns `response_id`, `gRNA_group`, and `p_value`."))
}

# add columns indicating the undercover gRNA, dataset name, and method name
out <- result_df |>
  dplyr::mutate(undercover_gRNA = gRNA_group, gRNA_group = NULL, dataset = dataset_name, method = method_name, ram_req = ram_req) |>
  dplyr::mutate_at(.vars = c("response_id", "undercover_gRNA", "dataset", "method", "ram_req"), .funs = factor)

# save result
saveRDS(object = out, file = "raw_result.rds")
