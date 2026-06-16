rule interproscan:
    """
    Create functional annotations using InterProScan.
    """
    input:
        proteins = f"{config['proteins']}/{{annotation_name}}.filtered.pep.faa"
    output:
        f"{config['functions']}/{{annotation_name}}.interproscan.gff"
    params:
        appl = config['applications']
    threads:
        max(workflow.cores / len(data.annotation), 1)
    log:
        f"{config['functions']}/logs/{{annotation_name}}.interproscan.log"
    shell:
        """
        command -v interproscan.sh > /dev/null 2>&1 || {{ echo >&2 "ERROR: 'interproscan.sh' is required but it's not installed. Aborting."; exit 1; }}
        interproscan.sh \
            -f gff3 \
            --appl {params.appl} \
            --goterms \
            --iprlookup \
            -i {input.proteins} \
            -o {output} \
            --cpu {threads} \
            -T {scratch}/interproscan_{wildcards.annotation_name} > {log}
        """
