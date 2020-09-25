function ProtoTable = prototypes_model_CAM(ProtoTable, opt)
% function ProtoTable = prototypes_model_CAM(ProtoTable, opt)
%
% This function provides an implementation of the Category Adjustment Model
% (CAM) as suggested by Huttenlocher et al., 1991. This version consider
% precise representations of boundaries. When targets are close to the
% boundaries, the responses are repelled away because of the truncation
% effect. 
%
% opt is a structure and must contain:
% - .w: the weight of the fine-grain memory
% - .method: the method used to assign each dot to a prototype
% - .prototypes: the location of the prototypes
% - .stdTRB: the sigma of the truncation effect
%
% optinal fiels are:
% - .stdNoise: sigma used to simulate noisy data (0 means no noise). 
%
% erreTi 20190407

if ~isfield(opt, 'stdTRB'); stdTRB=0;else; stdTRB=opt.stdTRB;end
if ~isfield(opt, 'stdNoise'); stdNoise=0;else; stdNoise=opt.stdNoise;end

% get the options
w           = opt.w;
prototypes  = opt.prototypes;
method      = opt.method;

% Assign a prototype to each point. I am using two ways for now: 1) the
% prototype of a dot depends on the subquadrant (data must be NORMALIZED
% for this); 2) the data are assigned to the related centroid estimated
% using KMEANS
ProtoTable      = helper_assignPrototypes2Targets(ProtoTable, prototypes, method);

% STILL NOT WORKING
% TruncBias = helper_compute_trucation_bias(ProtoTable, stdTRB);

TruncBias   = 0;

% this is the actual model
Responses = w.*ProtoTable.ActualDots_xy + (1-w).*ProtoTable.CategoryPrototypes + TruncBias;


if stdNoise
    Responses(:, 1) = Responses(:,1) + random('norm', 0, stdNoise, size(Responses, 1), 1);
    Responses(:, 2) = Responses(:,2) + random('norm', 0, stdNoise, size(Responses, 1), 1);
end

ProtoTable.ResponseDots_xy = Responses;

function ProtoTable = helper_assignPrototypes2Targets(ProtoTable, prototypes, method)

figure_size          = ProtoTable.Properties.UserData.ShapeRect;
vert_boundaries      = mean(figure_size([1 3]));
horz_boundaries      = mean(figure_size([2 4]));


if strcmp(method, 'CategoryPrototypes')
    % Method 1
    ProtoTable.CategoryPrototypes = zeros(size(ProtoTable, 1), 2);
    ProtoTable.CategoryID = zeros(size(ProtoTable, 1), 1);
    b = [vert_boundaries horz_boundaries];
    for p = 1:size(prototypes, 1)
        protoInd=ismember(double(ProtoTable.ActualDots_xy<b),double(prototypes(p,:)<b),'rows');
        ProtoTable.CategoryPrototypes(protoInd,:) = repmat(prototypes(p,:), sum(protoInd), 1);
        ProtoTable.CategoryID(protoInd,:) = p;
    end
end


if strcmp(method, 'KmeansPrototypes')
    
    % Method 2: kmeans centroids
    if ~isfield(ProtoTable.Properties.UserData, 'kmeans')
        error('if you want to use the kmeans centroids as initial prototypes, you have to compute the Kmeans first. Suggested function: ''prototypes_compute_clustering''');
    end
    
    ProtoTable.KmeansPrototypes = zeros(size(ProtoTable, 1), 2);
    Centroids = ProtoTable.Properties.UserData.kmeans.RespDots_xy.clusterInfo.Centroid;
    for p = 1:size(Centroids,1)
        idx = ProtoTable.Properties.UserData.kmeans.RespDots_xy.cluster_id==p;
        ProtoTable.KmeansPrototypes(idx,:) = repmat(Centroids(p,:), sum(idx), 1);
    end
end


function TruncBias = helper_compute_trucation_bias(ProtoTable, s)

figure_size         = ProtoTable.Properties.UserData.ShapeRect;
horz_border         = mean(figure_size([1 3]));
vert_border         = mean(figure_size([2 4]));

T = ProtoTable.ActualDots_xy;

% % correct for dots on the borders!
% T(ismember(T(:,1), horz_border), 1) = T(ismember(T(:,1), horz_border))+random('norm', 0, 0.00001*std(T(:,1)));
% T(ismember(T(:,2), vert_border), 2) = T(ismember(T(:,2), vert_border))+random('norm', 0, 0.00001*std(T(:,2)));


if s>0
    mu = ((T-[horz_border vert_border])/s);
else
    mu = 0;
end

% the last element indicate the sign
R_TruncBias = T + ((mvnpdf(mu).*s)./mvncdf(abs(mu))).*(mu./abs(mu));

TruncBias = R_TruncBias-T;