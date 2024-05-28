import argparse
import pandas as pd
from functools import reduce
from typing import List

# ToDo: Figure out expression matrix cleanup

def get_parser():
    """
    Initialize parser
    """
    parser = argparse.ArgumentParser(description = "Generate expression matrix from SRR_ids")

    parser.add_argument("-s", "--SE", required = True, nargs = "+", dest = "SE_data")
    parser.add_argument("-p", "--PE", required = True, nargs = "+", dest = "PE_data")
    parser.add_argument("-o", "--output", required = True, dest = "output")

    return parser

def combine_SE(SE_data: List[str]) -> List[pd.DataFrame]:
    """

    params
    ------
        SE_data: List[str]
            List of SE_data abundances from kallisto
    
    returns
    -------
        SE_df: List[pd.DataFrame]
            List of dataframes to combine from Single-End data
    """
    SE_df = []
    for file in SE_data:
        curr = pd.read_table(file)
        SRR_id = file.split("/")[-2]
        curr_tpm = curr[["target_id", "tpm"]].rename(columns={"tpm": SRR_id})
        SE_df.append(curr_tpm)

    return SE_df

def combine_PE(PE_data: List[str]) -> List[pd.DataFrame]:
    """
    params
    ------
        PE_data: List[str]
            List of PE_data abundances from kallisto
    
    returns
    -------
        PE_df: List[pd.DataFrame]
            List of dataframes to combine from Pingle-End data
    """
    PE_df = []
    for file in PE_data:
        curr = pd.read_table(file)
        SRR_id = file.split("/")[-2]
        curr_tpm = curr[["target_id", "tpm"]].rename(columns={"tpm": SRR_id})
        PE_df.append(curr_tpm)

    return PE_df

def merge_list(SE_data: List[pd.DataFrame], PE_data: List[pd.DataFrame]):
    """
    params
    ------
        SE_df: List[pd.DataFrame]
            List of dataframes to combine from Single-End data

        PE_df: List[pd.DataFrame]
            List of dataframes to combine from Paired-End data
    """
    SE_reduced = reduce(lambda df1, df2: pd.merge(df1, df2, on = "target_id"), SE_data)
    PE_reduced = reduce(lambda df1, df2: pd.merge(df1, df2, on = "target_id"), PE_data)

    combined = pd.merge(SE_reduced, PE_reduced, on = "target_id")

    return combined

def write_csv(combined_df: pd.DataFrame, output_path) -> None:
    combined_df.to_csv(output_path, sep="\t")

if __name__ == "__main__":
    args = get_parser().parse_args()
    SE = combine_SE(args.SE_data)
    PE = combine_PE(args.PE_data)
    combined = merge_list(SE, PE)
    write_csv(combined, args.output)
