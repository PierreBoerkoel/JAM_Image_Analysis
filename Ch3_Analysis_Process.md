1. Data acquisition, QA, and organiziation 
2. Manual layer segmentation - see a separate doc 
3. Analysis  
  * Input so far: Original image, layer segmentation image 
  3.1. Threshold selection 
    * Ab was stained and imaged for in the different sections from the same tissue in different sets.
    * So we use the amount of Ab staining to normalize the thresholding for the different sets. 
    * First, we 
  
  
  red & green staining intensity threshold values 
  * Output: Tables for layer thickness, red staining, green staining, red & green colocalization 
  * Algorithm
    1. Binarize the original image using the threshold values 
    2. Divide the original image into layers using the segmentation image
    3. Calculate the noramlizaed staining (by %), colocalization 
    4. Save 
