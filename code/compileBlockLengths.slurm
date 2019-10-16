#!/bin/bash

#SBATCH -J compileBlockLengths
#SBATCH -p shared,serial_requeue
#SBATCH --mem=500
#SBATCH -t 0-05:00
#SBATCH -n 1
#SBATCH -e compileBlockLengths.err
#SBATCH -o compileBlockLengths.out

for i in rep*
do
  num=$(echo $i|cut -d "p" -f 2)
  /n/scratchlfs/mallet_lab/edelman/IBD/code/getBlockLengths.py $i/blocks.out $i/blockLengths.tsv $num
  cat $i/blockLengths.tsv >> allBlockLengths.tsv
done
