#!/bin/bash

# To do:
# 1) ask Jeff to make the "IntendedFor" addition to the .json more robust
# 2) re-run for new subjects
# 3) clarify directory structure with Bart and Jasmine
# 4) need to re-transfer: 210 6

# set relative path to makes scripts more portable
cd .. 
maindir=`pwd`


sub=$1
#207 has the full 6
#203 has the full 6 + one extra cardgame -- 7
#180 has 6, with 2 cardgame and 3 rest --

bidsroot=${maindir}/ds000001
rm -rf ${bidsroot}/sub-${sub}
rm -rf ${bidsroot}/.heudiconv/${sub}

docker run --rm -it -v ${maindir}:/data:ro \
-v ${bidsroot}:/output \
-u $(id -u):$(id -g) \
nipy/heudiconv:latest \
-d /data/sourcedata/sub-{subject}/sub-{subject}/*/*.dcm -s $sub \
-f /data/code/heuristics.py -c dcm2niix -b -o /output

