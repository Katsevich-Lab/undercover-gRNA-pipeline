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

`data_method_pairs` is a groovy [map](https://www.tutorialspoint.com/groovy/groovy_maps.htm), i.e. a set of key-value pairs. The keys should be the names of datasets to analyze (in the above example, "schraivogel_tap" and "papalexi_gene") and must be a (possibly proper) subset of the datasets defined in `data_file`. The value for a given key (i.e., dataset) should be a string array giving the methods to evaluate on that dataset. In the above example we specify to the pipeline to evaluate "schraivogel_method" and "seurat_de" on "schraivogel_tap" and "seurat_de" on "papalexi_gene".

#### iii. `result_dir`

The directory in which to store the results.

#### iv. `result_file_name` (optional)

The name of the result file, "undercover_gRNA_check_results.rds" by default.

### 2. Pipeline output

The pipeline outputs a result file that by default is called `undercover_gRNA_check_results.rds`. This is a data frame with the following columns: `response_id`, `undercover_gRNA`, `dataset`, `method` (all factors) and `p_value` (numeric).

### 3. Data format
The data should be supplied in `ondisc` format. Specifically, the "response" matrix and gRNA matrix both should be `covariate_ondisc_matrix` objects. The feature covariates data frame of the gRNA matrix *must* contain a column called `target_type` indicating the target type of each gRNA. Furthermore, one of the values of this column *must* be "non-targeting".

### 4. Method API
All methods should be implemented in the [lowmoi](https://github.com/Katsevich-Lab/lowmoi) R package. Each method listed in the `data_method_pair_file` should be a function exported by `lowmoi`. (In the above example, therefore, "schraivogel_method" and "seurat_de" both are exported by `lowmoi`).

A given method exported by `lowmoi` should have formal parameters `response_odm`, `gRNA_odm`, and `response_gRNA_group_pairs`. `response_odm` is the response ODM; `gRNA_odm` is the matrix of gRNA expressions (or indicators); and `response_gRNA_group_pairs` is a data frame with columns `response_id` and `gRNA_group` giving response-gRNA pairs to analyze. (By default, each gRNA group is a group of size one, i.e. a single gRNA.) The method should output a data frame with columns `response_id`, `gRNA_group`, and `p_value`.

Each method exported by `lowmoi` should be documented. The Roxygen command `@inherit abstract_interface` should be inserted to inherit unified documentation for the parameters `response_odm`, `gRNA_odm`, and `response_gRNA_group_pairs`, as well as the return data frame. Any additional parameters should be documented manually. For example, the Roxygen documentation for `schraivogel_method` is below.

```
#' Run Schraivogel's MAST.cov method
#'
#' Runs Schraivogel's MAST.cov method.
#'
#' @inherit abstract_interface
#' @param gRNA_groups_table A table specifying which gRNAs are in which groups, as in \code{sceptre}.
#' This argument is optional, and the default assumption is that each gRNA is in its own group.
#' @param gRNA_threshold A threshold for gRNA expression. This argument is optional, and defaults to 8,
#' which was Schraivogel et al's choice.
#'
#' @export
```

## Invoking the pipeline

One can invoke the pipeline by running the following command on the command line:

```
nextflow pull
nextflow run https://github.com/Katsevich-Lab/undercover-gRNA-pipeline -r main \
 --data_file "path/to/data_file.R" \
 --data_method_pair_file "path/to/data_method_pair_file.groovy" \
 --result_dir "path/to/result_dir"
```

The arguments to `data_file`, `data_method_pair_file`, and `result_dir` are specified as command line arguments. It is best to wrap this call inside a bash script to facilate (i) ease of use and (ii) submission to a cluster scheduler.
