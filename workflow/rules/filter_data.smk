import os

rule seqkit_seq:
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

rule agat_sq_filter_feature_from_fasta:
    input:
        annotation = f"{config['annotations']}/{{annotation_name}}.gff",
        genome = lambda wildcards: "{filtered_genomes}/{genome_name}.filtered.fasta".format(
            filtered_genomes=config['filtered_genomes'],
            genome_name=data.loc[data.annotation_name == wildcards.annotation_name, 'genome_name'].item()
        )
    output:
        temp(f"{config['filtered_annotations']}/{{annotation_name}}_features_from_fasta.gff")
    conda:
        "../envs/agat.yaml"
    shell:
        """
        agat_sq_filter_feature_from_fasta.pl \
            --gff {input.annotation} \
            --fasta {input.genome} \
            --output {output} > /dev/null
        rm {input.genome}.index
        """


rule agat_sp_keep_longest_isoform:
    input:
        f"{config['filtered_annotations']}/{{annotation_name}}_features_from_fasta.gff"
    output:
        temp(f"{config['filtered_annotations']}/{{annotation_name}}_longest_isoform.gff")
    log:
        f"{config['filtered_annotations']}/logs/keep_longest_isoform/{{annotation_name}}_longest_isoform.agat.log"
    conda:
        "../envs/agat.yaml"
    shell:
        """
        agat_sp_keep_longest_isoform.pl --gff {input} --output {output} > /dev/null
        mv {wildcards.annotation_name}_features_from_fasta.agat.log {log}
        """

rule agat_sp_filter_by_orf_size:
    input:
        f"{config['filtered_annotations']}/{{annotation_name}}_longest_isoform.gff"
    output:
        temp(f"{config['filtered_annotations']}/{{annotation_name}}_sup={{orf_size}}.gff"),
        temp(f"{config['filtered_annotations']}/{{annotation_name}}_NOT_sup={{orf_size}}.gff")
    log:
        f"{config['filtered_annotations']}/logs/filter_by_orf_size/{{annotation_name}}_sup={{orf_size}}.agat.log"
    conda:
        "../envs/agat.yaml"
    script:
        "../scripts/filter_by_orf_size.sh"

rule filter_annotation:
    input:
        raw_annotation = "{full_path}/{{annotation_name}}.gff".format(
            full_path=os.path.abspath(config['annotations'])
        ),
        filtered_annotation = "{filtered_annotations}/{{annotation_name}}_sup={orf_size}.gff".format(
            filtered_annotations=config['filtered_annotations'],
            orf_size=config["orf_size"]
        )
    output:
        f"{config['filtered_annotations']}/{{annotation_name}}.filtered.gff"
    shell:
        """
        cmp -s {input.raw_annotation} {input.filtered_annotation} \
            && ln -sf {input.raw_annotation} {output} \
            || mv {input.filtered_annotation} {output}
        """