#!/usr/bin/env python

import sys

inFile=sys.argv[1]
outFile=sys.argv[2]
repNum=int(sys.argv[3])

def getBlockLengths(listOfPositions):
    blocks=[]
    counter=1
    current=""
    for pos in listOfPositions:
        try:
            if int(pos)==current+1:
                counter+=1
                current=int(pos)
            elif current!="":
                blocks.append(counter)
                counter=1
                current=int(pos)
        except TypeError:
            current=int(pos)
    if current!="":
        blocks.append(counter)
    return(blocks)

def getBlockDistribution(inFile,outFile, repNum):
    blockFile=open(inFile,"r")
    blockDict={}
    for line in blockFile:
        try:
            if "gen" in line:
                gen=int(line.split()[1])
                blockDict[gen]=[]
            else:
                blockDict[gen]+=getBlockLengths(line.split())
        except IndexError:
            pass
    o=open(outFile,"w")
    for k in blockDict.keys():
        for length in blockDict[k]:
            o.write('''%i\t%i\t%i\n''' % (repNum,k,length))
    blockFile.close()
    o.close()

getBlockDistribution(inFile,outFile,repNum)
