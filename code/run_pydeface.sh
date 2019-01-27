#!/bin/bash


bidsroot=/data/projects/rutgers-r21/ds000000

for sub in 179 180 189 203 207 208 209 210 211 212 213 214 215 217; do
	
	#sudo chmod -R aug+rwx ${bidsroot}/sub-${sub}
	
	# defacing anatomicals to ensure compatibility with data sharing
	pydeface.py ${bidsroot}/sub-${sub}/anat/sub-${sub}_T1w.nii.gz
	mv -f ${bidsroot}/sub-${sub}/anat/sub-${sub}_T1w_defaced.nii.gz ${bidsroot}/sub-${sub}/anat/sub-${sub}_T1w.nii.gz
	pydeface.py ${bidsroot}/sub-${sub}/anat/sub-${sub}_T2w.nii.gz
	mv -f ${bidsroot}/sub-${sub}/anat/sub-${sub}_T2w_defaced.nii.gz ${bidsroot}/sub-${sub}/anat/sub-${sub}_T2w.nii.gz

done