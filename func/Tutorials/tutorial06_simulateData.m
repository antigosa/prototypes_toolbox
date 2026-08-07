%% setup
clear; close all;
addpath(genpath('..\..\..\prototypes_toolbox'))
% addpath(genpath('..\..\..\CoSMoMVPA'))

%% Simulate a circle (no truncation bias)
close all;
opt             = [];
opt.ShapeDim    = [200 200];
opt.prototypes  = [0.35 0.35; 0.35 0.65; 0.65 0.35; 0.65 0.65].*opt.ShapeDim;
opt.truncation  = 0;
opt.stdNoise    = 0;
opt.w           = 1;
ProtoTable      = prototypes_synthetic_DS('Circle', opt);
ProtoTable      = prototypes_compute_errorVectors(ProtoTable);
% ProtoTable = prototypes_normalize_data(ProtoTable);

prototypes_check_prototable(ProtoTable, 1);

ProtoData = prototypes_ProtoStructure(ProtoTable);

opt = [];
opt.subj_id = 1;
figure; prototypes_plot_dots(ProtoData, 'both', opt);


%% with image in the middle
opt                         = [];
opt.withImage               = 1;
ProtoTable                  = prototypes_synthetic_DS('Circle', opt);
ProtoTable = prototypes_compute_errorVectors(ProtoTable);
% ProtoTable = prototypes_normalize_data(ProtoTable);

prototypes_check_prototable(ProtoTable, 1);

ProtoData = prototypes_ProtoStructure(ProtoTable);

opt = [];
opt.subj_id = 1;
figure; prototypes_plot_dots(ProtoData, 'both', opt);


%% test fit_model (CAM_noBoundaries)

figure_size = ProtoData.Trials.Properties.UserData.ShapeRect([3 4]); 
param0                  = [];
param0.w_theta          = [0.5 0.5 0.5 0.5]; % not sure I need to have 4 elements here
param0.w_r              = [0.5 0.5 0.5 0.5]; % not sure I need to have 4 elements here
param0.prototypesXY     = [0.75 0.25; 0.25 0.25; 0.25 0.75; 0.75 0.75].*figure_size;
param0.paramNames       = {'w_theta', 'w_r', 'prototypes_br', 'prototypes_bl', 'prototypes_tl', 'prototypes_tr'};
param0.nParam           = length(param0.paramNames); % is it really two?
param0.model            = 'CAM';


% =====================================================================
% Prepare the options for the fitting function
% =====================================================================
opt_fit                 = [];
opt_fit.DisplayIter     = 'Off'; % 'Off' | 'iter'
opt_fit.DisplayParam    = 0;
opt_fit.figure          = []; % [] | 1
opt_fit.truncation      = 0;


param = prototypes_fit_model(ProtoTable, @prototypes_model_CAM, param0, opt_fit);

%% Simulate a circle with truncation bias
opt                 = [];
opt.ShapeDim        = [200 200];
opt.sigmaM_r        = 0.1;
opt.sigmaM_theta    = 0.1;
opt.stdNoise        = 5;
ProtoTable          = prototypes_synthetic_DS('Circle', opt);
ProtoTable          = prototypes_compute_errorVectors(ProtoTable);
% ProtoTable = prototypes_normalize_data(ProtoTable);

prototypes_check_prototable(ProtoTable, 1);

ProtoData = prototypes_ProtoStructure(ProtoTable);

opt = [];
opt.subj_id = 1;
figure; prototypes_plot_dots(ProtoData, 'both', opt);


% csimap = prototypes_compute_cosineMap(ProtoTable, 10, 4);
% 
% ProtoData = prototypes_ProtoStructure(ProtoTable, csimap);
% 
% opt = [];
% opt.subj_id = 1;
% opt.showErrors=1;
% figure; prototypes_plot_cosineMap(ProtoData, 'W_SimixSubject', opt);


%% test fit_model (6 parameters: w_theta, w_r, 4 prototypes)

