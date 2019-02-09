#!/usr/bin/env bash

# make everything relative to root of the GitHub repository
cd ..
maindir=`pwd`

sub=$1
run=$2
TASK=cardgame


# denoise data, if it doesn't exist
cd ${maindir}/derivatives/fmriprep/sub-${sub}/func
if [ ! -e sub-${sub}_task-${TASK}_run-0${run}_bold_space-MNI152NLin2009cAsym_variant-unsmoothedAROMAnonaggr_preproc.nii.gz ]; then
	fsl_regfilt -i sub-${sub}_task-${TASK}_run-0${run}_bold_space-MNI152NLin2009cAsym_preproc.nii.gz \
	    -f $(cat sub-${sub}_task-${TASK}_run-0${run}_bold_AROMAnoiseICs.csv) \
	    -d sub-${sub}_task-${TASK}_run-0${run}_bold_MELODICmix.tsv \
	    -o sub-${sub}_task-${TASK}_run-0${run}_bold_space-MNI152NLin2009cAsym_variant-unsmoothedAROMAnonaggr_preproc.nii.gz
fi


# delete incomplete output
MAINOUTPUT=${maindir}/derivatives/fsl/sub-${sub}
mkdir -p $MAINOUTPUT
OUTPUT=${MAINOUTPUT}/L1_task-${TASK}_model-01_type-act_run-0${run}
if [ -e ${OUTPUT}.feat/cluster_mask_zstat1.nii.gz ]; then
	exit
else
	rm -rf ${OUTPUT}.feat
fi

EVDIR=${maindir}/derivatives/fsl/EVfiles/sub-${sub}/run-0${run}
DATA=${maindir}/derivatives/fmriprep/sub-${sub}/func/sub-${sub}_task-${TASK}_run-0${run}_bold_space-MNI152NLin2009cAsym_variant-unsmoothedAROMAnonaggr_preproc.nii.gz


ITEMPLATE=${maindir}/templates/L1_template_m01.fsf
OTEMPLATE=${MAINOUTPUT}/L1_task-${TASK}_model-01_type-act_run-0${run}.fsf
sed -e 's@OUTPUT@'$OUTPUT'@g' \
-e 's@DATA@'$DATA'@g' \
-e 's@EVDIR@'$EVDIR'@g' \
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
# not deleting filtered_func_data bc that's input for PPI
rm -rf ${OUTPUT}.feat/stats/res4d.nii.gz
rm -rf ${OUTPUT}.feat/stats/corrections.nii.gz
rm -rf ${OUTPUT}.feat/stats/threshac1.nii.gz
