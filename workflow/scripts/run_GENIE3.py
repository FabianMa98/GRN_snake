import argparse
import numpy as np
import pandas as pd

from GENIE3 import *
from pathlib import Path
from typing import Union

def get_parser():
    parser = argparse.ArgumentParser(description = "Run GENIE3 on your expression matrix")

    parser.add_argument("-i", "--input", required = True, dest = "input_matrix")
    parser.add_argument("-r", "--regulators", required = False, default = "all", dest = "regulators")
    parser.add_argument("-k", "--k", required = False, default = "sqrt", dest = "nodes")
    parser.add_argument("-n", "--threads", required = False, default = 4, dest = "nthreads")
    parser.add_argument("-m", "--method", required = False, default = "RF", dest = "tree_method")
    parser.add_argument("-t", "--trees", required = False, default = 1000, dest = "number_trees")
    parser.add_argument("-o", "--output", required = True, dest = "output")

    return parser

def run(expr_matrix: Union[Path, str], regulators: Union[Path, str, None], K: Union[int, str, None], threads: Union[int, None] ,method: Union[str, None], trees: Union[int, None]) -> np.ndarray:
    """
    Run GENIE3 on expression matrix, infers gene names from df columns

    TODO:
        - Implement proper parallelization
        - Get regulators fromt tsv/csv file
        - Think of expression data cleanup
        - Implement automatic detection pf 

    params
    ------
        expr_data:
            gene expression matrix (2d ndarray), where each row corresponds to an experiment and each column represents a gene
        genes:
            List of gene names. REFACTOR: Take column names automatically from expression matrix
        regulators:
            List of regulators for RF algorithm. 
        K:
            Number of nodes for each tree
        threads:
            Number of threads
        method:
            Either "RF" or "ET"
        trees:
            number of trees for each regulator

    returns
    -------
        VIM:
            Variable Importance Matrix where each score corresponds to the strenght of the interaction
    """
    # Cleanup uneccessary numbers from target_df (might have to move this to another rule)
    expr_data = pd.read_table(expr_matrix)
    regulators_df = pd.read_table(regulators)
    # Could also do reduce(lambda x,y: x+y, regulator_values)
    regulator_list = regulators_df.values.flatten().tolist()
    expr_data["target_id"] = expr_data["target_id"].map(lambda x: x.rstrip("0123456789").rstrip("_"))
    t_expr_data = expr_data.transpose()
    t_expr_data.columns = t_expr_data.iloc[0].drop(["target_id"])
    # Change type from pd.DataFrame to np.ndarray for GENIE3
    matrix = t_expr_data.to_numpy()
    # Remove column names
    matrix = matrix[1:]
    gene_names = t_expr_data.columns.tolist()
    # Run GENIE3 on all genes
    VIM = GENIE3(matrix, gene_names = gene_names, regulators = regulator_list, K = K, nthreads = threads, tree_method = method, ntrees = trees)
    pd_VIM = pd.DataFrame(VIM)
    pd_VIM.columns = gene_names
    pd_VIM.insert(0, "regulators", gene_names, True)
    row_sums = pd_VIM.sum(axis = 1, numeric_only = True)
    pd_VIM["row_sums"] = row_sums
    non_zero = pd_VIM[pd_VIM["row_sums"] != 0].drop("row_sums", axis = 1)

    return non_zero

def write(importance: pd.DataFrame, output: Union[Path, str]) -> None:
    """
    Write VIM matrix as tsv for further analysis

    params
    ------
        importance:
            VIM matrix from `run` function (see above)

    returns
    -------
        None
            Writes csv and get top regulators(TODO)
    """
    # Revert back to pd.DataFrame
    df.to_csv(output, sep="\t", index = False)

if __name__ == "__main__":
    args = get_parser().parse_args()
    VIM = run(args.input_matrix, regulators = args.regulators, K = args.nodes, threads = args.nthreads, method = args.tree_method, trees = args.number_trees)
    write(VIM, args.output)