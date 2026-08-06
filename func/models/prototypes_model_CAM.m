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
%            'CategoryPrototypes' or 'KmeansPrototypes'
% - .prototypes: the location of the prototypes
% - .stdTRB: the sigma of the truncation effect
%
% optinal fiels are:
% - .stdNoise: sigma used to simulate noisy data (0 means no noise).
%
% erreTi 20190407

if nargin<2; opt=[];end

if ~isfield(opt, 'stdTRB'); opt.stdTRB=0.1;end
if ~isfield(opt, 'stdNoise'); opt.stdNoise=0;end
if ~isfield(opt, 'method'); opt.method = 'CategoryPrototypes';end
if ~isfield(opt, 'w'); opt.w = 0.75;end
if ~isfield(opt, 'w_theta'); opt.w_theta = 0.75;end
if ~isfield(opt, 'w_r'); opt.w_r = 0.75;end
if ~isfield(opt, 'truncation'); opt.truncation = 1;end
if ~isfield(opt, 'categories'); opt.categories = {'bottom_left', 'top_left', 'bottom_right', 'top_right'};end

% get the options
w           = opt.w;
w_theta     = opt.w_theta;
w_r         = opt.w_r;
prototypes  = opt.prototypes;
categories  = opt.categories;
method      = opt.method;
stdTRB      = opt.stdTRB;
stdNoise    = opt.stdNoise;
% Assign a prototype to each point. I am using two ways for now: 1) the
% prototype of a dot depends on the subquadrant (data must be NORMALIZED
% for this); 2) the data are assigned to the related centroid estimated
% using KMEANS
ProtoTable      = helper_assignPrototypes2Targets(ProtoTable, prototypes, categories, method);

% STILL NOT WORKING

if opt.truncation
%     w_theta         = w;
%     w_r             = w;
    sigmaM_theta    = stdTRB; % stdTRB: 0-1
    sigmaM_r        = stdTRB; % stdTRB: 0-1
    ProtoTable  = helper_compute_trucation_bias(ProtoTable, w_theta, sigmaM_theta, w_r, sigmaM_r);
    Responses   = ProtoTable.ResponseDots_xy;
%     Responses   = w.*ProtoTable.ResponseDots_xy + (1-w).*ProtoTable.prototypeXY;
    
else    
    Responses = w.*ProtoTable.ActualDots_xy + (1-w).*ProtoTable.prototypeXY;
end

if stdNoise
    Responses(:, 1) = Responses(:,1) + random('norm', 0, stdNoise, size(Responses, 1), 1);
    Responses(:, 2) = Responses(:,2) + random('norm', 0, stdNoise, size(Responses, 1), 1);
end

ProtoTable.ResponseDots_xy = Responses;

function ProtoTable = helper_assignPrototypes2Targets(ProtoTable, prototypes, categories, method)

figure_size          = ProtoTable.Properties.UserData.ShapeRect;
vert_boundaries      = mean(figure_size([1 3]));
horz_boundaries      = mean(figure_size([2 4]));


if strcmp(method, 'CategoryPrototypes')
    % Method 1
    ProtoTable.prototypeXY     = zeros(size(ProtoTable, 1), 2);
    ProtoTable.category_id      = zeros(size(ProtoTable, 1), 1);
    ProtoTable.category_name    = cell(size(ProtoTable, 1), 1);
    b = [vert_boundaries horz_boundaries];
    for p = 1:size(prototypes, 1)
        protoInd=ismember(double(ProtoTable.ActualDots_xy<b), double(prototypes(p,:)<b),'rows');
        %         ProtoTable.CategoryPrototypes(protoInd,:) = repmat(prototypes(p,:), sum(protoInd), 1);
        %         ProtoTable.CategoryID(protoInd,:) = p;
        ProtoTable.prototypeXY(protoInd,:) = repmat(prototypes(p,:), sum(protoInd), 1);
        ProtoTable.category_id(protoInd,:) = p;
        ProtoTable.category_name(protoInd) = categories(p);
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


function ProtoTable = helper_compute_trucation_bias(ProtoTable, w_theta, sigmaM_theta, w_r, sigmaM_r)

% stdTRB              = stdTRB/ProtoTable.Properties.UserData.ShapeRect(3);
ProtoTable          = prototypes_normalize_data(ProtoTable, struct('centreOnly', 1));


figure_size         = ProtoTable.Properties.UserData.ShapeRect;
horz_border         = mean(figure_size([1 3]));
vert_border         = mean(figure_size([2 4]));

sigmaM_theta        = 90*sigmaM_theta;
sigmaM_r            = 2*figure_size(3)*sigmaM_r;

T                   = ProtoTable.ActualDots_xy;
% num_trials          = size(T, 1);

category_id = unique(ProtoTable.category_id);

for i = 1:length(category_id)
    
    idx = ProtoTable.category_id==category_id(i);
