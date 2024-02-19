#!/bin/bash

for FILE in /projects/f_geneva_1/chfal/test_c4l/iqtree/*.fa; do
       #echo "$FILE"
       sbatch run_iqtree.sh ${FILE}
       sleep=.05
done
