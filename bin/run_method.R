#!/usr/bin/env Rscript

# Get CL args
args <- commandArgs(trailingOnly = TRUE)
data_file <- args[1]
dataset_name <- args[2]
ntc_name <- args[3]
method_name <- args[4]

# load the data fps
source(data_file)

# Load packages
library(ondisc)

# read gene expression matrix and gRNA expression matrix
curr_fps <- data_list[[dataset_name]] 
gene_odm <- read_odm(odm_fp = curr_fps[["gene_odm_fp"]],
                     metadata_fp = curr_fps[["gene_metadata_fp"]])
gRNA_odm <- read_odm(odm_fp = curr_fps[["gRNA_odm_fp"]],
                     metadata_fp = curr_fps[["gRNA_metadata_fp"]])

# load the gRNA counts
gRNA_mat <- gRNA_odm[[seq(1, nrow(gRNA_odm)),]]
row.names(gRNA_mat) <- get_feature_ids(gRNA_odm)

gRNA_metadata <- get_feature_covariates(gRNA_odm) |> 
  dplyr::select(-mean_expression, -coef_of_variation, -n_nonzero)

