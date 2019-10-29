#!/bin/bash

#SBATCH -J runSLIM
#SBATCH -p shared
#SBATCH -n 1
#SBATCH --mem=10000
#SBATCH -t 0-10:00
#SBATCH -e runSlim.err
#SBATCH -o runSlim.out

slimCode=$1
varString=$2
outFile=$3
startRep=$4
endRep=$5
numGens=$6

for rep in $(seq $startRep $endRep)
  do mkdir rep$rep
  cd rep$rep
  /n/mallet_lab/edelman/software/SLiM_build/slim $varString $slimCode > $outFile
  tail -n $numGens > introgressionFraction.txt
  cd ..
  done
