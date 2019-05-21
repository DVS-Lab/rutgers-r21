#!/bin/bash

rm -rf ../check_L1.log
cd ../..
fnames=`$(cut -d ',' -f4 rest_task_outlier_exclusion_data.csv)`
#for ppi in dmn ecn; do
for filly in fnames; do 
	sub=`grep`
	nruns=`grep`
	for run in `seq $nruns`; do
	#Manages the number of jobs and cores
	#SCRIPTNAME=L1_task-reward_model-01.sh
	SCRIPTNAME=preproc_sm_demean.sh
	#SCRIPTNAME=L1_task-reward_model-01_nppi.sh
	NCORES=12
		while [ $(ps -ef | grep -v grep | grep $SCRIPTNAME | wc -l) -ge $NCORES ]; do
			sleep 5s
		  	done
		  	#bash $SCRIPTNAME $sub $run $ppi &
		  	bash $SCRIPTNAME $sub $run &
		  	sleep 5s
	  	
		done
	
	done

done
