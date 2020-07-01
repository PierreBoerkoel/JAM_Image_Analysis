remove(list=ls())

# load data 
mytablepath = 'C:/Users/Sieun/Desktop/Ch3/Measurements'
param_name <- 'cy3norm'; myylim = c(0,5); myylabel <- 'Layer-wise normalized % of A?? immunoreactivity'
# param_name <- 'fitcnorm'; myylim = c(0,45); myylabel <- 'fitc (%)'
# param_name <- 'cy3per_fitc'; myylim = c(0,55); myylabel <- 'cy3 colocalized with fitc (%)'
# param_name <- 'cy3per_fitcn'
# param_name <- 'cy3per_fitcratio'
# param_name <- 'thickum'; myylim = c(0,85); myylabel <- 'thickness (um)'

# label columns
labeltable <- read.csv(paste0(mytablepath,'/ALL_labeltable.csv'))
colnames(labeltable) <- c('Label','Subject','Dx','Region')
param <- read.csv(paste0(mytablepath,'/ALL_',param_name,'.csv'))
colnames(param) <- c('RNFL','GCL','IPL','INL','OPL','ONL')
data_wide = cbind(labeltable,param)

# Remove Outliers
source('C:/Users/Sieun/Desktop/Ch3/removeOutliers_ch3.R')
data_wide_clean <- removeOutliers_ch3(data_wide,'GFAP','Normal','C'); 
mytmp <- removeOutliers_ch3(data_wide,'GFAP','Normal','P'); data_wide_clean = rbind(data_wide_clean, mytmp); 
mytmp <- removeOutliers_ch3(data_wide,'GFAP','AD','C'); data_wide_clean = rbind(data_wide_clean, mytmp); 
mytmp <- removeOutliers_ch3(data_wide,'GFAP','AD','P'); data_wide_clean = rbind(data_wide_clean, mytmp); 
mytmp <- removeOutliers_ch3(data_wide,'TUBB','Normal','C'); data_wide_clean = rbind(data_wide_clean, mytmp); 
mytmp <- removeOutliers_ch3(data_wide,'TUBB','Normal','P'); data_wide_clean = rbind(data_wide_clean, mytmp); 
mytmp <- removeOutliers_ch3(data_wide,'TUBB','AD','C'); data_wide_clean = rbind(data_wide_clean, mytmp);
mytmp <- removeOutliers_ch3(data_wide,'TUBB','AD','P'); data_wide_clean = rbind(data_wide_clean, mytmp);

#install.packages('reshape2')
library(reshape2)
# Melt and remove NA
data_clean <- melt(data_wide_clean, measure.vars = 5:10)
data_clean <- data_clean[!data_clean$value=='NA',]
names(data_clean)[5]<-"Layer"  
names(data_clean)[6]<-"Value" # Long format
data_clean$Value <- as.numeric(data_clean$Value)
data <- data_clean

# Plot
library(ggpubr)
#install.packages("viridis")  # Install
library("viridis")     

# save png
#png(filename = paste0(mytablepath,'/',param_name,'_GFAP.png')) 

p <- ggboxplot(data[data$Label=='GFAP',], x = "Layer", y="Value", order= c('RNFL','GCL','IPL','INL','OPL','ONL'), color="Dx",
               facet.by = "Region", labelOutliers='TRUE',add="jitter", ylim=myylim, ylab=myylabel, outlier.shape=NA)

#dev.off()

