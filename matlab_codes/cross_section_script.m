clear;   

imagefolder = '/ensc/IMAGEBORG/PROJECTS/ADconfocal/Ch3_Final_Nov2019/Data/GFAP_Old_Geoffrey'; Cy3threshold = 20; FITCthreshold = 20; % old GFAP 
% imagefolder = '/ensc/IMAGEBORG/PROJECTS/ADconfocal/Ch3_Final_Nov2019/Data/TUBB_Old_Alice'; Cy3threshold = 80; FITCthreshold = 80; % old TUBB
% imagefolder = '/ensc/IMAGEBORG/PROJECTS/ADconfocal/Ch3_Final_Nov2019/Data/GFAP_TUBB_New_Normals_Geoffrey'; Cy3threshold = 45; FITCthreshold = 45;
outfolder = '/ensc/IMAGEBORG/PROJECTS/ADconfocal/Ch3_Final_Nov2019/Measurements/';

cross_section_staining_analysis(imagefolder, Cy3threshold, FITCthreshold, outfolder); 