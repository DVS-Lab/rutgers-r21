#!/usr/bin/env bash

# make everything relative to root of the GitHub repository
cd ..
maindir=`pwd`

MASK=${maindir}/masks/NAcc_resliced.nii.gz
TASK=cardgame
TYPE=act

for COPENUM in 1 2 3 4; do
	
	cnum_padded=`zeropad ${COPENUM} 2`
	
	MAINOUTPUT=${maindir}/derivatives/fsl/L3_n14_model-01
	OUTPUT=${MAINOUTPUT}/L3_task-${TASK}_model-01_type-${TYPE}_cope-${cnum_padded}
	DATA=${OUTPUT}.gfeat/cope1.feat/filtered_func_data.nii.gz
	fslmeants -i $DATA -o NAcc_type-${TYPE}_cope-${cnum_padded}.txt -m ${MASK}


done
