#!/usr/bin/env Rscript

# Get CL args
args <- commandArgs(trailingOnly = TRUE)
data_file <- args[1]
source(data_file)

cat(paste0(method_list, collapse = "\n"))
