1. Data acquisition, QA, and organiziation 
2. Manual layer segmentation - see a separate doc 
3. Analysis program 
  * Input: Original image, layer segmentation image, red & green staining intensity threshold values 
  * Output: Tables for layer thickness, red staining, green staining, red & green colocalization 
  * Algorithm
    1. Binarize the original image using the threshold values 
    2. Divide the original image into layers using the segmentation image
    3. Calculate the noramlizaed staining (by %), colocalization 
    4. Save 
