rule genome_contents_raw:
    input:
        expand(f"{config['genomes']}/{{genome_name}}.fna",
            genome_name=data.genome
        )
    output:
        f"{config['statistics']}/genome_contents_raw.tsv"
    script:
        "../scripts/fasta_contents.py"

rule genome_contents_filtered:
    input:
        expand(f"{config['filtered_genomes']}/{{genome_name}}.filtered.fna",
            genome_name=data.genome
        )
    output:
        f"{config['statistics']}/genome_contents_filtered.tsv"
    script:
        "../scripts/fasta_contents.py"

rule protein_contents_raw:
    input:
        expand(f"{config['proteins']}/{{annotation_name}}.raw.pep.faa",
            annotation_name=data.annotation
        )
    output:
        f"{config['statistics']}/protein_contents_raw.tsv"
    script:
        "../scripts/fasta_contents.py"

rule protein_contents_filtered:
    input:
        expand(f"{config['proteins']}/{{annotation_name}}.filtered.pep.faa",
            annotation_name=data.annotation
        )
    output:
        f"{config['statistics']}/protein_contents_filtered.tsv"
    script:
        "../scripts/fasta_contents.py"

rule annotation_contents_raw:
    input:
        expand(f"{config['annotations']}/{{annotation_name}}.filtered.gff",
            annotation_name=data.annotation
        )
    output:
        f"{config['statistics']}/annotation_contents_raw.tsv"
    script:
        "../scripts/gff_contents.py"

rule annotation_contents_filtered:
    input:
        expand(f"{config['filtered_annotations']}/{{annotation_name}}.filtered.gff",
            annotation_name=data.annotation
        )
    output:
        f"{config['statistics']}/annotation_contents_filtered.tsv"
    script:
        "../scripts/gff_contents.py"

rule agat_sp_statistics:
    input:
        annotation = f"{config['filtered_annotations']}/{{annotation_name}}.filtered.gff",
        genome = lambda wildcards: "{filtered_genomes}/{genome_name}.filtered.fna".format(
            filtered_genomes=config['filtered_genomes'],
            genome_name=data.loc[data.annotation == wildcards.annotation_name, 'genome'].item()
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
        log="{wildcards.annotation_name}.filtered.agat.log"
        [ ! -f "$log" ] || mv "$log"  {log}
        """

rule annotation_statistics:
    input:
        expand(f"{config['statistics']}/agat_sp_statistics/{{annotation_name}}.filtered.txt",
            annotation_name=data.annotation
        )
    output:
        f"{config['statistics']}/annotation_statistics.tsv"
    script:
        "../scripts/combine_statistics.py"
