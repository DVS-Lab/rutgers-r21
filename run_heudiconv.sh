#!/usr/bin/env bash

# example code for heudiconv
# runs heudiconv on input subject
# usage: bash run_heudiconv.sh sub xnat
# example: bash run_heudiconv.sh 102 1

sub=$1

bidsroot=/data/projects/rutgers-r21/bids
rm -rf ${bidsroot}/sub-${sub}
rm -rf ${bidsroot}/.heudiconv/${sub}

docker run --rm -it -v /data/projects/rutgers-r21:/data:ro \
-v ${bidsroot}:/output \
-u $(id -u):$(id -g) \
nipy/heudiconv:latest \
-d /data/dicoms/KLab-CardGame_sub-{subject}/*/*/*.dcm -s $sub \
-f /data/heuristics.py -c dcm2niix -b -o /output


# FMAP_INTENDEDFOR  set the list of func filenames correctly here (relative paths starting from within sub-### folder)
# will have to adjust for subjects who don't have this. need a better way to do this
FUNC01=\"func\\/sub-${sub}_task-cardgame_run-01_bold.nii.gz\"
FUNC02=\"func\\/sub-${sub}_task-cardgame_run-02_bold.nii.gz\"
FUNC03=\"func\\/sub-${sub}_task-rest_run-01_bold.nii.gz\"
FUNC04=\"func\\/sub-${sub}_task-rest_run-02_bold.nii.gz\"
FUNC05=\"func\\/sub-${sub}_task-rest_run-03_bold.nii.gz\"
FUNC06=\"func\\/sub-${sub}_task-rest_run-04_bold.nii.gz\"

#FMAP_INTENDEDFOR edit the line below so that it only includes as many FUNC_FILENAME as you need
#the formatting of this line is kind of tricky with all the special characters: \n \t
#be sure to include ,\n\t\t in between each ${FUNCFILENAME} (but not after the last one)
#after the last ${FUNCFILENAME} in the line there should be the characters ],/g before the closing quotation mark (")
sed -i "1s/{/{\n\t\"IntendedFor\": [${FUNC01},\n\t\t${FUNC02},\n\t\t${FUNC03},\n\t\t${FUNC04},\n\t\t${FUNC05},\n\t\t${FUNC06}],/g" ${bidsroot}/sub-${sub}/fmap/sub-${sub}_*.json


