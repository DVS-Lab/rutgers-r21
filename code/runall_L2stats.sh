#!/bin/bash


cat runcount.tsv | 
while read a; do 
	set -- $a
	sub=$1
	nruns=$2

  	#Manages the number of jobs and cores
  	SCRIPTNAME=L2_task-reward_model-01.sh
  	NCORES=32
  	while [ $(ps -ef | grep -v grep | grep $SCRIPTNAME | wc -l) -ge $NCORES ]; do
 		sleep 1s
  	done
  	bash $SCRIPTNAME $sub $nruns &
  	sleep 5s
  	
		
done