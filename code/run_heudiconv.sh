#!/bin/bash

# To do:
# 1) ask Jeff to make the "IntendedFor" addition to the .json more robust
# 2) re-run for new subjects
# 3) clarify directory structure with Bart and Jasmine

maindir=/data/projects/rutgers-r21

#for subnum in "179 5" "180 6" "189 6" "203 7" "207 6" "208 6" "209 6" "210 6" "211 6" "212 6" "213 6" "214 6" "215 6" "217 6"; do
for subnum in "189 6" "208 6" "209 6" "210 6" "211 6" "212 6" "213 6" "214 6" "215 6" "217 6"; do
	
	set -- $subnum
	sub=$1
	nruns=$2

	#207 has the full 6
	#203 has the full 6 + one extra cardgame -- 7
	#180 has 6, with 2 cardgame and 3 rest --
	
	bidsroot=${maindir}/ds000000
	rm -rf ${bidsroot}/sub-${sub}
	rm -rf ${bidsroot}/.heudiconv/${sub}
	
	docker run --rm -it -v ${maindir}:/data:ro \
	-v ${bidsroot}:/output \
	-u $(id -u):$(id -g) \
	nipy/heudiconv:latest \ #v0.5.3
	-d /data/sourcedata/dicoms/{subject}_*_KlabCardGame/*/*.dcm -s $sub \
	-f /data/code/heuristics.py -c dcm2niix -b -o /output
	
	if [ $nruns -eq 7 ]; then
	# FMAP_INTENDEDFOR  set the list of func filenames correctly here (relative paths starting from within sub-### folder)
	# will have to adjust for subjects who don't have this. need a better way to do this
	FUNC01=\"func\\/sub-${sub}_task-cardgame_run-01_bold.nii.gz\"
	FUNC02=\"func\\/sub-${sub}_task-cardgame_run-02_bold.nii.gz\"
	FUNC03=\"func\\/sub-${sub}_task-cardgame_run-03_bold.nii.gz\"
	FUNC05=\"func\\/sub-${sub}_task-rest_run-01_bold.nii.gz\"
	FUNC06=\"func\\/sub-${sub}_task-rest_run-02_bold.nii.gz\"
	FUNC07=\"func\\/sub-${sub}_task-rest_run-03_bold.nii.gz\"
	FUNC08=\"func\\/sub-${sub}_task-rest_run-04_bold.nii.gz\"
	
	#FMAP_INTENDEDFOR edit the line below so that it only includes as many FUNC_FILENAME as you need
	#the formatting of this line is kind of tricky with all the special characters: \n \t
	#be sure to include ,\n\t\t in between each ${FUNCFILENAME} (but not after the last one)
	#after the last ${FUNCFILENAME} in the line there should be the characters ],/g before the closing quotation mark (")
	sed -i "1s/{/{\n\t\"IntendedFor\": [${FUNC01},\n\t\t${FUNC02},\n\t\t${FUNC03},\n\t\t${FUNC05},\n\t\t${FUNC06},\n\t\t${FUNC07},\n\t\t${FUNC08}],/g" ${bidsroot}/sub-${sub}/fmap/sub-${sub}_*.json
	
	elif [ $nruns -eq 6 ]; then
	# FMAP_INTENDEDFOR  set the list of func filenames correctly here (relative paths starting from within sub-### folder)
	# will have to adjust for subjects who don't have this. need a better way to do this
	FUNC01=\"func\\/sub-${sub}_task-cardgame_run-01_bold.nii.gz\"
	FUNC02=\"func\\/sub-${sub}_task-cardgame_run-02_bold.nii.gz\"
	FUNC05=\"func\\/sub-${sub}_task-rest_run-01_bold.nii.gz\"
	FUNC06=\"func\\/sub-${sub}_task-rest_run-02_bold.nii.gz\"
	FUNC07=\"func\\/sub-${sub}_task-rest_run-03_bold.nii.gz\"
	FUNC08=\"func\\/sub-${sub}_task-rest_run-04_bold.nii.gz\"
	
	#FMAP_INTENDEDFOR edit the line below so that it only includes as many FUNC_FILENAME as you need
	#the formatting of this line is kind of tricky with all the special characters: \n \t
	#be sure to include ,\n\t\t in between each ${FUNCFILENAME} (but not after the last one)
	#after the last ${FUNCFILENAME} in the line there should be the characters ],/g before the closing quotation mark (")
	sed -i "1s/{/{\n\t\"IntendedFor\": [${FUNC01},\n\t\t${FUNC02},\n\t\t${FUNC05},\n\t\t${FUNC06},\n\t\t${FUNC07},\n\t\t${FUNC08}],/g" ${bidsroot}/sub-${sub}/fmap/sub-${sub}_*.json
	
	elif [ $nruns -eq 5 ]; then
	
	FUNC01=\"func\\/sub-${sub}_task-cardgame_run-01_bold.nii.gz\"
	FUNC02=\"func\\/sub-${sub}_task-cardgame_run-02_bold.nii.gz\"
	FUNC05=\"func\\/sub-${sub}_task-rest_run-01_bold.nii.gz\"
	FUNC06=\"func\\/sub-${sub}_task-rest_run-02_bold.nii.gz\"
	FUNC07=\"func\\/sub-${sub}_task-rest_run-03_bold.nii.gz\"
	
	
	sed -i "1s/{/{\n\t\"IntendedFor\": [${FUNC01},\n\t\t${FUNC02},\n\t\t${FUNC05},\n\t\t${FUNC06},\n\t\t${FUNC07}],/g" ${bidsroot}/sub-${sub}/fmap/sub-${sub}_*.json
	
	fi

done