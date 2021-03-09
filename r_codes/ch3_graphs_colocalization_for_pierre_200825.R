remove(list=ls())

mytablepath = '/Users/pierreboerkoel/Desktop/AD Project'
fitc_group = 'IBA-1'

# load both fitc and fitcn
param_name <- 'cy3per_fitc'; myylim = c(0,50); myylabel <- paste0('% Aβ colocalized with ', fitc_group)
labeltable <- read.csv(paste0(mytablepath,'/IBA-1_Data/ALL_IBA-1_labeltable.csv'))
colnames(labeltable) <- c('Label','Subject','Dx','Region')
param <- read.csv(paste0(mytablepath,'/IBA-1_Data/ALL_IBA-1_',param_name,'.csv'))
colnames(param) <- c('RNFL','GCL','IPL','INL','OPL','ONL')
clcol <- matrix(rep('fitc', each=nrow(param)), nrow=nrow(param)); colnames(clcol) <- 'cy3_colocalization'
data_wide1 = cbind(labeltable,clcol,param);

# Remove Outliers
source('/Users/pierreboerkoel/git/ADImageAnalysis/JAM_Image_Analysis/r_codes/removeOutliers_ch3.R')
data_wide_clean1 <- removeOutliers_ch3(data_wide1,fitc_group,'Normal','C');
mytmp <- removeOutliers_ch3(data_wide1,fitc_group,'Normal','P'); data_wide_clean1 = rbind(data_wide_clean1, mytmp);
mytmp <- removeOutliers_ch3(data_wide1,fitc_group,'AD','C'); data_wide_clean1 = rbind(data_wide_clean1, mytmp);
mytmp <- removeOutliers_ch3(data_wide1,fitc_group,'AD','P'); data_wide_clean1 = rbind(data_wide_clean1, mytmp);

param_name2 <- 'cy3per_fitcn';
param2 <- read.csv(paste0(mytablepath,'/IBA-1_Data/ALL_IBA-1_',param_name2,'.csv'))
colnames(param2) <- c('RNFL','GCL','IPL','INL','OPL','ONL')
clcol2 <- matrix(rep('fitcn', each=nrow(param2)), nrow=nrow(param2)); colnames(clcol2) <- 'cy3_colocalization'
data_wide2 = cbind(labeltable,clcol2,param2);

# Remove Outliers
source('/Users/pierreboerkoel/git/ADImageAnalysis/JAM_Image_Analysis/r_codes/removeOutliers_ch3.R')
data_wide_clean2 <- removeOutliers_ch3(data_wide2,fitc_group,'Normal','C');
mytmp <- removeOutliers_ch3(data_wide2,fitc_group,'Normal','P'); data_wide_clean2 = rbind(data_wide_clean2, mytmp);
mytmp <- removeOutliers_ch3(data_wide2,fitc_group,'AD','C'); data_wide_clean2 = rbind(data_wide_clean2, mytmp);
mytmp <- removeOutliers_ch3(data_wide2,fitc_group,'AD','P'); data_wide_clean2 = rbind(data_wide_clean2, mytmp);

data_wide_clean <- rbind(data_wide_clean1, data_wide_clean2)


#install.packages('reshape2')
library(reshape2)
# Melt and remove NA
data_clean <- melt(data_wide_clean, measure.vars = 6:11)
data_clean <- data_clean[!(data_clean$value=='NA'|data_clean$value=='NaN'),]
names(data_clean)[3]<-"Dx"
names(data_clean)[6]<-"Layer"
names(data_clean)[7]<-"Value" # Long format
data_clean$Value <- as.numeric(data_clean$Value)
data <- data_clean
data$Dx <- gsub("Normal", "Control", data$Dx)
data$cy3_colocalization <- gsub("\\<fitcn\\>", paste0(fitc_group, ' Negative'), data$cy3_colocalization)
data$cy3_colocalization <- gsub("\\<fitc\\>", paste0(fitc_group, ' Positive'), data$cy3_colocalization)

# Plot
library(ggpubr)
#install.packages("viridis")  # Install

png(filename = paste0(mytablepath,'/', fitc_group, ' Results/IBA-1 Updated Graphs/','coloc_',fitc_group,'_Normal.png'))

p <- ggbarplot(data[data$Label==fitc_group&data$Dx=='Control',], x = "Layer", y="Value",
               order= c('RNFL','GCL','IPL','INL','OPL','ONL'),
               fill="cy3_colocalization", facet.by = "Region",  ylab=myylabel, position = position_dodge(0.8),
               ylim=myylim, add = c("mean_se"), palette = c("#000000", "#16C416"),
               panel.labs = list(Region = c("Central", "Peripheral")))
p + stat_compare_means(aes(group = cy3_colocalization), method = "wilcox.test", label = "p.signif", hide.ns = TRUE, label.y=c(myylim[2]*0.99))+
  font("ylab", size = 16)+
  font("xlab", size = 16)+
  font("xy.text", size = 14)+
  theme(strip.text.x = element_text(size = 14))+
  guides(fill = guide_legend(title = "",
                             label = TRUE))

dev.off()

png(filename = paste0(mytablepath,'/',fitc_group,' Results/IBA-1 Updated Graphs/','coloc_',fitc_group,'_AD.png'))

p <- ggbarplot(data[data$Label==fitc_group&data$Dx=='AD',], x = "Layer", y="Value",
               order= c('RNFL','GCL','IPL','INL','OPL','ONL'),
               fill="cy3_colocalization", facet.by = "Region",  ylab=myylabel, position = position_dodge(0.8),
               ylim=myylim, add = c("mean_se"), palette = c("#000000", "#16C416"),
               panel.labs = list(Region = c("Central", "Peripheral")))
p + stat_compare_means(aes(group = cy3_colocalization), method = "wilcox.test", label = "p.signif", hide.ns = TRUE, label.y=c(myylim[2]*0.99))+
  font("ylab", size = 16)+
  font("xlab", size = 16)+
  font("xy.text", size = 14)+
  theme(strip.text.x = element_text(size = 14))+
  guides(fill = guide_legend(title = "",
                             label = TRUE))

dev.off()
