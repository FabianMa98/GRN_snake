rule generate_matrix:
    input:
        SE = expand("processed_data/SE/{dir}/abundance.tsv", dir = SRA_SE_acc),
        PE = expand("processed_data/PE/{dir}/abundance.tsv", dir = SRA_PE_acc)
    output:
        matrix = "processed_data/expression_matrix.tsv"
    conda:
        "../envs/pandas.yml"
    shell:
        """
        python3 scripts/get_expression_matrix.py -s {input.SE} -p {input.PE} -o {output.matrix}
        """