#!/bin/bash

# set relative path to makes scripts more portable
cd .. 
maindir=`pwd`

docker run -it --rm \
-v $maindir/ds000000:/data:ro \
-v $maindir/derivatives/mriqc:/out \
-v $maindir/derivatives/scratch:/scratch \
-u $(id -u):$(id -g) \
-w /scratch \
poldracklab/mriqc:0.14.2 \
/data /out \
participant --fft-spikes-detector --ica -w /scratch


