#!/bin/bash
# Robin van Esch - 05-12-2022

orf_size="${snakemake_wildcards[orf_size]}"
output="${snakemake_output[0]/%_sup=$orf_size.gff/.gff}"

agat_sp_filter_by_ORF_size.pl \
  --size "$orf_size" \
  --test '>=' --gff "${snakemake_input}" \
  --output "$output" > /dev/null

echo "$(basename "$output" .gff).agat.log"
mv "$(basename "$output" .gff)_longest_isoform.agat.log" "${snakemake_log}"