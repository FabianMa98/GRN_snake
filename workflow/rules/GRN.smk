rule genie3:
    input:
        expr_matrx = rules.generate_matrix.output.matrix
    output:
        VIM = "processed_data/genie3_vim.tsv"
    params:
        regulators = config["GENIE3"]["regulators"],
        tree_method = config["GENIE3"]["tree_method"],
        number_of_trees = config["GENIE3"]["number_of_trees"],
        K = config["GENIE3"]["K"]
    threads:
        config["GENIE3"]["nthreads"]
    conda:
        "envs/GENIE.yml"
    shell:
        """
        python3 scripts/run_GENIE3.py -i {input.expr_matrix} -r {params.regulators} -k {params.K} -n {threads} -m {params.tree_method} -t {params.number_of_trees}
        """