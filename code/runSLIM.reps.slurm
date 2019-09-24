#!/bin/bash

#SBATCH -J runSLIM
#SBATCH -p shared,general,serial_requeue
#SBATCH -n 1
#SBATCH --mem=10000
#SBATCH -t 0-02:00
#SBATCH -e runSlim.err
#SBATCH -o runSlum.out

slimCode=$1
varString=$2
outFile=$3
numGens=$4
numReps=$5

for rep in $(seq 1 $numReps)
  do mkdir rep$rep
  cd rep$rep
  /n/mallet_lab/edelman/software/SLiM_build/slim $varString $slimCode > $outFile
  tail -n $numGens $outFile > $(basename $outFile .out).percentages.tsv
  cd ..
  done
