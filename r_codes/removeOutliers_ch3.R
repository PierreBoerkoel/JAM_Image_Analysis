removeOutliers_ch3 <- function(data_wide, label, dx, region){
# removes layerwise-outliers 

# coefficients
k = c(5.6,2.9,3.0,2.2,3.3,2.4)

mysubset <- data_wide[data_wide[,"Label"]==label & data_wide[,"Dx"]==dx & data_wide[,"Region"]==region, ];

# 1. Select the layer values 
mysubsetLayers <- mysubset[,which(colnames(mysubset)=="RNFL"):which(colnames(mysubset)=="ONL")]

# 2. Which k? 
myk = k[nrow(mysubsetLayers)-4]

# 3. Obtain 1st, 3rd, IQR,and LB & UB 
myquartiles <- apply(mysubsetLayers,2,quantile, na.rm =TRUE)
myIQRs <- myquartiles[4,]-myquartiles[2,]
myLB <- myquartiles[2,]-myk*myIQRs
myUB <- myquartiles[4,]+myk*myIQRs

# 4. Find & remove outliers
# 4.1. repmat LB and UB
myLB <- matrix(rep(myLB,each=nrow(mysubsetLayers)),nrow=nrow(mysubsetLayers))
myUB <- matrix(rep(myUB,each=nrow(mysubsetLayers)),nrow=nrow(mysubsetLayers))

# 4.2. Find outliers
myOutliers <- mysubsetLayers < myLB | mysubsetLayers > myUB

# 4.3 Remove outliers 
mysubsetLayers_no <- mysubsetLayers 
mysubsetLayers_no[myOutliers] = 'NA' 

# 5. Replace the original 
mysubset[,which(colnames(mysubset)=="RNFL"):which(colnames(mysubset)=="ONL")] = mysubsetLayers_no

return(mysubset)

}
