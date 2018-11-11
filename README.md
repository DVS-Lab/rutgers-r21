# Remote Modulation of Reward Circuits
This repository contains code related to our R21 grant (NIH R21-MH113917). 

## Notes on repository organization and files
Some of the contents of this repository are not tracked (.gitignore) because the files are large. These files/folders specifically include our dicom images, converted images in bids format, fsl output, and derivatives from bids (e.g., mriqc and fmriprep). All scripts will reference these directories, which are only visible on our the primary linux workstation in Smith Lab.




## Basic steps for analyses


1. Transfer data from Rutgers server to dicoms folder (e.g., /data/projects/rutgers-r21/dicoms/<subject dicoms>).
1. Convert data to BIDS, preprocess, and run QA using the wrapper `bash run_prestats.sh $sub $xnat $nruns`.This wrapper will do the following:
    - Run [heudiconv][3] to convert dicoms to BIDS using `bash run_heudiconv.sh $sub $xnat $nruns`.
    - Run PyDeface to remove the face from the anats. This is done using `bash run_pydeface.sh $sub`.
    - Run [mriqc][4] and [fmriprep][5] using `bash run_mriqc.sh $sub` and `bash run_fmriprep.sh $sub`, respectively.
1. Convert `*_events.tsv` files to 3-column files (compatible with FSL) using Tom Nichols' [BIDSto3col.sh][2] script. This script is wrapped into our pipeline using `bash gen_3col_files.sh $sub $nruns`
1. Run analyses in FSL. Analyses in FSL consist of two stages, which we call "Level 1" (L1) and "Level 2" (L2). For L1, we have a wrapper that runs all tasks simultaneously `bash run_L1stats.sh $sub $nruns`. This wrapper will do the following:



[1]: https://openneuro.org/
[2]: https://github.com/INCF/bidsutils
[3]: https://github.com/nipy/heudiconv
[4]: https://mriqc.readthedocs.io/en/latest/index.html
[5]: http://fmriprep.readthedocs.io/en/latest/index.html
