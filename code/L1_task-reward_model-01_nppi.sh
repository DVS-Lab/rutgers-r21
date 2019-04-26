#!/usr/bin/env bash

# make everything relative to root of the GitHub repository
cd ..
maindir=`pwd`

sub=$1
run=$2
ppi=$3
TASK=cardgame


# delete incomplete output
MAINOUTPUT=${maindir}/derivatives/fsl/sub-${sub}
mkdir -p $MAINOUTPUT
OUTPUT=${MAINOUTPUT}/L1_task-${TASK}_model-01_type-nppi-${ppi}_run-0${run}
if [ -e ${OUTPUT}.feat/cluster_mask_zstat1.nii.gz ]; then
	exit
else
	rm -rf ${OUTPUT}.feat
	echo ${OUTPUT} >> check_L1.log
fi

DATA=${MAINOUTPUT}/L1_task-${TASK}_model-01_type-act_run-0${run}.feat/filtered_func_data.nii.gz
EVDIR=${maindir}/derivatives/fsl/EVfiles/sub-${sub}/run-0${run}
NVOLUMES=`fslnvols ${DATA}`

MASK=${MAINOUTPUT}/L1_task-${TASK}_model-01_type-act_run-0${run}.feat/mask
for net in `seq 0 9`; do
	NET=${maindir}/masks/nets/rPNAS_2mm_net000${net}.nii
	TSFILE=${MAINOUTPUT}/ts_task-${TASK}_net000${net}_run-0${run}.txt
	fsl_glm -i $DATA -d $NET -o $TSFILE --demean -m $MASK
	eval INPUT${net}=$TSFILE
done

DMN=$INPUT3
ECN=$INPUT7
if [ "$ppi" == "dmn" ]; then
	MAINNET=$DMN
	OTHERNET=$ECN
else
	MAINNET=$ECN
	OTHERNET=$DMN
fi

ITEMPLATE=${maindir}/templates/L1_template-m01_netppi.fsf
OTEMPLATE=${MAINOUTPUT}/L1_task-${TASK}_model-01_nppi-${ppi}_run-0${run}.fsf
sed -e 's@OUTPUT@'$OUTPUT'@g' \
-e 's@DATA@'$DATA'@g' \
-e 's@EVDIR@'$EVDIR'@g' \
-e 's@MAINNET@'$MAINNET'@g' \
-e 's@OTHERNET@'$OTHERNET'@g' \
-e 's@INPUT0@'$INPUT0'@g' \
-e 's@INPUT1@'$INPUT1'@g' \
-e 's@INPUT2@'$INPUT2'@g' \
-e 's@INPUT4@'$INPUT4'@g' \
-e 's@INPUT5@'$INPUT5'@g' \
-e 's@INPUT6@'$INPUT6'@g' \
-e 's@INPUT8@'$INPUT8'@g' \
-e 's@INPUT9@'$INPUT9'@g' \
<$ITEMPLATE> $OTEMPLATE

# runs feat on output template
feat $OTEMPLATE

# fix registration as per NeuroStars post:
# https://neurostars.org/t/performing-full-glm-analysis-with-fsl-on-the-bold-images-preprocessed-by-fmriprep-without-re-registering-the-data-to-the-mni-space/784/3
mkdir -p ${OUTPUT}.feat/reg
ln -s $FSLDIR/etc/flirtsch/ident.mat ${OUTPUT}.feat/reg/example_func2standard.mat
ln -s $FSLDIR/etc/flirtsch/ident.mat ${OUTPUT}.feat/reg/standard2example_func.mat
ln -s ${OUTPUT}.feat/mean_func.nii.gz ${OUTPUT}.feat/reg/standard.nii.gz

# delete unused files
rm -rf ${OUTPUT}.feat/filtered_func_data.nii.gz
rm -rf ${OUTPUT}.feat/stats/res4d.nii.gz
rm -rf ${OUTPUT}.feat/stats/corrections.nii.gz
rm -rf ${OUTPUT}.feat/stats/threshac1.nii.gz
rm -rf ${OUTPUT}.feat/filtered_func_data.nii.gz
