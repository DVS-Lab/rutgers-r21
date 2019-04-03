#!/bin/bash

# set relative path to makes scripts more portable
cd .. 
maindir=`pwd`

bidsroot=${maindir}/ds000001

sub=$1

#sudo chmod -R aug+rwx ${bidsroot}/sub-${sub}

# defacing anatomicals to ensure compatibility with data sharing
pydeface.py ${bidsroot}/sub-${sub}/anat/sub-${sub}_T1w.nii.gz
mv -f ${bidsroot}/sub-${sub}/anat/sub-${sub}_T1w_defaced.nii.gz ${bidsroot}/sub-${sub}/anat/sub-${sub}_T1w.nii.gz
pydeface.py ${bidsroot}/sub-${sub}/anat/sub-${sub}_T2w.nii.gz
mv -f ${bidsroot}/sub-${sub}/anat/sub-${sub}_T2w_defaced.nii.gz ${bidsroot}/sub-${sub}/anat/sub-${sub}_T2w.nii.gz
