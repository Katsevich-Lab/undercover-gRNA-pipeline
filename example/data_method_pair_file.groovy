// FIRST, define the dataset-method pairs to analyze in a map
data_method_pairs = ["schraivogel/enhancer_screen_chr11/gene": ["dummy_method_1"],
                     "schraivogel/enhancer_screen_chr8/gene": ["dummy_method_1", "dummy_method_2"]]

// SECOND, define a matrix indicating the amount of RAM to request for each dataset-method pair
data_method_ram_matrix = [[ 8,  8, 1, 1],
                          [50, 16, 1, 1],
                          [45, 14, 1, 1],
                          [50, 16, 1, 1],
                          [50,  8, 1, 1]]
row_names = ["schraivogel/ground_truth_tapseq/gene",
             "schraivogel/ground_truth_perturbseq/gene",
             "schraivogel/enhancer_screen_chr11/gene",
             "schraivogel/enhancer_screen_chr8/gene",
             "papalexi_gene"]
col_names = ["schraivogel_method",
             "seurat_de",
             "dummy_method_1",
             "dummy_method_2"]
