// FIRST, define the dataset-method pairs to analyze in a map


data_method_pairs = ["frangieh/co_culture/gene": ["schraivogel_method", "seurat_de", "mimosca", "weissman_method"],
                     "frangieh/control/gene": ["schraivogel_method", "seurat_de", "mimosca", "weissman_method"],
                     "frangieh/ifn_gamma/gene": ["schraivogel_method", "seurat_de", "mimosca", "weissman_method"],
                     "liscovitch/experiment_big/chromatin": ["liscovitch_method"],
                     "liscovitch/experiment_small/chromatin": ["liscovitch_method"],
                     "papalexi/eccite_screen/gene": ["schraivogel_method", "seurat_de", "mimosca", "weissman_method"],
                     "papalexi/eccite_screen/protein": ["schraivogel_method", "seurat_de", "mimosca", "weissman_method"],
                     "schraivogel/enhancer_screen_chr11/gene": ["schraivogel_method", "seurat_de", "mimosca", "weissman_method"],
                     "schraivogel/enhancer_screen_chr8/gene": ["schraivogel_method", "seurat_de", "mimosca", "weissman_method"],
                     "schraivogel/ground_truth_perturbseq/gene": ["schraivogel_method", "seurat_de", "mimosca", "weissman_method"],
                     "schraivogel/ground_truth_tapseq/gene": ["schraivogel_method", "seurat_de", "mimosca", "weissman_method"],
                     "simulated/experiment_1/gene": ["schraivogel_method", "seurat_de", "mimosca", "weissman_method"]
                     ]


// SECOND, define a matrix indicating the amount of RAM to request for each dataset-method pair
data_method_ram_matrix = [
[34, 13, 1, 35, 48], // frangieh/co_culture/gene
[23, 9, 1, 26, 33], // frangieh/control/gene
[36, 13, 1, 34, 51], // frangieh/ifn_gamma/gene
[2, 1, 1, 1, 1], // liscovitch/experiment_big/chromatin
[2, 1, 1, 1, 1], // liscovitch/experiment_small/chromatin
[18, 6, 1, 19, 21], // papalexi/eccite_screen/gene
[2, 1, 1, 5, 1], // papalexi/eccite_screen/protein
[6, 12, 1, 18, 5], // schraivogel/enhancer_screen_chr11/gene
[8, 14, 1, 21, 5], // schraivogel/enhancer_screen_chr8/gene
[44, 11, 1, 31, 33], // schraivogel/ground_truth_perturbseq/gene
[2, 1, 1, 5, 1], // schraivogel/ground_truth_tapseq/gene
[28, 7, 1, 17, 18] // simulated/experiment_1/gene
]
// schraivogel_method, seurat_de, liscovitch_method, mimosca, weissman_method


// THIRD, define a matrix indicating the queue in which to put a given dataset-method pair process
data_method_queue_matrix = [
["short.q", "short.q", "short.q", "all.q", "short.q"],  // frangieh/co_culture/gene
["short.q", "short.q", "short.q", "all.q", "short.q"], // frangieh/control/gene
["short.q", "short.q", "short.q", "all.q", "short.q"],  // frangieh/ifn_gamma/gene
["short.q", "short.q", "short.q", "short.q", "short.q"], // liscovitch/experiment_big/chromatin
["short.q", "short.q", "short.q", "short.q", "short.q"], // liscovitch/experiment_small/chromatin
["short.q", "short.q", "short.q", "all.q", "short.q"],  // papalexi/eccite_screen/gene
["short.q", "short.q", "short.q", "short.q", "short.q"], // papalexi/eccite_screen/protein
["short.q", "short.q", "short.q", "all.q", "short.q"], // schraivogel/enhancer_screen_chr11/gene
["short.q", "short.q", "short.q", "all.q", "short.q"],  // schraivogel/enhancer_screen_chr8/gene
["short.q", "short.q", "short.q", "all.q", "short.q"], // schraivogel/ground_truth_perturbseq/gene
["short.q", "short.q", "short.q", "all.q", "short.q"], // schraivogel/ground_truth_tapseq/gene
["short.q", "short.q", "short.q", "all.q", "short.q"] // simulated/experiment_1/gene
]


// FOURTH, define the row and column names of the above matrices
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
             "weissman_method"]


// FIFTH, define an ordered list of optional arguments to each of the methods
// Should be strings of the form "arg1=value1;arg2=value2;arg3=value3".
// If no optional argument, then set NA
optional_args = [
"", // schraivogel_method
"", // seurat_de
"", // liscovitch_method
"n_rep=50", // mimosca
"" // weissman_method
]
