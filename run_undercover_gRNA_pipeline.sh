#$ -j y

export NXF_OPTS="-Xms500M -Xmx4G" # limit NF driver to 4 GB of memory
source ~/.research_config

curr_time=$(date '+%m%d%H%M')
# nextflow pull https://github.com/Katsevich-Lab/undercover-gRNA-pipeline
# nextflow run undercover-gRNA-pipeline -r main \
nextflow run "/Users/timbarry/research_code/undercover-gRNA-pipeline/main.nf" \
 --data_method_pair_file "data_method_pair_file.groovy" \
 --result_dir $LOCAL_SCEPTRE2_DATA_DIR"results/undercover_grna_analysis" \
 --result_file_name "result_test.rds" \
 --grna_modality "assignment" \
 --group_size 3 \
 --is_group_size_frac "false" \
 --partition_count 1 \
 --is_partition_count_frac "true" \
 --machine_name $MACHINE_NAME \
 --time $curr_time \
 --max_retries 2
