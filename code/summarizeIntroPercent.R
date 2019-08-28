#!/usr/bin/env Rscript

library(ggplot2)
library(data.table)
library(optparse)

##### read options ####

option_list = list(
  make_option(c("-v", "--variableList"), type="character",
              help="comma-separated list of variables to compare. i.e. human,fly"),
  make_option(c("-d","--directoryList"), type="character",
              help="comma-separated list of directories in same order as variables. i.e. humDir,flyDir"),
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

###### parse args ####
opt_parser = OptionParser(option_list=option_list, usage = "R CMD summarizeIntroPercent.R -v variableList -d directoryList -o outputBase");
opt = parse_args(opt_parser);

##### read in files #####
vars <- unlist(strsplit(opt$variableList,","))
dirs <- unlist(strsplit(opt$directoryList,","))

allRunsList <- list()

for (dirType in seq(1,length(dirs))){
  repList <- c()
  files <- c()
  for (d in list.dirs(path=dirs[dirType])){files <- c(files,(list.files(path=d,pattern="*.percentages.tsv",full.names = TRUE)))}
  for (i in seq(1,length(files))){
    thisTable <- read.table(files[i])
    repList <- c(repList, thisTable)
  }
  fullDirType <- as.data.table(cbindlist(repList))
  fullDirType[,`:=` (variable=vars[dirType], generation=seq(1,nrow(fullDirType)))]
  allRunsList <- append(allRunsList,list(fullDirType))
}

allRunsTable <- as.data.table(rbindlist(allRunsList))
allRunsTable[,generationMean:=rowMeans(allRunsTable[,1:(ncol(allRunsTable)-2)])]
allRunsTable[,generationSD:=apply(allRunsTable[,1:(ncol(allRunsTable)-3)],1,sd)]

write.csv(file=paste0(opt$outBase,".allRunsTable.csv") , x=allRunsTable, quote=F, row.names=F)

simplePlot <- ggplot(data=allRunsTable) +
  geom_point(aes(x=generation,y=generationMean,col=variable))+
  geom_line(aes(x=generation,y=generationMean,col=variable))+
  geom_errorbar(aes(x=generation,ymin=generationMean-generationSD,ymax=generationMean+generationSD,col=variable))+
  scale_y_log10()+
  scale_color_brewer(palette = "Paired")+
  labs(x="Generation",y="Mean Introgressed Ancestry")
simplePlot
ggsave(filename = paste0(opt$outBase,".introProp.pdf"),simplePlot, height=10, width=15)
