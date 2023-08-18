# Filter genome and annotation data
genomes = config["genomes"]
annotations = config["annotations"]
filtered_genomes = config["genomes_filtered"]
filtered_annotations = config["annotations_filtered"]

rule seqkit_seq:
    input:
        f"{genomes}/{{genome}}.fasta"
    output:
        f"{filtered_genomes}/{{genome}}.filtered.fasta"
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
        temp(f"{filtered_annotations}/{{annotation}}_longest_isoform.gff")
    log:
        f"{filtered_annotations}/logs/keep_longest_isoform/{{annotation}}_longest_isoform.agat.log"
    conda:
        "../envs/agat.yaml"
    shell:
        """
        agat_sp_keep_longest_isoform.pl --gff {input} --output {output} > /dev/null
        mv {wildcards.annotation}.agat.log {log}
        """

rule agat_sp_filter_by_orf_size:
    input:
        f"{filtered_annotations}/{{annotation}}_longest_isoform.gff"
    output:
        temp(f"{filtered_annotations}/{{annotation}}_sup={{orf_size}}.gff"),
        temp(f"{filtered_annotations}/{{annotation}}_NOT_sup={{orf_size}}.gff")
    log:
        f"{filtered_annotations}/logs/filter_by_orf_size/{{annotation}}_sup={{orf_size}}.agat.log"
    conda:
        "../envs/agat.yaml"
    script:
        "../scripts/filter_by_orf_size.sh"

rule agat_sq_filter_feature_from_fasta:
    input:

rule filter_annotation:
    input:
        "{}/{{annotation}}_sup={}.gff".format(filtered_annotations, config["orf_size"])
    output:
        f"{filtered_annotations}/{{annotation}}.filtered.gff"
    shell:
        "mv {input} {output}"