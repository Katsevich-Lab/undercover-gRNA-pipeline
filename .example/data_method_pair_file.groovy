// FIRST, define the dataset-method pairs to analyze in a map
data_method_pairs = ["schraivogel/ground_truth_tapseq/gene": ["dummy_method_1", "dummy_method_2"],
                     "schraivogel/ground_truth_perturbseq/gene": ["dummy_method_1", "dummy_method_2"],
                     "schraivogel/enhancer_screen_chr11/gene": ["dummy_method_1"],
                     "schraivogel/enhancer_screen_chr8/gene": ["dummy_method_1", "dummy_method_2"],
                     "papalexi/eccite_screen/gene": ["dummy_method_2"],
                     "papalexi/eccite_screen/protein": ["dummy_method_2"],
                     "frangieh/co_culture/gene": ["dummy_method_1", "dummy_method_2"],
                     "frangieh/control/gene": ["dummy_method_1", "dummy_method_2"],
                     "frangieh/ifn_gamma/gene": ["dummy_method_1"],
                     "liscovitch/experiment_small/chromatin": ["dummy_method_1"],
                     "liscovitch/experiment_big/chromatin": ["dummy_method_2"],
                     "simulated/experiment_1/gene": ["dummy_method_1", "dummy_method_2"]]

// SECOND, define a matrix indicating the amount of RAM to request for each dataset-method pair
data_method_ram_matrix = [[ 8,  8, 1, 1],
                          [50, 16, 1, 1],
                          [45, 14, 1, 1],
                          [50, 16, 1, 1],
                          [50,  8, 1, 1],
                          [ 1,  1, 1, 1],
                          [ 1,  1, 1, 1],
                          [ 1,  1, 1, 1],
                          [ 1,  1, 1, 1],
                          [ 1,  1, 1, 1],
                          [ 1,  1, 1, 1],
                          [ 1,  1, 1, 1]]

row_names = ["schraivogel/ground_truth_tapseq/gene",
             "schraivogel/ground_truth_perturbseq/gene",
             "schraivogel/enhancer_screen_chr11/gene",
             "schraivogel/enhancer_screen_chr8/gene",
             "papalexi/eccite_screen/gene",
             "papalexi/eccite_screen/protein",
             "frangieh/co_culture/gene",
             "frangieh/control/gene",
             "frangieh/ifn_gamma/gene",
             "liscovitch/experiment_small/chromatin",
             "liscovitch/experiment_big/chromatin",
             "simulated/experiment_1/gene"]

col_names = ["schraivogel_method",
             "seurat_de",
             "dummy_method_1",
             "dummy_method_2"]
