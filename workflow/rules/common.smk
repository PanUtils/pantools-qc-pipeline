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
if config['data_table']:
    data = pd.read_table(config['data_table'])
else:
    print("No data table table specified, assuming alphabetically matching sequences and annotations.")
    data = pd.DataFrame()
    data['genome'] = [Path(x).stem for x in sorted(glob.glob("{genomes}/*.fna".format(genomes=config["genomes"])))]
    data['annotation'] = [Path(x).stem for x in sorted(glob.glob("{annotations}/*.gff".format(annotations=config["annotations"])))]
