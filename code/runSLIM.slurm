#!/bin/bash

#SBATCH -J runSLIM
#SBATCH -p shared,general,serial_requeue
#SBATCH -n 1
#SBATCH --mem=1000
#SBATCH -t 0-01:00
#SBATCH -e runSlim.err
#SBATCH -o runSlum.out

slimCode=$1
varString=$2
outFile=$3

/n/mallet_lab/edelman/software/SLiM_build/slim $varString $slimCode > $outFile
tail -n 2000 $outFile > $(basename $outFile .out).percentages.tsv
