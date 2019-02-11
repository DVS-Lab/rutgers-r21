#!/usr/bin/env bash

# make everything relative to root of the GitHub repository
cd ..
maindir=`pwd`


TASK=cardgame
ncopes=19
TYPE=ppi

for COPENUM in `seq $ncopes`; do
	
	cnum_padded=`zeropad ${COPENUM} 2`
	
	# delete incomplete output
	MAINOUTPUT=${maindir}/derivatives/fsl/L3_n14_model-01
	if [ ! -d ${MAINOUTPUT} ]; then
		mkdir $MAINOUTPUT
	fi
	OUTPUT=${MAINOUTPUT}/L3_task-${TASK}_model-01_type-${TYPE}_cope-${cnum_padded}
	if [ -e ${OUTPUT}.gfeat/cope${ncopes}.feat/cluster_mask_zstat1.nii.gz ]; then
		exit
	else
		rm -rf ${OUTPUT}.gfeat
	fi
	
	ITEMPLATE=${maindir}/code/templates/L3_template_n14.fsf
	OTEMPLATE=${MAINOUTPUT}/L3_task-${TASK}_model-01_type-${TYPE}_cope-${cnum_padded}.fsf
	sed -e 's@OUTPUT@'$OUTPUT'@g' \
	-e 's@TYPE@'$TYPE'@g' \
	-e 's@COPENUM@'$COPENUM'@g' \
	<$ITEMPLATE> $OTEMPLATE
	
	# runs feat on output template
	feat $OTEMPLATE &

done
