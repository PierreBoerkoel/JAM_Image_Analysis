function tif2nii(tifloc, niiloc)
%TIF2NII Convert .tif to .nii format
%   TIF2NII(TIFLOC, NIILOC) 
%       - converts all .tif files in TIFLOC and its subfolders into .nii 
%           format and saves the .nii files in NIILOC. 
%       - The file path and name of the .tif file is preserved in NIILOC
%           i.e. TIFLOC/.../FILE.tif will have a corresponding 
%           NIILOC/.../FILE.nii
%   Written by: Sieun Lee (sieunrhie2@gmail.com
%   Last update: May 1, 2020


tifloc = '/ensc/IMAGEBORG/PROJECTS/ADconfocal/IBA1/For Sieun Apr 30, 2020 Tif to Convert to Nii/TIFF files of Alis IBA-1 and BA4 post-adjustment/IBA-1/Tif'
outloc = '/ensc/IMAGEBORG/PROJECTS/ADconfocal/IBA1/nii_original';
    
cd(tifloc);
tiflist = dir('**/*.tif');
tifnames = extractfield(tiflist,'name');
tifpaths = extractfield(tiflist,'folder');

for i = 1:length(tiflist)

    Iimg = imread(fullfile(tifpaths{i},tifnames{i})); 
    
    dcmpath = fullfile(outloc,tifpaths{i}(length(tifloc)+1:end)); 
    if ~exist(dcmpath)
        mkdir 
    end    
    
    dicomwrite(Iimg,[dcmpath,'/',tifnames{i}(1:end-4),'.dcm']);   

end