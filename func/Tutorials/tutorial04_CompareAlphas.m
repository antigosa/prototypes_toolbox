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
load('PrototypesData_Rectangle.mat', 'SubjectsData');

% data info
prototypes_info(SubjectsData);
nsubj   = 6;

% we need only one participant
SubjectsData = SubjectsData(SubjectsData.ParticipantID == 1, :);

% compute error vectors
SubjectsData = prototypes_compute_errorVectors(SubjectsData);


%% 
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