%     % top-right quadrant
    mu_x                  = T(idx,1);
    mu_y                  = T(idx,2); 
    
    prototypeXY = unique(ProtoTable.prototypeXY(idx,:), 'rows');
    
    if prototypeXY(2)<horz_border && prototypeXY(1)<vert_border
        
        % bottom-left
        theta_min           = 180;
        theta_max           = 270;

        a_r                 = 0;
        [~, b_r]            = cart2pol(0, figure_size(3));
    elseif prototypeXY(2)>horz_border && prototypeXY(1)<vert_border
        
        % top-left
        theta_min           = 90;
        theta_max           = 180;
        a_r                 = 0;
        [~, b_r]            = cart2pol(0, figure_size(3));
    elseif prototypeXY(2)<horz_border && prototypeXY(1)>vert_border
        
        % bottom-right
        theta_min           = 270;
        theta_max           = 360;
        a_r                 = 0;
        [~, b_r]            = cart2pol(0, figure_size(3));
    elseif prototypeXY(2)>horz_border && prototypeXY(1)>vert_border
        
        % top-right
        theta_min           = 0;
        theta_max           = 90;
        a_r                 = 0;
        [~, b_r]            = cart2pol(0, figure_size(3));
    end
    

%     figure; polarscatter(theta_min, R);
%     hold on; polarscatter(theta_max, R);
    
    [p_theta, p_r]                      = cart2pol(prototypeXY(1), prototypeXY(2));
    p_theta                             = rad2deg(p_theta);
    p_theta                             = mod(p_theta, 360);
    [R_x, R_y]                          = CAM_polar(mu_x, mu_y, w_theta, sigmaM_theta, p_theta, theta_min, theta_max, w_r, sigmaM_r, p_r, a_r, b_r);
    ProtoTable.ResponseDots_xy(idx, :)  = [R_x, R_y];
    
    
    
end

ProtoTable          = prototypes_denormalize_data(ProtoTable);

function ProtoTable = helper_compute_trucation_bias_gemini(ProtoTable, stdTRB)

% stdTRB              = stdTRB/ProtoTable.Properties.UserData.ShapeRect(3);
ProtoTable          = prototypes_normalize_data(ProtoTable, struct('centreOnly', 1));


figure_size         = ProtoTable.Properties.UserData.ShapeRect;
horz_border         = mean(figure_size([1 3]));
vert_border         = mean(figure_size([2 4]));
b                   = [vert_border horz_border];

T                   = ProtoTable.ActualDots_xy;
% num_trials          = size(T, 1);

category_id = unique(ProtoTable.category_id);

for i = 1:length(category_id)
    
    idx = ProtoTable.category_id==category_id(i);
    num_trials          = sum(idx);
    % top-right quadrant
    mx                  = T(idx,1) + stdTRB * randn(num_trials, 1);
    my                  = T(idx,2) + stdTRB * randn(num_trials, 1);
    % [theta, rho] = pol2cart(T(:, 1), T(:,2));
    
    %     switch ProtoTable.category_name
    
    if unique(ProtoTable.prototypeXY(idx,2))<horz_border & unique(ProtoTable.prototypeXY(idx,1))<vert_border
        
        % bottom-left
        theta_min           = -cart2pol(-1, 0);
        theta_max           = cart2pol(0, -1);
%         R                   = 1;
        [~, R]              = cart2pol(0, figure_size(3));
    elseif unique(ProtoTable.prototypeXY(idx,2))>horz_border & unique(ProtoTable.prototypeXY(idx,1))<vert_border
        
        % top-left
        theta_min           = cart2pol(0, 1);
        theta_max           = cart2pol(-1, 0);
        [~, R]              = cart2pol(0, figure_size(3));
    elseif unique(ProtoTable.prototypeXY(idx,2))<horz_border & unique(ProtoTable.prototypeXY(idx,1))>vert_border
        
        % bottom-right
        theta_min           = cart2pol(0, -1);
        theta_max           = cart2pol(1, 0);
        [~, R]              = cart2pol(0, figure_size(3));
    elseif unique(ProtoTable.prototypeXY(idx,2))>horz_border & unique(ProtoTable.prototypeXY(idx,1))>vert_border
        
        % top-right
        theta_min           = cart2pol(1, 0);
        theta_max           = cart2pol(0, 1);
        [~, R]              = cart2pol(0, figure_size(3));
    end
    
%     figure; polarscatter(theta_min, R);
%     hold on; polarscatter(theta_max, R);
    
    [x_hat, y_hat]      = TMP_category_adjustment_estimate_polar(mx, my, R, theta_min, theta_max, stdTRB);
    
    ProtoTable.ResponseDots_xy(idx, :) = [x_hat, y_hat];
    
    
    
end

ProtoTable          = prototypes_denormalize_data(ProtoTable);

