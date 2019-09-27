#!/usr/bin/env python

import sys

inFile=sys.argv[1]
outFile=sys.argv[2]

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

def getBlockDistribution(inFile,outFile):
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
            o.write('''%i\t%i\n''' % (k,length))
    blockFile.close()
    o.close()

getBlockDistribution(inFile,outFile)
