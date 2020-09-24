addpath(genpath('D:\Programs\toolbox\prototypes_toolbox'))


%% test 1 - test prototypes_synthetic_simpleDS
% =========================================================================
% Simulate a participant with 50 dots
% =========================================================================
% Just test the basic function of prototypes_synthetic_simpleDS. It
% simulates simple biases, but not realistic responses (see test 4). It
% also uses the functions 'prototypes_check_prototable.m' that check
% whether the table contains all the important elements to be used in other
% functions. To compute the error vectors, it calls the function 
% prototypes_compute_errorVectors.m. To plot, it uses
% prototypes_plot_dots.m and prototypes_plot_errorVectors.m
clear;
close all;
ndots       = 50;

% the shape dimensions of the figure. 
ShapeDim    = [700 700];
nsubj       = 1;

% create synthetic data
aSubj       = prototypes_synthetic_simpleDS(ndots, ShapeDim, 0.07, nsubj);

% the table has a field called .Properties.UserData with important
% information about the data (check the : 
% aSubj.Properties.UserData
%  struct with fields:
% 
%          Simulated_bias: [4×2 double]
%              ScreenRect: [1 1 1920 1080]
%      ShapeContainerRect: [-70 -70 770 770]
%               ShapeRect: [0 0 700 700]
%                    YDir: 'normal'
%              Experiment: 'Synthetic data'
%            StimulusType: 'Square data'
%        StimulusFileName: ''
%              FolderName: ''
%                FileName: ''
%             ScreenDepth: 32
%     ScreenPixelsPerInch: 96
%                   Units: 'pixels'

% check the table format
prototypes_check_prototable(aSubj,1);

% compute error vectors
aSubj = prototypes_compute_errorVectors(aSubj);

% plot data
figure;prototypes_plot_dots(aSubj);
hold on;prototypes_plot_errorVectors(aSubj);


%% test 2 - simulate more participants and average
% =========================================================================
% Simulate 3 participants with 100 dots
% =========================================================================
% This is similar to test 1, but simulates more participants to allow
% computing simple statistics (e.g. mean) across participants. To do this
% it uses the function prototypes_mean.m. For more sophisticated analysis
% (e.g. comparting cosine maps), you should use the function 
% prototypes_stat_secondLevel.m (see test 9 and 10). 
close all;
ndots       = 100;
ShapeDim    = [600 300];
nsubj       = 4;

% create synthetic data
SubjectsData       = prototypes_synthetic_simpleDS(ndots, ShapeDim, 0.07, nsubj);

% compute error vectors
SubjectsData        = prototypes_compute_errorVectors(SubjectsData);

% plot data
figure;

for s = 1:nsubj
    subplot(2, 2, s);
    prototypes_plot_dots(SubjectsData, s);
    hold on;prototypes_plot_errorVectors(SubjectsData, s);
    title(sprintf('Participant %d', s));
end


% =========================================================================
% average across participants
% =========================================================================
% Remember that this can (should) be done only when the actual dots are the
% same

GroupData = prototypes_mean(SubjectsData);

% plot data
figure;prototypes_plot_dots(GroupData);
hold on;prototypes_plot_errorVectors(GroupData);


%% test 3 - simulate more participants and average
% =========================================================================
% Simulate 20 participants with 100 dots
% =========================================================================
close all;
ndots       = 100;
ShapeDim    = [600 300];
nsubj       = 20;

% create synthetic data
SubjectsData       = prototypes_synthetic_simpleDS(ndots, ShapeDim, 0.07, nsubj);

% check the table format
prototypes_check_prototable(SubjectsData,1);

% compute error vectors
SubjectsData        = prototypes_compute_errorVectors(SubjectsData);

% plot data
figure;

for s = 1:nsubj
    subplot(5, 4, s);
    prototypes_plot_dots(SubjectsData, s);
    hold on;prototypes_plot_errorVectors(SubjectsData, s);
    title(sprintf('Participant %d', s));
end


% =========================================================================
% average across participants
% =========================================================================
% Remember that this can (should) be done only when the actual dots are the
% same

GroupData = prototypes_mean(SubjectsData);

% plot data
figure;prototypes_plot_dots(GroupData);
hold on;prototypes_plot_errorVectors(GroupData);


%% test 4 - simulate using the CAM model and compute cosine maps
% =========================================================================
% Simulate 20 participants with 100 dots using the CAM model
% =========================================================================
clear;
close all;
ndots_x                 = 20;
ndots_y                 = 10;
ndots                   = ndots_x*ndots_y;
grid_offset             = 1;
dot_noise               = 0;
multOf                  = 4;
ShapeDim                = [600 300];
nsubj                   = 2;

nrows                   = 10;
ndotsXrow               = ndots/nrows;

% create synthetic data
ActualDots_xy           = prototypes_generate_grid('Rectangle', ShapeDim, ndots_x, ndots_y, multOf, grid_offset, dot_noise);
SubjectsData            = prototypes_synthetic_simpleDS(ActualDots_xy, ShapeDim, 0, nsubj);

% set the options for the CAM model
opt.w                   = 0.9;
opt.prototypes          = [0.25 0.25; 0.25 0.75; 0.75 0.25; 0.75 0.75].*ShapeDim;
opt.method              = 'CategoryPrototypes';
opt.stdTRB              = 10;

% generate data
SubjectsData            = prototypes_model_CAM(SubjectsData, opt);

% compute error vectors
SubjectsData            = prototypes_compute_errorVectors(SubjectsData);

% plot data
figure;prototypes_plot_dots(SubjectsData);
hold on;prototypes_plot_errorVectors(SubjectsData);


alphavalue              = 10;
nproc                   = 4;
SubjectsCosineMaps      = prototypes_compute_cosineMap(SubjectsData, alphavalue, nproc);
figure; prototypes_plot_cosineMap(SubjectsCosineMaps, 1);
hold on; prototypes_plot_errorVectors(SubjectsData, 1);

GroupCosineMaps         = prototypes_mean(SubjectsCosineMaps);
GroupData               = prototypes_mean(SubjectsData);
figure; prototypes_plot_cosineMap(GroupCosineMaps, [], [-2 2]);
hold on; prototypes_plot_errorVectors(GroupData);


%% test 5 - serial vs parallel analysis
% =========================================================================
% Compare the cosine maps when using one and 4 processors
% =========================================================================

ndots_x                 = 20;
ndots_y                 = 10;
ndots                   = ndots_x*ndots_y;
grid_offset             = 1;
dot_noise               = 0;
multOf                  = 4;
ShapeDim                = [600 300];
nsubj                   = 1;

nrows                   = 10;
ndotsXrow               = ndots/nrows;

% create synthetic data
ActualDots_xy           = prototypes_generate_grid('Rectangle', ShapeDim, ndots_x, ndots_y, multOf, grid_offset, dot_noise);
SubjectsData            = prototypes_synthetic_simpleDS(ActualDots_xy, ShapeDim, 0, nsubj);

% set the options for the CAM model
opt.w                   = 0.9;
opt.prototypes          = [0.25 0.25; 0.25 0.75; 0.75 0.25; 0.75 0.75].*ShapeDim;
opt.method              = 'CategoryPrototypes';
opt.stdTRB              = 10;

% generate data
SubjectsData            = prototypes_model_CAM(SubjectsData, opt);

% compute error vectors
SubjectsData            = prototypes_compute_errorVectors(SubjectsData);

% use 1 processor
alphavalue              = 10;
nproc                   = 1;
SubjectsCosineMapsP1    = prototypes_compute_cosineMap(SubjectsData, alphavalue, nproc);

% use 4 processors
alphavalue              = 10;
nproc                   = 4;
SubjectsCosineMapsP4    = prototypes_compute_cosineMap(SubjectsData, alphavalue, nproc);

assert(isequal(SubjectsCosineMapsP1, SubjectsCosineMapsP4), 'something is wrong with the parallel method');


%% test 6 - compare different alpha values
% =========================================================================
% play with alpha value
% =========================================================================
% close all;
ndots_x                 = 20;
ndots_y                 = 10;
ndots                   = ndots_x*ndots_y;
grid_offset             = 1;
dot_noise               = 0;
multOf                  = 4;
ShapeDim                = [600 300];
nsubj                   = 1;

nrows                   = 10;
ndotsXrow               = ndots/nrows;

% create synthetic data
ActualDots_xy           = prototypes_generate_grid('Rectangle', ShapeDim, ndots_x, ndots_y, multOf, grid_offset, dot_noise);
SubjectsData            = prototypes_synthetic_simpleDS(ActualDots_xy, ShapeDim, 0, nsubj);

% set the options for the CAM model
opt.w                   = 0.9;
opt.prototypes          = [0.25 0.25; 0.25 0.75; 0.75 0.25; 0.75 0.75].*ShapeDim;
opt.method              = 'CategoryPrototypes';
opt.stdTRB              = 10;

% generate data
SubjectsData            = prototypes_model_CAM(SubjectsData, opt);

% compute error vectors
SubjectsData            = prototypes_compute_errorVectors(SubjectsData);

% plot data
figure;prototypes_plot_dots(SubjectsData);
hold on;prototypes_plot_errorVectors(SubjectsData);


alphavalues             = [5 10 25 50];

nproc                   = 4;
SubjectsCosineMaps      = cell(1, length(alphavalues));
for a = 1:length(alphavalues)
    SubjectsCosineMaps{a}      = prototypes_compute_cosineMap(SubjectsData, alphavalues(a), nproc);
end


figure('Position', [680 641 1060 337]); 
for a = 1:length(alphavalues)
    subplot(2, 2, a);
    prototypes_plot_cosineMap(SubjectsCosineMaps{a}, 1);
    hold on; prototypes_plot_errorVectors(SubjectsData, 1);
    title(sprintf('alpha %d', alphavalues(a)));
end


%% test 7 - test prototypes_compute_cosineDot
% =========================================================================
% Test prototypes_compute_cosineDot
% =========================================================================
clear;
ndots_x                 = 20;
ndots_y                 = 10;
ndots                   = ndots_x*ndots_y;
grid_offset             = 1;
dot_noise               = 0;
multOf                  = 4;
ShapeDim                = [600 300];
nsubj                   = 2;

nrows                   = 10;
ndotsXrow               = ndots/nrows;

% create synthetic data
ActualDots_xy           = prototypes_generate_grid('Rectangle', ShapeDim, ndots_x, ndots_y, multOf, grid_offset, dot_noise);
SubjectsData            = prototypes_synthetic_simpleDS(ActualDots_xy, ShapeDim, 0, nsubj);

% set the options for the CAM model
opt.w                   = 0.9;
opt.prototypes          = [0.25 0.25; 0.25 0.75; 0.75 0.25; 0.75 0.75].*ShapeDim;
opt.method              = 'CategoryPrototypes';
opt.stdTRB              = 10;

% generate data
SubjectsData            = prototypes_model_CAM(SubjectsData, opt);

% compute error vectors
SubjectsData            = prototypes_compute_errorVectors(SubjectsData);

% use 1 processor
alphavalue              = 10;
nproc                   = 4;
SubjectsCosineMaps      = prototypes_compute_cosineMap(SubjectsData, alphavalue, nproc);
SubjectsData            = prototypes_compute_cosineDot(SubjectsData, SubjectsCosineMaps);


%% test 8 - check transformation to cosmo format
% =========================================================================
% Test prototypes_simMap2cosmo.m
% =========================================================================
% This is useful for permutation analysis (see function
% prototypes_stat_secondLevel.m)
addpath(genpath('D:\Programs\toolbox\CoSMoMVPA\mvpa'))
clear;
ndots_x                 = 20;
ndots_y                 = 10;
ndots                   = ndots_x*ndots_y;
grid_offset             = 1;
dot_noise               = 0;
multOf                  = 4;
ShapeDim                = [600 300];
nsubj                   = 2;

nrows                   = 10;
ndotsXrow               = ndots/nrows;

% create synthetic data
ActualDots_xy           = prototypes_generate_grid('Rectangle', ShapeDim, ndots_x, ndots_y, multOf, grid_offset, dot_noise);
SubjectsData            = prototypes_synthetic_simpleDS(ActualDots_xy, ShapeDim, 0, nsubj);

% set the options for the CAM model
opt.w                   = 0.9;
opt.prototypes          = [0.25 0.25; 0.25 0.75; 0.75 0.25; 0.75 0.75].*ShapeDim;
opt.method              = 'CategoryPrototypes';
opt.stdTRB              = 10;

% generate data
SubjectsData            = prototypes_model_CAM(SubjectsData, opt);

% compute error vectors
SubjectsData            = prototypes_compute_errorVectors(SubjectsData);

% use 1 processor
alphavalue              = 10;
nproc                   = 4;
SubjectsCosineMaps      = prototypes_compute_cosineMap(SubjectsData, alphavalue, nproc);

ds = prototypes_simMap2cosmo(SubjectsCosineMaps.W_SimixSubject);


%% test 9 - test one-sample T-test
% =========================================================================
% Test permutation analysis (one-sample T-test)
% =========================================================================
addpath(genpath('D:\Programs\toolbox\CoSMoMVPA\mvpa'))
clear;
ndots_x                 = 20;
ndots_y                 = 10;
ndots                   = ndots_x*ndots_y;
grid_offset             = 1;
dot_noise               = 0;
multOf                  = 4;
ShapeDim                = [600 300];
nsubj                   = 15;

nrows                   = 10;
ndotsXrow               = ndots/nrows;

% create synthetic data
ActualDots_xy           = prototypes_generate_grid('Rectangle', ShapeDim, ndots_x, ndots_y, multOf, grid_offset, dot_noise);
SubjectsData            = prototypes_synthetic_simpleDS(ActualDots_xy, ShapeDim, 0, nsubj);

% set the options for the CAM model
opt.w                   = 0.9;
opt.prototypes          = [0.25 0.25; 0.25 0.75; 0.75 0.25; 0.75 0.75].*ShapeDim;
opt.method              = 'CategoryPrototypes';
opt.stdNoise            = 10;

% generate data
SubjectsData            = prototypes_model_CAM(SubjectsData, opt);

% compute error vectors
SubjectsData            = prototypes_compute_errorVectors(SubjectsData);

% use 4 processors
alphavalue              = 10;
nproc                   = 4;
SubjectsCosineMaps      = prototypes_compute_cosineMap(SubjectsData, alphavalue, nproc);

figure; 
subplot(1, 2, 1);prototypes_plot_cosineMap(SubjectsCosineMaps, 1);
hold on; prototypes_plot_errorVectors(SubjectsData, 1);
subplot(1, 2, 2);prototypes_plot_cosineMap(SubjectsCosineMaps, 2);
hold on; prototypes_plot_errorVectors(SubjectsData, 2);


opt                 = [];
opt.runPermutation  = 1;
opt.niter           = 500;
groupStat           = prototypes_stat_secondLevel(SubjectsCosineMaps, opt);

figure;prototypes_plot_cosineMap(groupStat, [], [-0.5 0.5], 'W_SimixSubject_avg');
figure;prototypes_plot_cosineMap(groupStat, [], [-15 15], 'W_SimixSubject_T');
figure;prototypes_plot_cosineMap(groupStat, [], [-15 15], 'W_SimixSubject_Tcorr');
figure;prototypes_plot_cosineMap(groupStat, [], [0 0.02], 'W_SimixSubject_SE');


%% test 10 - test two-samples T-test
% =========================================================================
% Test permutation analysis (two-samples T-test)
% =========================================================================
addpath(genpath('D:\Programs\toolbox\CoSMoMVPA\mvpa'))
clear;
ndots_x                 = 20;
ndots_y                 = 10;
ndots                   = ndots_x*ndots_y;
grid_offset             = 1;
dot_noise               = 0;
multOf                  = 4;
ShapeDim                = [600 300];
nsubj                   = 12;

nrows                   = 10;
ndotsXrow               = ndots/nrows;

% create synthetic data
ActualDots_xy           = prototypes_generate_grid('Rectangle', ShapeDim, ndots_x, ndots_y, multOf, grid_offset, dot_noise);
SubjectsData            = prototypes_synthetic_simpleDS(ActualDots_xy, ShapeDim, 0, nsubj);

% set the options for the CAM model
opt.w                   = 0.9;
opt.method              = 'CategoryPrototypes';
opt.stdNoise            = 1;

% generate data
opt.prototypes          = [0.1 0.1; 0.1 0.9; 0.9 0.1; 0.9 0.9].*ShapeDim;
SubjectsDataA           = prototypes_model_CAM(SubjectsData, opt);

opt.prototypes          = [0.45 0.45; 0.45 0.65; 0.65 0.45; 0.65 0.65].*ShapeDim;
SubjectsDataB           = prototypes_model_CAM(SubjectsData, opt);

% compute error vectors
SubjectsDataA           = prototypes_compute_errorVectors(SubjectsDataA);
SubjectsDataB           = prototypes_compute_errorVectors(SubjectsDataB);

figure; prototypes_plot_errorVectors(SubjectsDataA, 1);
figure; prototypes_plot_errorVectors(SubjectsDataB, 1);

% use 4 processors
alphavalue              = 10;
nproc                   = 4;
SubjectsCosineMapsA     = prototypes_compute_cosineMap(SubjectsDataA, alphavalue, nproc);
SubjectsCosineMapsB     = prototypes_compute_cosineMap(SubjectsDataB, alphavalue, nproc);

figure; 
subplot(1, 2, 1);prototypes_plot_cosineMap(SubjectsCosineMapsA, 1);
hold on; prototypes_plot_errorVectors(SubjectsDataA, 1);
subplot(1, 2, 2);prototypes_plot_cosineMap(SubjectsCosineMapsB, 1);
hold on; prototypes_plot_errorVectors(SubjectsDataB, 2);


% Since the .ParticipantID for SubjectsCosineMapsA and SubjectsCosineMapsB
% are the same, the function will run a paired statistical analysis. To run
% an independent statistical analysis, .ParticipantID must be different

opt                 = [];
opt.runPermutation  = 1;
opt.niter           = 500;
groupStat2          = prototypes_stat_secondLevel({SubjectsCosineMapsA, SubjectsCosineMapsB}, opt);

figure;prototypes_plot_cosineMap(groupStat2, [], [-0.5 0.5], 'W_SimixSubject_avg');
figure;prototypes_plot_cosineMap(groupStat2, [], [-15 15], 'W_SimixSubject_T');
figure;prototypes_plot_cosineMap(groupStat2, [], [-15 15], 'W_SimixSubject_Tcorr');
figure;prototypes_plot_cosineMap(groupStat2, [], [0 0.02], 'W_SimixSubject_SE');


%% test 11 - test normalize data
% To fit the data using a model, the data needs to be normlized
clear;
close all;
ndots_x                 = 20;
ndots_y                 = 10;
ndots                   = ndots_x*ndots_y;
grid_offset             = 1;
dot_noise               = 0;
multOf                  = 4;
ShapeDim                = [600 300];
nsubj                   = 2;

nrows                   = 10;
ndotsXrow               = ndots/nrows;

% create synthetic data
ActualDots_xy           = prototypes_generate_grid('Rectangle', ShapeDim, ndots_x, ndots_y, multOf, grid_offset, dot_noise);
SubjectsData            = prototypes_synthetic_simpleDS(ActualDots_xy, ShapeDim, 0, nsubj);

% set the options for the CAM model
opt.w                   = 0.9;
opt.prototypes          = [0.25 0.25; 0.25 0.75; 0.75 0.25; 0.75 0.75].*ShapeDim;
opt.method              = 'CategoryPrototypes';


% generate data
opt.stdNoise            = 1;
SubjectsData            = prototypes_model_CAM(SubjectsData, opt);
SubjectsData            = prototypes_compute_errorVectors(SubjectsData);

SubjectsDataNorm        = prototypes_normalize_data(SubjectsData);

SubjectsDataNorm        = prototypes_compute_errorVectors(SubjectsDataNorm);

figure; prototypes_plot_dots(SubjectsDataNorm);
hold on; prototypes_plot_errorVectors(SubjectsDataNorm);

SubjectsDataDenorm        = prototypes_denormalize_data(SubjectsDataNorm);


figure; prototypes_plot_dots(SubjectsDataDenorm);
hold on; prototypes_plot_errorVectors(SubjectsDataDenorm);


%% test 11 - test R2
clear;
close all;
ndots_x                 = 20;
ndots_y                 = 10;
ndots                   = ndots_x*ndots_y;
grid_offset             = 1;
dot_noise               = 0;
multOf                  = 4;
ShapeDim                = [600 300];
nsubj                   = 2;

nrows                   = 10;
ndotsXrow               = ndots/nrows;

% create synthetic data
ActualDots_xy           = prototypes_generate_grid('Rectangle', ShapeDim, ndots_x, ndots_y, multOf, grid_offset, dot_noise);
SubjectsData            = prototypes_synthetic_simpleDS(ActualDots_xy, ShapeDim, 0, nsubj);

% set the options for the CAM model
opt.w                   = 0.1;
opt.prototypes          = [0.25 0.25; 0.25 0.75; 0.75 0.25; 0.75 0.75].*ShapeDim;
opt.method              = 'CategoryPrototypes';


% generate data
opt.stdNoise            = 5;
SubjectsData            = prototypes_model_CAM(SubjectsData, opt);

% generate data
opt.stdNoise            = 0;
SubjectsDataPredicted   = prototypes_model_CAM(SubjectsData, opt);

subjlist = unique(SubjectsData.ParticipantID);
for s = 1:nsubj    
    aSubject            = SubjectsData(SubjectsData.ParticipantID == subjlist(s),:);
    aSubjectPredicted   = SubjectsDataPredicted(SubjectsDataPredicted.ParticipantID == subjlist(s),:);
        
    
%     aSubject = prototypes_normalize_data(aSubject);
%     aSubjectPredicted = prototypes_normalize_data(aSubjectPredicted);
    R2(s) = prototypes_R2(aSubject, aSubjectPredicted.ResponseDots_xy, 'SST', 1);
end


%% test 12 - test error
clear;
close all;
ndots_x                 = 20;
ndots_y                 = 10;
ndots                   = ndots_x*ndots_y;
grid_offset             = 1;
dot_noise               = 0;
multOf                  = 4;
ShapeDim                = [600 300];
nsubj                   = 2;

nrows                   = 10;
ndotsXrow               = ndots/nrows;

% create synthetic data
ActualDots_xy           = prototypes_generate_grid('Rectangle', ShapeDim, ndots_x, ndots_y, multOf, grid_offset, dot_noise);
SubjectsData            = prototypes_synthetic_simpleDS(ActualDots_xy, ShapeDim, 0, nsubj);

% set the options for the CAM model
opt.w                   = 0.6;
opt.prototypes          = [0.25 0.25; 0.25 0.75; 0.75 0.25; 0.75 0.75].*ShapeDim;
opt.method              = 'CategoryPrototypes';


% generate data
opt.stdNoise            = 5;
SubjectsData            = prototypes_model_CAM(SubjectsData, opt);


subjlist = unique(SubjectsData.ParticipantID);
for s = 1:nsubj    
    aSubject            = SubjectsData(SubjectsData.ParticipantID == subjlist(s),:);
        
    param               = [0.6 reshape(opt.prototypes, 1, [])];
    
    opt_in              = [];
    opt_in.Param0       = [0.9 reshape(opt.prototypes, 1, [])];
    opt_in.fit_wOnly    = 0;
    opt_in.figure       = 100;
    opt_in.DisplayParam = 1;
    figure; prototypes_plot_dots(aSubject);
    Err(s)              = prototypes_errfun(@prototypes_model_CAM, param, aSubject, opt_in);
end


%% test 12 - test fit model
clear;
close all;
ndots_x                 = 20;
ndots_y                 = 10;
ndots                   = ndots_x*ndots_y;
grid_offset             = 1;
dot_noise               = 0;
multOf                  = 4;
ShapeDim                = [600 300];
nsubj                   = 2;

nrows                   = 10;
ndotsXrow               = ndots/nrows;

% create synthetic data
ActualDots_xy           = prototypes_generate_grid('Rectangle', ShapeDim, ndots_x, ndots_y, multOf, grid_offset, dot_noise);
SubjectsData            = prototypes_synthetic_simpleDS(ActualDots_xy, ShapeDim, 0, nsubj);

% set the options for the CAM model
opt.w                   = 0.6;
opt.prototypes          = [0.25 0.25; 0.25 0.75; 0.75 0.25; 0.75 0.75].*ShapeDim;
opt.method              = 'CategoryPrototypes';


% generate data
opt.stdNoise            = 5;
SubjectsData            = prototypes_model_CAM(SubjectsData, opt);
save('PrototypesData', 'SubjectsData');


subjlist = unique(SubjectsData.ParticipantID);
param_best = [];
for s = 1:nsubj    
    aSubject            = SubjectsData(SubjectsData.ParticipantID == subjlist(s),:);
    
    param0              = [];
    param0.w            = 0.8;
    param0.prototypes   = [0.2 0.25; 0.3 0.75; 0.75 0.25; 0.75 0.75].*ShapeDim; 
    opt                 = [];
%     opt.figure          = 100;
    opt.DisplayParam     = 1;

    param_best{s}      = prototypes_fit_model(aSubject, @prototypes_model_CAM, param0, opt);
end

%% test 13 - save data ('Rectangle')
clear;
close all;
ndots_x                 = 20;
ndots_y                 = 10;
ndots                   = ndots_x*ndots_y;
grid_offset             = 20;
dot_noise               = 0;
multOf                  = 4;
ShapeDim                = [600 300];
nsubj                   = 6;

nrows                   = 10;
ndotsXrow               = ndots/nrows;

% create synthetic data
ActualDots_xy           = prototypes_generate_grid('Rectangle', ShapeDim, ndots_x, ndots_y, multOf, grid_offset, dot_noise);
SubjectsData            = prototypes_synthetic_simpleDS(ActualDots_xy, ShapeDim, 0, nsubj);

% set the options for the CAM model
opt.w                   = 0.75;
opt.prototypes          = [0.25 0.25; 0.25 0.75; 0.75 0.25; 0.75 0.75].*ShapeDim;
opt.method              = 'CategoryPrototypes';


% generate data
opt.stdNoise            = 5;
SubjectsData            = prototypes_model_CAM(SubjectsData, opt);

SubjectsData.CategoryID = [];
SubjectsData.CategoryPrototypes = [];

SubjectsData.Age        = reshape(repmat(round(random('norm', 30, 5, nsubj, 1)), 1, ndots)', [],1);
Gender     = reshape(repmat(random('unid', 2, nsubj, 1), 1, ndots)', [],1);
SubjectsData.Gender     = cell(length(SubjectsData.Age), 1);
SubjectsData.Gender(Gender==1)     = {'Female'};
SubjectsData.Gender(Gender==2)     = {'Male'};



save('PrototypesData_Rectangle', 'SubjectsData');


%% test 13 - save data ('Rectangle')
clear;
close all;
ndots_x                 = 20;
ndots_y                 = 10;
grid_offset             = 20;
dot_noise               = 0;
multOf                  = 4;
ShapeDim                = [300 300];
nsubj                   = 6;

nrows                   = 10;

% create synthetic data
ActualDots_xy           = prototypes_generate_grid('Circle', ShapeDim, ndots_x, ndots_y, multOf, grid_offset, dot_noise);
SubjectsData            = prototypes_synthetic_simpleDS(ActualDots_xy, ShapeDim, 0, nsubj);
SubjectsData.Properties.UserData.StimulusType = 'Circle';


Dots = prototypes_info(SubjectsData, 'Dots');
ndots = Dots.Ndots;

% set the options for the CAM model
opt.w                   = 0.75;
opt.prototypes          = [0.25 0.25; 0.25 0.75; 0.75 0.25; 0.75 0.75].*ShapeDim;
opt.method              = 'CategoryPrototypes';


% generate data
opt.stdNoise            = 5;
SubjectsData            = prototypes_model_CAM(SubjectsData, opt);

SubjectsData.CategoryID = [];
SubjectsData.CategoryPrototypes = [];

SubjectsData.Age        = reshape(repmat(round(random('norm', 30, 5, nsubj, 1)), 1, ndots)', [],1);
Gender     = reshape(repmat(random('unid', 2, nsubj, 1), 1, ndots)', [],1);
SubjectsData.Gender     = cell(length(SubjectsData.Age), 1);
SubjectsData.Gender(Gender==1)     = {'Female'};
SubjectsData.Gender(Gender==2)     = {'Male'};

prototypes_plot_dots(SubjectsData)

save('PrototypesData_Circle', 'SubjectsData');