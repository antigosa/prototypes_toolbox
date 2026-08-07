%% setup
clear; close all;
addpath(genpath('..\..\..\prototypes_toolbox'))
% addpath(genpath('..\..\..\CoSMoMVPA'))

%% Manipulate sigmaM_center and sigmaM_theta

% default sigmaM_edge   = 0.1
% default sigmaP_r      = 0.1
% default sigmaP_theta  = 0.1

sigmaM_center   = 0.01:0.05:0.2;
sigmaM_theta    = 0.01:0.05:0.2;

opt             = [];
opt.ShapeDim    = [200 200];
opt.stdNoise    = 0;

k = 1;
ProtoData = cell(1, length(sigmaM_center)*length(sigmaM_theta));

for i = 1:length(sigmaM_center)
    for j = 1:length(sigmaM_theta)
        
        opt.sigmaM_center = sigmaM_center(i);
        opt.sigmaM_theta = sigmaM_theta(j);
        
        ProtoTable      = prototypes_synthetic_DS('Circle', opt);
        ProtoTable      = prototypes_compute_errorVectors(ProtoTable);
        % ProtoTable = prototypes_normalize_data(ProtoTable);
        
        prototypes_check_prototable(ProtoTable, 1);
        
        ProtoData{k} = prototypes_ProtoStructure(ProtoTable);
        ProtoData{k}.sim.sigmaM_center = sigmaM_center(i);
        ProtoData{k}.sim.sigmaM_theta = sigmaM_theta(j);
        k = k+1;
    end
end

figure; 
tiledlayout(4, 4);
for i = 1:length(ProtoData)
    opt = [];
    opt.subj_id = 1;
    nexttile; prototypes_plot_dots(ProtoData{i}, 'both', opt);
    title(sprintf('sMC:%.02f - sMT%.02f', ProtoData{i}.sim.sigmaM_center, ProtoData{i}.sim.sigmaM_theta));
end

%% Manipulate sigmaM_edge and sigmaM_theta

% default sigmaM_center = 0.1
% default sigmaM_theta  = 0.1
% default sigmaP_r      = 0.1
% default sigmaP_theta  = 0.1

sigmaM_edge   = 0.01:0.05:0.2;
sigmaM_theta    = 0.01:0.05:0.2;

opt             = [];
opt.ShapeDim    = [200 200];
opt.stdNoise    = 0;

k = 1;
ProtoData = cell(1, length(sigmaM_edge)*length(sigmaM_theta));

for i = 1:length(sigmaM_edge)
    for j = 1:length(sigmaM_theta)
        
        opt.sigmaM_edge = sigmaM_edge(i);
        opt.sigmaM_theta = sigmaM_theta(j);
        
        ProtoTable      = prototypes_synthetic_DS('Circle', opt);
        ProtoTable      = prototypes_compute_errorVectors(ProtoTable);
        % ProtoTable = prototypes_normalize_data(ProtoTable);
        
        prototypes_check_prototable(ProtoTable, 1);
        
        ProtoData{k} = prototypes_ProtoStructure(ProtoTable);
        ProtoData{k}.sim.sigmaM_edge = sigmaM_edge(i);
        ProtoData{k}.sim.sigmaM_theta = sigmaM_theta(j);
        k = k+1;
    end
end

figure; 
tiledlayout(4, 4);
for i = 1:length(ProtoData)
    opt = [];
    opt.subj_id = 1;
    nexttile; prototypes_plot_dots(ProtoData{i}, 'both', opt);
    title(sprintf('sME:%.02f - sMT%.02f', ProtoData{i}.sim.sigmaM_edge, ProtoData{i}.sim.sigmaM_theta));
end

%% Manipulate sigmaP_r and sigmaP_theta

% default sigmaM_center = 0.1
% default sigmaM_edge   = 0.1
% default sigmaM_theta  = 0.1

sigmaP_r            = 0.001:0.05:0.2;
sigmaP_theta        = 0.001:0.05:0.2;

opt                 = [];
opt.ShapeDim        = [200 200];
opt.stdNoise        = 0;
opt.sigmaM_r        = 0.1;
opt.sigmaM_theta    = 0.1;

k = 1;
ProtoData = cell(1, length(sigmaP_r)*length(sigmaP_theta));

for i = 1:length(sigmaP_r)
    for j = 1:length(sigmaP_theta)
        
        opt.sigmaP_r = sigmaP_r(i);
        opt.sigmaP_theta = sigmaP_theta(j);
        
        ProtoTable      = prototypes_synthetic_DS('Circle', opt);
        ProtoTable      = prototypes_compute_errorVectors(ProtoTable);
        % ProtoTable = prototypes_normalize_data(ProtoTable);
        
        prototypes_check_prototable(ProtoTable, 1);
        
        ProtoData{k} = prototypes_ProtoStructure(ProtoTable);
        ProtoData{k}.sim.sigmaP_r = sigmaP_r(i);
        ProtoData{k}.sim.sigmaP_theta = sigmaP_theta(j);
        k = k+1;
    end
end

figure; 
tiledlayout(4, 4);
for i = 1:length(ProtoData)
    opt = [];
    opt.subj_id = 1;
    nexttile; prototypes_plot_dots(ProtoData{i}, 'both', opt);
    title(sprintf('sPE:%.02f - sPT%.02f', ProtoData{i}.sim.sigmaP_r, ProtoData{i}.sim.sigmaP_theta));
end