export NXF_OPTS="-Xms500M -Xmx3G" # limit NF to 2 GB of memory

nextflow main.nf --data_file $PWD"/data_file.R" \
 --data_method_pair_file $PWD"/data_method_pair_file.groovy" \
 --result_dir $PWD
