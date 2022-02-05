%Takes final processed whole-brain skeletons and extracts average pixel
%density for a cell type in each 100um voxel of a coronal slice. Plots
%these densities as dots with visible area of a dot corresponding with
%increased innervation by that cell type.

%folders: folders (1 per brain) containing processed brain skeletons (FP_skel.tif)
folders = {'D:\TRAILMAP\Brains\cPL112623\cPL112623_scaled', 'D:\TRAILMAP\Brains\cPL117251\cPL117251_scaled', 'D:\TRAILMAP\Brains\cPL117252\cPL117252_scaled', 'D:\TRAILMAP\Brains\cPLF\cPLF_scaled', 'D:\TRAILMAP\Brains\NAc326F\NAc326F_scaled', 'D:\TRAILMAP\Brains\NAc326M\NAc326M_scaled', 'D:\TRAILMAP\Brains\NAc132502_4\NAc132502_4_scaled', 'D:\TRAILMAP\Brains\NAc1325023\NAc1325023_scaled', 'D:\TRAILMAP\Brains\VTA_1_Laser50\VTA_1_Laser50_scaled', 'D:\TRAILMAP\Brains\VTA325F\VTA325F_scaled', 'D:\TRAILMAP\Brains\VTA1129M\VTA1129M_scaled', 'D:\TRAILMAP\Brains\VTA11291F\VTA11291F_scaled'};

w = folders{1};
cd(w)
s = imfinfo('FP_skel.tif');
test = uint8(zeros(numel(folders),s(1).Height,s(1).Width,numel(s)));
for brain = 1:12
    w = folders{brain};
    for j = 1:1
        brain
        tic
        cd(w)
        s = imfinfo('FP_skel.tif');
        for i = 1:numel(s)
            test(brain,:,:,i) = imread('FP_skel.tif',i);
        end
        toc
        
        %Select coronal slice to be plotted 
        slice_to_plot = 1031;
        
        slice = 1137-slice_to_plot;
        rm = rem(size(test,2),10);
        rn = rem(size(test,3),10);
        rp = rem(size(test,4),10);
        for m = 1:(size(test,2)-rm)/10
            for n = 1:(size(test,3)-rn)/10
                for p = 1:(size(test,4)-rp)/10
                    each{brain,m,n,p} = test(brain,1+rm+(m-1)*10:rm+m*10, 1+rn+(n-1)*10:rn+n*10, 1+rp+(p-1)*10:rp+p*10);
                    eachr{brain,m,n,p} = reshape(each{brain,m,n,p}, [1000,1]);
                    Density{brain,m,n,p} = sum(eachr{brain,m,n,p}>64)/1000;
                end
            end
        end
    end
end

%%
for i = 1:length(folders)
    flatdens(i,:) = cell2mat(reshape(Density(i,:,:,:), [1,515280]));
end
%%
flatdens2 = flatdens(:,any(flatdens));
%%

for n = 1:size(Density,2)
    for p = 1:size(Density,3)
        avgdens{1,n,p} = mean(cell2mat(Density(1:4,n,p)));
        avgdens{2,n,p} = mean(cell2mat(Density(5:8,n,p)));
        avgdens{3,n,p} = mean(cell2mat(Density(9:12,n,p)));
    end
end



%%
a = [255/255 225/255 114/255];
%a = [0.737 0.855 0.506];
b = [0.667 0.808 247/255];
c = [0.757 0.557 189/255];
% ab = cell(2,2);
% ab(1,1) = {[4,a; 5,b; 6,c]};
% ab(2,1) = {[3,a; 5,b; 4,c]};
% ab(1,2) = {[4,a; 4.1,b; 6,c]};
% ab(2,2) = {[6,a; 6.1,b; 3,c]};

for n = 1:size(Density,2)
    for p = 1:size(Density,3)
        ab(n,p) = {[avgdens(1,n,p),a; avgdens(2,n,p),b; avgdens(3,n,p),c]};
    end
end

absort = cell(size(ab));
for i = 1:size(ab,1)
    for j = 1:size(ab,2)
        absort(i,j) = {sortrows(ab{i,j},1)};
    end
end

%%
cell2mat(absort{i,j}(1,1))
%%
sf = 0.8;
for i = 1:size(absort,1)
    for j = 1:size(absort,2)
        r{i,j}(1) = cell2mat(absort{i,j}(1,1)) / sf;
        r{i,j}(2) = sqrt((cell2mat(absort{i,j}(2,1))/sf)^2 + r{i,j}(1)^2);
        r{i,j}(3) = sqrt((cell2mat(absort{i,j}(3,1))/sf)^2 + r{i,j}(2)^2);
        r{i,j}(4) = j;
        r{i,j}(5) = i;
    end
end

%%
for i = 1:size(r,1)
    for j = 1:size(r,2)
        rectangle('position',[r{i,j}(4),80-r{i,j}(5),2*r{i,j}(3),2*r{i,j}(3)], 'Curvature', [1 1], 'FaceColor', cell2mat(absort{i,j}(3,2)), 'EdgeColor', cell2mat(absort{i,j}(3,2)));
        rectangle('position',[r{i,j}(4)+r{i,j}(3)-1.1*r{i,j}(2),80-r{i,j}(5)+r{i,j}(3)-1.1*r{i,j}(2),2*r{i,j}(2),2*r{i,j}(2)], 'Curvature', [1 1], 'FaceColor', cell2mat(absort{i,j}(2,2)), 'EdgeColor', cell2mat(absort{i,j}(2,2)));
        rectangle('position',[r{i,j}(4)+r{i,j}(3)-1.1*r{i,j}(1),80-r{i,j}(5)+r{i,j}(3)-1.1*r{i,j}(1),2*r{i,j}(1),2*r{i,j}(1)], 'Curvature', [1 1], 'FaceColor', cell2mat(absort{i,j}(1,2)), 'EdgeColor', cell2mat(absort{i,j}(1,2)));
    end
end
axis equal
cd('C:\Users\Michael\Documents\TRAILMAP\Cropping\Atlas AI\new')
f = gcf;
exportgraphics(f,'dot1031.pdf', 'contenttype', 'vector')