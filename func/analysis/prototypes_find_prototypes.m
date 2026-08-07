function prototypesInfo=prototypes_find_prototypes(csimaps, mapType, dataType, gaussfilt)
% function csimaps=prototypes_find_prototypes(csimaps, mapType, dataType, gaussfilt)
%
% dataType: choose which data to use for statistics (default is 'W_SimixSubject_Tcorr')

if nargin <3; dataType='W_SimixSubject';end
if nargin<4; gaussfilt=5;end

assert(ismember(mapType, {'csi', 'cosine_map', 'kde'}), 'mapType: ''csi'', cosine_map, ''kde''');

data_type = prototypes_datatype(csimaps);
assert(strcmp(data_type, 'csimaps'), 'you need to run this function on csimaps data');

if ~isfield(csimaps, 'subj_id')
    if isfield(csimaps, 'z') || isfield(csimaps, 't') || isfield(csimaps, 't_masked')
        csimaps.subj_id={'group'};
    else
        error('wrong data');
    end
end


subjlist = unique(csimaps.subj_id);

% if ischar(subjlist)
if strcmp(subjlist, 'group')
    
    switch mapType
        case {'csi', 'cosine_map'}
            prototypesInfo=prototypes_find_prototypes_csi(csimaps, dataType, gaussfilt);
            
        case 'kde'
            prototypesInfo=prototypes_find_prototypes_kde(csimaps, dataType, gaussfilt);
            
            %         case 'kmeans'
            %             groupStat=prototypes_find_prototypes_kmeans(groupStat, dataType);
            
    end
else
    
    
    for s = 1:length(subjlist)
        subNum = subjlist{s};
        subjTrials = prototypes_slice(csimaps, subNum);
        
        switch mapType
            case {'csi', 'cosine_map'}
                if s==1;csimaps.Properties.Usercsimaps.cosine_map.clusterInfo=table;end
                subjTrials=prototypes_find_prototypes_csi(subjTrials, dataType, gaussfilt);
                subj_id = repmat(subNum, size(subjTrials.Properties.Usercsimaps.cosine_map.clusterInfo, 1), 1);
                clusterInfo = [table(subj_id) subjTrials.Properties.Usercsimaps.cosine_map.clusterInfo];
                csimaps.Properties.Usercsimaps.cosine_map.clusterInfo  = ...
                    [csimaps.Properties.Usercsimaps.cosine_map.clusterInfo; clusterInfo];
                
            case 'kde'
                if s==1;csimaps.Properties.Usercsimaps.KDE.clusterInfo=table;end
                subjTrials=prototypes_find_prototypes_kde(subjTrials, dataType, gaussfilt);
                subj_id = repmat(subNum, size(subjTrials.Properties.Usercsimaps.KDE.clusterInfo, 1), 1);
                clusterInfo = [table(subj_id) subjTrials.Properties.Usercsimaps.KDE.clusterInfo];
                csimaps.Properties.Usercsimaps.KDE.clusterInfo  = ...
                    [csimaps.Properties.Usercsimaps.KDE.clusterInfo; clusterInfo];
                
        end
        
        
    end
    
    
    
end


function prototypesInfo=prototypes_find_prototypes_csi(csimaps, dataType, gaussfilt)
prototypesInfo=find_centreOfMass(csimaps.(dataType), gaussfilt);
% display(prototypesInfo);

function csimaps=prototypes_find_prototypes_kde(csimaps, dataType, gaussfilt)
if ~isfield(csimaps.Properties.Usercsimaps, 'KDE')
    error('You need to run prototypes_compute_kde before running this analysis');
end

kde_map=csimaps.Properties.Usercsimaps.KDE;

com=find_centreOfMass(kde_map.(dataType), gaussfilt);
if isfield(csimaps.Properties.Usercsimaps, 'Experiment')
    Experiment = {csimaps.Properties.Usercsimaps.Experiment};
else
    Experiment = {''};
end
Experiment  = repmat(Experiment, size(com,1),1);
Analysis    = repmat({'KDE'}, size(com,1),1);
prototypesInfo = [com table(Experiment, Analysis)];

csimaps.Properties.Usercsimaps.KDE.clusterInfo=prototypesInfo;

str = sprintf('defined prototypes');
csimaps = prototypes_save_history(csimaps, str);

display(prototypesInfo);

function com=find_centreOfMass(X, gaussfilt)

X2=X;

if ~isempty(gaussfilt)
    X2 = imgaussfilt(X2, gaussfilt); % 5
end

X_bw = imbinarize(X2);
pos = regionprops('table', X_bw, X, 'Centroid', 'MajorAxisLength', 'MinorAxisLength', 'Eccentricity', 'Extent', 'EulerNumber', 'Orientation', 'MaxIntensity', 'MinIntensity', 'MeanIntensity', 'WeightedCentroid');
pos_img = X_bw;

X(~X_bw) = 0;

% find peaks
CC = bwconncomp(X_bw); % Blobs and their data
x = zeros(1, CC.NumObjects);
y = zeros(1, CC.NumObjects);
max_val = zeros(1, CC.NumObjects);

for c = 1:CC.NumObjects
    sub_X = zeros(size(X));
    sub_X(CC.PixelIdxList{c}) = X(CC.PixelIdxList{c});
    [max_val(c), max_idx] = max(sub_X(:));
    [x(c), y(c)]=ind2sub(size(sub_X),max_idx);
end
xy = [y' x'];
pos.PeakVal = max_val';
pos.PeakPos = xy;

Direction = repmat({'Positive'}, size(pos, 1), 1);
pos = [pos table(Direction)];


X = -X2;
X_bw = imbinarize(X);
neg = regionprops('table', X_bw, X, 'Centroid', 'MajorAxisLength', 'MinorAxisLength', 'Eccentricity', 'Extent', 'EulerNumber', 'Orientation', 'MaxIntensity', 'MinIntensity', 'MeanIntensity', 'WeightedCentroid');
neg_img = X_bw;


X(~X_bw) = 0;

% find peaks
CC = bwconncomp(X); % Blobs and their data
x = zeros(1, CC.NumObjects);
y = zeros(1, CC.NumObjects);
max_val = zeros(1, CC.NumObjects);

for c = 1:CC.NumObjects
    sub_X = zeros(size(X));
    sub_X(CC.PixelIdxList{c}) = X(CC.PixelIdxList{c});
    [max_val(c), max_idx] = max(sub_X(:));
    [x(c), y(c)]=ind2sub(size(sub_X),max_idx);
end
xy = [y' x'];% it seems correct like this, but I should check better
neg.PeakVal = max_val';
neg.PeakPos = xy;

Direction = repmat({'Negative'}, size(neg, 1), 1);
neg = [neg table(Direction)];

com = [pos; neg];
com.Properties.UserData.neg_mask=neg_img;
com.Properties.UserData.pos_mask=pos_img;
