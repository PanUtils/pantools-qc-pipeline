rule genome_contents_raw:
    input:
        expand(f"{config['genomes']}/{{genome_name}}.fasta",
            genome_name=data['genome_name']
        )
    output:
        f"{config['statistics']}/genome_contents_raw.tsv"
    script:
        "../scripts/fasta_contents.py"

rule genome_contents_filtered:
    input:
        expand(f"{config['filtered_genomes']}/{{genome_name}}.filtered.fasta",
            genome_name=data['genome_name']
        )
    output:
        f"{config['statistics']}/genome_contents_filtered.tsv"
    script:
        "../scripts/fasta_contents.py"

rule protein_contents:
    input:
        expand(f"{config['proteins']}/{{genome_name}}.pep.fa",
            genome_name=data['genome_name']
        )
    output:
        f"{config['statistics']}/protein_contents.tsv"
    script:
        "../scripts/fasta_contents.py"

rule annotation_contents_raw:
    input:
        expand(f"{config['annotations']}/{{annotation_name}}.gff",
            annotation_name=data['annotation_name']
        )
    output:
        f"{config['statistics']}/annotation_contents_raw.tsv"
    script:
        "../scripts/gff_contents.py"

rule annotation_contents_filtered:
    input:
        expand(f"{config['filtered_annotations']}/{{annotation_name}}.filtered.gff",
            annotation_name=data['annotation_name']
        )
    output:
        f"{config['statistics']}/annotation_contents_filtered.tsv"
    script:
        "../scripts/gff_contents.py"

rule agat_sp_statistics:
    input:
        annotation = f"{config['filtered_annotations']}/{{annotation_name}}.filtered.gff",
        genome = lambda wildcards: "{filtered_genomes}/{genome_name}.filtered.fasta".format(
            filtered_genomes=config['filtered_genomes'],
            genome_name=data.loc[data.annotation_name == wildcards.annotation_name, 'genome_name'].item()
        )
    output:
        f"{config['statistics']}/agat_sp_statistics/{{annotation_name}}.filtered.txt"
    log:
        f"{config['statistics']}/agat_sp_statistics/logs/{{annotation_name}}.filtered.agat.log"
    conda:
        "../envs/agat.yaml"
    shell:
        """
        agat_sp_statistics.pl -i {input.annotation} -f {input.genome} --output {output} > /dev/null
        mv {wildcards.annotation_name}.filtered.agat.log {log}
        """

rule annotation_statistics:
    input:
        expand(f"{config['statistics']}/agat_sp_statistics/{{annotation_name}}.filtered.txt",
            annotation_name=data['annotation_name']
        )
    output:
        f"{config['statistics']}/annotation_statistics.tsv"
    script:
        "../scripts/combine_statistics.py"