#!/usr/bin/env python3

from numpy import sum, array, cumsum, median
import os
import csv


def parse_fasta(lines):
    curr_label = None
    curr_seq = []
    for line in lines:
        if not line.strip():
            continue
        if line.startswith('>'):
            if curr_label:
                yield curr_label, ''.join(curr_seq)
            curr_label = line.strip()[1:]
            curr_seq = []
        else:
            curr_seq.append(line.strip())
    yield curr_label, ''.join(curr_seq)


def calc_N_values(lengths):
    num_bases = sum(lengths)
    data = array(lengths)
    data.sort()
    data = data[::-1]
    cum = cumsum(data)

    lookups = [('N25', num_bases * 0.25),
               ('N50', num_bases * 0.5),
               ('N75', num_bases * 0.75),
               ('N95', num_bases * 0.95)]

    res = []
    for lookup_label, lookup_val in lookups:
        sub_total = 0
        for idx, sub_total in enumerate(cum):
            if sub_total >= lookup_val:
                res.append((lookup_label, lookup_val, idx + 1, data[idx]))
                break
    return res


def get_len_stats(lengths):
    res = {}
    res['numseq'] = len(lengths)
    res['numbps'] = sum(lengths)
    res['avglen'] = lengths.mean()
    res['stdlen'] = lengths.std()
    res['maxlen'] = max(lengths)
    res['minlen'] = min(lengths)
    res['medlen'] = float(median(lengths))
    return res


if __name__ == "__main__":

    KEYS = ['numseq', 'numbps', 'avglen', 'stdlen', 'minlen', 'maxlen', \
            'medlen', 'n25idx', 'n25len', 'n50idx', 'n50len', 'n75idx', 'n75len', \
            'n95idx', 'n95len', 'counts']

    result = {}
    file_storage = [""]
    len_storage = []
    counts_storage = []

    for fna_file in snakemake.input:
        file_storage.append(os.path.basename(fna_file))

        lengths = []
        for label, read in parse_fasta(open(fna_file)):
            lengths.append(len(read))

        counts = {}
        lengths = array(lengths)

        len_storage.append(lengths)
        counts_storage.append(counts)

    for fn, lengths, counts in zip(snakemake.input, len_storage, counts_storage):
        len_stats = get_len_stats(lengths)
        N_vals = calc_N_values(lengths)
        result[fn] = {}
        result[fn].update(len_stats)
        for lookup_label, lookup_val, item_idx, item_len in N_vals:
            result[fn][lookup_label + 'idx'] = item_idx
            result[fn][lookup_label + 'len'] = item_len
        result[fn]['counts'] = counts

    with open(snakemake.output[0], 'w', newline='') as tsvfile:
        writer = csv.writer(tsvfile, delimiter='\t', lineterminator='\n')
        writer.writerow(file_storage)
        writer.writerow(["Number of sequences:"] + [result[fn]['numseq'] for fn in snakemake.input])
        writer.writerow(["Total sequence length:"] + [result[fn]['numbps'] for fn in snakemake.input])
        writer.writerow(["Average sequence length:"] + [result[fn]['avglen'] for fn in snakemake.input])
        writer.writerow(["Std. dev. sequence length:"] + [result[fn]['stdlen'] for fn in snakemake.input])
        writer.writerow(["Minimum sequence length:"] + [result[fn]['minlen'] for fn in snakemake.input])
        writer.writerow(["Maximum sequence length:"] + [result[fn]['maxlen'] for fn in snakemake.input])
        writer.writerow(["Median sequence length:"] + [result[fn]['medlen'] for fn in snakemake.input])
        writer.writerow(["N25 sequence index:"] + [result[fn]['N25idx'] for fn in snakemake.input])
        writer.writerow(["N25 sequence length:"] + [result[fn]['N25len'] for fn in snakemake.input])
        writer.writerow(["N50 sequence index:"] + [result[fn]['N50idx'] for fn in snakemake.input])
        writer.writerow(["N50 sequence length:"] + [result[fn]['N50len'] for fn in snakemake.input])
        writer.writerow(["N75 sequence index:"] + [result[fn]['N75idx'] for fn in snakemake.input])
        writer.writerow(["N75 sequence length:"] + [result[fn]['N75len'] for fn in snakemake.input])
        writer.writerow(["N95 sequence index:"] + [result[fn]['N95idx'] for fn in snakemake.input])
        writer.writerow(["'N95 sequence length:"] + [result[fn]['N95len'] for fn in snakemake.input])
