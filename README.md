# pantools-qc-pipeline
Pipeline for quality control of PanTools input data.

This pipeline can be used to obtain genome, annotation and protein data statistics,
filter genome and annotation data, extract protein sequences and create functional annotations.

Requirements: Snakemake, Mamba.

## Cloning this git
For cloning this git, run:
```bash
git clone https://github.com/PanUtils/pantools-qc-pipeline
cd pantools-qc-pipeline
```

## Install Snakemake and Mamba
If you don't have mamba, install it using
```bash
conda install -n base -c conda-forge mamba
```

Then, a Snakemake environment can be created using
```bash
conda activate base
mamba create -c conda-forge -c bioconda -n snakemake snakemake
```

Which can be activated and verified with
```bash
conda activate snakemake
snakemake --help
```

## Specify config settings
By default, the pipeline uses the provided test data set as raw input data, 
this can be changed by updating the input paths in the provided config.yaml.
Filtering parameters, output paths and scratch directory can also be altered.

## Input data
Two input directories are required. One with genomic fasta files and one with matching annotations.
All fasta files must end in *.fna*, all annotations files in *.gff3*. 
If this is not the case, the genome and annotation file extensions can be altered using:

```bash
for file in <genomes>/*.fa*; do mv -- "$file" "${file%.fa*}.fna"; done
```

```bash
for file in <annotations>/*.gff; do mv -- "$file" "${file%.gff}.gff3"; done
```

By default, the pipeline assumes the genome and annotation files match alphabetically. 
If this is not the case, a *data.tsv* file needs to be provided in the *config/* directory
with the file names or paths of the matching files. For example:
```tsv
genome                  annotation
genome1.fna             annotation1.gff3
/path/to/genome2.fna    /path/to/second_annotation.gff3
...                     ...
```

## Run the pipeline
The pipeline can be run with

```bash
snakemake --use-conda --conda-frontend 'mamba' --cores <threads> [rule]
```

Where <threads> is the number of threads to run on, and the possible rules are discussed below.
The full pipeline will run if no rule is provided.

## Rules
### raw_statistics
Provide statistics of raw genome and annotation data, and extracted protein sequences of the raw data.
These statistics can be used to set the filtering parameters for the other rules.

### filter
Filter the genomic fasta based on sequence length. Filter features from the annotation files not matching 
sequences in the gff, then filter the annotations on longest isoform and ORF size of the CDS. 
Provide statistics of the filtered data.

### proteins
Extract protein sequences from the filtered genomes with CDS features in the filtered annotations.
Provide statistics of the protein fasta file contents.

### functions
Create functional annotations from extracted protein sequences of the filtered data using InterProScan.