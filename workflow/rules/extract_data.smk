rule agat_sp_extract_sequences:
    input:
        genome = f"{config['filtered_genomes']}/{{genome_name}}.filtered.fasta",
        annotation = lambda wildcards: "{filtered_annotations}/{annotation_name}.filtered.gff".format(
            filtered_annotations=config['filtered_annotations'],
            annotation_name=data.loc[data.genome_name == wildcards.genome_name, 'annotation_name'].item())
    output:
        f"{config['proteins']}/{{genome_name}}.pep.fa"
    conda:
        "../envs/agat.yaml"
    log:
        f"{config['proteins']}/logs/{{genome_name}}.pep.agat.log"
    shell:
        """
        agat_sp_extract_sequences.pl -f {input.genome} -g {input.annotation} -p --cis --cfs -o {output} > /dev/null 
        mv $(basename {input.annotation} .gff).agat.log {log}
        rm {input.genome}.index
        """

rule download_eggnog_data:
    output:
        directory(f"{config['eggnog_data']}")
    conda:
        "../envs/eggnog_mapper.yaml"
    shell:
        """
        mkdir -p {output}
        download_eggnog_data.py -y --data_dir {output}
        """

rule eggnog_mapper:
    input:
        proteins = f"{config['proteins']}/{{genome_name}}.pep.fa",
        data = f"{config['eggnog_data']}"
    output:
        function = f"{config['functions']}/{{genome_name}}.eggnog.gff"
    threads:
        workflow.cores * 0.75
    conda:
        "../envs/eggnog_mapper.yaml"
    log:
        f"{config['functions']}/logs/{{genome_name}}.eggnog.log"
    shell:
        """
        emapper.py --data_dir {input.data} -i {input.proteins} -o {output} --cpu {threads} > {log}
        """