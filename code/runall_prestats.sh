#!/bin/bash

# set relative path to makes scripts more portable
cd .. 
maindir=`pwd`
cd code

# skipping 179 180 
for subrun in "189 3" "203 3" "207 2" "208 3" "209 3" "211 3" "212 2" "213 2" "214 3" "215 3" "217 3" "218 3" "219 3" "222 3"; do
	set -- $subrun
	sub=$1
	nruns=$2

	#echo "$sub $nruns"
  	bash run_heudiconv.sh $sub
  	bash run_pydeface.sh $sub

	task=cardgame
	datadir=${maindir}/ds000000/sub-${sub}/func
	for r in `seq $nruns`; do
	  	oldlength=`fslnvols ${datadir}/sub-${sub}_task-${task}_run-0${r}_bold.nii.gz` 
		let newlength=${oldlength}-9
	 	fslroi ${datadir}/sub-${sub}_task-${task}_run-0${r}_bold.nii.gz ${datadir}/tmp${r} 9 ${newlength}
	 	mv -f ${datadir}/tmp${r}.nii.gz ${datadir}/sub-${sub}_task-${task}_run-0${r}_bold.nii.gz
	done
	
done
