#!/usr/bin/env Rscript

# Get CL args; set sceptre2 offsite dir
args <- commandArgs(trailingOnly = TRUE)
dataset_name <- args[1]
undercover_ntc_name_in <- args[2]
method_name <- args[3]
grna_modality <- args[4]
if (length(args) >= 5) {
  optional_args <- args[seq(5, length(args))]
} else {
  optional_args <- NULL
}

# Load packages
library(ondisc)
library(lowmoi)

# read response matrix and gRNA expression matrix
response_odm <- load_dataset_modality(dataset_name)
grna_dataset_name <- get_gRNA_dataset_name(dataset_name, grna_modality)
gRNA_odm <- load_dataset_modality(grna_dataset_name)

# perform the label swap
undercover_ntc_name <- strsplit(x = undercover_ntc_name_in, split = ",", fixed = TRUE) |> unlist()
gRNA_feature_covariates <- gRNA_odm |> get_feature_covariates()
gRNA_feature_covariates[undercover_ntc_name, "target"] <- "undercover"
if (!("non-targeting" %in% gRNA_feature_covariates$target)) {
  stop("After performing label swap, `non-targeting` is no longer string in the `target` column.")
}
gRNA_odm_swapped <- gRNA_odm |> mutate_feature_covariates(target = gRNA_feature_covariates$target)


# obtain the (response, gRNA) pairs to analyze
response_gRNA_group_pairs <- data.frame(response_id = get_feature_ids(response_odm),
                                        gRNA_group = "undercover")

# verify that "method" is a function within the lowmoi package
if (!exists(x = method_name, where = "package:lowmoi", mode = "function")) {
  stop(paste0("The method `", method_name, "` is not present in the `lowmoi` package. Either add this method to the package or update the `data_method_pair_file.groovy` file."))
}
# verify that the formal arguments of "method" are correct
formal_args <- names(formals(method_name))
if (!all(c("response_odm", "gRNA_odm", "response_gRNA_group_pairs") %in% formal_args)) {
  stop(paste0("The formal arguments of `", method_name, "` must include `response_odm`, `gRNA_odm`, and `response_gRNA_group_pairs`."))
}

to_pass_list <- list(response_odm = response_odm, gRNA_odm = gRNA_odm_swapped, response_gRNA_group_pairs = response_gRNA_group_pairs)
if (!is.null(optional_args)) { # if there are optional arguments specified, add them to the list
  values_vect <- NULL
  names_vect <- NULL
  for (str in optional_args) {
    str_split <- strsplit(x = str, split = "=", fixed = TRUE)[[1]]
    values_vect <- c(values_vect, str_split[2])
    names_vect <- c(names_vect, str_split[1])
  }
  to_append_list <- purrr::set_names(as.list(values_vect), names_vect)
  to_pass_list <- c(to_pass_list, to_append_list)
}

result_df <- do.call(what = method_name, args = to_pass_list)

if (!identical(sort(colnames(result_df)), c("gRNA_group", "p_value", "response_id"))) {
  stop(paste0("The output of `", method_name, "` must be a data frame with columns `response_id`, `gRNA_group`, and `p_value`."))
}

# add columns indicating the undercover gRNA, dataset name, and method name
out <- result_df |>
  dplyr::mutate(undercover_gRNA = undercover_ntc_name_in, gRNA_group = NULL, dataset = dataset_name, method = method_name) |>
  dplyr::mutate_at(.vars = c("response_id", "undercover_gRNA", "dataset", "method"), .funs = factor)

# save result
saveRDS(object = out, file = "raw_result.rds")
