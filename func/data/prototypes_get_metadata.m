function v = prototypes_get_metadata(ProtoTable, k)
% function v = prototypes_get_metadata(ProtoTable, k, v)
%
%
% - Simulated_bias
% - ScreenRect
% - ScreenDim
% - ShapeContainerRect
% - ShapeRect
% - YDir
% - Experiment
% - StimulusProtoTableype
% - StimulusFileName
% - FolderName
% - FileName
% - ScreenDepth
% - ScreenPixelsPerInch
% - Units
%
% ProtoTable is a prototable
%
% ProtoTableypical metadata (EXAMPLE)
% ===================
% 	User Data:
% ===================
%          Simulated_bias: [4×2 double]
%              ScreenRect: [1 1 1920 1080]
%      ShapeContainerRect: [-60 -30 660 330]
%               ShapeRect: [0 0 600 300]
%                    YDir: 'normal'
%              Experiment: 'Synthetic data'
%            StimulusProtoTableype: 'Square data'
%        StimulusFileName: ''
%              FolderName: ''
%                FileName: ''
%             ScreenDepth: 32
%     ScreenPixelsPerInch: 96
%                   Units: 'pixels'

if strcmp(k, 'ShapeDim')
    v = ProtoTable.Properties.UserData.ShapeRect([3 4]);
    return;
end

if iscell(k)
    v = ProtoTable.Properties.UserData;
    for i = 1:length(k)
        v = v.(k{i});    
    end
else
    v = ProtoTable.Properties.UserData.(k);
end
