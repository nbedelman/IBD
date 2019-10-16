#!/bin/bash

#SBATCH -J runSLIM
#SBATCH -p shared,serial_requeue
#SBATCH -n 1
#SBATCH --mem=10000
#SBATCH -t 3-00:00
#SBATCH -e runSlim.err
#SBATCH -o runSlim.out

slimCode=$1
varString=$2
startRep=$3
endRep=$4

for rep in $(seq $startRep $endRep)
  do mkdir rep$rep
  cd rep$rep
  /n/mallet_lab/edelman/software/SLiM_build/slim $varString $slimCode
  /n/scratchlfs/mallet_lab/edelman/IBD/code/getBlockLengths.py blocks.out blockLengths.tsv $rep
  cat blockLengths.tsv >> ../allBlockLengths.tsv
  cd ..
  done
