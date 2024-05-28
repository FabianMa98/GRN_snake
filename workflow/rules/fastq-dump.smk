rule download_SE:
    output:
        fastq=temp(expand("raw_data/SE/{accession}.fastq", accession = SRA_SE_acc))
    #log:
    #    expand("logs/fasterq_dump/{accession}_fasterq.log", accession = SRA_SE_acc)
    threads:
        4
    params:
        download_folder=config["SRA_download_SE"],
        accession=lambda wildcards: SRA_SE_acc
    conda:
        "../envs/SRA.yml"
    shell:
        """
        fasterq-dump --threads {threads} --split-files {params.accession} -O {params.download_folder}
        """

rule gzip_SE:
    input:
        #SE_fastq=rules.download_SE.output.fastq
        SE_fastq="raw_data/SE/{accession}.fastq"
    output:
        fastq_gz="raw_data/SE/{accession}.fastq.gz"
    threads:
        4
    params:
        extra=""
    shell:
        """
        gzip {input.SE_fastq}
        """

rule download_PE:
    output:
        fastqs=temp(expand("raw_data/PE/{accession}_{PE}.fastq", PE = [1, 2], accession = SRA_PE_acc)),
    threads:
        4
    params:
        download_folder=config["SRA_download_PE"],
        accessions=lambda wildcards: SRA_PE_acc
    conda:
        "../envs/SRA.yml"
    shell:
        """
        fasterq-dump --threads {threads} --split-files {params.accessions} -O {params.download_folder} > {log} 2&>1 
        """

rule gzip_PE:
    input:
        fastqs=rules.download_PE.output.fastqs
    output:
        fastqs_gz=expand("raw_data/PE/{accession}_{PE}.fastq.gz", PE = [1, 2], accession = SRA_PE_acc)
    threads:
        4
    params:
        extra=""
    shell:
        """
        gzip {input.fastqs}
        """