%% tutorial05_CosineMaps_AroundObject.m


%% setup
clear; close all;
addpath(genpath('..\..\..\prototypes_toolbox'))
addpath(genpath('..\..\..\CoSMoMVPA'))

%% load dataset
% load the dataset ('SubjectsData')
load('PrototypesData_AroundObjects.mat', 'SubjectsData');

% data info
prototypes_info(SubjectsData);
nsubj   = 2;

% compute error vectors
SubjectsData = prototypes_compute_errorVectors(SubjectsData);

%% plot errors

figure('Position', [827 310 819 632]);

% plot data for each participant
for s = 1:nsubj
    subplot(1, 2, s);
    
    % plot the actual dots and the responses
    prototypes_plot_dots(SubjectsData, s);
    
    % plot the error vectors
    hold on;prototypes_plot_errorVectors(SubjectsData, s);
    title(sprintf('Participant %d', s));
end

%% Compute cosine maps

% use 4 processor, if present
alphavalue              = 10;
nproc                   = 4;
SubjectsCosineMaps      = prototypes_compute_cosineMap(SubjectsData, alphavalue, nproc);

%% Plot cosine maps
% plot data for each participant
figure('Position', [827 310 819 632]);

for s = 1:nsubj
    subplot(1, 2, s);
    
    % plot the actual dots and the responses
    prototypes_plot_cosineMap(SubjectsCosineMaps, s);
    
    % plot the error vectors
    hold on;prototypes_plot_errorVectors(SubjectsData, s);
    title(sprintf('Participant %d', s));
end