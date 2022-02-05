%Takes multiple transformed axon segmentations for a single brain and
%concatenates them into a single image, using different segmentations for
%different regions.

%%
%regions: annotation file with pixel values corresponding to atlas ID#
regions = nrrdread('C:\Users\Michael\Documents\TRAILMAP\Cropping\annotation_10_lsfm_collapse_crop_flip_newf.nrrd');

%folders: folders (1 per brain) containing transformed axon segmentations (FP.tif, etc)  
folders = {'D:\TRAILMAP\Brains\cPL112623\cPL112623_scaled', 'D:\TRAILMAP\Brains\cPL117251\cPL117251_scaled', 'D:\TRAILMAP\Brains\cPL117252\cPL117252_scaled', 'D:\TRAILMAP\Brains\cPLF\cPLF_scaled', 'D:\TRAILMAP\Brains\NAc326F\NAc326F_scaled', 'D:\TRAILMAP\Brains\NAc326M\NAc326M_scaled', 'D:\TRAILMAP\Brains\NAc132502_4\NAc132502_4_scaled', 'D:\TRAILMAP\Brains\NAc1325023\NAc1325023_scaled', 'D:\TRAILMAP\Brains\VTA_1_Laser50\VTA_1_Laser50_scaled', 'D:\TRAILMAP\Brains\VTA325F\VTA325F_scaled', 'D:\TRAILMAP\Brains\VTA1129M\VTA1129M_scaled', 'D:\TRAILMAP\Brains\VTA11291F\VTA11291F_scaled'};

cd(folders{1})
s = imfinfo('FP.tif');
masks = zeros(s(1).Height,s(1).Width,numel(s));


for brain = 1:length(folders)
    brain
    w = folders{brain};
    tic
    cd(w)
    s = imfinfo('FP.tif');
    
    %Load Model 2 segmentation
    model2 = uint8(zeros(s(1).Height,s(1).Width,numel(s)));
    for i = 1:numel(s)
        model2(:,:,i) = imread('FP.tif',i);
    end
    
    %Load Model 3 segmentation
    model3 = uint8(zeros(s(1).Height,s(1).Width,numel(s)));
    for i = 1:numel(s)
        model3(:,:,i) = imread('FP_stri.tif',i);
    end
    
    %Load Model 1 segmentation
    model1 = uint8(zeros(s(1).Height,s(1).Width,numel(s)));
    for i = 1:numel(s)
        model1(:,:,i) = imread('FP_cort2.tif',i);
    end
    
    b = [0];
    backgroundlogical = ismember(regions,b);
    
    
    %Select regions where you would like to replace default segmentation
    %(Model 2) with Model 3.
    rmodel3 = [354	370	379	386	771	1117	1132	987	549	178	27	321	138	239	262	444	51	571	186	483	1008	1044	406	609	637	313	323	215	531	294	749	795	50	339	4	1052	197	591	872	275	672	56	803	351	1022	1031	581	564 797];
    model3logical = ismember(regions,rmodel3);
    
    %Select regions where you would like to replace default segmentation
    %(Model 2) with Model 1.
    rmodel1 = [612	10671	141	157	1004	331	515	693	88	980	302	403	754	596	298	1037	1084	502	843	918	926	1057	184	417	1002	1011	1018	1027	254	322	378	985	993	541	385	394	402	409	425	533	677	723	731	746	895	922	104	111	119	698	151	159	507	566	589	619	639	647	788	961	451	327	334	780	942 312782546	312782574	312782628	484682470];
    model1logical = ismember(regions,rmodel1);    
    
    %Apply segmentations by region
    for l = 1:numel(s)
        for k = 1:s(1).Width
            for j = 1:s(1).Height
                if backgroundlogical(j,k,l)==1
                    model2(j,k,l) = 0;
                end
                if model3logical(j,k,l)==1
                    model2(j,k,l) = model3(j,k,l);
                end
                if model1logical(j,k,l)==1
                    model2(j,k,l) = model1(j,k,l);
                end
            end
        end
    end
cd 'C:\Users\Michael\Documents\TRAILMAP\Cropping'
saveastiff(model2, strcat(w, '\FP_comb2.tif'))    
end

                