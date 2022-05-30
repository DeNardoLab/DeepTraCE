folders = {'C:\Users\Michael\Documents\TRAILMAP\TrainVal\TRAP_validation\seg-P60_3_TH_scaled'};
w = folders{1};
cd(w)
s = imfinfo('10um.tif');
test = uint8(zeros(s(1).Height,s(1).Width,numel(s)));

for brain = 1:length(folders)
    w = folders{brain};
    for j = 1:1
        brain
        tic
        cd(w)
        s = imfinfo('10um.tif');
        for i = 1:numel(s)
            test(:,:,i) = imread('10um.tif',i);
        end
        BW = imextendedmax(test,50);
        CC = bwconncomp(BW);
        
        %%
        for i = 1:CC.NumObjects,
            index = CC.PixelIdxList{i};
            if (numel(index) > 1 && (rem(numel(index),2) == 1))
                indexmed = median(index);
                indexnonmed = index(index~=indexmed);
                BW(indexnonmed) = false;
            else
            if (numel(index) > 1)
                indexmedeven = numel(index)/2;
                indexmed = index(indexmedeven);
                indexnonmed = index(index~=indexmed);
                BW(indexnonmed) = false;
            end
            end
        end
        BW8 = uint8(BW);
        cd C:\Users\Michael\Documents\TRAILMAP\Cropping
        options.compress = 'lzw';
        options.color = 0;
        options.overwrite = true;
        %%
        saveloc = strcat(folders(brain), '\maxpoints.tif');
        saveastiff(BW8, saveloc{1}, options)
        %%
    end
end

%%
cccheck = bwconncomp(BW);