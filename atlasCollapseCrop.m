%Generates a custom atlas with brain regions collapsed as
%you would like. Also crops atlas in pre-specified way (e.g. cerebellum 
%may be cropped out). This is to be 
%selected prior to analysis. If a subregion
%is collapsed into a parent region, all pixels
%in the final annotation file that correspond to that subregion will be
%assigned the value of the parent region. 

%This requires modification of a csv file indicating which regions are to
%be collapsed. In the 10th column of the annotation file ("J" in excel),
%which is labeled "collapse", indicate regions whose subregions you would
%like to collapse with a 1. 

%For example, if you would like to collapse
%layers 1-6 of prelimbic cortex, indicate this by placing a "1" in
%"prelimbic area" and a "0" in all of the sublayers. If you would like to
%only preserve certain subregions within a parent region, indicate these with a "1" and
%they will not be collapsed into the parent regions, but those with a "0"
%will. The hierarchy of parent regions is contained in "structure_id_path"
%in the csv file.

%Dimensions of cropped atlas can be selected under "make a cropped atlas".

%All paths shown in purple must be updated with those of the computer being
%used. Only one collapsed atlas is required for an entire dataset.

%%

%load in an annotation.csv table that includes the parental hierarchy.

regions = nrrdread('C:\Users\Michael\Documents\TRAILMAP\Cropping\annotation_10_lsfm.nrrd');
annotated = readtable('C:\Users\Michael\Documents\TRAILMAP\Cropping\annotation_info_0118_1327_collapseDeNardoLabMGnew.csv');
regionID = unique(regions);
regionsT = permute(regions, [2,1,3]);
regionsT = flip(regionsT, 2);
%regionsT = regionsT(218:1354,:,1:579);
%%
regionsT = double(regionsT);
%calculate volume of each region
%for i = 1:length(regionID)
%    regionID(i,2) = length(find(regions == regionID(i)));
%end

%regionID(89,2) = length(find(regions == 1080));

for i = 1:height(annotated)
    a = str2double(strsplit(annotated.structure_id_path{i},'/'));
    pathId{i} = a(~isnan(a));
end
%%
%combineids = a list of region ids that have all children collapsed
%for the "full" annotation file, only 73 and 1009 are collapsed
%for the "collapsed" annotation file, see the 0108_1327.csv
%combineids = [51 138 141 157 239 290 275 322 323 339 348 370 379 386 444 467 519 571 637 645 1073 809 818 826 835 987 1008 1014 1117 1132]; %157 %322
combineid = annotated.id(logical(annotated.collapse));
combineids = transpose(combineid);

%correct for incorrect labels in annotation file
regionsT(regionsT==182305696) = 182305689;
regionsT(regionsT==182305712) = 182305689;
regionsT(regionsT==312782560) = 312782546;
regionsT(regionsT==312782592) = 312782574;
regionsT(regionsT==312782656) = 312782628;
regionsT(regionsT==484682464) = 484682470;
regionsT(regionsT==484682496) = 956;
regionsT(regionsT==496345664) = 603;
regionsT(regionsT==526157184) = 526157192;
regionsT(regionsT==526322272) = 526322264;
regionsT(regionsT==527696992) = 527696977;
regionsT(regionsT==549009216) = 549009207;
regionsT(regionsT==560581568) = 560581551;
regionsT(regionsT==563807424) = 563807435;
regionsT(regionsT==576073728) = 576073704;
regionsT(regionsT==589508416) = 589508447;
regionsT(regionsT==589508480) = 589508455;
regionsT(regionsT==599626944) = 530;
regionsT(regionsT==606826624) = 732;
regionsT(regionsT==606826688) = 606826659;
regionsT(regionsT==607344832) = 607344830;
regionsT(regionsT==614454272) = 614454277;


%%
for i = 1:numel(pathId)
    try
        if any(ismember(pathId{i},combineids))
            regionsT(regionsT == annotated.id(i)) = pathId{i}(ismember(pathId{i},combineids));
        i
        end
    catch
        if any(ismember(pathId{i},combineids))
            multi = pathId{i}(ismember(pathId{i},combineids));
            regionsT(regionsT == annotated.id(i)) = multi(end);    
        end
        disp("exception")
    end
end
%%
nrrdWriter('C:\Users\Michael\Documents\TRAILMAP\Cropping\annotation_10_lsfm_collapse_newf.nrrd', regionsT, [10,10,10], [0,0,0], 'raw');

%check size of new atlas (just a sanity check)
regionsCollapse = nrrdread('C:\Users\Michael\Documents\TRAILMAP\Cropping\annotation_10_lsfm_collapse_newf.nrrd');
checkSize = size(unique(regionsCollapse))

%make a cropped atlas 
atlas = nrrdread('C:\Users\Michael\Documents\TRAILMAP\Cropping\annotation_10_lsfm_collapse_newf.nrrd');
atlasCrop = atlas(218:1354,:,1:579); 
%atlasCrop = atlas(:,:,:); %half brain
nrrdWriter('C:\Users\Michael\Documents\TRAILMAP\Cropping\annotation_10_lsfm_collapse_crop_newf.nrrd', atlasCrop, [10,10,10], [0,0,0], 'raw');

regionsCollapse = nrrdread('C:\Users\Michael\Documents\TRAILMAP\Cropping\annotation_10_lsfm_collapse_crop_newf.nrrd');
checkSize = size(unique(regionsCollapse))

%counts = readtable('/Users/laurawilke/Dropbox/folders/6010-2/AxonCountsCollapsed3Norm.csv');
%regions = nrrdread('/Users/laurawilke/Dropbox/DeNardoLab/ClearMapFiles/320x280x528_25um/annotation_sagittal_collapsedCrop_LDCollapseMore.nrrd');
%%
test = unique(regionsCollapse);