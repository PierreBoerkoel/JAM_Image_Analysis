clear; close all; 

addpath(genpath('/ensc/IMAGEBORG/PROJECTS/ADconfocal/SLRP/'));
imagefolder = '/ensc/IMAGEBORG/PROJECTS/ADconfocal/Ch3_Final_Nov2019/Data';
outfolder = '/ensc/IMAGEBORG/PROJECTS/ADconfocal/SLRP/Cleaned/';
datalistloc = '/ensc/IMAGEBORG/PROJECTS/ADconfocal/SLRP/pilotDataList2';
scaleImgLoc = '/ensc/IMAGEBORG/PROJECTS/ADconfocal/SLRP/scaleBarImg.tif';

cd(imagefolder); 

% List of data that needs to be removed  
fid = fopen(datalistloc);
imgnames = {}; 
tline = fgetl(fid);
while ischar(tline)
    imgnames{end+1,1} = tline;
    tline = fgetl(fid)
end
fclose(fid); clear tline; 


for i = 2:size(imgnames,1)

    myfile = imgnames{i}; 
        
    disp([num2str(i), '/', num2str(length(imgnames)),' - ', myfile]);
    
    % 0. Find files 
    imglist = dir(['**/*',myfile,'.tif']);
    imgname = extractfield(imglist,'name');

    seglist = dir(['**/*',myfile,'*seg.tif']);
    segnames = extractfield(seglist,'name'); 

    
    % 1. load image & segmentation files 
    Iimg= imread(fullfile(imglist.folder,imglist.name)); Iimg = Iimg(:,:,1:3);

%     Iimg2 = removeScaleBar(scaleImgLoc, Iimg); 
%     figure; subplot(1,2,1); imagesc(Iimg); subplot(1,2,2); imagesc(Iimg2); pause; close all;  
%     Iimg = Iimg2; clear Iimg2;
    
    I= imread(fullfile(seglist.folder,seglist.name));
    I = transpose(I);
    
    % quickcheck
    figure; subplot(1,2,1); imagesc(Iimg); subplot(1,2,2); imagesc(I); pause; close all;  
    
    % 2. make layer masks for removing post-ONL stuff 
    Ilayer = zeros(size(I)); 
    labelposition_allLayers = []; 
    for k = 7:7 % for last layer
        myind = k; 

        % vertical thickness - average
        [Y, X] = meshgrid(1:size(I,2),1:size(I,1)); %clear Y; 
        Ibw = I == myind;
        Iind = X.*Ibw;
        Iind(Iind == 0) = NaN;
        labelposition= nanmean(Iind,1);

        labelposition_filled = labelposition;
            
        % horizontal gap: grab nearest neighbor 
        if any(isnan(labelposition))
            blankind = find(isnan(labelposition));
            fillind = find(~isnan(labelposition)); 
            for j = 1:length(blankind)
                [tempmin minind] = min(abs(fillind - blankind(j)));
                labelposition_filled(blankind(j)) = labelposition(fillind(minind(1)));
            end
        end

        % label masks 
        labelmask = repmat(labelposition_filled,[size(I,1),1]); 
        labelmask2 = ones(size(I));
        labelmask2(X<labelmask) = 0;

        Ilayer = Ilayer + labelmask2; 
        labelposition_allLayers = [labelposition_allLayers; labelposition_filled]; 
    end  
    Ilayer7 = Ilayer; 

    Ilayer = zeros(size(I)); 
    labelposition_allLayers = []; 
    for k = 1:1 % for each layer
        myind = k; 

        % vertical thickness - average
        [Y, X] = meshgrid(1:size(I,2),1:size(I,1)); %clear Y; 
        Ibw = I == myind;
        Iind = X.*Ibw;
        Iind(Iind == 0) = NaN;
        labelposition= nanmean(Iind,1);

        labelposition_filled = labelposition;
            
        % horizontal gap: grab nearest neighbor 
        if any(isnan(labelposition))
            blankind = find(isnan(labelposition));
            fillind = find(~isnan(labelposition)); 
            for j = 1:length(blankind)
                [tempmin minind] = min(abs(fillind - blankind(j)));
                labelposition_filled(blankind(j)) = labelposition(fillind(minind(1)));
            end
        end

        % label masks 
        labelmask = repmat(labelposition_filled,[size(I,1),1]); 
        labelmask2 = ones(size(I));
        labelmask2(X<labelmask) = 0;

        Ilayer = Ilayer + labelmask2; 
        labelposition_allLayers = [labelposition_allLayers; labelposition_filled]; 
    end  
    Ilayer1 = Ilayer; 

    
    % 3. Add offset & flipt the mask7 
    osc=20;
    Ilayer72 = ones(size(Ilayer7));
    Ilayer72(1:end-osc,:) = Ilayer7(osc+1:end,:);
    Ilayer72 = abs(Ilayer72-1);

    % 4. Combine masks1&7 and apply   
    Ilayer = Ilayer1.*Ilayer72;
    I_masked = mat2gray(Iimg).*repmat(mat2gray(Ilayer),[1 1 3]); 

        % 5. Remove white mark 
    Iwhite = std(double(Iimg),1,3)< 10 & mean(Iimg,3) > 10;
    [Y X] = meshgrid(1:size(Iwhite,2), 1:size(Iwhite,1));
    Iwhite = Iwhite & Y<200 & X<200;    
    I_masked = I_masked.*repmat(~Iwhite,[1 1 3]); 

    
    Ired_masked = I_masked(:,:,1);  

   figure; subplot(1,3,1); imagesc(Iimg); subplot(1,3,2); imagesc(I_masked); subplot(1,3,3); imagesc(Ired_masked);  
   pause; close all;

    
    % 5. Save data 
    imwrite(mat2gray(Ired_masked),fullfile(outfolder,[myfile,'.tif']));  
    save(fullfile(outfolder,[myfile,'.mat']),'Ired_masked'); 
end

