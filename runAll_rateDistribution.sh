#!/bin/bash

#### run replicate slim simulations across an array of parameters
#### make new directory for each parameter set. Within that directory, new directory for each
#### replicate run. Then need to collect results.

#### setup environment
# module load centos6/0.0.1-fasrc01 R/3.4.1-fasrc01
# export R_LIBS_USER=$HOME/apps/R:$R_LIBS_USER

######## SEX DIFFERENCE #########
### define constant variables ###
BASEDIR=$PWD
slimTemplate=$BASEDIR/code/rateDistribution.slim
workDir=$BASEDIR/rateDistribution
numReps=10000
outBase=constantRecMap_ratePopChrom

L=1000 #Length (number of loci.
s=0.4
hyb_frac=0.2
N=100000
numGens=200

## define changing variables ###
rateFiles=$(ls data/CO_distribution_shift/*)

#setup looping
counter=100

### run code ###
mkdir -p $workDir

cd $workDir

#run SLIM for specified parameters
for rate in $rateFiles
  do
    varString=$(echo "-d" L=$L "-d" s=$s "-d" hyb_frac=$hyb_frac \
    "-d" rateFile="'$BASEDIR/$rate'" "-d" N=$N)
    echo $varString
    rateName=$(basename $rate .txt)
    echo $rateName >> rateNames.txt
    mkdir -p $rateName
    cd $rateName
    startRep=1
    let endRep="$startRep + $counter"
    while [ $endRep -le $numReps ]
      do
      sbatch $BASEDIR/code/runSLIM.rateDistribution.slurm $slimTemplate "$varString" fullOutput.out $startRep $endRep $numGens
      let startRep="$endRep + 1"
      let endRep="$startRep + $counter"
      done
    cd $workDir
  done



#collect results and graph output
#run this after everything is done
#vars=$(basename $(tr '\n' ',' < variableNames.txt) ,)
#R CMD $BASEDIR/code/summarizeIntroPercent.R -v $vars -d $vars -o $outBase
