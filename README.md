# pantools-qc-pipeline
Pipeline for quality control of PanTools input data.

This pipeline can be used to obtain genome, annotation and protein data statistics,
filter genome and annotation data, extract protein sequences and create functional annotations.
Using this pipeline is highly recommended for PanTools input data because it prevents a lot
of common parser issues.

Requirements: Snakemake, Mamba.

## Installation
### Clone this git
For cloning this git, run:
```bash
git clone https://github.com/PanUtils/pantools-qc-pipeline
cd pantools-qc-pipeline
```

### Install Snakemake and Mamba
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

### Specify config settings
By default, the pipeline uses the provided test data set as raw input data, 
this can be changed by updating the input paths in the provided config.yaml.
Filtering parameters, output paths and scratch directory can also be altered.

### Install InterProScan
InterProScan is required for the functional annotation step which is enabled by using the `functions:` field in the `config.yaml`.
Please follow the instructions on the [InterProScan website](https://interproscan-docs.readthedocs.io/en/v5/HowToDownload.html) to install InterProScan.
You can test if InterProScan is installed correctly by running the following command:
```bash
interproscan.sh --help
``````

## Input data
Two input directories are required. One with genomic fasta files and one with matching annotations.
All fasta files must end in *.fna*, all annotations files in *.gff*. 
If this is not the case, the genome and annotation file extensions can be altered using:

```bash
for file in <genomes>/*.fa*; do mv -- "$file" "${file%.fa*}.fna"; done
```

```bash
for file in <annotations>/*.gff3; do mv -- "$file" "${file%.gff3}.gff"; done
```

By default, the pipeline assumes the genome and annotation files match alphabetically. 
If this is not the case, a data table needs to be provided in the config
with the file names of the matching genome and annotation files (tab separated). 
The headers "genome" and "annotation" are required. For example:
```tsv
genome      annotation
genome1.fna annotation1.gff
genome2.fna annotation2.gff
...         ...
```

## Run the pipeline
The pipeline can be run with

```bash
snakemake [rule] --use-conda --cores <threads> [--configfile <config>] [--conda-prefix <prefix>]
```

Where <threads> is the number of threads to run on, and <config> a custom config file.
If no config is provided, the pipeline will run on a small yeast test dataset.
The possible rules are discussed below. The pipeline will create everything except for the 
functional annotations if no rule is provided (since these take a lot of time).
The conda environments needed for this pipeline will be created in the pipeline directory;
you can instead set a directory as <prefix> to store the environments.

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

## Output
All output will be stored in your designated output data directories.

### filtered genomes
This directory contains all genomic fasta (.fna) files which have been filtered based on a minimum sequence length
set in the config.
If no sequences have been removed this way, a symbolic link to the raw data is created instead to prevent redundancy.

### filtered annotations
This directory contains all filtered gene annotation (.gff) files. Again, if no sequences have been removed this way, 
a symbolic link to the raw data is created instead to prevent redundancy.
These annotation files are filtered using the following steps:
1. Some common format inaccuracies (like trailing semicolons) are corrected to prevent later parser issues.
2. The annotations are compared to the filtered fasta files, removing any features that do not match.
3. If selected in the config, only the longest isoforms will be kept.
4. Features are filtered on ORF size and removed if they do not pass the threshold set in the config.

### proteins
This directory contains protein fasta files (.pep.faa) which have been created by matching the CDS features from the 
gene annotations to the sequences from the genomic fasta, and translating these sequences to proteins.

### functions
This directory contains functional annotations created by InterProScan. These annotations are created from the protein 
files. You can choose the analysis done by InterProScan by setting the applications parameter in the config.
This parameter matches the [--applications](
https://interproscan-docs.readthedocs.io/en/latest/HowToRun.html#appl-applications-application-name-optional) 
flag of InterProScan. By default, only the TIGRFAM and Pfam analysis are performed, other analysis might take a very 
long time to run.

### statistics
This directory contains data statistics for the raw and filtered genome, annotation and protein files.
- Genome and protein content files contain statistics for sequence number and lengths.
- Annotation content files contain numbers for all included features in the genomic annotation files.
- annotation_statistics.tsv contains more detailed statistics for the genomic annotations created by AGAT.
- The agat_sp_statistics directory contains the same annotation statistics on a per-genome basis.

### metadata
The metadata directory contains location files with the full paths for filtered genome and gene annotation files, 
as well as the generated protein and functional annotation files. These files can directly be used as input for the 
following PanTools commands:
- genome_locations.txt can be used for [build_pangenome](
  https://pantools.readthedocs.io/en/stable/construction/build.html#build-pangenome)
- annotation_locations.txt can be used for [add_annotations](
  https://pantools.readthedocs.io/en/stable/construction/annotate.html#add-annotations)
- protein_locations.txt can be used for [build_panproteome](
  https://pantools.readthedocs.io/en/stable/construction/build.html#build-panproteome)
- function_locations.txt can be used for [add_functions](
  https://pantools.readthedocs.io/en/stable/construction/annotate.html#add-functions)
