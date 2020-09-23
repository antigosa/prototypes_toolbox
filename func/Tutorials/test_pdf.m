addpath(genpath('..\..\..\prototypes_toolbox'))

clear; close all;

% load data
load('PrototypesData.mat', 'SubjectsData');

% data info
subjlist    = unique(SubjectsData.ParticipantID);
nsubj       = length(subjlist);

% compute error vectors
SubjectsData = prototypes_compute_errorVectors(SubjectsData);

%% plot errors

figure('Position', [827 310 819 632]);

% plot data for each participant
for s = 1:nsubj
    subplot(3, 2, s);
    
    % plot the actual dots and the responses
    prototypes_plot_dots(SubjectsData, s);
    
    % plot the error vectors
    hold on;prototypes_plot_errorVectors(SubjectsData, s);
    title(sprintf('Participant %d', s));
end