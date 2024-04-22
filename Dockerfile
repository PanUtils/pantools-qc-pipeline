FROM condaforge/mambaforge:23.11.0-0

RUN apt-get update -y
RUN apt-get install -y git

RUN git clone https://github.com/PanUtils/pantools-qc-pipeline
WORKDIR pantools-qc-pipeline

RUN mamba create -c conda-forge -c bioconda -n snakemake snakemake
RUN echo "conda activate snakemake" >> ~/.bashrc
