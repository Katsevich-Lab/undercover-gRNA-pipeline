# undercover-gRNA-pipeline

A Nextflow pipeline to carry out the "undercover gRNA" negative control calibration assessment on a collection of methods and datasets.

## Example usage

Git clone this repository.

```
git clone https://github.com/Katsevich-Lab/undercover-gRNA-pipeline.git
```

Change directories into `undercover-gRNA-pipeline` and execute the pipeline via `bash example_invoke.sh`.

## API

We break the API of the pipeline down into several parts: pipeline input, pipeline output, data format, and method API.

### 1. Pipeline input

The pipeline takes several required inputs: a `data_file`, a `data_method_pair_file`, and a `result_dir`.

#### i. `data_file`

The `data_file` is an R file specifying the file paths of datasets to be used in the analysis. The `data_file` should have the following format (taken from `data_file.R` in the example):

```
papalexi_offsite <- .get_config_path("LOCAL_PAPALEXI_2021_DATA_DIR")
schraivogel_offsite <- .get_config_path("LOCAL_SCHRAIVOGEL_2020_DATA_DIR")

# create a list; each element of the list contains:
# (i) response_odm_fp,
# (ii) response_metadata_fp,
# (iii) gRNA_odm_fp,
# (iv) gRNA_metadata_fp

data_list <- list(
  # Papalexi gene modality
  papalexi_gene = c(response_odm_fp = paste0(papalexi_offsite,
    "processed/gene/expression_matrix.odm"),
                    response_metadata_fp = paste0(papalexi_offsite,
                      "processed/gene/metadata.rds"),
                    gRNA_odm_fp = paste0(papalexi_offsite,
                      "processed/gRNA/count_matrix.odm"),
                    gRNA_metadata_fp = paste0(papalexi_offsite,
                      "processed/gRNA/metadata.rds")),

  # Schraivogel TAP-seq
  schraivogel_tap = c(response_odm_fp = paste0(schraivogel_offsite,
    "processed/ground_truth_tapseq/gene/expression_matrix.odm"),
                      response_metadata_fp = paste0(schraivogel_offsite,
                        "processed/ground_truth_tapseq/gene/metadata.rds"),
                      gRNA_odm_fp = paste0(schraivogel_offsite,
                        "processed/ground_truth_tapseq/gRNA/raw_ungrouped.odm"),
                      gRNA_metadata_fp = paste0(schraivogel_offsite,
                        "processed/ground_truth_tapseq/gRNA/raw_ungrouped_metadata.rds")),

  # Schraivogel Perturb-seq
  schraivogel_perturb = c(response_odm_fp = paste0(schraivogel_offsite,
    "processed/ground_truth_perturbseq/gene/expression_matrix.odm"),
                          response_metadata_fp = paste0(schraivogel_offsite,
                            "processed/ground_truth_perturbseq/gene/metadata.rds"),
                          gRNA_odm_fp = paste0(schraivogel_offsite,
                            "processed/ground_truth_perturbseq/gRNA/raw_ungrouped.odm"),
                          gRNA_metadata_fp = paste0(schraivogel_offsite,
                            "processed/ground_truth_perturbseq/gRNA/raw_ungrouped_metadata.rds"))
)
```

A named list called `data_list` should be defined, with the names corresponding to different datasets (in the above example, "papalexi_gene", "schraivogel_tap", and "schraivogel_perturb"). Each entry of named list should be a named character vector with the following entries: "response_odm_fp" (file path to the backing .odm file of the response matrix), "response_metadata_fp" (file path to the metadata.rds file of the response matrix), "gRNA_odm_fp" (file path to the backing .odm file of the gRNA matrix), and "gRNA_metadata_fp" (file path to the metadata.rds file of gRNA matrix). We call the `.get_config_path` function to specify full file paths in a portable way, but this is not strictly speaking necessary; all that is required is that the specified files be available on the machine on which the pipeline is being run.

#### ii. `data_method_pair_file`

The `data_method_pair_file` is a [groovy](https://groovy-lang.org/) file specifying the methods to evaluate on each dataset. The `data_method_pair_file` should have the following format (taken from `data_method_pair_file.groovy` in the example):

```
data_method_pairs = [schraivogel_tap: ["schraivogel_method", "seurat_de"],
                     papalexi_gene: ["seurat_de"]]
```

`data_method_pairs` is a groovy [map](https://www.tutorialspoint.com/groovy/groovy_maps.htm), i.e. a set of key-value pairs. The keys should be the names of datasets to analyze (in the above example, "schraivogel_tap" and "papalexi_gene"); the keys must be a (possibly proper) subset of the datasets defined in `data_file`. The value for a given key (i.e., dataset) should be a string array giving the methods to evaluate on that dataset. In the above example we specify that we seek to evaluate "schraivogel_method" and "seurat_de" on "schraivogel_tap" and "seurat_de" on "papalexi_gene".

#### iii. `result_dir`

The directory in which to store the results.

#### iv. `result_file_name` (optional)

The name of the result file, "undercover_gRNA_check_results.rds" by default.

gRNA and response ODMs

1. The gRNA ODM should have a column called "target_type" in its `features_metadata` data frame;
this column should contain the type of target of each gRNA. Non-targeting gRNAs should be
labeled "non-targeting".

2. The response ODM should contain contain only genes to be used in the calibration assessment. By default we pair each undercover NTC to the entire set of features in the response ODM.

## Invoking the pipeline
