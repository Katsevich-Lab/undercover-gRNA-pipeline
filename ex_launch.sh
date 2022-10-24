export NXF_OPTS="-Xms500M -Xmx5G" # limit NF driver to 5 GB of memory
source ~/.research_config

curr_time=$(date '+%m%d%H%M')
nextflow run "main.nf" \
 --data_method_pair_file $LOCAL_CODE_DIR"/sceptre2-manuscript/param_files/mw_debug.groovy" \
 --result_dir $LOCAL_SCEPTRE2_DATA_DIR"results/undercover_grna_analysis" \
 --result_file_name "mw_debug.rds" \
 --grna_modality "assignment" \
 --group_size "1" \
 --is_group_size_frac "false" \
 --partition_count 1 \
 --is_partition_count_frac "true" \
 --machine_name $MACHINE_NAME \
 --pair_restriction "/Users/timbarry/research_offsite/projects/sceptre2/results/undercover_grna_analysis/mw_debug_pairs.rds" \
 --time $curr_time \
 -profile standard
