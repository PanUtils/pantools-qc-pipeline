import os

rule filter_gff_fields:
    """
    Filters the gff fields for PanTools parser compatibility.
    1. Discard non-utf-8 characters.
    2. Remove trailing semicolons.
    3. Only keep the first value for attributes values with multiple values.
    4. Remove attribute values without key=value format.
    5. Remove features with unknown strands.
    TODO: Unknown strands should be dealt with in the PanTools code and not here;
    agat will fill in the gaps but dealing with these features and their children
    will be cleaner during the gff parsing step.
    """
    input:
        annotation = f"{config['annotations']}/{{annotation_name}}.gff"
    output:
        temp(f"{config['annotations']}/{{annotation_name}}.filtered.gff")
    shell:
        """
        iconv -f utf-8 -t utf-8 -c {input.annotation} | 
            sed 's/;$//g' |
            sed 's/=\\([^;,]*\\),[^;]*/=\\1/g' |
            sed 's/;[^=;]*;/;/g' | sed 's/;[^=;]*$//g' |
            awk -F'\\t' '$7 !~ "[^-+]"' > {output}
        """

rule agat_sq_filter_feature_from_fasta:
    """
    Compare a fasta and gff file using AGAT.
    Cut all features from the gff file that do not match a fasta sequence. 
    """
    input:
        annotation = f"{config['annotations']}/{{annotation_name}}.filtered.gff",
        genome = lambda wildcards: "{filtered_genomes}/{genome_name}.filtered.fna".format(
            filtered_genomes=config['filtered_genomes'],
            genome_name=data.loc[data.annotation == wildcards.annotation_name, 'genome'].item()
        )
    output:
        temp(f"{config['filtered_annotations']}/{{annotation_name}}_features_from_fasta.gff")
    conda:
        "../envs/agat.yaml"
    shell:
        """
        agat_sq_filter_feature_from_fasta.pl \
            --gff {input.annotation} \
            --fasta {input.genome} \
            --output {output} > /dev/null
        rm -f {input.genome}.index
        """

rule agat_sp_keep_longest_isoform:
    """
    Only keep isoforms with the longest CDS using AGAT.
    """
    input:
        f"{config['filtered_annotations']}/{{annotation_name}}_features_from_fasta.gff"
    output:
        temp(f"{config['filtered_annotations']}/{{annotation_name}}_longest_isoform.gff")
    log:
        f"{config['filtered_annotations']}/logs/keep_longest_isoform/{{annotation_name}}_longest_isoform.agat.log"
    conda:
        "../envs/agat.yaml"
    shell:
        """
        agat_sp_keep_longest_isoform.pl --gff {input} --output {output} > /dev/null
        log="{wildcards.annotation_name}_features_from_fasta.agat.log"
        [ ! -f "$log" ] || mv "$log"  {log}
        """

rule agat_sp_filter_by_orf_size:
    """
    Filter features from gff using AGAT with an ORF smaller than the threshold set in the config.
    """
    input:
        f"{config['filtered_annotations']}/{{annotation_name}}_longest_isoform.gff" if config['longest_isoform'] else \
            f"{config['filtered_annotations']}/{{annotation_name}}_features_from_fasta.gff"
    output:
        filtered=temp(f"{config['filtered_annotations']}/{{annotation_name}}_sup={{orf_size}}.gff"),
        discarded=temp(f"{config['filtered_annotations']}/{{annotation_name}}_NOT_sup={{orf_size}}.gff")
    log:
        f"{config['filtered_annotations']}/logs/filter_by_orf_size/{{annotation_name}}_sup={{orf_size}}.agat.log"
    conda:
        "../envs/agat.yaml"
    shell:
        """
        final_output={output.filtered}
        output="${{final_output/%_sup={wildcards.orf_size}.gff/.gff}}"
        
        agat_sp_filter_by_ORF_size.pl \
          --size {wildcards.orf_size} \
          --test '>=' --gff {input} \
          --output "$output" > /dev/null
        
        log="$(basename "$output" .gff)_longest_isoform.agat.log"
        [ ! -f "$log" ] || mv "$log"  {log}
        """

rule filter_annotation:
    """
    Compare the output of the latest annotation filtering step with the raw input.
    If the two files are identical, the filtered file is replaced with a symbolic link.
    """
    input:
        raw_annotation = "{full_path}/{{annotation_name}}.gff".format(
            full_path=os.path.abspath(config['annotations'])
        ),
        filtered_annotation = "{filtered_annotations}/{{annotation_name}}_sup={orf_size}.gff".format(
            filtered_annotations=config['filtered_annotations'],
            orf_size=config["orf_size"]
        )
    output:
        f"{config['filtered_annotations']}/{{annotation_name}}.filtered.gff"
    shell:
        """
        cmp -s {input.raw_annotation} {input.filtered_annotation} \
            && ln -sf {input.raw_annotation} {output} \
            || mv {input.filtered_annotation} {output}
        """

rule agat_sp_extract_sequences_filtered:
    """
    Create a fasta file with protein sequences.
    Sequences are from the genome with CDS features in the gff file using AGAT.
    """
    input:
        annotation = f"{config['filtered_annotations']}/{{annotation_name}}.filtered.gff",
        genome = lambda wildcards: "{filtered_genomes}/{genome_name}.filtered.fna".format(
            filtered_genomes=config['filtered_genomes'],
            genome_name=data.loc[data.annotation == wildcards.annotation_name, 'genome'].item()
        )
    output:
        f"{config['proteins']}/{{annotation_name}}.filtered.pep.faa"
    log:
        f"{config['proteins']}/logs/{{annotation_name}}.filtered.agat.log"
    conda:
        "../envs/agat.yaml"
    shell:
        """
        agat_sp_extract_sequences.pl -f {input.genome} -g {input.annotation} -p --cis --cfs -o {output} > /dev/null
        rm -f {input.genome}.index
        log="{wildcards.annotation_name}.filtered.agat.log"
        [ ! -f "$log" ] || mv "$log"  {log}
        """

rule agat_sp_extract_sequences_raw:
    """
    Create a fasta file with protein sequences from raw data.
    Sequences are from the genome with CDS features in the gff file using AGAT.
    """
    input:
        annotation = f"{config['annotations']}/{{annotation_name}}.gff",
        genome = lambda wildcards: "{genomes}/{genome_name}.fna".format(
            genomes=config['genomes'],
            genome_name=data.loc[data.annotation == wildcards.annotation_name, 'genome'].item()
        )
    output:
        temp(f"{config['proteins']}/{{annotation_name}}.raw.pep.faa")
    conda:
        "../envs/agat.yaml"
    shell:
        """
        agat_sp_extract_sequences.pl -f {input.genome} -g {input.annotation} -p --cis --cfs -o {output} > /dev/null
        rm -f {input.genome}.index
        rm -f {wildcards.annotation_name}.agat.log
        """
