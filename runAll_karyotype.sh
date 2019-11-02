#!/bin/bash

#### run replicate slim simulations across an array of parameters
#### make new directory for each parameter set. Within that directory, new directory for each
#### replicate run. Then need to collect results.


######## karyotype #########
### define constant variables ###
BASEDIR=$PWD
slimTemplate=$BASEDIR/code/karyotypes.slim
workDir=$BASEDIR/karyotype
numReps=10000
outBase=karyoptype
numGens=200

## define changing variables ###
numChroms=$(echo 2 5 20 100)


### run code for all "middle" chromosomal values ###
mkdir -p $workDir

cd $workDir

run SLIM for specified parameters
for k in $numChroms
  do
    startRep=1
    let counter="1000 / $k - 1"
    let endRep="$startRep + $counter"
    varString=$(echo "-d" K=$k)
    echo $varString
    varName=$k\_chroms
    echo $varName >> variableNames.txt
    mkdir $varName
    cd $varName
    while [ $endRep -le $numReps ];
    do
      echo $startRep $endRep $counter
      sbatch $BASEDIR/code/runSLIM.specReps.slurm $slimTemplate "$varString" slimOut.$varName.out $numGens $startRep $endRep
      let startRep="$endRep + 1"
      let endRep="$startRep + $counter"
    done
    cd $workDir
  done

#now, do separate runs for numChroms=1 and 1000 since they have different slim code
startRep=1
counter=1
k=1
let endRep="$startRep + $counter"
varName=$k\_chroms
echo $varName >> variableNames.txt
mkdir $varName
cd $varName
while [ $endRep -le $numReps ];
do
  echo $startRep $endRep $counter
  sbatch $BASEDIR/code/runSLIM.specReps.slurm $BASEDIR/code/karyotypes_1chrom.slim "-d N=100000" slimOut.$varName.out $numGens $startRep $endRep
  let startRep="$endRep + 1"
  let endRep="$startRep + $counter"
done
cd $workDir

startRep=1
counter=1
k=1000
let endRep="$startRep + $counter"
varName=$k\_chroms
echo $varName >> variableNames.txt
mkdir $varName
cd $varName
while [ $endRep -le $numReps ];
do
  echo $startRep $endRep $counter
  sbatch $BASEDIR/code/runSLIM.specReps.slurm $BASEDIR/code/karyotypes_allunlinked.slim "-d N=100000" slimOut.$varName.out $numGens $startRep $endRep
  let startRep="$endRep + 1"
  let endRep="$startRep + $counter"
done
