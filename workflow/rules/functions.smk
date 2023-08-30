rule download_eggnog_data:
    """
    Download eggnog databases into the conda environment to map against.
    """
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
    """
    Create functional annotations using eggNOG-mapper.
    """
    input:
        ".snakemake/done/download_eggnog_data.done",
        proteins = f"{config['proteins']}/{{genome_name}}.pep.fa"
    output:
        f"{config['functions_eggnog']}/{{genome_name}}.emapper.annotations"
    threads:
        workflow.cores * 0.75
    conda:
        "../envs/eggnog_mapper.yaml"
    log:
        f"{config['functions_eggnog']}/logs/{{genome_name}}.eggnog.log"
    shell:
        """
        emapper.py -i {input.proteins} -o {wildcards.genome_name} --cpu {threads} > {log}
        """

rule interproscan_setup:
    """
    Download the interproscan database into the conda environment to scan against.
    """
    output:
        touch(".snakemake/.done/download_interproscan_data.done")
    conda:
        "../envs/interproscan.yaml"
    shell:
        """
        cd $CONDA_PREFIX/share/InterProScan/
        python3 setup.py -f interproscan.properties
        """

rule interproscan:
    """
    Create functional annotations using InterProScan.
    """
    input:
        ".snakemake/.done/interproscan_setup.done",
        proteins = f"{config['proteins']}/{{genome_name}}.pep.fa"
    output:
        f"{config['functions_interproscan']}/{{genome_name}}.interproscan.gff3"
    params:
        appl = "TIGRFAM,SUPERFAMILY,PANTHER,Gene3D,Coils,Pfam,MobiDBLite"
    threads:
        workflow.cores * 0.75
    conda:
        "../envs/interproscan.yaml"
    log:
        f"{config['functions_interproscan']}/logs/{{genome_name}}.interproscan.log"
    shell:
        """
        interproscan.sh \
            -f gff3 \
            --appl {params.appl} \
            --goterms \
            --iprlookup \
            -i {input.proteins} \
            -o {output} \
            --cpu {threads} > {log}
        """