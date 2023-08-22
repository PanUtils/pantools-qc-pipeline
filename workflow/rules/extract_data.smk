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
    shell:
        """
        agat_sp_extract_sequences.pl -f {input.genome} -g {input.annotation} -p --cis --cfs -o {output} > /dev/null
        rm {input.genome}.index
        """

rule download_eggnog_data:
    output:
        touch(".snakemake/done/download_eggnog_data.done")
    conda:
        "../envs/eggnog_mapper.yaml"
    shell:
        """
        mkdir -p $CONDA_PREFIX/lib/python3.7/site-packages/data
        download_eggnog_data.py -y
        """

rule eggnog_mapper:
    input:
        ".snakemake/done/download_eggnog_data.done",
        proteins = f"{config['proteins']}/{{genome_name}}.pep.fa"
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
        emapper.py -i {input.proteins} -o {output} --cpu {threads} > {log}
        """

rule download_interproscan_data:
    output:
        touch(".snakemake/done/download_interproscan_data.done")
    conda:
        "../envs/interproscan.yaml"
    shell:
        """
        wget http://ftp.ebi.ac.uk/pub/software/unix/iprscan/5/5.59-91.0/interproscan-5.59-91.0-64-bit.tar.gz.md5
        wget http://ftp.ebi.ac.uk/pub/software/unix/iprscan/5/5.59-91.0/interproscan-5.59-91.0-64-bit.tar.gz
        md5sum -c interproscan-5.59-91.0-64-bit.tar.gz.md5
        tar xvzf interproscan-5.59-91.0-64-bit.tar.gz
        rm -rf $CONDA_PREFIX/share/InterProScan/data/
        mv interproscan-5.59-91.0/data $CONDA_PREFIX/share/InterProScan/
        """