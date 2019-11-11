#!/usr/bin/env python

#for the output files that only have block lengths, not mutation IDs
import sys

inFile=sys.argv[1]
outFile=sys.argv[2]
repNum=int(sys.argv[3])



def getBlockDistribution(inFile):
    blockFile=open(inFile,"r")
    blockDict={}
    chromNum=1
    for line in blockFile:
        try:
            if "gen" in line:
                gen=int(line.split()[1])
                blockDict[gen]=[[],[],[]] #for each generation, we'll have a list of all block lengths, a list of number of blocks in each individual, and a list of number of introgressed alleles in each individual.
            elif chromNum==1:
                individual=list(map(int,line.split()))
                chromNum=2
            else:
                individual+=list(map(int,line.split()))
                blockDict[gen][0]+=individual
                blockDict[gen][1].append(len(individual))
                blockDict[gen][2].append(sum(individual))
                chromNum=1
        except IndexError:
            pass
    blockFile.close()
    return(blockDict)

def getMeanAndVariance(aList):
    # calculate mean
    m = float(sum(aList)) / len(aList)
    # calculate variance using a list comprehension
    var_res = float(sum((xi - m) ** 2 for xi in aList)) / len(aList)
    return([m,var_res])

def summarizeBlockDistribution(inFile,outFile, repNum):
    '''report mean and variance of block length, mean and variance of squared block length
    mean and variance of blocks per individual, mean and variance of introgressed alleles per individual'''
    blockDict=getBlockDistribution(inFile)
    o=open(outFile,"w")
    o.write('''replicate\tgeneration\tmeanBlockLength\tvarBlockLength\tmeanSquaredBlockLength\tvarSquaredBlockLength\tmeanNumBlocks\tvarNumBlocks\tmeanNumAlleles\tvarNumAlleles\tpropWithHyb\n''')
    for k in blockDict.keys():
        lenRes=getMeanAndVariance(blockDict[k][0])
        sqLen=[i**2 for i in blockDict[k][0]]
        sqLenRes=getMeanAndVariance(sqLen)
        numBlockRes=getMeanAndVariance(blockDict[k][1])
        numAlleleRes=getMeanAndVariance(blockDict[k][2])
        propWithBlocks=sum([ bl!=0 for bl in blockDict[k][1]])/float(len(blockDict[k][1]))
        o.write('''%i\t%i\t%f\t%f\t%f\t%f\t%f\t%f\t%f\t%f\t%f\n''' % (repNum,k,lenRes[0],lenRes[1],sqLenRes[0],sqLenRes[1],numBlockRes[0],numBlockRes[1],numAlleleRes[0],numAlleleRes[1],propWithBlocks))
    o.close()

summarizeBlockDistribution(inFile,outFile,repNum)
