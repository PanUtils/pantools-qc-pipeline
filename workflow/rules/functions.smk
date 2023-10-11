rule interproscan_setup:
    """
    Download the interproscan database into the conda environment to scan against.
    """
    output:
        touch(".snakemake/metadata/interproscan_setup.done")
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
        ".snakemake/metadata/interproscan_setup.done",
        proteins = f"{config['proteins']}/{{annotation_name}}.filtered.pep.faa"
    output:
        f"{config['functions']}/{{annotation_name}}.interproscan.gff"
    params:
        appl = config['applications']
    threads:
        max(workflow.cores / len(data.annotation), 1)
    conda:
        "../envs/interproscan.yaml"
    log:
        f"{config['functions']}/logs/{{annotation_name}}.interproscan.log"
    shell:
        """
        interproscan.sh \
            -f gff3 \
            --appl {params.appl} \
            --goterms \
            --iprlookup \
            -i {input.proteins} \
            -o {output} \
            --cpu {threads} \
            -T {scratch}/interproscan > {log}
        """