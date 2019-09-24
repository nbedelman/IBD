#!/usr/bin/env Rscript

library(ggplot2)
library(data.table)
library(optparse)
library(pbapply)
library(dplyr)
library(RColorBrewer)

##### read options ####

option_list = list(
  make_option(c("-v", "--variableList"), type="character",
              help="comma-separated list of variable combinations to compare. i.e. 1e-9_1000_10"),
  make_option(c("-d","--directoryList"), type="character",
              help="comma-separated list of directories in same order as variables. i.e. humDir,flyDir"),
  make_option(c("-k","--variableKey"), type="character",
              help="comma-separated list of variables in named order. i.e. rate,popSize,chroms"),
  make_option(c("-o", "--outBase"), type="character", default="out",
              help="analysis output base name [default= %default]", metavar="file path")#,
);


####### Define functions 
joinList <- function(list) { ## function from https://www.rdocumentation.org/packages/mvmeta/versions/0.2.4/topics/cbindlist
  n <- length(list)
  res <- list[1][[1]]
  for (i in seq(2,n)) res <- full_join(res, list[i][[1]], by=c("Group.1", "Group.2", "Group.3"), suffix = c("", i))
  return(res)
}

getRateProportion <- function(rateList,rate,constant){
  proportion <- which(rateList==rate)*constant
}

###### parse args ####
opt_parser = OptionParser(option_list=option_list, usage = "R CMD summarizeIntroPercent.R -v variableList -d directoryList -o outputBase");
opt = parse_args(opt_parser);

##### read in files #####
vars <- unlist(strsplit(opt$variableList,","))
dirs <- unlist(strsplit(opt$directoryList,","))
keys <- unlist(strsplit(opt$variableKey,","))
outBase <- opt$outBase

vars <- c("250_10", "2500_10", "25000_10")
keys <- c("popSize","chroms")
dirs <- vars

allRunsList <- pbsapply(X=seq(1,length(dirs)), FUN=function(x){
  repList <- pbsapply(X=list.dirs(path=dirs[x])[grepl("rep",list.dirs(path=dirs[x]))], FUN=function(z){
    genomeInfo <- fread(paste0(z,"/genomeInfo.out") , col.names =c("position","recRate","chromName","chromSize"))
    genomeInfo[,position:=position+1]
    tab <- read.table(paste0(z,"/frequencies.out"), header=F, col.names=c("position","frequency","generation"))
    fullInfo <- right_join(genomeInfo,tab,by="position")
    fullTable <- aggregate(fullInfo$frequency,by=list(fullInfo$recRate,fullInfo$chromSize,fullInfo$generation), FUN="sum")
    return(list(fullTable))
  })
  fullDirType <- as.data.table(joinList(repList))
  indVariables <- unlist(strsplit(vars[x],"_"))
  fullDirType[,variable:=vars[x]]
  for (v in seq(1,length(indVariables))) {
    fullDirType[,keys[v]:= indVariables[v]]
  }
  return(list(fullDirType))
}
)

allRunsTable <- as.data.table(rbindlist(allRunsList, use.names=T, fill=T))
allRunsTable[,generationMean:=rowMeans(allRunsTable[,4:(ncol(allRunsTable)-(2+length(keys)))], na.rm=T)]
allRunsTable[,generationSD:=apply(X=allRunsTable[,4:(ncol(allRunsTable)-(3+length(keys)))],1,FUN=function(x) sd(x,na.rm=T))]
allRunsTable[,generationSEM:=generationSD/sqrt(ncol(allRunsTable)-(4+length(keys)))]
allRunsTable[,chroms:=factor(chroms,levels=c(1,5,10,50,100))]

rates <- unique(allRunsTable$Group.1)
constant <- 1000/sum(1:10)
allRunsTable[,numSites:=sapply(allRunsTable$Group.1, FUN=function(x) (11-which(rates==x))*constant)]

write.csv(file=paste0("randomRecRate",".2Kgens.allRunsTable.csv") , x=allRunsTable, quote=F, row.names=F)


#### generate slope table #####
allSlopes <- sapply(unique(allRunsTable$Group.3), FUN=function(gen){
  oneModel <- lm(generationMean/Group.2 ~ Group.1, data=subset(allRunsTable, Group.3==gen & popSize==250 & Group.1 != 0.5))
  oneSlope <- oneModel$coefficients[2]
  rsquare <- summary(oneModel)$r.squared
  return(list(oneSlope,rsquare))
})
slopeFrame <- data.table(gens=unique(allRunsTable$Group.3), slopes=unlist(t(allSlopes)[,1]),rsquare=unlist(t(allSlopes)[,2]))


####### plotting #####
colourCount = length(unique(allRunsTable$Group.3))
getPalette = colorRampPalette(brewer.pal(8,"Blues"))

chromSizeVsFreq <- ggplot(data=allRunsTable[Group.1 !=0.5], aes(x=Group.1,y=generationMean/numSites))+
  geom_point()+
  geom_line(aes(col=factor(Group.3)))+
  scale_color_manual(values = getPalette(colourCount))+
  facet_wrap(facets=~popSize)+
  labs(col = "Generation", x="Recombination Rate", y="Percent Hybrid Ancestry")
chromSizeVsFreq
ggsave(filename = paste0("randomRecRate","introPropByRate.pdf"),chromSizeVsFreq, height=10, width=15)

GenVsFreq <- ggplot(data=allRunsTable[Group.1 !=0.5 & popSize ==25000], aes(x=Group.3,y=generationMean/numSites))+
  geom_point()+
  geom_line(aes(col=factor(Group.1)))+
  scale_color_manual(values = getPalette(length(unique(allRunsTable$Group.1))))+
  scale_y_log10()+
  #facet_wrap(facets=~popSize)+
  labs(x="Generation", y="Percent Hybrid Ancestry")
GenVsFreq
ggsave(filename = paste0("randomRecRate","introPropByGeneration.pdf"),GenVsFreq, height=10, width=15)



ggsave(filename = paste0("hillRobertson",".slope.2Kgens.zoom.introProp.pdf"),slopePlot, height=10, width=15)

