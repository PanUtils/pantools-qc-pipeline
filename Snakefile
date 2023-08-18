include: 'rules/data_filter.smk'

#### USE CASES ####
filtered_genomes = config["genomes_filtered"]
filtered_annotations = config["annotations_filtered"]

rule all:
    input:
        f"{filtered_annotations}/273614_chrI.filtered.gff"