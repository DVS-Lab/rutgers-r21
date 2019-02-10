#!/usr/bin/env bash

# make everything relative to root of the GitHub repository
cd ..
maindir=`pwd`


TASK=cardgame
ncopes=9

# delete incomplete output
MAINOUTPUT=${maindir}/derivatives/fsl/sub-${sub}
OUTPUT=${MAINOUTPUT}/L2_task-${TASK}_model-01_type-act
rm -rf ${OUTPUT}.gfeat
if [ -e ${OUTPUT}.gfeat/cope${ncopes}.feat/cluster_mask_zstat1.nii.gz ]; then
	exit
else
	rm -rf ${OUTPUT}.gfeat
fi


ITEMPLATE=${maindir}/code/templates/L2_copes-${ncopes}_runs-${nruns}.fsf
OTEMPLATE=${MAINOUTPUT}/L2_task-${TASK}_model-01_type-act_copes-${ncopes}_runs-${nruns}.fsf
sed -e 's@OUTPUT@'$OUTPUT'@g' \
-e 's@INPUT1@'$INPUT1'@g' \
-e 's@INPUT2@'$INPUT2'@g' \
-e 's@INPUT3@'$INPUT3'@g' \
<$ITEMPLATE> $OTEMPLATE

# runs feat on output template
feat $OTEMPLATE


