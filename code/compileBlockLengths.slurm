#!/bin/bash

#SBATCH -J compileBlockLengths
#SBATCH -p shared,serial_requeue
#SBATCH --mem=5000
#SBATCH -t 0-05:00
#SBATCH -n 8
#SBATCH -e compileBlockLengths.err
#SBATCH -o compileBlockLengths.out

start=$1
end=$2

for i in $(seq $start $end)
do
  /n/scratchlfs/mallet_lab/edelman/IBD/code/getBlockLengths.py rep$i/blocks.out rep$i/blockLengthSummary.tsv $i
  cat rep$i/blockLengthSummary.tsv >> allBlockLengthSummaries.tsv
done
