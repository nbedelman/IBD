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
slimTemplate=$BASEDIR/code/introgression_Human_sexdiff.template.slim
workDir=$BASEDIR/sexDiff_multiParTrial
numReps=10
outBase=sexDiff_multiParTrial

## define changing variables ###
L=$(echo 1000) #Length (number of loci. Would need new recombination maps to change this)
N=$(echo 100000)
s=$(echo 0.4)
hyb_frac=$(echo 0.1 0.2 0.4)
MR=("'$BASEDIR/data/linkage_data_male.human.txt'" "'$BASEDIR/data/linkage_data_male.fly.txt'")
FR=("'$BASEDIR/data/linkage_data_female.human.txt'" "'$BASEDIR/data/linkage_data_female.fly.txt'")
rLabel=('Human' 'Fly')

### run code ###
mkdir -p $workDir

cd $workDir

#run SLIM for specified parameters
for length in $L
  do for num in $N
    do for sel in $s
      do for frac in $hyb_frac
        do for rec in 0 1
          do for gens in $numGens
            do varString=$(echo "-d" L=$length "-d" N=$num "-d" s=$sel "-d" hyb_frac=$frac "-d" MR=$(printf '%s' ${MR[rec]}) "-d" FR=$(printf '%s' ${FR[rec]}) "-d" numGens=$gens)
              echo $varString
              varName=h$frac.sp${rLabel[rec]}
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
