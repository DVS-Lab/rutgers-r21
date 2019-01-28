#!/bin/bash

# leaving out 210 for now
# skipping 179 (pilot subject)
for sub in 180 189 203 207 208 209 211 212 213 214 215 217; do

	bash gen_3col_files.sh $sub

done
