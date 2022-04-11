papalexi_offsite <- .get_config_path("LOCAL_PAPALEXI_2021_DATA_DIR")
schraivogel_offsite <- .get_config_path("LOCAL_SCHRAIVOGEL_2020_DATA_DIR")

# create a list; each element of the list contains:
# (i) response_odm_fp,
# (ii) response_metadata_fp,
# (iii) gRNA_odm_fp,
# (iv) gRNA_metadata_fp

data_list <- list(
  # Papalexi gene modality
  papalexi_gene = c(response_odm_fp = paste0(papalexi_offsite, "processed/gene/expression_matrix.odm"),
                    response_metadata_fp = paste0(papalexi_offsite, "processed/gene/metadata.rds"),
                    gRNA_odm_fp = paste0(papalexi_offsite, "processed/gRNA/count_matrix.odm"),
                    gRNA_metadata_fp = paste0(papalexi_offsite, "processed/gRNA/metadata.rds")),
  
  # Schraivogel TAP-seq
  schraivogel_tap = c(response_odm_fp = paste0(schraivogel_offsite, "processed/ground_truth_tapseq/gene/expression_matrix.odm"),
                      response_metadata_fp = paste0(schraivogel_offsite, "processed/ground_truth_tapseq/gene/metadata.rds"),
                      gRNA_odm_fp = paste0(schraivogel_offsite, "processed/ground_truth_tapseq/gRNA/raw_ungrouped.odm"),
                      gRNA_metadata_fp = paste0(schraivogel_offsite, "processed/ground_truth_tapseq/gRNA/raw_ungrouped_metadata.rds"))
)

# ADD: Papalexi protein modality, Schraivogel perturb-seq