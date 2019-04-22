#!/bin/bash

# set relative path to makes scripts more portable
cd .. 
maindir=`pwd`

docker run -it --rm \
-v ${maindir}/ds000001:/data:ro \
-v ${maindir}/derivatives:/out \
-v ${maindir}/code/fs_license.txt:/opt/freesurfer/fs_license.txt \
-v ${maindir}/derivatives/scratch:/scratch \
-u $(id -u):$(id -g) \
-w /scratch \
poldracklab/fmriprep:1.2.6-1 \
/data /out \
participant --participant_label 226 233 235 237 238 \
--use-aroma --fs-no-reconall --fs-license-file /opt/freesurfer/fs_license.txt \
-w /scratch

# --participant_label 216 230 232
# missing T1w for sub-238?
