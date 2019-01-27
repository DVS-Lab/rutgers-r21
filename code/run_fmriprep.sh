#!/bin/bash

maindir=/data/projects/rutgers-r21

docker run -it --rm \
-v ${maindir}/ds000000:/data:ro \
-v ${maindir}/derivatives:/out \
-v ${maindir}/code/fs_license.txt:/opt/freesurfer/fs_license.txt \
-v ${maindir}/derivatives/scratch:/scratch \
-u $(id -u):$(id -g) \
-w /scratch \
poldracklab/fmriprep:1.2.6-1 \
/data /out \
participant \
--use-aroma --fs-no-reconall --fs-license-file /opt/freesurfer/fs_license.txt -w /scratch
