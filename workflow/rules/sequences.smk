import os

rule seqkit_seq:
    """
    Filter sequences by length provided in the config using seqkit_seq.
    """
    input:
        f"{config['genomes']}/{{genome_name}}.fasta"
    output:
        temp(f"{config['filtered_genomes']}/{{genome_name}}.seqkit.fasta")
    params:
        m = config['min_len']
    log:
        f"{config['filtered_genomes']}/logs/{{genome_name}}.seqkit.log"
    conda:
        "../envs/seqkit.yaml"
    shell:
        "seqkit seq -g -m {params.m} -o {output} {input} > {log}"

rule filter_genome:
    """
    Compare the output of the filtered genome file with the raw input.
    If the two files are identical, the filtered file is replaced with a symbolic link.
    """
    input:
        raw_genome = "{full_path}/{{genome_name}}.fasta".format(
            full_path=os.path.abspath(config['genomes'])
        ),
        filtered_genome = f"{config['filtered_genomes']}/{{genome_name}}.seqkit.fasta"
    output:
        f"{config['filtered_genomes']}/{{genome_name}}.filtered.fasta"
    shell:
        """
        cmp -s {input.raw_genome} {input.filtered_genome} \
            && ln -sf {input.raw_genome} {output} \
            || mv {input.filtered_genome} {output}
        """