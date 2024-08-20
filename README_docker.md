# Build docker image
In folder where Dockerfile is located:
```bash
docker build -t pantools-qc-pipeline .
```

# Run interactive container
Make sure you mount (-v "{folder-local-pc}:{folder-docker}") your configuration file and in- and output folders. Make sure the paths in your configuration file are pointing to the docker folder locations (/resources and /results in example)
```bash
docker run -v "/path/to/qc_config.yaml:/pantools-qc-pipeline/config/config.yaml" -v "/path/to/pantools-qc-pipeline/resources:/resources/" -v "/path/to/results:/results/" -it pantools-qc-pipeline bash
```
This creates an interactive container where you can run all snakemake commands as described in the README for the pipeline. Type ```exit``` when you want to stop the container.