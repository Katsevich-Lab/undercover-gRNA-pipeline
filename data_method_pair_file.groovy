// FIRST, define the dataset-method pairs to analyze in a map
data_method_pairs = [schraivogel_tap: ["schraivogel_method", "seurat_de"],
                     schraivogel_perturb: ["schraivogel_method", "seurat_de"],
                     papalexi_gene: ["schraivogel_method", "seurat_de"]]
// data_method_pairs = [schraivogel_tap: ["schraivogel_method", "seurat_de"]]


// SECOND, define a matrix indicating the amount of RAM to request for each dataset-method pair
data_method_ram_matrix = [[8, 8],
                          [64, 16],
                          [64, 8]]
row_names = ["schraivogel_tap", "schraivogel_perturb", "papalexi_gene"]
col_names = ["schraivogel_method", "seurat_de"]

def get_matrix_entry(data_method_ram_matrix, row_names, col_names, my_row_name, my_col_name) {
  row_idx = row_names.findIndexOf{ it == my_row_name }
  col_idx = col_names.findIndexOf{ it == my_col_name }
  return data_method_ram_matrix[row_idx][col_idx]
}
