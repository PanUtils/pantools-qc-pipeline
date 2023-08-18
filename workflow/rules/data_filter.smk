# Filter genome and annotation data
genomes = config["genomes"]
annotations = config["annotations"]
filtered_genomes = config["genomes_filtered"]
filtered_annotations = config["annotations_filtered"]

rule seqkit_seq:
    input:
        f"{genomes}/{{genome}}.fasta"
    output:
        temp(f"{filtered_genomes}/{{genome}}.filtered.fasta")
    params:
        m = config['min_len']
    log:
        f"{filtered_genomes}/logs/seqkit_seq/{{genome}}.filtered.seqkit.log"
    conda:
        "../envs/seqkit.yaml"
    shell:
        "seqkit seq -g -m {params.m} -o {output} {input} > {log}"
        
rule agat_sp_keep_longest_isoform:
    input:
        f"{annotations}/{{annotation}}.gff"
    output:
        temp(f"{filtered_annotations}/{{annotation}}.longest_isoform.gff")
    log:
        f"{filtered_annotations}/logs/{{annotation}}.longest_isoform.agat.log"
    conda:
        "../envs/agat.yaml"
    shell:
        """
        agat_sp_keep_longest_isoform.pl --gff {input} --output {output} > /dev/null
        mv {wildcards.annotation}.agat.log {log}
        """

rule agat_sp_filter_by_orf_size:
    input:
        f"{filtered_annotations}/{{annotation}}.longest_isoform.gff"
    output:
        f"{filtered_annotations}/{{annotation}}.filtered.gff"
    params:
        orf_size = config['orf_size']
    log:
        f"{filtered_annotations}/logs/{{annotation}}.orf_size.agat.log"
    conda:
        "../envs/agat.yaml"
    script:
        "../scripts/filter_by_orf_size.sh"