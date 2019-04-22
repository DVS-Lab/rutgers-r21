#!/bin/bash

rm -rf ../check_L1.log

cat runcount.tsv | 
while read a; do 
	set -- $a
	sub=$1
	nruns=$2

		
	for run in `seq $nruns`; do
	
	  	#Manages the number of jobs and cores
	  	SCRIPTNAME=L1_task-reward_model-01.sh
	  	#SCRIPTNAME=L1_task-reward_model-01_ppi.sh
	  	NCORES=24
	  	while [ $(ps -ef | grep -v grep | grep $SCRIPTNAME | wc -l) -ge $NCORES ]; do
	 		sleep 1s
	  	done
	  	bash $SCRIPTNAME $sub $run &
	  	sleep 5s
  	
	done
		
done
