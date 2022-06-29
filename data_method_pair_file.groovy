// FIRST, define the dataset-method pairs to analyze in a map
/*
data_method_pairs = ["frangieh/co_culture/gene": ["schraivogel_method", "seurat_de", "liscovitch_method", "mimosca", "weissman_method", "permutation_test", "nb_regression"],
                     "frangieh/control/gene": ["schraivogel_method", "seurat_de", "liscovitch_method", "mimosca", "weissman_method", "permutation_test", "nb_regression"],
                     "frangieh/ifn_gamma/gene": ["schraivogel_method", "seurat_de", "liscovitch_method", "mimosca", "weissman_method", "permutation_test", "nb_regression"],
                     "liscovitch/experiment_big/chromatin": ["liscovitch_method"],
                     "liscovitch/experiment_small/chromatin": ["liscovitch_method"],
                     "papalexi/eccite_screen/gene": ["schraivogel_method", "seurat_de", "liscovitch_method", "mimosca", "weissman_method", "permutation_test", "nb_regression"],
                     "papalexi/eccite_screen/protein": ["schraivogel_method", "seurat_de", "liscovitch_method", "mimosca", "weissman_method", "permutation_test", "nb_regression"],
                     "schraivogel/enhancer_screen_chr11/gene": ["schraivogel_method", "seurat_de", "liscovitch_method", "mimosca", "weissman_method", "permutation_test", "nb_regression"],
                     "schraivogel/enhancer_screen_chr8/gene": ["schraivogel_method", "seurat_de", "liscovitch_method", "mimosca", "weissman_method", "permutation_test", "nb_regression"],
                     "schraivogel/ground_truth_perturbseq/gene": ["schraivogel_method", "seurat_de", "liscovitch_method", "mimosca", "weissman_method", "permutation_test", "nb_regression"],
                     "schraivogel/ground_truth_tapseq/gene": ["schraivogel_method", "seurat_de", "liscovitch_method", "mimosca", "weissman_method", "permutation_test", "nb_regression"],
                     "simulated/experiment_1/gene": ["schraivogel_method", "seurat_de", "liscovitch_method", "mimosca", "weissman_method", "permutation_test", "nb_regression"]
                     ]
*/
data_method_pairs = [//"frangieh/co_culture/gene": ["liscovitch_method", "permutation_test", "nb_regression"],
                     //"frangieh/control/gene": ["liscovitch_method", "permutation_test", "nb_regression"],
                     //"frangieh/ifn_gamma/gene": ["liscovitch_method", "permutation_test", "nb_regression"],
                     //"liscovitch/experiment_big/chromatin": ["liscovitch_method"],
                     "liscovitch/experiment_small/chromatin": ["liscovitch_method"],
                     // "papalexi/eccite_screen/gene": ["liscovitch_method", "permutation_test", "nb_regression"],
                     //"papalexi/eccite_screen/protein": ["liscovitch_method", "permutation_test", "nb_regression"],
                     //"schraivogel/enhancer_screen_chr11/gene": ["liscovitch_method", "permutation_test", "nb_regression"],
                     //"schraivogel/enhancer_screen_chr8/gene": ["liscovitch_method", "permutation_test", "nb_regression"],
                     //"schraivogel/ground_truth_perturbseq/gene": ["liscovitch_method", "permutation_test", "nb_regression"],
                     "schraivogel/ground_truth_tapseq/gene": ["liscovitch_method", "permutation_test", "nb_regression"],
                     //"simulated/experiment_1/gene": ["liscovitch_method", "permutation_test", "nb_regression"]
                     ]

// FIRST, define the row and column names of the below matrices and vectors
row_names = ["frangieh/co_culture/gene",
             "frangieh/control/gene",
             "frangieh/ifn_gamma/gene",
             "liscovitch/experiment_big/chromatin",
             "liscovitch/experiment_small/chromatin",
             "papalexi/eccite_screen/gene",
             "papalexi/eccite_screen/protein",
             "schraivogel/enhancer_screen_chr11/gene",
             "schraivogel/enhancer_screen_chr8/gene",
             "schraivogel/ground_truth_perturbseq/gene",
             "schraivogel/ground_truth_tapseq/gene",
             "simulated/experiment_1/gene"]
