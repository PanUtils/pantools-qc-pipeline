#!/bin/bash
set -o pipefail

# Define the InterProScan version
version_major=5.59
version_minor=91.0

# Update the InterProScan files
cd $CONDA_PREFIX/share/InterProScan/
wget http://ftp.ebi.ac.uk/pub/software/unix/iprscan/5/${version_major}-${version_minor}/interproscan-${version_major}-${version_minor}-64-bit.tar.gz.md5
wget http://ftp.ebi.ac.uk/pub/software/unix/iprscan/5/${version_major}-${version_minor}/interproscan-${version_major}-${version_minor}-64-bit.tar.gz
md5sum -c interproscan-${version_major}-${version_minor}-64-bit.tar.gz.md5
tar xzf interproscan-${version_major}-${version_minor}-64-bit.tar.gz
rm -rd data/
mv interproscan-${version_major}-${version_minor}/data .
rm interproscan-${version_major}-${version_minor}-64-bit.tar.gz
rm interproscan-${version_major}-${version_minor}-64-bit.tar.gz.md5
rm -rd interproscan-${version_major}-${version_minor}/
python3 setup.py -f interproscan.properties
