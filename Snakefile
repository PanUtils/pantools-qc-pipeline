import glob
from pathlib import Path

include: 'workflow/rules/data_filter.smk'


#### USE CASES ####
filtered_genomes = config["genomes_filtered"]
filtered_annotations = config["annotations_filtered"]
genome_names = [Path(x).stem for x in glob.glob("{genomes}/*.fasta".format(genomes=config["genomes"]))]
annotation_names = [Path(x).stem for x in glob.glob("{annotations}/*.gff".format(annotations=config["annotations"]))]

rule all:
    input:
        expand(f"{filtered_genomes}/{{genome}}.filtered.fasta", genome=genome_names),
        expand(f"{filtered_annotations}/{{annotation}}.filtered.gff", annotation=annotation_names)