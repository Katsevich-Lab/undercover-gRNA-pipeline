#!/usr/bin/env Rscript

# Get CL args; set sceptre2 offsite dir
args <- commandArgs(trailingOnly = TRUE)
dataset_name <- args[1]
undercover_ntc_name_in <- args[2]
method_name <- args[3]
grna_modality <- args[4]
genes_to_subsample <- as.integer(args[5])
optional_args <- if (length(args) == 6) args[6] else NULL

# Load packages
library(ondisc)
library(lowmoi)

# read response matrix and grna expression matrix
response_odm <- load_dataset_modality(dataset_name)
grna_dataset_name <- get_grna_dataset_name(dataset_name, grna_modality)
grna_odm <- load_dataset_modality(grna_dataset_name)

# perform the label swap
undercover_ntc_name <- strsplit(x = undercover_ntc_name_in, split = ",", fixed = TRUE) |> unlist()
grna_feature_covariates <- grna_odm |> get_feature_covariates()
grna_feature_covariates[undercover_ntc_name, "target"] <- "undercover"
if (!("non-targeting" %in% grna_feature_covariates$target)) {
  stop("After performing label swap, `non-targeting` is no longer string in the `target` column.")
}
grna_odm_swapped <- grna_odm |> mutate_feature_covariates(target = grna_feature_covariates$target)

# obtain the (response, grna) pairs to analyze
response_ids <- get_feature_ids(response_odm)
if (genes_to_subsample > 0 && length(response_ids) >= genes_to_subsample) {
  set.seed(4)
  response_ids <- sample(response_ids, genes_to_subsample)
}
response_grna_group_pairs <- data.frame(response_id = response_ids,
                                        grna_group = "undercover")

# verify that "method" is a function within the lowmoi package
if (!exists(x = method_name, where = "package:lowmoi", mode = "function")) {
  stop(paste0("The method `", method_name, "` is not present in the `lowmoi` package. Either add this method to the package or update the `data_method_pair_file.groovy` file."))
}
# verify that the formal arguments of "method" are correct
formal_args <- names(formals(method_name))
if (!all(c("response_odm", "grna_odm", "response_grna_group_pairs") %in% formal_args)) {
  stop(paste0("The formal arguments of `", method_name, "` must include `response_odm`, `grna_odm`, and `response_grna_group_pairs`."))
}

to_pass_list <- list(response_odm = response_odm, grna_odm = grna_odm_swapped, response_grna_group_pairs = response_grna_group_pairs)
if (!is.null(optional_args)) { # if there are optional arguments specified, add them to the list
  optional_args <- strsplit(x = optional_args, split = ":") |> unlist()
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

if (!all(c("grna_group", "p_value", "response_id") %in% colnames(result_df))) {
  stop(paste0("The output of `", method_name, "` must contain columns `response_id`, `grna_group`, and `p_value`."))
}

# add columns indicating the undercover grna, dataset name, and method name
out <- result_df |>
  dplyr::mutate(undercover_grna = undercover_ntc_name_in, grna_group = NULL, dataset = dataset_name, method = method_name) |>
  dplyr::mutate_at(.vars = c("response_id", "undercover_grna", "dataset", "method"), .funs = factor)

# save result
saveRDS(object = out, file = "raw_result.rds")
