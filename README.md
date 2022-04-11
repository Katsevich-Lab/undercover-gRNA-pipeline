# undercover-gRNA-pipeline
A Nextflow pipeline to carry out the "undercover gRNA" negative control calibration assessment

# API requirements

## gRNA and response ODMs

1. The gRNA ODM should have a column called "target_type" in its `features_metadata` data frame;
this column should contain the type of target of each gRNA. Non-targeting gRNAs should be
labeled "non-targeting".

2. The response ODM should contain contain only genes to be used in the calibration assessment. By default we pair each undercover NTC to the entire set of features in the response ODM.
