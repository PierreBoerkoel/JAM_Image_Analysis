remove(list=ls())

mytablepath = '/Users/pierreboerkoel/Desktop/IBA-1'
# param_name <- 'cy3norm'; myylim = c(0,4); myylabel <- 'Layer-wise normalized % Aβ immunoreactivity'
# param_name <- 'fitcnorm'; myylim = c(0,2); myylabel <- 'Layer-wise normalized % IBA-1 immunoreactivity'
# param_name <- 'cy3_and_fitc'; myylim = c(0,0.20); myylabel <- 'Layer-wise normalized % Aβ and IBA-1 immunoreactivity'
param_name <- 'cy3per_fitc'; myylim = c(0,70); myylabel <- 'Layer-wise % Aβ immunoreactivity in an IBA-1 immunoreactive area'

# param_name <- 'cy3per_fitcn'
# param_name <- 'cy3per_fitcratio'
# param_name <- 'thickum'; myylim = c(0,85); myylabel <- 'thickness (um)'

labeltable <- read.csv(paste0(mytablepath,'/ALL_g_labeltable.csv'))
colnames(labeltable) <- c('Label','Subject','Dx','Region')
param <- read.csv(paste0(mytablepath,'/ALL_g_cy3perfitc.csv'))
colnames(param) <- c('RNFL','GCL','IPL','INL','OPL','ONL')
data_wide = cbind(labeltable,param)

# Remove Outliers
source('/Users/pierreboerkoel/git/ADImageAnalysis/JAM_Image_Analysis/r_codes/removeOutliers_ch3.R')
data_wide_clean <- removeOutliers_ch3(data_wide,'IBA-1','Normal','C');
mytmp <- removeOutliers_ch3(data_wide,'IBA-1','Normal','P'); data_wide_clean = rbind(data_wide_clean, mytmp);
mytmp <- removeOutliers_ch3(data_wide,'IBA-1','AD','C'); data_wide_clean = rbind(data_wide_clean, mytmp);
mytmp <- removeOutliers_ch3(data_wide,'IBA-1','AD','P'); data_wide_clean = rbind(data_wide_clean, mytmp);

#install.packages('reshape2')
library(reshape2)
# Melt and remove NA and NaN
data_clean <- melt(data_wide_clean, measure.vars = 5:10)
data_clean <- data_clean[!data_clean$value=='NA',]
data_clean <- data_clean[!data_clean$value=='NaN',]
names(data_clean)[5]<-"Layer"  
names(data_clean)[6]<-"Value" # Long format
data_clean$Value <- as.numeric(data_clean$Value)
data <- data_clean

# Plot
library(ggpubr)
#install.packages("viridis")  # Install
library("viridis")     

png(filename = paste0(mytablepath,'/IBA-1 Results/BarPlots/',param_name,'_IBA-1.png'))

#p <- ggboxplot(data[data$Label=='IBA-1',], x = "Layer", y="Value", order= c('RNFL','GCL','IPL','INL','OPL','ONL'), color="Dx",
#               facet.by = "Region", labelOutliers='TRUE',add="jitter", ylim=myylim, ylab=myylabel, outlier.shape=8)
p <- ggbarplot(data[data$Label=='IBA-1',], x = "Layer", y="Value", order= c('RNFL','GCL','IPL','INL','OPL','ONL'),
               color="Dx", facet.by = "Region",  ylab=myylabel, position = position_dodge(0.8),
               ylim=myylim, add = c("mean_se"), palette="Set1")
p + stat_compare_means(aes(group = Dx), method = "wilcox.test", label = "p.signif", label.y=c(myylim[2]*0.99))

dev.off()
