rule genome_locations:
    input:
        files = expand(f"{config['filtered_genomes']}/{{genome_name}}.filtered.fna",
            genome_name=data.genome
        )
    output:
        f"{config['metadata']}/genome_locations.txt"
    shell:
        "realpath {input} > {output}"

rule annotation_locations:
    input:
        expand(f"{config['filtered_annotations']}/{{annotation_name}}.filtered.gff",
            annotation_name=data.annotation
        )
    output:
        f"{config['metadata']}/annotation_locations.txt"
    shell:
        "realpath {input} | nl -w1 -s ' ' > {output}"

rule protein_locations:
    input:
        files = expand(f"{config['proteins']}/{{annotation_name}}.filtered.pep.faa",
            annotation_name=data.annotation
        )
    output:
        f"{config['metadata']}/protein_locations.txt"
    shell:
        "realpath {input} > {output}"

rule function_locations:
    input:
        expand(f"{config['functions']}/{{annotation_name}}.interproscan.gff",
            annotation_name=data.annotation
        )
    output:
        f"{config['metadata']}/function_locations.txt"
    shell:
        "realpath {input} | nl -w1 -s ' ' > {output}"