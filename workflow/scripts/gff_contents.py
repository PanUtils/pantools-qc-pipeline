#!/usr/bin/env python3

from sys import argv
import numpy as np
import os
import csv


if __name__ == "__main__":

    counts = {}
    files = ['']

    # expecting files in GFF/GFF3 format
    for i, gffFile in enumerate(snakemake.input):
        files.append(os.path.basename(gffFile))
        for line in open(gffFile):
            if line.startswith('#') or not line.strip():
                continue
            feature = line.split('\t')[2]
            if feature not in counts:
                counts[feature] = np.zeros(len(snakemake.input))
            counts[feature][i] += 1

    with open(snakemake.output[0], 'w', newline='') as tsvfile:
        writer = csv.writer(tsvfile, delimiter='\t', lineterminator='\n')
        writer.writerow(files)
        for feature in counts:
            writer.writerow([feature] + counts[feature].tolist())
