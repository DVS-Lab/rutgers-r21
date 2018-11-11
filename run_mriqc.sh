# example code for MRIQC
# runs MRIQC on input subject
# usage: bash run_mriqc.sh sub
# example: bash run_mriqc.sh 102

sub=$1

docker run -it --rm \
-v /data/projects/rutgers-r21/bids:/data:ro \
-v /data/projects/rutgers-r21/mriqc:/out \
-v /data/projects/rutgers-r21/scratch:/scratch \
-u $(id -u):$(id -g) \
-w /scratch \
poldracklab/mriqc:0.12.1 \
/data /out \
participant --participant_label $sub --n_cpus 12 --fft-spikes-detector --ica -w /scratch

# #--participant_label $sub
