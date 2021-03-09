function cross_section_staining_analysis(imagefolder, Cy3threshold, FITCthreshold, outfolder, exclusion_data, desired_threshold_image)
% Input 
% * imagefolder 
%   * this given location should contain 
%     * Tif (.tif) files of original images 
%     * Nifti (.nii) files of layer segmentation images
%   * The name of the last directory in imagefolder will be used in output naming 
%   * The code processes all *COMBO.tif, and all of their corresponding *seg.nii
% * Cy3threshold, FITCthreshold: red and green positive staining threshold
% * outfoder: location where the output is saved 
%
% Output
% * groupname_measurement_threCy3threshold.mat: this contains all MATLAB workspace input and output objects 
% * CSVs (row: unique data point (subject + region); column: layer) 
%   * labeltable_unique: data clinical information 
%   * cy3norm_unique: layer-wise red-positive pixels by % 
%   * fitcnorm_unique: layer-wise green-positive pixels in %
%   * thickum_unique: layer-wise average thickness in um 
%   * cy3per_fitc_unique: layer-wise % of red-positive pixels among the green-positive pixels
%   * cy3per_fitcn_unique: layer-wise % of red-positive pixels among the green-negative pixels 
%   * cy3per_fitcratio_unique: layer-wise ratio of cy3per_fitc_unique / cy3per_fitcn_unique  
 


[tmp1, groupname, tmp2] = fileparts(imagefolder); clear tmp1 tmp2; 
cd(imagefolder); 

% get list
imglist = dir('**/*COMBO.tif');
seglist = dir('**/*seg.nii');
imgnames = extractfield(imglist,'name');
segnames = extractfield(seglist,'name'); 

labeltable = {'label'	'subject'	'dx'	'section'	'region'	'regionnum'};
[voltable, thicktable, cy3table, fitctable, fitcntable, cy3fitctable, cy3nfitctable] = deal([]);  

