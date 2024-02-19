#!/bin/bash

for FILE in *.fasta;
do
 awk '/^>/ {gsub(/.fa(sta)?$/,"",FILENAME);printf(">%s\n",FILENAME);next;} {print}' $FILE > changed_${FILE}
done
