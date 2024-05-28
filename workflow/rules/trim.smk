rule trim_SE:
    input:
        SE_fastqs="raw_data/SE/{accession}.fastq.gz"
    output:
        trimmed_fastqs="raw_data/SE/{accession}.trimmed.fastq.gz"
    params:
        adapters_file=config["SE_adapter"]
    threads:
        4
    conda:
        "../envs/trimmo.yml"
    shell:
        """
        trimmomatic SE -threads {threads} -phred33 {input.SE_fastqs} {output.trimmed_fastqs}  ILLUMINACLIP:{params.adapters_file}:2:30:10 LEADING:3 TRAILING:3 SLIDINGWINDOW:4:15 MINLEN:36
        """

rule trim_PE:
    input:
        PE_fastq_1="raw_data/PE/{accession}_1.fastq.gz",
        PE_fastq_2="raw_data/PE/{accession}_2.fastq.gz"
    output:
        forward_paired="raw_data/PE/{accession}_1.trimmed.fastq.gz",
        forward_unpaired=temp("raw_data/PE/{accession}_1.unpaired.trimmed.fastq.gz"),
        reverse_paired="raw_data/PE/{accession}_2.trimmed.fastq.gz",
        reverse_unpaired=temp("raw_data/PE/{accession}_2.unpaired.trimmed.fastq.gz")
    log:
        err="logs/trimmo/{accession}_stderr.err",
        out="logs/trimmo/{accession}_stdout.out"
    params:
        adapters_file=config["PE_adapter"]
    threads:
        4
    conda:
        "../envs/trimmo.yml"
    shell:
        """
        trimmomatic PE -threads {threads} -phred33 {input.PE_fastq_1} {input.PE_fastq_2} {output.forward_paired} {output.forward_unpaired} {output.reverse_paired} {output.reverse_unpaired} ILLUMINACLIP:{params.adapters_file}:2:30:10 LEADING:33 TRAILING:3 SLIDINGWINDOW:4:15 MINLEN:36 2> {log.err} 1> {log.out}
        """