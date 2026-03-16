%% setup
clear; close all;
addpath(genpath('..\..\..\prototypes_toolbox'))
% addpath(genpath('..\..\..\CoSMoMVPA'))

%% simplest way
ProtoTable = prototypes_synthetic_DS

%%



ProtoTable = prototypes_model_CAM(ProtoTable, opt);