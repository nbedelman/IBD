#!/bin/bash

##test the expectation of hill-roberston interference
##expectation: populations are less efficient at removing deleterious alleles when 4Nr < 1
##keep mutation map (number of chromosomes and fine-scale recomb rate) constant, but change population size
##symmetric, 2 orders of magnitude around 4Nr=1

#### setup environment
#module load centos6/0.0.1-fasrc01 R/3.4.1-fasrc01
#export R_LIBS_USER=$HOME/apps/R:$R_LIBS_USER

######## SEX DIFFERENCE #########
### define constant variables ###
BASEDIR=$PWD
slimTemplate=$BASEDIR/code/variedChromSizes.slim
workDir=$BASEDIR/variedChromSize
numReps=1000
outBase=variedChromSize
numGens=100

L=1000  #Length (number of loci.
s=0.4
hyb_frac=0.4

## define changing variables ###

N=$(echo 250 2500 25000)
numChroms=$(echo 10 50)



#be smart about number of serial jobs based on expected time to completion when N=250, can do all runs in serial; when N=2.5M, should only do 2 per submission

### run code ###
mkdir -p $workDir

cd $workDir

#run SLIM for specified parameters

for num in $N
  do
  let counter="25000000 / $num - 1" #re-ran code with this and increased memory for N=2.5M
  #let counter="2500000 / $num - 1"
  if [ $counter -ge $numReps ]
  then let counter="$numReps - 1"
  fi
  for chr in $numChroms
    do
    startRep=1
    let endRep="$startRep + $counter"
    varString=$(echo "-d" L=$L "-d" s=$s "-d" hyb_frac=$hyb_frac \
     "-d" N=$num "-d" numChroms=$chr)
      echo $varString
      varName=$num\_$chr
      echo $varName >> variableNames.txt
      mkdir $varName
      cd $varName
      while [ $endRep -le $numReps ];
        do
          echo $startRep $endRep $counter
          sbatch $BASEDIR/code/runSLIM.specReps.slurm $slimTemplate "$varString" slimOut.$varName.out $numGens $startRep $endRep
        let startRep="$endRep + 1"
        let endRep="$startRep + $counter"
        cd $workDir/$varName
        done
        cd $workDir
    done
done
