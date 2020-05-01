* Overview
  * Tissue: Alzheimer's & control retina, cross-section 
  * Imaging: Immunohistochemistry + confocal microscopy 
  * Staining target (marker, colour): 
    * Microglia (IBA-1, green)
    * Nuclei (DAPI, blue) 
    * A-beta (BA4, red)
  * Data summary
    * 5 AD eyes, 5 control eyes
    * Per eye - 8 images = Total 80 images
      * 4 in central (Section A & B, Repeat 1 & 2 - see naming convention below) 
      * 4 in peripheral (Section A & B, Repeat 1 & 2 - see naming convention below)
    * Two sets (of 80 images) were acquired  
      * Set 1 processed and imaged by Geoffrey, image-adjusted by Tyler
      * Set 2 processed, imaged, and image-adjusted by Alis    
    * Image file naming convention: ex. TUBB 2011-040 A C2 COMBO.extension 
      * TUBB: The type of (specific) marker 
      * 2011-040: Subject ID 
      * A: Section # 
      * C: Central (P for peripheral) 
      * 2: Repeat #
      * COMBO: Image RGB Channel - COMBO = All of RGB  
    * Data organiziation convention
      * Set #
        * File type
          * Subject ID
            * IBA-1 06-0288 A C1 COMBO
            * IBA-1 06-0288 A C2 COMBO
            * ...
  * Quantitative parameters
    * Layer-wise thickness
    * Layer-wise staining of IBA-1 and BA4
    * Co-localized staining of IBA-1 and BA4

* To Dos
  * Data acquisition
    - [x] Immunohistochemistry  
    - [x] Confocal microscopy
    - [ ] Image quality control & adjustment - Set 2 done, Set 1 to by completed by Tyler today   
  * Data QA
    - [x] Sieun email image naming convention to Pierre
    - [ ] Pierre make sure naming correct 
    - [ ] Image access? Is everything there & properly organized? 
      - [x] Eleanor copy volunteer-1 folder to inside the Brain Canada folder, and email me & Pierre, 
      - [x] Joanne to email Jonathan for Pierre, Tyler to access the Brain Canada folder or alternative
      - [ ] Pierre check data organization
    - [ ] Image acquisition consistent, magnification, across diff. machines, person, etc.? - Pierre 
  * Analysis
    * Manual segmentation
      - [ ] Q. Can Zen export .czi file to a format that can be opened & segmented in ITK-Snap? Or any other software that can be used for manual segmentation?  
       
* Analysis plan 
   1. load the image
   2. manual layer segmentation - Alis & Tyler 
   3. apply layer segmentation to the image 
   4. threshold Red, Green, Blue /layer
   5. measure thickness /layer
   6. colocalization of Red & Green 
   
