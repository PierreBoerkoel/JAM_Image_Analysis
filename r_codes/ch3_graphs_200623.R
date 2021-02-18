remove(list=ls())

mytablepath = '/Users/pierreboerkoel/Desktop/AD Project'
param_name <- 'cy3norm'; myylim = c(0,3); myylabel <- 'Layer-wise normalized % Aβ immunoreactivity'
# param_name <- 'fitcnorm'; myylim = c(0,4); myylabel <- 'Layer-wise normalized % IBA-1 immunoreactivity'
# param_name <- 'cy3_and_fitc'; myylim = c(0,0.3); myylabel <- 'Layer-wise normalized % Aβ and IBA-1 immunoreactivity'
# param_name <- 'cy3per_fitc'; myylim = c(0,60); myylabel <- 'Layer-wise % Aβ immunoreactivity in a IBA-1 immunoreactive area'

# param_name <- 'cy3per_fitcn'
# param_name <- 'cy3per_fitcratio'
# param_name <- 'thickum'; myylim = c(0,85); myylabel <- 'thickness (um)'

labeltable <- read.csv(paste0(mytablepath,'/IBA-1_Data/ALL_IBA-1_labeltable.csv'))
colnames(labeltable) <- c('Label','Subject','Dx','Region')
param <- read.csv(paste0(mytablepath,'/IBA-1_Data/ALL_IBA-1_',param_name,'.csv'))
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
names(data_clean)[3]<-"Diagnosis"
names(data_clean)[5]<-"Layer"  
names(data_clean)[6]<-"Value" # Long format
data_clean$Value <- as.numeric(data_clean$Value)
data <- data_clean
data$Diagnosis <- gsub("Normal", "Control", data$Diagnosis)

# Plot
library(ggpubr)
#install.packages("viridis")  # Install
library("viridis")
#, width = 850, height = 850, res = 80

png(filename = paste0(mytablepath,'/IBA-1 Results/',param_name,'_IBA-1_updated_layout_outline_default.png'))

#p <- ggboxplot(data[data$Label=='IBA-1',], x = "Layer", y="Value", order= c('RNFL','GCL','IPL','INL','OPL','ONL'), color="Dx",
#               facet.by = "Region", labelOutliers='TRUE',add="jitter", ylim=myylim, ylab=myylabel, outlier.shape=8)
p <- ggbarplot(data[data$Label=='IBA-1',], x = "Layer", y="Value", order = c('RNFL','GCL','IPL','INL','OPL','ONL'),
               color="Diagnosis", facet.by = "Region", panel.labs = list(Region = c("Central", "Peripheral")), ylab=myylabel, lab.size = "100", position = position_dodge(0.9),
               ylim=myylim, add = c("mean_se"), palette="Set1", size = 0.7)
p + stat_compare_means(aes(group = Diagnosis), method = "wilcox.test", label = "p.signif", hide.ns=TRUE, label.y=c(myylim[2]*0.99))+
  font("ylab", size = 16)+
  font("xlab", size = 16)+
  font("xy.text", size = 14)+
  theme(strip.text.x = element_text(size = 14))+
  guides(color = guide_legend(title = "",
                              label = TRUE))

#  ggsave(paste0(mytablepath,'/IBA-1 Results/',param_name,'_IBA-1_updated_layout.tiff'), p, device = "tiff", dpi = 400)

dev.off()
