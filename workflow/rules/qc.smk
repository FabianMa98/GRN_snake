rule generate_fastqc_SE:
    input:
        SE_fastqs=expand("raw_data/SE/{accession}.trimmed.fastq.gz", accession = SRA_SE_acc)
    output:
        html_report=expand("processed_data/fastqc/SE/{accession}.trimmed_fastqc.html", accession = SRA_SE_acc)
    params:
        output_dir=directory("processed_data/fastqc/SE")
    threads:
        8
    conda:
        "../envs/fastqc.yml"
    shell:
        """
        fastqc -t {threads} -o {params.output_dir} {input.SE_fastqs}
        """

rule generate_fastqc_PE:
    input:
        PE_fastqs=expand("raw_data/PE/{accession}_{PE}.trimmed.fastq.gz", accession = SRA_PE_acc, PE = [1, 2])
    output:
        html_report=expand("processed_data/fastqc/PE/{accession}_{PE}.trimmed_fastqc.html", accession = SRA_PE_acc, PE = [1, 2])
    params:
        output_dir=directory("processed_data/fastqc/PE")
    threads:
        8
    conda:
        "../envs/fastqc.yml"
    shell:
        """
        fastqc -t {threads} -o {params.output_dir} {input.PE_fastqs}
        """