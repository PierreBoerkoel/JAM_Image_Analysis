function sizeList = imageSizeCheck(imagefolder)
% Input 
% * imagefolder 
%   * this given location should contain 
%     * Tif (.tif) files of original images 
%
% Output
% * A n x 3 listing all *COMBO.tif file locations, names, and dimensions


[tmp1, groupname, tmp2] = fileparts(imagefolder); clear tmp1 tmp2; 
cd(imagefolder); 

% get list
imglist = dir('**/*COMBO.tif');
imgnames = extractfield(imglist,'name');
sizeList = {};
% 1. Apply layer segmentation mask. Obtain layer-wise measurements 
for i = 1:length(imglist)
    myfile = imgnames{i}; 

    disp([num2str(i), '/', num2str(length(imglist)),' - ', myfile]);
    
    Iimg= imread(fullfile(imglist(i).folder,imglist(i).name)); Iimg = Iimg(:,:,1:3);

    sizeList{i,1} = imglist(i).folder; 
    sizeList{i,2} = imglist(i).name; 
    sizeList{i,3} = size(Iimg);
end
end