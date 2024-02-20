#!/bin/bash

for FILE in ./*.fa; do
       #echo "$FILE"
       sbatch run_iqtree.sh ${FILE}
       sleep=.05
done
