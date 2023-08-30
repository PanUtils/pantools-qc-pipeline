rule genome_locations:
    input:
        files = expand(f"{config['filtered_genomes']}/{{genome_name}}.filtered.fasta",
            genome_name=data.genome_name
        )
    output:
        f"{config['metadata']}/genome_locations.txt"
    shell:
        "realpath {input} > {output}"

rule annotation_locations:
    input:
        expand(f"{config['filtered_annotations']}/{{annotation_name}}.filtered.gff",
            annotation_name=data.annotation_name
        )
    output:
        f"{config['metadata']}/annotation_locations.txt"
    shell:
        "realpath {input} | nl -w1 -s ' ' > {output}"

rule protein_locations:
    input:
        files = expand(f"{config['proteins']}/{{genome_name}}.pep.fa",
            genome_name=data.genome_name
        )
    output:
        f"{config['metadata']}/protein_locations.txt"
    shell:
        "realpath {input} > {output}"