import glob
from pathlib import Path
import pandas as pd

# read tsv config file matching genome and annotation file locations
try:
    data = pd.read_table("config/data.tsv")
except FileNotFoundError:
    print("No data.tsv table found, assuming alphabetically matching sequences and annotations.")
    data = pd.DataFrame()
    data['genome'] = [x for x in sorted(glob.glob("{genomes}/*.fasta".format(genomes=config["genomes"])))]
    data['annotation'] = [x for x in sorted(glob.glob("{annotations}/*.gff".format(annotations=config["annotations"])))]

# get the file name from the given path for naming newly created files.
data['genome_name'] = [Path(x).stem for x in data['genome']]
data['annotation_name'] = [Path(x).stem for x in data['annotation']]