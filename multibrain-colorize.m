%Overlays multiple skeletonized whole-brain images, with each brain being
%displayed in a user-defined color.

%%
s = imfinfo('D:\TRAILMAP\Brains\cPL112623\cPL112623_scaled\FP_skel.tif');
    %masks1 = uint8(zeros(s(1).Height,s(1).Width,numel(s)));
    
    %folders: folders (1 per brain) containing processed brain skeletons (FP_skel.tif)
    folders = {'D:\TRAILMAP\Brains\cPL112623\cPL112623_scaled', 'D:\TRAILMAP\Brains\cPL117251\cPL117251_scaled', 'D:\TRAILMAP\Brains\cPL117252\cPL117252_scaled', 'D:\TRAILMAP\Brains\cPLF\cPLF_scaled', 'D:\TRAILMAP\Brains\NAc326F\NAc326F_scaled', 'D:\TRAILMAP\Brains\NAc326M\NAc326M_scaled', 'D:\TRAILMAP\Brains\NAc132502_4\NAc132502_4_scaled', 'D:\TRAILMAP\Brains\NAc1325023\NAc1325023_scaled', 'D:\TRAILMAP\Brains\VTA_1_Laser50\VTA_1_Laser50_scaled', 'D:\TRAILMAP\Brains\VTA325F\VTA325F_scaled', 'D:\TRAILMAP\Brains\VTA1129M\VTA1129M_scaled', 'D:\TRAILMAP\Brains\VTA11291F\VTA11291F_scaled'};


    braincolors = zeros(12,3);
    
    %select colors for each brain
    braincolors(1,:) = [255,228,79]; %cpl112623
    braincolors(2,:) = [235,193,87]; %cpl117251
    braincolors(3,:) = [229,148,67]; %cpl117252
    braincolors(4,:) = [250,120,68]; %cplF
    braincolors(1,:) = [104,230,100]; %cpl112623
    braincolors(2,:) = [62,214,120]; %cpl117251
    braincolors(3,:) = [27,195,140]; %cpl117252
    braincolors(4,:) = [0,204,160]; %cplF
    braincolors(5,:) = [159,255,253]; %NAc326F
    braincolors(6,:) = [71,233,255]; %NAc326M
    braincolors(7,:) = [71,201,255]; %NAc132502_4
    braincolors(8,:) = [87,143,255]; %NAc1325023
    braincolors(9,:) = [255,137,221]; %VTA1laser50
    braincolors(10,:) = [210,139,249]; %VTA325F
    braincolors(11,:) = [184,113,255]; %VTA1129M
    braincolors(12,:) = [156,121,255]; %VTA11291F
    

    %%
    
    masks = zeros(s(1).Height,s(1).Width,numel(s));
    masks = masks(:,:,:,[1,1,1]);
    masks(:,:,:,:) = 255;
    
    vis = [4 5 12];
    
    for i = 1:length(vis)
        brain = vis(i)
        w = folders{brain};
        tic
        cd(w)
        s = imfinfo('FP_skel2.tif');
        test = uint8(zeros(s(1).Height,s(1).Width,numel(s)));
        for i = 1:numel(s)
            test(:,:,i) = imread('FP_skel2.tif',i);
        end
        
        for l = 1:numel(s)
            for k = 1:s(1).Width
                for j = 1:s(1).Height
                    for h = 1:15
                        if test(j,k,l) == 17*h
                            masks(j,k,l,1)=255-((255-masks(j,k,l,1)) + h*((255-braincolors(brain,1)))/20);
                            masks(j,k,l,2)=255-((255-masks(j,k,l,2)) + h*((255-braincolors(brain,2)))/20);
                            masks(j,k,l,3)=255-((255-masks(j,k,l,3)) + h*((255-braincolors(brain,3)))/20);
                        end
                        if masks(j,k,l,1) < 0
                            masks(j,k,l,1) = 0;
                        end
                        if masks(j,k,l,2) < 0
                            masks(j,k,l,2) = 0;
                        end
                        if masks(j,k,l,3) < 0
                            masks(j,k,l,3) = 0;
                        end
                    end
                end
            end
        end
    end

%     for l = 1:numel(s)
%         for k = 1:s(1).Width
%             for j = 1:s(1).Height
%                 for h = 0:15
%                     if masks2(j,k,l) == 17*h
%                         masks(j,k,l,2)=masks2(j,k,l);
%                         masks(j,k,l,3)=0;
%                     end
%                 end
%             end
%         end
%     end
    
    masks = permute(masks, [1,2,4,3]);
    masks8 = uint8(masks);
%%
options.compress = 'lzw';
options.color = 1;
options.overwrite = true;
cd 'C:\Users\Michael\Documents\TRAILMAP\Cropping'
saveastiff(masks8, 'C:\Users\Michael\Documents\TRAILMAP\Cropping\oneeachrgbwhite.tif', options)