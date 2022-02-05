%Takes final processed whole-brain skeletons and extracts
%anterior-posterior (or medial-lateral or dorsal-ventral) distributions of
%axons within that region, normalized to total fluorescence.

%%
cd C:\Users\Michael\Documents\TRAILMAP\Cropping

%regions: annotation file with pixel values corresponding to atlas ID#
regions = nrrdread('C:\Users\Michael\Documents\TRAILMAP\Cropping\annotation_10_lsfm_collapse_crop_flip_newf.nrrd');
regions = double(regions);

%folders: folders (1 per brain) containing processed brain skeletons (FP_skel.tif)
folders = {'D:\TRAILMAP\Brains\cPL112623\cPL112623_scaled', 'D:\TRAILMAP\Brains\cPL117251\cPL117251_scaled', 'D:\TRAILMAP\Brains\cPL117252\cPL117252_scaled', 'D:\TRAILMAP\Brains\cPLF\cPLF_scaled', 'D:\TRAILMAP\Brains\NAc326F\NAc326F_scaled', 'D:\TRAILMAP\Brains\NAc326M\NAc326M_scaled', 'D:\TRAILMAP\Brains\NAc132502_4\NAc132502_4_scaled', 'D:\TRAILMAP\Brains\NAc1325023\NAc1325023_scaled', 'D:\TRAILMAP\Brains\VTA_1_Laser50\VTA_1_Laser50_scaled', 'D:\TRAILMAP\Brains\VTA325F\VTA325F_scaled', 'D:\TRAILMAP\Brains\VTA1129M\VTA1129M_scaled', 'D:\TRAILMAP\Brains\VTA11291F\VTA11291F_scaled'};

w = folders{1};
cd(w)
s = imfinfo('FP_skel.tif');
test = uint8(zeros(numel(folders),s(1).Height,s(1).Width,numel(s)));

%rroi: region(s) to be included in directional distribution plot
rroi = [254];
roilogical = ismember(regions, rroi);
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
        roi(brain,:,:,:) = test(brain,:,:,:);
            for l = 1:size(test,4)
                for k = 1:size(test,3)
                    for j = 1:size(test,2)
                        if roilogical(j,k,l)~=1
                            roi(brain,j,k,l) = 0;
                        end
                    end
                end
            end
        toc
        rm = rem(size(test,2),10);
        rn = rem(size(test,3),10);
        rp = rem(size(test,4),10);
        for m = 1:(size(test,2)-rm)/10
            for n = 1:(size(test,3)-rn)/10
                for p = 1:(size(test,4)-rp)/10
                    each{brain,m,n,p} = roi(brain,1+rm+(m-1)*10:rm+m*10, 1+rn+(n-1)*10:rn+n*10, 1+rp+(p-1)*10:rp+p*10);
                    eachr{brain,m,n,p} = reshape(each{brain,m,n,p}, [1000,1]);
                    Density{brain,m,n,p} = sum(eachr{brain,m,n,p}>64)/1000;
                end
            end
        end
        for m = 1:(size(test,2)-rm)/10
            for n = 1:(size(test,3)-rn)/10
                for p = 1:(size(test,4)-rp)/10
                    eachwb{brain,m,n,p} = test(brain,1+rm+(m-1)*10:rm+m*10, 1+rn+(n-1)*10:rn+n*10, 1+rp+(p-1)*10:rp+p*10);
                    eachrwb{brain,m,n,p} = reshape(eachwb{brain,m,n,p}, [1000,1]);
                    Densitywb{brain,m,n,p} = sum(eachrwb{brain,m,n,p}>64)/1000;
                end
            end
        end
    end
end
%%
%Select distribution to be plotted

%for posterior anterior: [1 2 3 4] or comment out
%for lateral medial: [1 4 2 3]
%for ventral dorsal: [1 3 2 4]
%to flip, uncomment flip line

%Density = permute(Density, [1 3 4 2]);
Density=flip(Density, 2);
%%
clear averageamygcpl averageamygnac averageamygvta
for brain = 1:4
    flatwb = cell2mat(reshape(Densitywb(brain,:,:,:), [1,(size(Densitywb,2)*size(Densitywb,3)*size(Densitywb,4))]));
    for m = 1:size(Density,2)
        flatslice = cell2mat(reshape(Density(brain,m,:,:), [1,(size(Density,3)*size(Density,4))]));
        flatslice2 = flatslice(flatslice~=0);
        averageroicpl(brain,m) = mean(flatslice)/mean(flatwb);
    end
end

for brain = 5:8
    flatwb = cell2mat(reshape(Densitywb(brain,:,:,:), [1,(size(Densitywb,2)*size(Densitywb,3)*size(Densitywb,4))]));
    for m = 1:size(Density,2)
        flatslice = cell2mat(reshape(Density(brain,m,:,:), [1,(size(Density,3)*size(Density,4))]));
        flatslice2 = flatslice(flatslice~=0);
        averageroinac(brain-4,m) = mean(flatslice)/mean(flatwb);

    end
