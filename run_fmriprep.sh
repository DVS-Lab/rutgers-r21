# example code for FMRIPREP
# runs FMRIPREP on input subject
# usage: bash run_fmriprep.sh sub
# example: bash run_fmriprep.sh 102

sub=$1

docker run -it --rm \
-v /data/projects/rutgers-r21/bids:/data:ro \
-v /data/projects/rutgers-r21/fmriprep:/out \
-v /data/projects/rutgers-r21/fs_license.txt:/opt/freesurfer/fs_license.txt \
-v /data/projects/rutgers-r21/scratch:/scratch \
-u $(id -u):$(id -g) \
-w /scratch \
poldracklab/fmriprep:1.1.4 \
/data /out \
participant --participant_label $sub \
--use-aroma --fs-no-reconall --fs-license-file /opt/freesurfer/fs_license.txt -w /scratch
