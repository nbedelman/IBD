#!/bin/bash

#SBATCH -J runSLIM
#SBATCH -p shared
#SBATCH -n 1
#SBATCH --mem=50000
#SBATCH -t 1-00:00
#SBATCH -e runSlim.err
#SBATCH -o runSlim.out

slimCode=$1
varString=$2
outFile=$3
numGens=$4
startRep=$5
endRep=$6

for rep in $(seq $startRep $endRep)
  do mkdir rep$rep
  cd rep$rep
  /n/mallet_lab/edelman/software/SLiM_build/slim $varString $slimCode > $outFile
  tail -n $numGens $outFile > $(basename $outFile .out).percentages.tsv
  awk -v r=$rep '{print r "\t" NR "\t" $0}' $(basename $outFile .out).percentages.tsv >> ../allRepSummary.out
  cd ..
  done
