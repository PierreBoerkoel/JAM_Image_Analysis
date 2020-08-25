remove(list=ls())

mytablepath = 'C:/Users/Sieun/Desktop/Ch3/Measurements'

# load both fitc and fitcn
param_name <- 'cy3per_fitc'; myylim = c(0,55); myylabel <- 'cy3 colocalized with fitc (%)'
labeltable <- read.csv(paste0(mytablepath,'/ALL_labeltable.csv'))
colnames(labeltable) <- c('Label','Subject','Dx','Region')
param <- read.csv(paste0(mytablepath,'/ALL_',param_name,'.csv'))
colnames(param) <- c('RNFL','GCL','IPL','INL','OPL','ONL')
clcol <- matrix(rep('fitc', each=nrow(param)), nrow=nrow(param)); colnames(clcol) <- 'cy3_colocalization'
data_wide1 = cbind(labeltable,clcol,param); 

# Remove Outliers
source('C:/Users/Sieun/Desktop/Ch3/removeOutliers_ch3.R')
data_wide_clean1 <- removeOutliers_ch3(data_wide1,'GFAP','Normal','C'); 
mytmp <- removeOutliers_ch3(data_wide1,'GFAP','Normal','P'); data_wide_clean1 = rbind(data_wide_clean1, mytmp); 
mytmp <- removeOutliers_ch3(data_wide1,'GFAP','AD','C'); data_wide_clean1 = rbind(data_wide_clean1, mytmp); 
mytmp <- removeOutliers_ch3(data_wide1,'GFAP','AD','P'); data_wide_clean1 = rbind(data_wide_clean1, mytmp); 
mytmp <- removeOutliers_ch3(data_wide1,'TUBB','Normal','C'); data_wide_clean1 = rbind(data_wide_clean1, mytmp); 
mytmp <- removeOutliers_ch3(data_wide1,'TUBB','Normal','P'); data_wide_clean1 = rbind(data_wide_clean1, mytmp); 
mytmp <- removeOutliers_ch3(data_wide1,'TUBB','AD','C'); data_wide_clean1 = rbind(data_wide_clean1, mytmp);
mytmp <- removeOutliers_ch3(data_wide1,'TUBB','AD','P'); data_wide_clean1 = rbind(data_wide_clean1, mytmp);

param_name2 <- 'cy3per_fitcn';
param2 <- read.csv(paste0(mytablepath,'/ALL_',param_name2,'.csv'))
colnames(param2) <- c('RNFL','GCL','IPL','INL','OPL','ONL')
clcol2 <- matrix(rep('fitcn', each=nrow(param2)), nrow=nrow(param2)); colnames(clcol2) <- 'cy3_colocalization'
data_wide2 = cbind(labeltable,clcol2,param2); 

# Remove Outliers
source('C:/Users/Sieun/Desktop/Ch3/removeOutliers_ch3.R')
data_wide_clean2 <- removeOutliers_ch3(data_wide2,'GFAP','Normal','C'); 
mytmp <- removeOutliers_ch3(data_wide2,'GFAP','Normal','P'); data_wide_clean2 = rbind(data_wide_clean2, mytmp); 
mytmp <- removeOutliers_ch3(data_wide2,'GFAP','AD','C'); data_wide_clean2 = rbind(data_wide_clean2, mytmp); 
mytmp <- removeOutliers_ch3(data_wide2,'GFAP','AD','P'); data_wide_clean2 = rbind(data_wide_clean2, mytmp); 
mytmp <- removeOutliers_ch3(data_wide2,'TUBB','Normal','C'); data_wide_clean2 = rbind(data_wide_clean2, mytmp); 
mytmp <- removeOutliers_ch3(data_wide2,'TUBB','Normal','P'); data_wide_clean2 = rbind(data_wide_clean2, mytmp); 
mytmp <- removeOutliers_ch3(data_wide2,'TUBB','AD','C'); data_wide_clean2 = rbind(data_wide_clean2, mytmp);
mytmp <- removeOutliers_ch3(data_wide2,'TUBB','AD','P'); data_wide_clean2 = rbind(data_wide_clean2, mytmp);

data_wide_clean <- rbind(data_wide_clean1, data_wide_clean2)


#install.packages('reshape2')
library(reshape2)
# Melt and remove NA
data_clean <- melt(data_wide_clean, measure.vars = 6:11)
data_clean <- data_clean[!(data_clean$value=='NA'|data_clean$value=='NaN'),]
names(data_clean)[6]<-"Layer"  
names(data_clean)[7]<-"Value" # Long format
data_clean$Value <- as.numeric(data_clean$Value)
data <- data_clean

# Plot
library(ggpubr)
#install.packages("viridis")  # Install

png(filename = paste0(mytablepath,'/coloc_GFAP_Normal.png')) 

p <- ggbarplot(data[data$Label=='GFAP'&data$Dx=='Normal',], x = "Layer", y="Value", 
               order= c('RNFL','GCL','IPL','INL','OPL','ONL'), 
               color="cy3_colocalization", facet.by = "Region",  ylab=myylabel, position = position_dodge(0.8),
               ylim=myylim, add = c("mean_se"), palette="Set1")
p + stat_compare_means(aes(group = cy3_colocalization), method = "wilcox.test", label = "p.signif", label.y=c(myylim[2]*0.99))

dev.off()

png(filename = paste0(mytablepath,'/coloc_GFAP_AD.png')) 

p <- ggbarplot(data[data$Label=='GFAP'&data$Dx=='AD',], x = "Layer", y="Value", 
               order= c('RNFL','GCL','IPL','INL','OPL','ONL'), 
               color="cy3_colocalization", facet.by = "Region",  ylab=myylabel, position = position_dodge(0.8),
               ylim=myylim, add = c("mean_se"), palette="Set1")
p + stat_compare_means(aes(group = cy3_colocalization), method = "wilcox.test", label = "p.signif", label.y=c(myylim[2]*0.99))

dev.off()

png(filename = paste0(mytablepath,'/coloc_TUBB_Normal.png')) 

p <- ggbarplot(data[data$Label=='TUBB'&data$Dx=='Normal',], x = "Layer", y="Value", 
               order= c('RNFL','GCL','IPL','INL','OPL','ONL'), 
               color="cy3_colocalization", facet.by = "Region",  ylab=myylabel, position = position_dodge(0.8),
               ylim=myylim, add = c("mean_se"), palette="Set1")
p + stat_compare_means(aes(group = cy3_colocalization), method = "wilcox.test", label = "p.signif", label.y=c(myylim[2]*0.99))

dev.off()

png(filename = paste0(mytablepath,'/coloc_TUBB_AD.png')) 

p <- ggbarplot(data[data$Label=='TUBB'&data$Dx=='AD',], x = "Layer", y="Value", 
               order= c('RNFL','GCL','IPL','INL','OPL','ONL'), 
               color="cy3_colocalization", facet.by = "Region",  ylab=myylabel, position = position_dodge(0.8),
               ylim=myylim, add = c("mean_se"), palette="Set1")
p + stat_compare_means(aes(group = cy3_colocalization), method = "wilcox.test", label = "p.signif", label.y=c(myylim[2]*0.99))

dev.off()
