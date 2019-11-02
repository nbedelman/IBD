#!/bin/bash

#SBATCH -J runSLIM
#SBATCH -p shared
#SBATCH -n 1
#SBATCH --mem=50000
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
  /n/scratchlfs/mallet_lab/edelman/IBD/code/getBlockLengths.IBD.py blocks.out IBDBlockLengths.tsv $rep
  cat IBDBlockLengths.tsv >> ../allIBDBlockLengths.tsv
  cd ..
  done
