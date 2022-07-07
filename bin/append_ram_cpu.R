#!/usr/bin/env Rscript
library(magrittr)

args <- commandArgs(trailingOnly = TRUE)
log_file_fp <- args[1]
result_df_fp <- args[2]
result_file_name <- args[3]

tbl <- readr::read_csv(log_file_fp, c("key", "value"), c("cc"))
jobname_idxs <- seq(from = 1, by = 3, to = nrow(tbl))
clock_idxs <- seq(from = 2, by = 3, to = nrow(tbl))
ram_idxs <- seq(from = 3, by = 3, to = nrow(tbl))

job_names <- tbl$value[jobname_idxs]
clock_times <- as.numeric(tbl$value[clock_idxs])
max_rams <- as.numeric(tbl$value[ram_idxs]) * 1e-6
to_join_df <- data.frame(job_name = job_names, clock_time = clock_times, max_ram = max_rams)
to_join_df <- to_join_df[grepl(pattern = "^nf-run_method_", x = to_join_df$job_name),]

# process the job_names further
jobs_df <- to_join_df$job_name %>%
   gsub(pattern = "nf-run_method_\\(|)", replacement = "", x = .) %>%
   strsplit(x = ., split = "\\+") %>%
   lapply(X = ., FUN = function(i) matrix(i, ncol = 3, nrow = 1)) %>%
   do.call(what = rbind, args = .) %>%
   as.data.frame() %>%
   purrr::set_names(c("dataset", "method", "undercover_grna"))
to_join_df <- to_join_df %>% dplyr::mutate(jobs_df, job_name = NULL,
                                           clock_time = as.numeric(clock_time), max_ram = as.numeric(max_ram),
                                           dataset = factor(dataset), method = factor(method), undercover_grna = factor(undercover_grna))

# join with the result df
result_df <- readRDS(result_df_fp)
result_df$dataset <- factor(gsub(pattern = "/", replacement = "_", x = result_df$dataset, fixed = TRUE))

new_result_df <- dplyr::left_join(x = result_df, y = to_join_df,
                                  by = c("dataset", "method", "undercover_grna"))
# save
saveRDS(object = new_result_df, file = result_file_name)
