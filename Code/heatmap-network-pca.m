%Takes axon counts from each brain and plots them as a heatmap, which can
%be sorted by Allen Brain atlas order or in a custom-defined order. Also
%extracts correlational values for network analysis and
%plots each brain in PCA space based on regional axon counts.

%%
%Load Axon Counts and Ontology

%ontology: Allen Brain Atlas ontology file
ontology = readtable('C:\Users\Michael\Documents\TRAILMAP\Cropping\aba_ontology.csv');

%folders: folders (1 per brain) containing processed brain skeletons (FP_skel.tif)
folders = {'D:\TRAILMAP\Brains\cPL112623\cPL112623_scaled', 'D:\TRAILMAP\Brains\cPL117251\cPL117251_scaled', 'D:\TRAILMAP\Brains\cPL117252\cPL117252_scaled', 'D:\TRAILMAP\Brains\cPLF\cPLF_scaled', 'D:\TRAILMAP\Brains\NAc326F\NAc326F_scaled', 'D:\TRAILMAP\Brains\NAc326M\NAc326M_scaled', 'D:\TRAILMAP\Brains\NAc132502_4\NAc132502_4_scaled', 'D:\TRAILMAP\Brains\NAc1325023\NAc1325023_scaled', 'D:\TRAILMAP\Brains\VTA_1_Laser50\VTA_1_Laser50_scaled', 'D:\TRAILMAP\Brains\VTA325F\VTA325F_scaled', 'D:\TRAILMAP\Brains\VTA1129M\VTA1129M_scaled', 'D:\TRAILMAP\Brains\VTA11291F\VTA11291F_scaled'};

htmp = ontology.id;
parent = ontology.name;
abb = ontology.acronym;
mainparent = ontology.main_parent;

for brain = 1:numel(folders)
    cd(folders{brain})
    axoncounts = readtable('AxonCounts_new.xlsx');    
    for i = 1:length(htmp)
        for j = 1:length(axoncounts.atlasNumber)
            if ismember(htmp(i,1), axoncounts.atlasNumber(j)) && axoncounts.atlasNumber(j) ~= 312782624
                htmp(i,(brain+1)) = table2array(axoncounts(j,5));
            end
        end
    end
end

htmp = array2table(htmp);
htmp(:,(length(folders)+2)) = parent;
htmp(:,(length(folders)+3)) = abb;
htmp = htmp(any(table2array(htmp(:,2)),2),:);
%%
%Plot heatmap sorted by allen brain atlas

htmpl = table2array(htmp(:,2:(length(folders)+1)));
htmplabels = htmp(:,(length(folders)+2));
%htmplabels(
cd('C:\Users\Michael\Documents\TRAILMAP\Cropping')
figure
h = heatmap(htmpl(:,1:12));
h.XDisplayLabels = {'cPL112623' 'cPL117251' 'cPL117252' 'cPLF' 'NAc326F' 'NAc326M' 'NAc132502_4' 'NAc1325023' 'VTA_1_Laser50' 'VTA325F' 'VTA1129M' 'VTA11291F'};%  };
h.YDisplayLabels = table2array(htmplabels(:,1));
h.GridVisible = 'off'
colormap(viridis)
h

%%
%Plot heatmap sorted in custom order

htmpsort = htmp(:,1:14);
for i = 1:height(htmp)
    htmpsort(i,length(folders)+1+2) = {mean(table2array(htmp(i,2:5)))};
    htmpsort(i,length(folders)+2+2) = {mean(table2array(htmp(i,6:9)))};
    htmpsort(i,length(folders)+3+2) = {mean(table2array(htmp(i,10:13)))};
    htmpsort(i,length(folders)+4+2) = {mean(table2array(htmp(i,6:13)))};
    htmpsort(i,length(folders)+5+2) = {mean(table2array(htmp(i,2:9)))};
    htmpsort(i,length(folders)+6+2) = {mean(table2array(htmp(i,[2:5, 9:13])))};
    if table2array(htmpsort(i,length(folders)+1+2)) > table2array(htmpsort(i,length(folders)+3+2))
        htmpsort(i,length(folders)+7+2) = {1};
        htmpsort(i,length(folders)+8+2) = htmpsort(i,length(folders)+1+2);
    else
        htmpsort(i,length(folders)+7+2) = {0};
        htmpsort(i,length(folders)+8+2) = {0};
    end
    if table2array(htmpsort(i,length(folders)+2+2)) > table2array(htmpsort(i,length(folders)+6+2))
        htmpsort(i,length(folders)+9+2) = {1};
        htmpsort(i,length(folders)+10+2) = htmpsort(i,length(folders)+2+2);
    else
        htmpsort(i,length(folders)+9+2) = {0};
        htmpsort(i,length(folders)+10+2) = {0};
    end
    if table2array(htmpsort(i,length(folders)+3+2)) > table2array(htmpsort(i,length(folders)+1+2))
        htmpsort(i,length(folders)+11+2) = {1};
        htmpsort(i,length(folders)+12+2) = htmpsort(i,length(folders)+3+2);
    else
        htmpsort(i,length(folders)+11+2) = {0};
        htmpsort(i,length(folders)+12+2) = {0};
    end
