import glob
import tempfile
from pathlib import Path
import pandas as pd

# set scratch directory
if config['scratch']:
    scratch = config['scratch']
else:
    scratch = tempfile.gettempdir()

# read tsv config file matching genome and annotation file locations
try:
    data = pd.read_table(config['data_table'])
except FileNotFoundError:
    print("No data table table found, assuming alphabetically matching sequences and annotations.")
    data = pd.DataFrame()
    data['genome'] = [x for x in sorted(glob.glob("{genomes}/*.fna".format(genomes=config["genomes"])))]
    data['annotation'] = [x for x in sorted(glob.glob("{annotations}/*.gff3".format(annotations=config["annotations"])))]

# get the file name from the given path for naming newly created files.
data['genome_name'] = [Path(x).stem for x in data.genome]
data['annotation_name'] = [Path(x).stem for x in data.annotation]