problemfiles={}; 
% 1. Apply layer segmentation mask. Obtain layer-wise measurements 
for i = 1:length(imglist)
    myfile = imgnames{i}; 

    disp([num2str(i), '/', num2str(length(imglist)),' - ', myfile]);
        
    % extract metadata
    spaceind = find(isspace(myfile));
    mylabel = myfile(1:spaceind(1)-1);
    mysubject = myfile(spaceind(1)+1:spaceind(2)-1);
    mysect = myfile(spaceind(2)+1:spaceind(3)-1);
    myregion = myfile(spaceind(3)+1);        
    myregionnum = myfile(spaceind(3)+2); 

    % Identify: Group 
    if isempty(str2num(mysubject(1)))
        mydx = 'AD';
    else
        mydx = 'Normal';
    end

    
    % select pixres
    Iimg = imread(fullfile(imglist(i).folder,imglist(i).name));
    Iimg = Iimg(:,:,1:3);
    imgSize = size(Iimg);
    if all(imgSize == [1104 1376 3])
        pixres = 0.454;
    elseif all(imgSize == [1376 1104 3])
        pixres = 0.454;
    elseif all(imgSize == [1024 1024 3])
        pixres = 0.44;
    elseif all(imgSize == [2048 2048 3])
        pixres = 0.156;
    else
        errordlg(sprintf('Image size not supported: %s', myfile));
        error('Image size not supported: %s', myfile);
    end

    % create a cy3 (red) mask
    Icy3 = Iimg(:,:,1); 
    Icy3_mask = Icy3 > Cy3threshold;

    % create a fitc (green) mask
    Ifitc = Iimg(:,:,2);
    Ifitc_mask = Ifitc > FITCthreshold;
        
    % cy3 & fitc
    Icy3_fitc = Icy3_mask&Ifitc_mask;
    Icy3_nfitc = Icy3_mask&(~Ifitc_mask); 

    % layers - read nii data
    segind = find(contains(segnames,imgnames{i}(1:end-4)));
    I = niftiread(fullfile(seglist(segind).folder,seglist(segind).name));
    I = transpose(I);
    
    % quality check 1/3: rotation 
    if ~all([size(Iimg,1) size(Iimg,2)] == size(I))
        errordlg(sprintf('Image size not matching: %s.', myfile));
        error('Image size not matching: %s.', myfile);
    end     
    
    % quality check 2/3: all 7 labels are there
    if ~all(ismember([1:7],I))
        errordlg(sprintf('Image %s is missing label(s). Images must have 7 labels.', myfile));
        error('Image %s is missing label(s). Images must have 7 labels.', myfile);
    end
    
    % quality check 3/3: image is upside down  
    Imid = I(:,size(I,2)/2);
    if mean(find(Imid==1)) > mean(find(Imid==7))
        errordlg(sprintf('Image %s is not oriented correctly.', myfile));
        error('Image %s is not oriented correctly.', myfile);
    end

    % make layer masks from segmentation 
    Ilayer = zeros(size(I));
    labelposition_allLayers = [];

    threshold_mask = ones(size(I));

    for k = 1:7 % for each layer
        myind = k; 

        % vertical thickness - average
        [Y, X] = meshgrid(1:size(I,2),1:size(I,1)); %clear Y; 
        Ibw = I == myind;
        Iind = X.*Ibw;
        Iind(Iind == 0) = NaN;
        labelposition = nanmean(Iind,1);

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

        % only create threshold images for the desired image(s)
        if myfile == desired_threshold_image
            switch k
                case 1
                    % don't consider anything above layer 1
                    threshold_mask(X<labelmask) = 0;
                case 7
                    % don't consider anything below layer 7
                    threshold_mask(X>labelmask) = 0;

                    % create a masked image that shows all FITC pixels above
                    % threshold at maximum intensity
                    fitc_max_intensity_threshold = bsxfun(@times, Ifitc_mask, 255);
                    fitc_max_intensity_threshold = bsxfun(@times, fitc_max_intensity_threshold, threshold_mask);
                    fitc_max_intensity_threshold = double(cat(3, fitc_max_intensity_threshold, fitc_max_intensity_threshold, fitc_max_intensity_threshold));
                    fitc_max_intensity_threshold(:,:,1) = 0;
                    fitc_max_intensity_threshold(:,:,3) = 0;

                    % create a masked image that shows all Cy3 pixels above
                    % threshold at maximum intensity
                    cy3_max_intensity_threshold = bsxfun(@times, Icy3_mask, 255);
                    cy3_max_intensity_threshold = bsxfun(@times, cy3_max_intensity_threshold, threshold_mask);
                    cy3_max_intensity_threshold = double(cat(3, cy3_max_intensity_threshold, cy3_max_intensity_threshold, cy3_max_intensity_threshold));
                    cy3_max_intensity_threshold(:,:,2) = 0;
                    cy3_max_intensity_threshold(:,:,3) = 0;
            end
        end

        Ilayer = Ilayer + labelmask2; 
        labelposition_allLayers = [labelposition_allLayers; labelposition_filled]; 
    end  
        
    % thickness 
    cdist = []; 
    for k = 1:6
        fromBoundv = labelposition_allLayers(k,:);
        toBoundv = labelposition_allLayers(k+1,:); 

        % closest distance 
        fromx = repmat((1:size(I,2)),[size(I,2) 1]); 
        tox = repmat((1:size(I,2))',[1 size(I,2)]);
        fromy = repmat(fromBoundv,[size(I,2) 1]); 
        toy = repmat(toBoundv',[1 size(I,2)]); 
        xdist = fromx - tox;
        ydist = fromy - toy;       
        distmap = sqrt(xdist.^2 + ydist.^2);
        cdist(k,:) = min(distmap);        
    end
    
    % layer-wise parameters    
    layervols = zeros(1,6);
    layerthicks = zeros(1,6);
    layercy3 = zeros(1,6);
    layerfitc = zeros(1,6);
    layernfitc = zeros(1,6); 
    layercy3fitc = zeros(1,6);
    layercy3nfitc = zeros(1,6);

    exclusion_layers = exclusion_data{ismember(exclusion_data, myfile), 2};

    for k = 1:6
        % set layer data to NaN if excluded; ignore any selected
        % layers if 'Analyze All Layers'(value = 0) was selected
        if ~ismember(string(0), exclusion_layers) && ismember(string(k), exclusion_layers)
            disp(['Excluding layer ', num2str(k), ' from ', myfile]);
            layervols(k) = NaN;
            layerthicks(k) = NaN;
            layercy3(k) = NaN;
            layerfitc(k) = NaN;
            layernfitc(k) = NaN;
            layercy3fitc(k) = NaN;
            layercy3nfitc(k) = NaN;
            continue
        end

        layervols(k) = nnz(Ilayer == k);
        layerthicks(k) = mean(cdist(k,:))*pixres;
        layercy3(k) = nnz(Ilayer == k & Icy3_mask);
        layerfitc(k) = nnz(Ilayer == k & Ifitc_mask);
        layernfitc(k) = nnz(Ilayer == k & ~Ifitc_mask); 
        layercy3fitc(k) = nnz(Ilayer == k & Icy3_fitc);
        layercy3nfitc(k) = nnz(Ilayer == k & Icy3_nfitc);
    end
        
    % fill in table
    labeltable = [labeltable; {mylabel mysubject mydx mysect myregion myregionnum}]; 
    voltable = [voltable; layervols];
    thicktable = [thicktable; layerthicks]; 
    cy3table = [cy3table; layercy3];
    fitctable = [fitctable; layerfitc]; 
    fitcntable = [fitcntable; layernfitc]; 
    cy3fitctable = [cy3fitctable; layercy3fitc]; 
    cy3nfitctable = [cy3nfitctable; layercy3nfitc]; 
end     


% 2. Adjust parameters 
thickum = thicktable; 
cy3norm = cy3table./voltable*100; % (Cy3 pixels / total pixels) * 100
fitcnorm = fitctable./voltable*100; % (FITC pixels / total pixels) * 100
cy3_and_fitc = cy3fitctable./voltable*100; % (Cy3 AND FITC pixels / total pixels) * 100
cy3per_fitc = cy3fitctable./fitctable*100; % (Cy3 AND FITC pixels / FITC pixels) * 100
fitcper_cy3 = cy3fitctable./cy3table*100; % (Cy3 AND FITC pixels / Cy3 pixels) * 100
cy3per_fitcn = cy3nfitctable./fitcntable*100; % (Cy3 pixles that aren't FITC / All pixels that aren't FITC) * 100
cy3per_fitcratio = cy3per_fitc./cy3per_fitcn; % ((Cy3 AND FITC pixels / FITC pixels) * 100)) / ((Cy3 pixles that aren't FITC / All pixels that aren't FITC) * 100)

% 3. unique data points (average A, B, 1, 2)  
labelsubjdxreg = strcat(labeltable(2:end, 1), labeltable(2:end,2), labeltable(2:end, 3), labeltable(2:end, 5));  
labelsubjdxreg_unique = unique(labelsubjdxreg);

labeltable_unique = {'label'	'subject'	'dx'	'section'	'region'	'regionnum'};
[thickum_unique, cy3norm_unique, fitcnorm_unique, cy3_and_fitc_unique, fitcper_cy3_unique, cy3per_fitc_unique, cy3per_fitcn_unique, cy3per_fitcratio_unique] = deal([]);

for i = 1:size(labelsubjdxreg_unique,1)
    mydatalabel = labelsubjdxreg_unique(i);
    mydata_inds = find(~cellfun(@isempty, strfind(labelsubjdxreg, mydatalabel))); 

    labeltable_unique = [labeltable_unique; labeltable(mydata_inds(1)+1,:)];  
    
    thickum_unique = [thickum_unique; nanmean(thickum(mydata_inds,:),1)];
    cy3norm_unique = [cy3norm_unique; nanmean(cy3norm(mydata_inds,:),1)]; 
    fitcnorm_unique = [fitcnorm_unique; nanmean(fitcnorm(mydata_inds,:),1)];
    cy3_and_fitc_unique = [cy3_and_fitc_unique; nanmean(cy3_and_fitc(mydata_inds,:),1)];
    cy3per_fitc_unique = [cy3per_fitc_unique; nanmean(cy3per_fitc(mydata_inds,:),1)];
    fitcper_cy3_unique = [fitcper_cy3_unique; nanmean(fitcper_cy3(mydata_inds,:),1)];
    cy3per_fitcn_unique = [cy3per_fitcn_unique; nanmean(cy3per_fitcn(mydata_inds,:),1)]; 
    cy3per_fitcratio_unique = [cy3per_fitcratio_unique; nanmean(cy3per_fitcratio(mydata_inds,:),1)]; 
end
labeltable_unique(:,4) = []; labeltable_unique(:,end) = []; labeltable_unique(1,:) = [];

% 4. Save output 
outputfile_name = [groupname,'_measurement_thre',num2str(Cy3threshold),'.mat']; 
save(fullfile(outfolder,outputfile_name), 'imagefolder', 'pixres', 'Cy3threshold', 'FITCthreshold', ...
     'labeltable_unique', 'thickum_unique', 'cy3norm_unique', 'fitcnorm_unique', 'fitcper_cy3_unique', ...
     'cy3per_fitc_unique', 'cy3per_fitcn_unique', 'cy3per_fitcratio_unique');
csvfolder = outfolder;  

writetable(cell2table(labeltable_unique),fullfile(csvfolder,[groupname,'_','labeltable_unique.csv']));
writetable(array2table(cy3norm_unique),fullfile(csvfolder,[groupname,'_','cy3norm_unique.csv']));
writetable(array2table(fitcnorm_unique),fullfile(csvfolder,[groupname,'_','fitcnorm_unique.csv']));
writetable(array2table(cy3_and_fitc_unique),fullfile(csvfolder,[groupname,'_','cy3_and_fitc_unique.csv']));
writetable(array2table(thickum_unique), fullfile(csvfolder,[groupname,'_','thickum_unique.csv'])); 
writetable(array2table(cy3per_fitc_unique),fullfile(csvfolder,[groupname,'_','cy3per_fitc_unique.csv'])); 
writetable(array2table(cy3per_fitcn_unique),fullfile(csvfolder,[groupname,'_','cy3per_fitcn_unique.csv']));
writetable(array2table(fitcper_cy3_unique),fullfile(csvfolder,[groupname,'_','fitcper_cy3_unique.csv'])); 
writetable(array2table(cy3per_fitcratio_unique),fullfile(csvfolder,[groupname,'_','cy3per_fitcratio_unique.csv']));

% write our masked images to the output
imwrite(fitc_max_intensity_threshold, fullfile(outfolder, [desired_threshold_image(1:end-4), '_fitc_threshold_', num2str(FITCthreshold), '_image.tif']));
imwrite(cy3_max_intensity_threshold, fullfile(outfolder, [desired_threshold_image(1:end-4), '_cy3_threshold_', num2str(Cy3threshold), '_image.tif']));
end



% % threshold optimizaiton 
% ADdata = cy3norm_unique(contains(labeltable_unique(:,3),'AD'),:);
% normaldata = cy3norm_unique(contains(labeltable_unique(:,3),'Normal'),:);
% 
% % sig test
% myparam = cy3norm_unique;
% mypvals = ch3wtest(labeltable_unique,myparam);
% numsigs = nnz(mypvals<0.05); 

% % visual exploration of the data
% normaldata = cy3norm_unique(contains(labeltable_unique(:,3),'Normal'),:);
% figure; boxplot(normaldata); axis([0.5 6.5 -0.5 5.5]);
% hold on; scatter(repmat(1:6,[1 size(normaldata,1)]),normaldata(:));
% hold on; plot(0.5:1:6.5,0.5*(ones(7)),'-r'); 
% 
% ADdata = cy3norm_unique(contains(labeltable_unique(:,3),'AD'),:);
% figure; boxplot(ADdata); axis([0.5 6.5 -0.5 5.5]);
% hold on; scatter(repmat(1:6,[1 size(ADdata,1)]),ADdata(:));
% hold on; plot(0.5:1:6.5,0.5*(ones(7)),'-r'); 

% % plotting 
% savefolder = '/ensc/IMAGEBORG/PROJECTS/ADconfocal/Ch3/figs_180914'; 
% if ~exist(savefolder);
%     mkdir(savefolder); 
% end
% 
% myparam = thickum_unique; figtitle = [mylabel,' - Layer thickness (um)']; 
% myaxis = [1 6 0 80]; 
% ch3plot_all(labeltable_unique, myregion,mydx,myparam,myaxis,figtitle);
% saveas(gcf, [figtitle,'.png']);
% 
% myparam = cy3norm_unique; figtitle = [mylabel,' - cy3 label (%)']; 
% myaxis = [1 6 0 10]; 
% ch3plot_all(labeltable_unique, myregion,mydx,myparam,myaxis,figtitle);
% saveas(gcf, [figtitle,'.png']);
% 
% myparam = fitcnorm_unique; figtitle = [mylabel,' - fitc label (%)'];
% myaxis = [1 6 0 20]; 
% ch3plot_all(labeltable_unique, myregion,mydx,myparam,myaxis,figtitle);
% saveas(gcf, [figtitle,'.png']);
% 
% myparam = cy3per_fitc_unique; figtitle = [mylabel,' - cy3 & fitc (%)'];
% myaxis = [1 6 0 40]; 
% plotnumbers = ch3plot_all(labeltable_unique, myregion,mydx,myparam,myaxis,figtitle);
% saveas(gcf, [figtitle,'.png']);
% 
% myparam = cy3per_fitcn_unique; figtitle = [mylabel,' - cy3 & not-fitc (%)'];
% myaxis = [1 6 0 40]; 
% plotnumbers = ch3plot_all(labeltable_unique, myregion,mydx,myparam,myaxis,figtitle);
% saveas(gcf, [figtitle,'.png']);
% 
% % myparam = cy3per_fitcn_unique; figtitle = [mylabel,' - cy3 & not-fitc (%)'];
% % myaxis = [1 6 0 40]; 
% % ch3plot_all(labeltable_unique, myregion,mydx,myparam,myaxis,figtitle);c
% 
% 
% myparam = thickum_unique;
% mypvals = ch3ttest(labeltable_unique,myparam)
% 
% myparam = cy3norm_unique;
% mypvals = ch3ttest(labeltable_unique,myparam)
% 
% myparam = fitcnorm_unique;
% mypvals = ch3ttest(labeltable_unique,myparam)
% 
% myparam = cy3per_fitc_unique;
% mypvals = ch3ttest(labeltable_unique,myparam)
% 
% myparam = cy3per_fitcn_unique;
% mypvals = ch3ttest(labeltable_unique,myparam)
% 
% myparam = cy3per_fitcratio_unique;
% mypvals = ch3ttest(labeltable_unique,myparam)
