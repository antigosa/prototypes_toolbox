%% tutorial03_CosineMaps_2Conditions.m
% This tutorial shows the basic usage of the prototypes_toolbox. I will be
% using a simulated dataset to compute the cosine similarity index maps of
% individual participants and to fit the data with a categorical adjustment
% model, or CAM (Huttenlocher et al., 1991). 
%
% Note that in order to compute the permutation analysis, you need to have
% the CoSMoMVPA toolbox (http://cosmomvpa.org/download.html). If you do not
% have it, you can skip that section and continue with the model fit. 
%

%% setup
clear; close all;
addpath(genpath('..\..\..\prototypes_toolbox'))
addpath(genpath('..\..\..\CoSMoMVPA'))


%% dataset
% The data are organized in a table. Each row is a participant's trial,
% meaning a response to a dot. The dot position (xy coordinates) is stored 
% in a variable called 'ActualDots_xy' and each dot has a dot id ('DotID'). 
% Each response (xy coordinates) is stored in a variable called
% 'ResponseDots_xy'. The coordinates are in pixels and relative to the
% object rect ('ShapeRect', e.g. a square or a rectangle). The origin is
% the bottom-left (unless data have been normalised).

% load the dataset ('SubjectsData')
load('PrototypesData_2Conditions.mat', 'SubjectsDataA', 'SubjectsDataB');

% data info
prototypes_info(SubjectsDataA);
prototypes_info(SubjectsDataB);
nsubj   = 6;

% compute error vectors
SubjectsDataA = prototypes_compute_errorVectors(SubjectsDataA);
SubjectsDataB = prototypes_compute_errorVectors(SubjectsDataB);

%% plot errors

figure('Position', [827 310 819 632], 'Name', 'Group A');

% plot data for each participant
for s = 1:nsubj
    subplot(3, 2, s);
    
    % plot the actual dots and the responses
    prototypes_plot_dots(SubjectsDataA, s);
    
    % plot the error vectors
    hold on;prototypes_plot_errorVectors(SubjectsDataA, s);
    title(sprintf('Participant %d', s));
end


figure('Position', [827 310 819 632], 'Name', 'Group B');

% plot data for each participant
for s = 1:nsubj
    subplot(3, 2, s);
    
    % plot the actual dots and the responses
    prototypes_plot_dots(SubjectsDataB, s);
    
    % plot the error vectors
    hold on;prototypes_plot_errorVectors(SubjectsDataB, s);
    title(sprintf('Participant %d', s));
end


%% Compute cosine maps

% use 4 processor, if present
alphavalue              = 10;
nproc                   = 4;
SubjectsCosineMapsA      = prototypes_compute_cosineMap(SubjectsDataA, alphavalue, nproc);
SubjectsCosineMapsB      = prototypes_compute_cosineMap(SubjectsDataB, alphavalue, nproc);


%% Plot cosine maps
% plot data for each participant

figure('Position', [827 310 819 632], 'Name', 'Group A');


for s = 1:nsubj
    subplot(3, 2, s);
    
    % plot the actual dots and the responses
    prototypes_plot_cosineMap(SubjectsCosineMapsA, s);
    
    % plot the error vectors
    hold on;prototypes_plot_errorVectors(SubjectsDataA, s);
    title(sprintf('Participant %d', s));
end


figure('Position', [827 310 819 632], 'Name', 'Group B');


for s = 1:nsubj
    subplot(3, 2, s);
    
    % plot the actual dots and the responses
    prototypes_plot_cosineMap(SubjectsCosineMapsB, s);
    
    % plot the error vectors
    hold on;prototypes_plot_errorVectors(SubjectsDataB, s);
    title(sprintf('Participant %d', s));
end

%% Stats (descriptive)
% =========================================================================
% average the error vectors across participants
% =========================================================================
% Remember that this can (should) be done only when the actual dots are the
% same

GroupDataA = prototypes_mean(SubjectsDataA);
GroupDataB = prototypes_mean(SubjectsDataB);

% plot data
figure;prototypes_plot_dots(GroupDataA);
hold on;prototypes_plot_errorVectors(GroupDataA);
title('Group A');


% plot data
figure;prototypes_plot_dots(GroupDataB);
hold on;prototypes_plot_errorVectors(GroupDataB);
title('Group B');

% =========================================================================
% average the cosine maps across participants
% =========================================================================
GroupCosineMapsA = prototypes_mean(SubjectsCosineMapsA);
GroupCosineMapsB = prototypes_mean(SubjectsCosineMapsB);

% plot mean
figure;prototypes_plot_cosineMap(GroupCosineMapsA);
hold on;prototypes_plot_errorVectors(GroupDataA);
title('Group A');

% plot standard deviation
figure;prototypes_plot_cosineMap(GroupCosineMapsB);
hold on;prototypes_plot_errorVectors(GroupDataB);
title('Group B');


%% stats (inferential) - permutation analysis
% NOTE: You need to have cosmomvpa in the path (http://cosmomvpa.org/download.html)
opt                 = [];
opt.runPermutation  = 1;
opt.niter           = 500;

% Since the .ParticipantID for SubjectsCosineMapsA and SubjectsCosineMapsB
% are the same, the function will run a paired statistical analysis. To run
% an independent statistical analysis, .ParticipantID must be different
SubjectsCosineMaps  = {SubjectsCosineMapsA, SubjectsCosineMapsB};
groupStat           = prototypes_stat_secondLevel(SubjectsCosineMaps, opt);

% plot the mean
figure;prototypes_plot_cosineMap(groupStat, [], [-0.5 0.5], 'W_SimixSubject_avg');  % same as from prototypes_mean

% plot the t scores (no mask)
figure;prototypes_plot_cosineMap(groupStat, [], [-15 15], 'W_SimixSubject_T');      % no masked

% plot the t scores (only shows the surviving pixels)
figure;prototypes_plot_cosineMap(groupStat, [], [-15 15], 'W_SimixSubject_Tcorr');  % corrected (masked)


%% model fit: find prototypes and w
% In a few words, the category adjustment theory (Huttenlocher et al., 1991) 
% claims that when recalling an object position from memory two types of
% information are combined: the metric (actual location) information and
% the category information. The category information are used because the
% metric information are noisy. As a consequence, people report a bias
% towards the spatial category. 
% Therefore, the model has N+1 parameters, where N is the number of
% prototypes. Generally, in a geometrical shape (e.g. a square) the number 
% of prototypes is 4. The 5th parameter ('w') concerns how much of category
% information is used over the metric information. It varies from 0 (only
% category information used) to 1 (only metric information used). Here, I
% am going to estimate these 5 parameters using a fitting procedure. 

% initial parameters for fitting the data
param0              = [];

% how much participants used the prototypes?
% - 0 indicates they used maximally the prototypes (max bias)
% - 1 indicates they did not use the prototypes
param0.w            = 0.5;

% we assume the prototypes are at the centre of the 4 subquadrants
ShapeDim            = prototypes_get_metadata(SubjectsDataA, 'ShapeDim');
param0.prototypes   = [0.2 0.25; 0.3 0.75; 0.75 0.25; 0.75 0.75].*ShapeDim;


opt                 = [];
% uncomment this if you want to visualize the fitting procedure
% opt.figure          = 100; 
opt.DisplayParam     = 0;

subjlist = unique(SubjectsDataA.ParticipantID);
param_bestA = [];
for s = 1:nsubj
    
    % select a participant
    aSubjectA           = SubjectsDataA(SubjectsDataA.ParticipantID == subjlist(s),:);    
    
    % fit data for this participant
    param_bestA{s}      = prototypes_fit_model(aSubjectA, @prototypes_model_CAM, param0, opt);    
end

subjlist = unique(SubjectsDataB.ParticipantID);
param_bestB = [];
for s = 1:nsubj
    
    % select a participant    
    aSubjectB           = SubjectsDataB(SubjectsDataB.ParticipantID == subjlist(s),:);
    
    % fit data for this participant    
    param_bestB{s}      = prototypes_fit_model(aSubjectB, @prototypes_model_CAM, param0, opt);
end


%% model fit: visualize parameters (weights)

param_wA             = zeros(nsubj, 1);
param_prototypesA    = zeros(4, 2, nsubj);
param_R2_adjA        = zeros(nsubj, 1);
for s = 1:nsubj
    param_wA(s)                 = param_bestA{s}.w;
    param_prototypesA(:, :, s)  = param_bestA{s}.prototypes;
    param_R2_adjA(s)            = param_bestA{s}.R2_adj;
end


param_wB             = zeros(nsubj, 1);
param_prototypesB    = zeros(4, 2, nsubj);
param_R2_adjB        = zeros(nsubj, 1);
for s = 1:nsubj
    param_wB(s)                 = param_bestB{s}.w;
    param_prototypesB(:, :, s)  = param_bestB{s}.prototypes;
    param_R2_adjB(s)            = param_bestB{s}.R2_adj;
end

% =========================================================================
% plot the weights
% =========================================================================
figure; plot(1, param_wA, 'Marker', 'o', 'MarkerFaceColor', 'b', 'MarkerEdgeColor', 'k');
hold on; plot(2, param_wB, 'Marker', 'o', 'MarkerFaceColor', 'r', 'MarkerEdgeColor', 'k');

ax = gca; ax.YTick=[0.7 0.75 0.8];ax.XTick=[];
hold on;plot([0 3], [mean(param_wA), mean(param_wA)], 'b--');
hold on;plot([0 3], [mean(param_wB), mean(param_wB)], 'r--');
title('memory weight');


%% model fit: visualize parameters (prototypes)
% =========================================================================
% plot the prototypes
% =========================================================================
param_prototypes_avgA = mean(param_prototypesA, 3);
param_prototypes_avgB = mean(param_prototypesB, 3);

figure; 
hold on;scatter(param_prototypes_avgA(:, 1) , param_prototypes_avgA(:, 2), 'Marker', 'o', 'MarkerFaceColor', 'b', 'MarkerEdgeColor', 'k');
hold on;scatter(param_prototypes_avgB(:, 1) , param_prototypes_avgB(:, 2), 'Marker', 'o', 'MarkerFaceColor', 'r', 'MarkerEdgeColor', 'k');
title('prototypes locations');
ax = gca; ax.YLim = [0 ShapeDim(2)];ax.XLim=[0 ShapeDim(1)];axis image;

rect = prototypes_get_metadata(SubjectsDataA, 'ShapeRect');
rectangle('Position', rect);