end

htmpsort = sortrows(htmpsort, [21 22 25 26], 'descend');

figure
% htmpz = normalize(htmpl, 2);
% htmpzn = normalize(htmpz, 'range');
j = heatmap(table2array(htmpsort(:,2:13)));
j.XDisplayLabels = {'cPL112623' 'cPL117251' 'cPL117252' 'cPLF' 'NAc326F' 'NAc326M' 'NAc132502_4' 'NAc1325023' 'VTA_1_Laser50' 'VTA325F' 'VTA1129M' 'VTA11291F'};
j.YDisplayLabels = table2array(htmpsort(:,14));
j.GridVisible = 'off'
colormap(viridis)
j


%%
%Extract Pearson R correlations and P values for network analysis
all = htmpl(:,1:12);

alll = [table2array(htmp(:,1)), all].';



for i = 1:length(alll)
    if mean(alll(2:size(alll,1),i)) < 0.001
        alll(2:size(alll,1),i) = 0;
    end
end


allc = alll(:,any(alll(2:size(alll,1),:)));
for i = 1:length(allc)
    for j = 1:size(htmp,1)
        if table2array(htmp(j,1)) == allc(1,i)
            alllabels(i,1) = htmp(j,length(folders)+2);
            alllpca1(i,1) = weights1(i,1);
        end
    end
end  


[R,P] = corrcoef(allc(2:size(allc,1),:));
Rallfull = R;
Pallfull = P;
Callr = triu(R,1); %extracts elements above main diagnoal & main diagnoal
Callp = triu(P,1);

figure
corall = heatmap(Rallfull);
corall.XDisplayLabels = table2array(alllabels(:,1));
corall.YDisplayLabels = table2array(alllabels(:,1));
colormap jet


allsource = (alllabels);
allsource = repmat(allsource,1,height(allsource));
allwtpca = repmat(alllpca1,1,size(alllpca1,1));
alltarget = rows2vars(allsource); 
alltarget = alltarget(:,2:width(alltarget));
for i = 1:height(alllabels)
    for j = 1:length(parent)
        if strcmp(alllabels{i,1}, parent{j,1})
            allparent(i,1) = mainparent(j);
        end
    end
end


ck = find(Callp < 0.05 & Callp ~= 0 & Callr > 0.85);
C = {'source', 'target', 'r', 'parent', 'pca1'};
for i = 1:length(ck)
    ii = ck(i);
    [iix, iiy] = ind2sub(size(Callr),ii);
    C(i+1,1) = allsource{iix,iiy};
    C(i+1,2) = alltarget{iix,iiy};
    C(i+1,3) = num2cell(Callr(ii));
    C(i+1,4) = cellstr(allparent{iix,1});
    C(i+1,5) = num2cell(allwtpca(iix,1));
end


cd 'C:\Users\Michael\Documents\NetworkX\trailmap\' % location of saved files
    % column A = source node 
    % column B = target node
xlswrite('all.xlsx', C);


gcf
colormap inferno
%%
%Principal component analysis by whole-brain output patterns

a = [255/255 225/255 114/255];
b = [0.667 0.808 247/255];
c = [0.757 0.557 189/255];
color = [a' a' a' a' b' b' b' b' c' c' c' c'];
htmpi = htmpl';
[COEFF, SCORE, LATENT, TSQUARED, EXPLAINED] = pca(htmpi);
reducedDimension = COEFF(:,1:2);
scatter(SCORE(:,1),SCORE(:,2), [], color')
figure
weights1 = COEFF(:,1);
wt = heatmap(weights1)
wt.YDisplayLabels = table2array(htmplabels(:,1));
%colormap inferno
%%
figure();
pareto(EXPLAINED);
title('Percentage of Variance Explained');