col_names = ["schraivogel_method",
             "seurat_de",
             "liscovitch_method",
             "mimosca",
             "weissman_method",
             "permutation_test",
             "nb_regression"]

// SECOND, define a matrix indicating the amount of RAM to request for each dataset-method pair
data_method_ram_matrix = [
[34, 13, 45, 35, 48, 45, 45], // frangieh/co_culture/gene
[23, 9,  45, 26, 33, 45, 45], // frangieh/control/gene
[36, 13, 45, 34, 51, 45, 45], // frangieh/ifn_gamma/gene
[2,  1,  45, 1,  1,  45, 45], // liscovitch/experiment_big/chromatin
[2,  1,  45, 1,  1,  45, 45], // liscovitch/experiment_small/chromatin
[18, 6,  45, 19, 21, 45, 45], // papalexi/eccite_screen/gene
[2,  1,  45, 5,  1,  45, 45], // papalexi/eccite_screen/protein
[6,  12, 45, 18, 5,  45, 45], // schraivogel/enhancer_screen_chr11/gene
[8,  14, 45, 21, 5,  45, 45], // schraivogel/enhancer_screen_chr8/gene
[44, 11, 45, 31, 33, 45, 45], // schraivogel/ground_truth_perturbseq/gene
[2,  1,  45, 5,  1,  45, 45], // schraivogel/ground_truth_tapseq/gene
[28, 7,  45, 17, 18, 45, 45] // simulated/experiment_1/gene
]
// schraivogel_method, seurat_de, liscovitch_method, mimosca, weissman_method, permutation_test, nb_regression

// THIRD, define a matrix indicating the queue in which to put a given dataset-method pair process
data_method_queue_matrix = [
["short.q", "short.q", "short.q", "all.q",   "short.q", "all.q",   "all.q"],  // frangieh/co_culture/gene
["short.q", "short.q", "short.q", "all.q",   "short.q", "all.q",   "all.q"], // frangieh/control/gene
["short.q", "short.q", "short.q", "all.q",   "short.q", "all.q",   "all.q"],  // frangieh/ifn_gamma/gene
["short.q", "short.q", "short.q", "short.q", "short.q", "short.q", "short.q"], // liscovitch/experiment_big/chromatin
["short.q", "short.q", "short.q", "short.q", "short.q", "short.q", "short.q"], // liscovitch/experiment_small/chromatin
["short.q", "short.q", "short.q", "all.q",   "short.q", "all.q",   "all.q"],  // papalexi/eccite_screen/gene
["short.q", "short.q", "short.q", "short.q", "short.q", "short.q", "short.q"], // papalexi/eccite_screen/protein
["short.q", "short.q", "short.q", "all.q",   "short.q", "all.q",   "all.q"], // schraivogel/enhancer_screen_chr11/gene
["short.q", "short.q", "short.q", "all.q",   "short.q", "all.q",   "all.q",],  // schraivogel/enhancer_screen_chr8/gene
["short.q", "short.q", "short.q", "all.q",   "short.q", "all.q",   "all.q"], // schraivogel/ground_truth_perturbseq/gene
["short.q", "short.q", "short.q", "all.q",   "short.q", "all.q",   "all.q"], // schraivogel/ground_truth_tapseq/gene
["short.q", "short.q", "short.q", "all.q",   "short.q", "all.q",   "all.q"] // simulated/experiment_1/gene
]
// schraivogel_method, seurat_de, liscovitch_method, mimosca, weissman_method, permutation_test, nb_regression

// FOURTH, define an ordered list of optional arguments to each of the methods ( Should be strings of the form "arg1=value1;arg2=value2;arg3=value3")
optional_args = [
"", // schraivogel_method
"", // seurat_de
"", // liscovitch_method
"n_rep=50", // mimosca
"", // weissman_method
"n_rep=100", // permutation_test
"" // nb_regression
]
