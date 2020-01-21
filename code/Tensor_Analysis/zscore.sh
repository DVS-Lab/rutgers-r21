cd ../..
maindir=`pwd`
echo ${maindir}
sub=$1
run=$2
TASK=rest
echo "sub-${sub} run-${run} task-${TASK}"
events=${maindir}/sourcedata/sub-${sub}/sub-${sub}_task-${TASK}_run-${run}_events.tsv

if [ ! -f ${events} ]; then     echo "File not found!";else echo "file ${events} exists"; fi

if [ ! -e $events ]; then
    exit
fi

STIM=`awk 'FNR==2{print $3}' ${events}`

MAINOUTPUT=${maindir}/derivatives/Tensor_ICA/sub-${sub}
OTEMPLATE=${MAINOUTPUT}/preproc_task-${TASK}_run-${run}_stim-${STIM}_sm-6.fsf

OUTPUT=${MAINOUTPUT}/preproc_task-${TASK}_run-${run}_stim-${STIM}_sm-6

current_image=${OUTPUT}.feat/filtered_func_data.nii.gz
current_mean=${OUTPUT}.feat/sub-${sub}_stim-${STIM}_tmean.nii.gz
current_sd=${OUTPUT}.feat/sub-${sub}_stim-${STIM}_tstd.nii.gz
current_tdiff=${OUTPUT}.feat/sub-${sub}_stim-${STIM}_tdiff.nii.gz

fslmaths $current_image -Tmean $current_mean
fslmaths $current_image -Tstd $current_sd
fslmaths $current_image -sub $current_mean $current_tdiff
fslmaths $current_tdiff -div $current_sd "${OUTPUT}.feat/sub-${sub}_stim-${STIM}_zscored_image.nii.gz"