end

for brain = 9:12        
    flatwb = cell2mat(reshape(Densitywb(brain,:,:,:), [1,(size(Densitywb,2)*size(Densitywb,3)*size(Densitywb,4))]));
    for m = 1:size(Density,2)
        flatslice = cell2mat(reshape(Density(brain,m,:,:), [1,(size(Density,3)*size(Density,4))]));
        flatslice2 = flatslice(flatslice~=0);
        averageroivta(brain-8,m) = mean(flatslice)/mean(flatwb);
    end
end
%%
options.handle     = figure(1);
options.color_area = [128 193 219]./255;    % Blue theme
options.color_line = [ 52 148 186]./255;
%options.color_area = [243 169 114]./255;    % Orange theme
%options.color_line = [236 112  22]./255;
options.alpha      = 0.5;
options.line_width = 2;
options.error      = 'sem';

optionscpl = options;
optionscpl.color_area = [255 216 114]./255;
optionscpl.color_line = [240 174 0]./255;
plot_areaerrorbar(averageroicpl, optionscpl);

optionsnac = options;
optionsnac.color_area = [170 206 237]./255;
optionsnac.color_line = [60 152 209]./255;
plot_areaerrorbar(averageroinac, optionsnac);

optionsvta = options;
optionsvta.color_area = [193 142 179]./255;
optionsvta.color_line = [146 68 116]./255;
plot_areaerrorbar(averageroivta, optionsvta);
%%
%Víctor Martínez-Cagigal (2022). Shaded area error bar plot (https://www.mathworks.com/matlabcentral/fileexchange/58262-shaded-area-error-bar-plot), MATLAB Central File Exchange. Retrieved February 5, 2022.
% ----------------------------------------------------------------------- %
% Function plot_areaerrorbar plots the mean and standard deviation of a   %
% set of data filling the space between the positive and negative mean    %
% error using a semi-transparent background, completely customizable.     %
%                                                                         %
%   Input parameters:                                                     %
%       - data:     Data matrix, with rows corresponding to observations  %
%                   and columns to samples.                               %
%       - options:  (Optional) Struct that contains the customized params.%
%           * options.handle:       Figure handle to plot the result.     %
%           * options.color_area:   RGB color of the filled area.         %
%           * options.color_line:   RGB color of the mean line.           %
%           * options.alpha:        Alpha value for transparency.         %
%           * options.line_width:   Mean line width.                      %
%           * options.x_axis:       X time vector.                        %
%           * options.error:        Type of error to plot (+/-).          %
%                   if 'std',       one standard deviation;               %
%                   if 'sem',       standard error mean;                  %
%                   if 'var',       one variance;                         %
%                   if 'c95',       95% confidence interval.              %
% ----------------------------------------------------------------------- %
%   Example of use:                                                       %
%       data = repmat(sin(1:0.01:2*pi),100,1);                            %
%       data = data + randn(size(data));                                  %
%       plot_areaerrorbar(data);                                          %
% ----------------------------------------------------------------------- %
%   Author:  Victor Martinez-Cagigal                                      %
%   Date:    30/04/2018                                                   %
%   E-mail:  vicmarcag (at) gmail (dot) com 
function plot_areaerrorbar(data, options)
    % Default options
    if(nargin<2)
        options.handle     = figure(1);
        options.color_area = [128 193 219]./255;    % Blue theme
        options.color_line = [ 52 148 186]./255;
        %options.color_area = [243 169 114]./255;    % Orange theme
        %options.color_line = [236 112  22]./255;
        options.alpha      = 0.5;
        options.line_width = 2;
        options.error      = 'sem';
    end
    if(isfield(options,'x_axis')==0), options.x_axis = 1:size(data,2); end
    options.x_axis = options.x_axis(:);
    
    % Computing the mean and standard deviation of the data matrix
    data_mean = mean(data,1);
    data_std  = std(data,0,1);
    
    % Type of error plot
    switch(options.error)
        case 'std', error = data_std;
        case 'sem', error = (data_std./sqrt(size(data,1)));
        case 'var', error = (data_std.^2);
        case 'c95', error = (data_std./sqrt(size(data,1))).*1.96;
    end
    
    % Plotting the result
    figure(options.handle);
    x_vector = [options.x_axis', fliplr(options.x_axis')];
    patch = fill(x_vector, [data_mean+error,fliplr(data_mean-error)], options.color_area);
    set(patch, 'edgecolor', 'none');
    set(patch, 'FaceAlpha', options.alpha);
    hold on;
    plot(options.x_axis, data_mean, 'color', options.color_line, ...
        'LineWidth', options.line_width);
    hold on;
    
end