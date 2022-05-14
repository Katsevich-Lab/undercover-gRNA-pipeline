export NXF_OPTS="-Xms500M -Xmx3G" # limit NF to 2 GB of memory
source ~/.research_config

curr_time=$(date '+%m%d%H%M')
# nextflow pull https://github.com/Katsevich-Lab/undercover-gRNA-pipeline
nextflow run ../main.nf \
 --data_file $PWD"/data_file.R" \
 --data_method_pair_file $PWD"/data_method_pair_file.groovy" \
 --machine_name $MACHINE_NAME \
 --result_dir $PWD \
 --time $curr_time
