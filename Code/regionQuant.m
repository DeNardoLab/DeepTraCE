%Extracts axon labeling density by region from processed skeletonized
%whole-brain images.


%%
%regions: annotation file with pixel values corresponding to atlas ID#
regions = nrrdread('C:\Users\Michael\Documents\TRAILMAP\Cropping\annotation_10_lsfm_collapse_crop_flip_newf.nrrd');
regions = double(regions);

%annotated: csv file used to generate collapsed atlas
annotated = readtable('C:\Users\Michael\Documents\TRAILMAP\Cropping\annotation_info_0118_1327_collapseDeNardoLabMGnew.csv');
sz = size(regions);
each = cell(height(annotated),1);

%get region volumes
clear unique
unique = unique(regions);
for i=1:length(unique)
    volume(1,:) = length(find(regions==unique(i)));
end
unique(:,2) = volume';

%%

%folders: folders (1 per brain) containing processed brain skeletons (FP_skel.tif)
folders = {'D:\TRAILMAP\Brains\cPL112623\cPL112623_scaled', 'D:\TRAILMAP\Brains\cPL117251\cPL117251_scaled', 'D:\TRAILMAP\Brains\cPL117252\cPL117252_scaled', 'D:\TRAILMAP\Brains\cPLF\cPLF_scaled', 'D:\TRAILMAP\Brains\NAc326F\NAc326F_scaled', 'D:\TRAILMAP\Brains\NAc326M\NAc326M_scaled', 'D:\TRAILMAP\Brains\NAc132502_4\NAc132502_4_scaled', 'D:\TRAILMAP\Brains\NAc1325023\NAc1325023_scaled', 'D:\TRAILMAP\Brains\VTA_1_Laser50\VTA_1_Laser50_scaled', 'D:\TRAILMAP\Brains\VTA325F\VTA325F_scaled', 'D:\TRAILMAP\Brains\VTA1129M\VTA1129M_scaled', 'D:\TRAILMAP\Brains\VTA11291F\VTA11291F_scaled'};

for brain = 1:numel(folders)
    w = folders{brain};
    for j = 1:1
        j
        tic
        cd(w)
        %Load processed brain image
        s = imfinfo('FP_skel.tif');
        test = uint8(zeros(s(1).Height,s(1).Width,numel(s)));
        for i = 1:numel(s)
            test(:,:,i) = imread('FP_skel.tif',i);
        end

        for i = 1:height(annotated)
            each{i,j} = test(regions == double(annotated.id(i))); %each saves intensity value for each pixel in a region
            i
        end
        toc
    end


    %%
    %Remove background, ventricles, fiber tracts, cerebellum, and olfactory
    %bulb.
    size1 = size(each(1,1));
    size2 = size(each(2,1));
    size216 = size(each(216,1));
    size604 = size(each(604,1));
    size605 = size(each(605,1));
    size610 = size(each(610,1));
    size1328 = size(each(1328,1));
    size1251 = size(each(1251,1));

    each{1,1}=zeros(size1);
    each{2,1}=zeros(size2);
    each{216,1}=zeros(size216);
    each{604,1}=zeros(size604);
    each{605,1}=zeros(size605);
    each{610,1}=zeros(size610);
    each{1328,1}=zeros(size1328);
    each{1251,1}=zeros(size1251);

    %Calculate raw and normalized labeling density
    clear RegionalDensity NormalizedRegionalDensity
    for j = 1:1
    for i = 1:length(each)
        RegionalDensity(i,j) = sum(each{i,j}>64)/numel(each{i,j}); %counts # of pixels above 64 and divides by total number of pixels in that region
    end
    end

    for i = 1:1
    NormalizedRegionalDensity(:,i) = RegionalDensity(:,i)/nansum(RegionalDensity(:,i));
    end

    clear AxonsByRegion NormalizedInnervation
    for j=1:1
        for i=1:length(each)
            AxonsByRegion(i,j) = sum(each{i,j}>64);
        end
    end

    for i=1:1
        NormalizedInnervation(:,i) = AxonsByRegion(:,i)/nansum(AxonsByRegion(:,i));
    end

    for j = 1:1
    for i = 1:length(each)
        rawCounts(i,j) = sum(each{i,j}>64); %counts # of pixels above 0
    end
    end

    % group1d = [1 2 3 7 8];
    % group14d = [4 5 6 9];


    ids = find(~isnan(RegionalDensity(:,1)));
    all = RegionalDensity(ids,:);
    % [~,regionalP] = ttest2(all(:,group1d)', all(:,group14d)');
    % sorted = [ids annotated.id(ids) mean(all(:,group1d),2) mean(all(:,group14d),2) regionalP'];
    % sorted = [sorted sorted(:,3)>sorted(:,4) all];
    % % annotatedcopy = annotated;
    % % annotatedcopy(~ismember(annotated.id,annotated.id(ids)),:) = [];
    % % annotatedcopy(653:end,:) = []; %fibertracts
    idsN = find(~isnan(NormalizedRegionalDensity(:,1)));
    allN = NormalizedRegionalDensity(ids,:);
    % [~,regionalP] = ttest2(allN(:,group1d)', allN(:,group14d)');
    % sortedN = [idsN annotated.id(idsN) mean(allN(:,group1d),2) mean(allN(:,group14d),2) regionalP'];
    % sortedN = [sortedN sortedN(:,3)>sortedN(:,4) allN];
    idsNN = find(~isnan(NormalizedInnervation(:,1)));
    allNN = NormalizedInnervation(ids,:);
    allRaw = rawCounts(ids,:);



    parentList = [];
    regionIDs = annotated.id(ids);
    sorted = [num2cell(ids), annotated.name(ids), num2cell(annotated.id(ids)), num2cell(all), num2cell(allN), num2cell(allNN), num2cell(allRaw)];
    for i = 1:length(sorted)
        clear parent
        if ismember(regionIDs(i), annotated.id) == 1
        parent = find(regionIDs(i) == annotated.id);
        parentList(i) = annotated.parent_id(parent);
        else parentList(i) = NaN;
        end
    end

    sorted(:,8) = num2cell(parentList);

    %%
    sorted([1,2,3,63,64,65,130,149],:) = [];
    headers = {'ids', 'name', 'atlas number', 'axons normalized by region volume', 'axons normalized by region volume and total fluorescence', 'axons normalized by total fluorescence', 'raw counts', 'parent'};
    output = [headers; sorted];
    xlswrite('AxonCounts_new.xlsx', output);
end
