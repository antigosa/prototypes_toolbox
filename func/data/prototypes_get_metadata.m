function v = prototypes_get_metadata(T, k)
% function v = prototypes_get_metadata(T, k, v)
%
%
% - Simulated_bias
% - ScreenRect
% - ScreenDim
% - ShapeContainerRect
% - ShapeRect
% - YDir
% - Experiment
% - StimulusType
% - StimulusFileName
% - FolderName
% - FileName
% - ScreenDepth
% - ScreenPixelsPerInch
% - Units
%
% T is a prototable
%
% Typical metadata (EXAMPLE)
% ===================
% 	User Data:
% ===================
%          Simulated_bias: [4×2 double]
%              ScreenRect: [1 1 1920 1080]
%      ShapeContainerRect: [-60 -30 660 330]
%               ShapeRect: [0 0 600 300]
%                    YDir: 'normal'
%              Experiment: 'Synthetic data'
%            StimulusType: 'Square data'
%        StimulusFileName: ''
%              FolderName: ''
%                FileName: ''
%             ScreenDepth: 32
%     ScreenPixelsPerInch: 96
%                   Units: 'pixels'

if strcmp(k, 'ShapeDim')
    v = T.Properties.UserData.ShapeRect([3 4]);
    return;
end

if iscell(k)
    v = T.Properties.UserData;
    for i = 1:length(k)
        v = v.(k{i});    
    end
else
    v = T.Properties.UserData.(k);
end
