%Takes the binarized skeletons for each brain from python and 
%combines them into a single skeleton for each brain.


%%
%folders: folders (1 per brain) containing subfolders of skeletons from previous step
folders = {'D:\TRAILMAP\Brains\cPL112623\cPL112623_scaled', 'D:\TRAILMAP\Brains\cPL117251\cPL117251_scaled', 'D:\TRAILMAP\Brains\cPL117252\cPL117252_scaled', 'D:\TRAILMAP\Brains\cPLF\cPLF_scaled', 'D:\TRAILMAP\Brains\NAc326F\NAc326F_scaled', 'D:\TRAILMAP\Brains\NAc326M\NAc326M_scaled', 'D:\TRAILMAP\Brains\NAc132502_4\NAc132502_4_scaled', 'D:\TRAILMAP\Brains\NAc1325023\NAc1325023_scaled', 'D:\TRAILMAP\Brains\VTA_1_Laser50\VTA_1_Laser50_scaled', 'D:\TRAILMAP\Brains\VTA325F\VTA325F_scaled', 'D:\TRAILMAP\Brains\VTA1129M\VTA1129M_scaled', 'D:\TRAILMAP\Brains\VTA11291F\VTA11291F_scaled'};
for brain = 1:numel(folders)
    d = dir(fullfile(folders{brain},'*thres*'));
    e = dir(fullfile([folders{brain} '/' d(1).name '/*tif*']));
    mkdir([folders{brain} '/skel_combined'])
    slice = imread([folders{brain} '/' d(1).name '/' e(1).name]);
    slice = zeros(size(slice,1),size(slice,2),8);
    axons = uint8(zeros(size(slice,1),size(slice,2),numel(e)));

    for i = 1:numel(e)
    parfor j = 1:8
    slice(:,:,j) = imread([folders{brain} '/' d(j).name '/' e(i).name])*-1*j;
    end
    axons(:,:,i) = sum(slice,3);
    imwrite(uint8(axons(:,:,i)),[folders{brain} '/skel_combined/a_' e(i).name]);
    disp(['combining slices; ' num2str(ceil(i/numel(e)*100)) '%'])
    end
    %%
    % binarize
    dimSkel = 5;
    thresh = imbinarize(axons,dimSkel/255); %,dimSkel/255 <-- took this out because it was not defined
    % analyze all object connectivity in the binary variable 'thresh'
    disp('analyzing connected components')
    CC = bwconncomp(thresh);
    numPixels = cellfun(@numel,CC.PixelIdxList);
    % save RAM
    elim = uint8(thresh);
    clear thresh
%%
    sizeCut = 90; % <-- Also not defined so I added a value
    for j = 1:CC.NumObjects
    if numPixels(j)<sizeCut
    elim(CC.PixelIdxList{j}) = 4; % color-code small objects
    CC.PixelIdxList{j} = {}; % remove small objects
    end
    end
    CC.PixelIdxList = CC.PixelIdxList(~cellfun(@isempty,CC.PixelIdxList));
    CC.NumObjects = numel(CC.PixelIdxList);
    numPixels = cellfun(@numel,CC.PixelIdxList);
    %QC check on small object removal
    elim(CC.PixelIdxList{find(numPixels==max(numPixels))}) = 0;
    % if QCimages
    % figure;
    % imshow(rot90(label2rgb(max(elim(:,:,zStack),[],3))))
    % title(folders{brain})
    % end
    % elim(CC.PixelIdxList{find(numPixels==max(numPixels))}) = 2;
    % if QCimages
    % figure;
    % imshow(rot90(label2rgb(max(elim(:,:,zStack),[],3))))
    % title(folders{brain})
    % end
    %%
    mkdir(folders{brain},'sizeCut_slices')
    for i = 1:numel(e)
    combined = squeeze(elim(:,:,i)) == 4;
    imwrite(uint8(squeeze(double(axons(:,:,i))).*~combined),[folders{brain} '/sizeCut_slices/a_' num2str(i,'%04.f') '.tif']);
    disp(['writing sizeCut slices; ' num2str(ceil(i/numel(e)*100)) '%'])
    end
end