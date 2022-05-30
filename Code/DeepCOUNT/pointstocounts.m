
    
regions = nrrdread('C:\Users\Michael\Documents\TRAILMAP\Cropping\annotation_10_lsfm_collapse_crop_flip_newf.nrrd');
regions = double(regions);
% f([1:38 end-143:end],:,:) = [];
annotated = readtable('C:\Users\Michael\Documents\TRAILMAP\Cropping\annotation_info_0118_1327_collapseDeNardoLabMGnew.csv');
sz = size(regions);
%each = cell(height(annotated),8);
each = cell(height(annotated),1);

%get region volumes
clear unique
unique = unique(regions);
for i=1:length(unique)
    volume(1,:) = length(find(regions==unique(i)));
end
unique(:,2) = volume';
%%
folders = {'C:\Users\Michael\Documents\TRAILMAP\Brains\p60_216\p60_216_scaled'};


for brain = 1:numel(folders)
    w = folders{brain};
    for j = 1:1
        j
        tic
        cd(w)
        s = imfinfo('maxpoints.tif');
        test = uint8(zeros(s(1).Height,s(1).Width,numel(s)));
        for i = 1:numel(s)
            test(:,:,i) = imread('maxpoints.tif',i);
        end

        for i = 1:height(annotated)
            each{i,j} = test(regions == double(annotated.id(i))); %each saves intensity value for each pixel in a region
            i
        end
        toc
    end

    % eachmin = min(cell2mat(each), [], 'all');
    % eachmax = max(cell2mat(each), [], 'all');

    %%
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

    clear RegionalDensity NormalizedRegionalDensity
    for j = 1:1
    for i = 1:length(each)
        RegionalDensity(i,j) = sum(each{i,j}>0)/numel(each{i,j}); %counts # of pixels above 0 and divides by total number of pixels in that region
    end
    end

    for i = 1:1
    NormalizedRegionalDensity(:,i) = RegionalDensity(:,i)/nansum(RegionalDensity(:,i));
    end

    clear AxonsByRegion NormalizedInnervation
    for j=1:1
        for i=1:length(each)
            AxonsByRegion(i,j) = sum(each{i,j}>0);
        end
    end

    for i=1:1
        NormalizedInnervation(:,i) = AxonsByRegion(:,i)/nansum(AxonsByRegion(:,i));
    end

    for j = 1:1
    for i = 1:length(each)
        rawCounts(i,j) = sum(each{i,j}>0); %counts # of pixels above 0
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
    % sortedCopy = sorted;
    % sortedCopy(1:2,1:length(sortedCopy)) = NaN; %remove background, fiber tracts, check numbers for each nrrd
    % sortedCopy(108:109,1:length(sortedCopy)) = NaN; %remove ventricles, fiber tracts, check numbers for each nrrd
    % for i = 1:16
    %     sortedCopy(:,i) = sortedCopy(~isnan(sortedCopy));
    % end
    %%
    sorted([1,2,3,63,64,65,130,149],:) = [];
    headers = {'ids', 'name', 'atlas number', 'cell counts normalized by region volume', 'cell counts normalized by region volume and total cells', 'cell counts normalized by total cells', 'raw cell counts', 'parent'};
    output = [headers; sorted];
    xlswrite('CellCounts.xlsx', output);
end
%sorted = sortrows(sorted,4);

% [coeff, scores, latent, tsq, explained] = pca(zscore(sortedN(:,7:15)));
% [coeff, scores, latent, tsq, explained] = pca(zscore(sortedN(:,:)));
% sorted(:,11) = scores(:,2); %plot along second principal component. plot the one that separates groups well if exists
% a = sortrows(sorted,15);
% b = a(a(:,6) == 1,:);
% b = [b; flipud(a(a(:,6) == 0,:))];
% 
% %h = heatmap(b(:,7:15),'colormap',viridis(1000),'gridvisible','off')
% figure; h = heatmap(sorted(:,7:15),'colormap',viridis(1000),'gridvisible','off')%download viridis from file exchange (purple to yellow colormap)
% figure; h = heatmap(b(:,5),'colormap',cc,'gridvisible','off')
% figure; h = heatmap(scores(:,2), 'colormap', viridis(1000), 'gridvisible', 'off')
% figure; h= plot(coeff(:,1), coeff(:,2));

%% not normalized by region volume
% 
% clear AxonsByRegion NormalizedInnervation
% for j=1:9
%     for i=1:length(each)
%         AxonsByRegion(i,j) = sum(each{i,j})>8000;
%     end
% end
% 
% for i=1:9
%     NormalizedInnervation(:,i) = AxonsByRegion(:,i)/nansum(AxonsByRegion(:,i));
% end
% 
% group1d = [1 2 3 7 8];
% group14d = [4 5 6 9];
% 
% clear regionalP
% ids = find(~isnan(NormalizedInnervation(:,1)));
% all = NormalizedInnervation(ids,:);
% [~,regionalP] = ttest2(all(:,group1d)', all(:,group14d)');
% 
% parentFile = readtable('/Users/laurawilke/Dropbox/Luo Lab/TRAP2 Paper/iDISCO/Ehsan_ARA2_annotation_info_collapse_2017.csv');
% 
% for i = 1:length(ids)
%     clear parent
%     if ismember(annotated.id(i), parentFile.id)
%     parent = find(annotated.id(i) == parentFile.id);
%     parentList(i) = parentFile.parent_id(parent);
%     end
% end
% parentList = parentList';
% 
% sortedN = [ids annotated.id(ids) parentList mean(all(:,group1d),2) mean(all(:,group14d),2) regionalP'];
% %sortedN = [sortedN sortedN(:,4)>sortedN(:,3) all];
% % annotatedcopy = annotated;
% % annotatedcopy(~ismember(annotated.id,annotated.id(ids)),:) = [];
% % annotatedcopy(653:end,:) = []; %fibertracts
% 
% 
% %[coeff, scores, latent, tsq, explained] = pca(zscore(sorted(:,7:15)));
% [coeff, scores, latent, tsq, explained] = pca(zscore(sorted(:,:)));
% sorted(:,11) = scores(:,2); %plot along second principal component. plot the one that separates groups well if exists
% a = sortrows(sorted,15);
% b = a(a(:,6) == 1,:);
% b = [b; flipud(a(a(:,6) == 0,:))];
% 
% h = heatmap(b(:,7:15),'colormap',viridis(1000),'gridvisible','off')
% h = heatmap(sorted(:,:),'colormap',viridis(1000),'gridvisible','off')%download viridis from file exchange (purple to yellow colormap)
% figure; h = heatmap(b(:,5),'colormap',cc,'gridvisible','off')
