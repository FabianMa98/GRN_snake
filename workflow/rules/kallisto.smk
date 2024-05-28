rule kallisto_index:
    input:
        fasta=config["genome"]
    output:
        index=temp("raw_data/genome/genome.idx")
    params:
        extra=""
    log:
        "logs/kallisto_index_genome.log"
    threads:
        8
    conda:
        "../envs/kallisto.yml"
    shell:
        """
        kallisto index --threads {threads} --index {output.index} {input.fasta} > {log} 2>&1
        """

#ToDo: Find better way to implement stranded option
rule kallisto_se:
    input:
        fastq="raw_data/SE/{accession}.trimmed.fastq.gz",
        index=rules.kallisto_index.output.index
    output:
        output_dir=directory("processed_data/SE/{accession}/"),
        abundance="processed_data/SE/{accession}/abundance.tsv"
    log:
        "logs/kallisto_{accession}.log"
    threads:
        4
    params:
        fragment_length=config["fragment_length"],
        standard_deviation=config["standard_deviation"],
        #stranded=config[stranded]["rf"] # choose either rf or fr for your options and add {params.stranded} to command
    conda:
        "../envs/kallisto.yml"
    shell:
        """
        kallisto quant --single --threads {threads} --index {input.index} -l {params.fragment_length} -s {params.standard_deviation} --output-dir {output.output_dir} {input.fastq} > {log} 2>&1
        """

rule kallisto_pe:
    input:
        fastqs=["raw_data/PE/{accession}_1.trimmed.fastq.gz", "raw_data/PE/{accession}_2.trimmed.fastq.gz"],
        index=rules.kallisto_index.output.index
    output:
        output_dir=directory("processed_data/PE/{accession}/"),
        abundance="processed_data/PE/{accession}/abundance.tsv"
    log:
        "logs/kallisto_{accession}.log"
    threads:
        4
    params:
        fragment_length=config["fragment_length"],
        standard_deviation=config["standard_deviation"]
        #stranded=config[stranded]["rf"] # choose either rf or fr for your options and add {params.stranded} to command
    conda:
        "../envs/kallisto.yml"
    shell:
        """
        kallisto quant --threads {threads} --index {input.index} --output-dir {output.output_dir} {input.fastqs} > {log} 2>&1
        """