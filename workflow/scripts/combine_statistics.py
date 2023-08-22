#!/usr/bin/env python3
# Robin van Esch

import numpy as np
import os
import csv
import re

if __name__ == "__main__":

    stats = {}
    files = ['']

    # iterate through snakemake input files
    for i, textFile in enumerate(snakemake.input):
        # record gff file name for headers
        files.append(os.path.basename(os.path.splitext(textFile)[0]))

        # add values to dictionary
        with open(textFile) as f:
            for line in f.readlines():
                values = re.split(r'\s{2,}', line.strip())
                if len(values) != 2:
                    continue
                if values[0] not in stats:
                    stats[values[0]] = np.zeros(len(snakemake.input))
                stats[values[0]][i] = values[1]

    # write values to csv
    with open(snakemake.output[0], 'w', newline='') as tsvfile:
        writer = csv.writer(tsvfile, delimiter='\t', lineterminator='\n')
        writer.writerow(files)
        for feature in stats:
            writer.writerow([feature] + stats[feature].tolist())
