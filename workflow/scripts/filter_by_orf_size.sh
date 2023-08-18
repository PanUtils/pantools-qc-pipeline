#!/bin/bash
# Robin van Esch - 05-12-2022

size=${snakemake_params[orf_size]}
output="${snakemake_output}"
agat_sp_filter_by_ORF_size.pl --size $size --test '>=' --gff ${snakemake_input[0]} --output $output > /dev/null
mv "$(basename $output .gff).agat.log" ${snakemake_log[0]}