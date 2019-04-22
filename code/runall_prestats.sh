#!/bin/bash

# set relative path to makes scripts more portable
cd .. 
maindir=`pwd`
cd code


# skipping 179 180 
# skipping 223 (unsure whether stimulator was working)
#for sub in 189 203 207 208 209 210 211 212 213 214 215 216 217 218 219 220 221 222 224 225 226 227 228 230 231 232 234; do
# for sub in 216 230 232; do
for sub in 226 233 235 237 238; do

  	bash run_heudiconv.sh $sub &
	sleep 5
	
done

sleep 15m
#for sub in 216 230 232; do
for sub in 226 233 235 237 238; do

  	bash run_pydeface.sh $sub &
	sleep 5
	
done
