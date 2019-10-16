#!/bin/bash

#### run replicate slim simulations across an array of parameters
#### make new directory for each parameter set. Within that directory, new directory for each
#### replicate run. Then need to collect results.

#### setup environment
module load centos6/0.0.1-fasrc01 R/3.4.1-fasrc01
export R_LIBS_USER=$HOME/apps/R:$R_LIBS_USER

######## SEX DIFFERENCE #########
### define constant variables ###
BASEDIR=$PWD
slimTemplate=$BASEDIR/code/introgression_constRecRate.slim
workDir=$BASEDIR/constantRecMap_ratePopChrom
numReps=10
outBase=constantRecMap_ratePopChrom

L=1000 #Length (number of loci.
s=0.4
baseGenSize=1e9
hyb_frac=0.1

## define changing variables ###
baseRate=$(echo 1e-7 1e-8 1e-9 1e-10)
N=$(echo 1000 10000 100000 1000000)
numChroms=$(echo 1 5 10 20 30 100 1000)

### run code ###
mkdir -p $workDir

cd $workDir

#run SLIM for specified parameters
for rate in $baseRate
  do for num in $N
    do for chr in $numChroms
            do varString=$(echo "-d" L=$L "-d" s=$s "-d" baseGenSize=$baseGenSize "-d" hyb_frac=$hyb_frac \
            "-d" baseRate=$rate "-d" N=$num "-d" numChroms=$chr)
              echo $varString
              varName=$rate\_$num\_$chr
              echo $varName >> variableNames.txt
              mkdir $varName
              cd $varName
              for rep in $(seq 1 $numReps)
                do mkdir rep$rep
                cd rep$rep
                sbatch $BASEDIR/code/runSLIM.slurm $slimTemplate "$varString" slimOut.$varName.rep$rep.out
                cd $workDir/$varName
                done
              cd $workDir
            done
        done
      done
    done
  done
done


#collect results and graph output
#run this after everything is done
#vars=$(basename $(tr '\n' ',' < variableNames.txt) ,)
#R CMD $BASEDIR/code/summarizeIntroPercent.R -v $vars -d $vars -o $outBase
