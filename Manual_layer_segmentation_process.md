1. Export .czi images (native Zeiss microscopy format) are exported into tif files.
   * Using Zeiss's Zen software  
2. Covert the tif images into nifti (.nii) format 
   * Using Matlab (code location here) 
3. Segment layers manually following the protocol
   * Using ITK-Snap using .nii files
   * (Protocol location here) 

Current process:
i. Alis exports the .czi images to .tif, uploads them in Teamshare (proper naming & organization), and let Sieun know. 
ii. Sieun downloads the .tif files, convert them to .nii format, upload to Teamshare, and let Alis know. 
iii. Alis manually segments the .nii files in ITK-Snap, upload to Teamshare, and let Sieun know. 
iv. Sieun uses the original and segmented images to do analysis
