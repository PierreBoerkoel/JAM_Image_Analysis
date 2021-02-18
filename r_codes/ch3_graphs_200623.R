remove(list=ls())

fitc_group = 'GFAP'

mytablepath = '/Users/pierreboerkoel/Desktop/AD Project'
#param_name <- 'cy3norm'; myylim = c(0,4); myylabel <- paste('Normalized % ',fitc_group,' immunoreactivity')
#param_name <- 'fitcnorm'; myylim = c(0,30); myylabel <- paste('Normalized % ',fitc_group,' immunoreactivity')
#param_name <- 'cy3_and_fitc'; myylim = c(0,0.3); myylabel <- paste('Normalized % Aβ and ',fitc_group,'  immunoreactivity')
param_name <- 'cy3per_fitc'; myylim = c(0,30); myylabel <- paste('% Aβ immunoreactivity in a ',fitc_group,'  immunoreactive area')

# param_name <- 'cy3per_fitcn'
# param_name <- 'cy3per_fitcratio'
# param_name <- 'thickum'; myylim = c(0,85); myylabel <- 'thickness (um)'

labeltable <- read.csv(paste0(mytablepath,'/GFAP_TUBB_Data/ALL_GFAP_TUBB_labeltable.csv'))
colnames(labeltable) <- c('Label','Subject','Dx','Region')
param <- read.csv(paste0(mytablepath,'/GFAP_TUBB_Data/ALL_GFAP_TUBB_',param_name,'.csv'))
colnames(param) <- c('RNFL','GCL','IPL','INL','OPL','ONL')
data_wide = cbind(labeltable,param)

# Remove Outliers
source('/Users/pierreboerkoel/git/ADImageAnalysis/JAM_Image_Analysis/r_codes/removeOutliers_ch3.R')
data_wide_clean <- removeOutliers_ch3(data_wide,fitc_group,'Normal','C');
mytmp <- removeOutliers_ch3(data_wide,fitc_group,'Normal','P'); data_wide_clean = rbind(data_wide_clean, mytmp);
mytmp <- removeOutliers_ch3(data_wide,fitc_group,'AD','C'); data_wide_clean = rbind(data_wide_clean, mytmp);
mytmp <- removeOutliers_ch3(data_wide,fitc_group,'AD','P'); data_wide_clean = rbind(data_wide_clean, mytmp);

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

png(filename = paste0(mytablepath,'/',fitc_group,' Results/Updated Graphs/',param_name,'_',fitc_group,'_updated_layout_outline_pval.png'), width=850, height=850, res=80)

p <- ggbarplot(data[data$Label==fitc_group,], x = "Layer", y="Value", order = c('RNFL','GCL','IPL','INL','OPL','ONL'),
               fill="Diagnosis", facet.by = "Region", panel.labs = list(Region = c("Central", "Peripheral")), ylab=myylabel, lab.size = "100", position = position_dodge(0.9),
               ylim=myylim, add = c("mean_se"), palette="Set1", size = 0.7)
p + stat_compare_means(aes(group = Diagnosis), method = "wilcox.test", label = "p.format", hide.ns=FALSE, label.y=c(myylim[2]*0.99))+
  font("ylab", size = 16)+
  font("xlab", size = 16)+
  font("xy.text", size = 14)+
  theme(strip.text.x = element_text(size = 14))+
  guides(fill = guide_legend(title = "",
                              label = TRUE))

dev.off()
