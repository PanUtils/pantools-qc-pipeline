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

rule interproscan:
    input:
        ".snakemake/done/download_interproscan_data.done",
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