# Kallisto_snake
Basic fasterq-dump/kallisto pipeline for automatic download of SRR ids and mapping with kallisto. Generates expression matrix from all 
SRR experiments automatic at
```
"processed_data/expression_matrix.tsv"
```
This was a side project, because I was bored. The pipeline is still in its development and testing phase, so feedback and bug reports are welcome!

## ToDos:
- Implement proper slurm execution
- Cleanup conda environments

## Setup
For proper use, edit the config file "config/config.yaml". Stranded options are given in the file, but automatic execution has not yet been implemented

You will need a `SraRunInfo.csv` from the SRA containing "Run" and "LibraryLayout". Edit `SraRunInfo` in the config
```
SraRunInfo: "path/to/SraRunInfo.csv"
```
For now do not change the download directories as output paths are hardcoded right now and need these donwload directories
Further a reference genome is needed for mapping. Edit `genome` in the config.
```
genome: "path/to/reference.fa"
```

Either call a snakemake command in your terminal while in the `./workflow` ddirectory
```
snakemake --keep-going --cores 12 --use-conda --rerun-incomplete  
```

Or call the given bash script with the same command
```
./pipeline.sh
```