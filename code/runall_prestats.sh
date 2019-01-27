#!/bin/bash

for subrun in 179 180 189 203 207 208 209 210 211 212 213 214 215 217; do

  bash run_heudiconv.sh $sub
  bash run_pydeface.sh $sub

done
