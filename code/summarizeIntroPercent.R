#!/usr/bin/env Rscript

library(ggplot2)
library(data.table)
library(optparse)
library(pbapply)

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

#### define formulas ####
cbindlist <- function(list) { ## function from https://www.rdocumentation.org/packages/mvmeta/versions/0.2.4/topics/cbindlist
  n <- length(list)
  res <- NULL
  for (i in seq(n)) res <- cbind(res, list[[i]])
  return(res)
}

nzmean <- function(x) {
  zvals <- x==0
  if (all(zvals)) 0 else mean(x[!zvals], na.rm=T)
}

###### parse args ####
opt_parser = OptionParser(option_list=option_list, usage = "R CMD summarizeIntroPercent.R -v variableList -d directoryList -o outputBase");
opt = parse_args(opt_parser);

##### read in files #####
vars <- unlist(strsplit(opt$variableList,","))
dirs <- unlist(strsplit(opt$directoryList,","))
keys <- unlist(strsplit(opt$variableKey,","))
outBase <- opt$outBase

#vars <- c("0.01_250_10","0.01_250_50","0.10_2500_10","0.10_2500_50","1.00_25000_10","1.00_25000_50","10.00_250000_10","10.00_250000_50")
vars <- c("0.10_2500_10","0.10_2500_50","0.01_250_10","0.01_250_50","1.00_25000_10","1.00_25000_50")
keys <- c("rho","popSize","chroms")
dirs <- vars

allRunsList <- pbsapply(X=seq(1,length(dirs)), FUN=function(x){
  repList <- c()
  files <- unlist(lapply(X=list.dirs(path=dirs[x]), FUN=function(y) {list.files(path=y,pattern="*.percentages.tsv",full.names = TRUE)}))
  repList <- sapply(X=seq(1,length(files)), FUN=function(z){
    read.table(files[z])
  })
  indVariables <- unlist(strsplit(vars[x],"_"))
  fullDirType <- as.data.table(cbindlist(repList))
  fullDirType[,`:=` (variable=vars[x], generation=seq(1,nrow(fullDirType)))]
  for (v in seq(1,length(indVariables))) {
    fullDirType[,keys[v]:= indVariables[v]]
  }
  return(list(fullDirType))
}
)

allRunsTable <- as.data.table(rbindlist(allRunsList, use.names=T, fill=T))
allRunsTable[,generationMean:=rowMeans(allRunsTable[,1:(ncol(allRunsTable)-(2+length(keys)))], na.rm=T)]
allRunsTable[,generationSD:=apply(X=allRunsTable[,1:(ncol(allRunsTable)-(3+length(keys)))],1,FUN=function(x) sd(x,na.rm=T))]
allRunsTable[,generationSEM:=generationSD/sqrt(ncol(allRunsTable)-(4+length(keys)))]
allRunsTable[,nonZeroMean:=apply(allRunsTable[,1:(ncol(allRunsTable)-(5+length(keys)))], 1,nzmean)]
allRunsTable[,chroms:=factor(chroms,levels=c(1,5,10,50,100))]
allRunsTable[,slope:=generationMean/shift(generationMean,1)]
allRunsTable[,nzSlope:=nonZeroMean/shift(nonZeroMean,1)]

write.csv(file=paste0("hillRobertson",".2Kgens.allRunsTable.csv") , x=allRunsTable, quote=F, row.names=F)

allRunsTable[,ymin:=ifelse(generationMean-generationSEM < 0,0,generationMean-generationSEM)]

simplePlot <- ggplot(data=allRunsTable) +
  # geom_point(aes(x=generation,y=generationMean,col=popSize))+
  geom_line(aes(x=generation,y=generationMean,col=rho))+
  geom_ribbon(aes(x=generation,ymin=generationMean-generationSEM,ymax=generationMean+generationSEM,fill=rho),alpha=.8)+
  facet_wrap(facets=~chroms) + #,scales = "free_y")+
  scale_y_log10()+
  #xlim(c(0,200))+
  #scale_color_brewer(palette = "Paired")+
  labs(x="Generation",y="Mean Introgressed Ancestry")
simplePlot
ggsave(filename = paste0("hillRobertson.SEM",".means.2Kgens.introProp.pdf"),simplePlot, height=10, width=15)

slopePlot <- ggplot(data=allRunsTable[generation != c(1,2000)]) +
  geom_line(aes(x=generation,y=slope,col=rho),n=2000/2)+
  facet_wrap(facets=~chroms)+
  ylim(c(0.975,1))+
  #scale_y_log10(limits=c(0.975,1))+
  labs(y="Introgression Fraction(t)/Introgression Fraction(t-1)")#+
#geom_hline(yintercept=0.9964)
slopePlot             
ggsave(filename = paste0("hillRobertson",".slope.2Kgens.zoom.introProp.pdf"),slopePlot, height=10, width=15)

