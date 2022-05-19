export NXF_OPTS="-Xms500M -Xmx3G" # limit NF to 3 GB of memory
source ~/.research_config

curr_time=$(date '+%m%d%H%M')
# nextflow pull https://github.com/Katsevich-Lab/undercover-gRNA-pipeline
nextflow run ../main.nf \
 --data_method_pair_file $PWD"/data_method_pair_file.groovy" \
 --machine_name $MACHINE_NAME \
 --result_dir $PWD \
 --time $curr_time \
 --one_neg_control "TRUE" \
 --max_retries 4