figure_size = ProtoData.Trials.Properties.UserData.ShapeRect([3 4]); 

param0                  = [];
param0.sigmaM_theta     = [0.5 0.5 0.5 0.5]; % not sure I need to have 4 elements here
param0.sigmaM_r         = [0.5 0.5 0.5 0.5]; % not sure I need to have 4 elements here
param0.prototypesXY     = [0.75 0.25; 0.25 0.25; 0.25 0.75; 0.75 0.75].*figure_size;
param0.paramNames       = {'w_theta', 'w_r', 'prototypes_br', 'prototypes_bl', 'prototypes_tl', 'prototypes_tr'};
param0.nParam           = length(param0.paramNames); % is it really two?
param0.model            = 'CAM';

% =====================================================================
% Prepare the options for the fitting function
% =====================================================================
opt_fit                 = [];
opt_fit.DisplayIter     = 'Off'; % 'Off' | 'iter'
opt_fit.DisplayParam    = 0;
opt_fit.figure          = []; % [] | 1


param                   = prototypes_fit_model(ProtoTable, @prototypes_model_CAM, param0, opt_fit);

ProtoData               = prototypes_ProtoStructure(ProtoTable);

ProtoTable_sim          = ProtoTable;
opt                     = [];
opt.prototypes          = param.prototypesXY;
opt.w_theta             = param.w_theta;
opt.w_r                 = param.w_r;
ProtoTable_sim          = prototypes_model_CAM(ProtoTable_sim, opt);
ProtoData_sim           = prototypes_ProtoStructure(ProtoTable_sim);

opt                     = [];
opt.subj_id             = 1;
figure; 
tiledlayout(1, 2);
nexttile; prototypes_plot_dots(ProtoData, 'both', opt);
nexttile; prototypes_plot_dots(ProtoData_sim, 'both', opt);

hold on; plot(param.prototypesXY(:, 1), param.prototypesXY(:, 2), 'o', 'MarkerFaceColor', 'g', 'MarkerEdgeColor', 'k');

%% test fit_model (2 parameters: w_theta, w_r)

figure_size = ProtoData.Trials.Properties.UserData.ShapeRect([3 4]); 

param0                  = [];
param0.w_theta          = [0.5 0.5 0.5 0.5]; % not sure I need to have 4 elements here
param0.w_r              = [0.5 0.5 0.5 0.5]; % not sure I need to have 4 elements here
param0.paramNames       = {'w_theta', 'w_r'};
param0.nParam           = length(param0.paramNames); % is it really two?
param0.model            = 'CAM';

% =====================================================================
% Prepare the options for the fitting function
% =====================================================================
opt_fit                 = [];
opt_fit.DisplayIter     = 'iter'; % 'Off' | 'iter'
opt_fit.DisplayParam    = 0;
opt_fit.figure          = 1; % [] | 1
opt_fit.prototypesXY    = [0.75 0.25; 0.25 0.25; 0.25 0.75; 0.75 0.75].*figure_size;

param                   = prototypes_fit_model(ProtoTable, @prototypes_model_CAM, param0, opt_fit);

ProtoData               = prototypes_ProtoStructure(ProtoTable);

ProtoTable_sim          = ProtoTable;
opt                     = [];
opt.prototypes          = opt_fit.prototypesXY;
opt.w_theta             = param.w_theta;
opt.w_r                 = param.w_r;
ProtoTable_sim          = prototypes_model_CAM(ProtoTable_sim, opt);
ProtoData_sim           = prototypes_ProtoStructure(ProtoTable_sim);

opt                     = [];
opt.subj_id             = 1;
figure; 
tiledlayout(1, 2);
nexttile; prototypes_plot_dots(ProtoData, 'both', opt);
nexttile; prototypes_plot_dots(ProtoData_sim, 'both', opt);

hold on; plot(opt_fit.prototypesXY(:, 1), opt_fit.prototypesXY(:, 2), 'o', 'MarkerFaceColor', 'g', 'MarkerEdgeColor', 'k');