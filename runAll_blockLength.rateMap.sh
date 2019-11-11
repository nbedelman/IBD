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
slimTemplate=$BASEDIR/code/blockLengthDistribution.slim
workDir=$BASEDIR/blockLengthDistribution_rate1e3_frac1_fly_IBDblocks
numReps=100
outBase=randomRecRate

L=1000  #Length (number of loci.
s=0.4
hyb_frac=1.0
N=100000
numChroms=1
counter=0
maleRate=data/linkage_data_male.fly.txt #linkage_data_male.human.txt
femaleRate=data/linkage_data_female.fly.txt #linkage_data_female.human.txt
### run code ###
mkdir -p $workDir

cd $workDir

#run SLIM for specified parameters
startRep=1
let endRep="$startRep + $counter"
while [ $endRep -le $numReps ]
do
    varString=$(echo "-d" L=$L "-d" s=$s "-d" hyb_frac=$hyb_frac \
     "-d" N=$N "-d" numChroms=$numChroms "-d" MR=$maleRate "-d" FR=$femaleRate)
      echo $varString
      echo $startRep $endRep $counter
      sbatch $BASEDIR/code/runSLIM.blockLength.slurm $slimTemplate "$varString" $startRep $endRep
      let startRep="$endRep + 1"
      let endRep="$startRep + $counter"
done

#compile results
#run this separately, after previous code is done - added to the actual script, so no longer necessary for IBD block lengths.
cd $workDir
startRep=1
counter=2
let endRep="$startRep + $counter"
while [ $endRep -le $numReps ]
do
sbatch ../code/compileBlockLengths.slurm $startRep $endRep
let startRep="$endRep + 1"
let endRep="$startRep + $counter"
done
