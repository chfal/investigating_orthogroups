#!/bin/bash

for FILE in ./investigating_orthogroups/iqtree/*.fa; do
       #echo "$FILE"
       sbatch run_iqtree.sh ${FILE}
       sleep=.05
done
