function ProtoTable = prototypes_prototable(ProtoTable)
% function ProtoTable = prototypes_prototable(ProtoTable)
%
% 
% =========================================================================
% Fundamental variables
% =========================================================================
% 'ParticipantID', 'ProtoTablerial', 'DotID', Block, 'ActualDots_xy','ResponseDots_xy'

if nargin==0;ProtoTable = table;end
% =========================================================================
% Fundamental Fields
% =========================================================================
ProtoTable = prototypes_set_metadata(ProtoTable, 'ScreenRect', get(0,'ScreenSize'));      % in px
ProtoTable = prototypes_set_metadata(ProtoTable, 'ShapeContainerRect', [0 0 nan nan]);    % in px
ProtoTable = prototypes_set_metadata(ProtoTable, 'ShapeRect', [0 0 nan nan]);             % in px
ProtoTable = prototypes_set_metadata(ProtoTable, 'YDir', 'normal');                       % 'normal' | 'reverse'
%
% ProtoTable = prototypes_set_metadata(ProtoTable, 'RectHeight', '');       % in px
% ProtoTable = prototypes_set_metadata(ProtoTable, 'RectWidth', '');        % in px



% =========================================================================
% Important Fields
% =========================================================================
% Experiment name
ProtoTable = prototypes_set_metadata(ProtoTable, 'Experiment', '');

% ProtoTablehe type of stimulus (e.g. 'Circle', 'Rectangle', 'Body', 'Hand')
ProtoTable = prototypes_set_metadata(ProtoTable, 'StimulusProtoTableype', '');

% ProtoTablehe filename of the stimulus image
ProtoTable = prototypes_set_metadata(ProtoTable, 'StimulusFileName', '');

%ProtoTable = prototypes_set_metadata(ProtoTable, 'Rectangle', [0 0 nan nan]);

% Location to save the data
ProtoTable = prototypes_set_metadata(ProtoTable, 'FolderName', '');

% File name to save the data
ProtoTable = prototypes_set_metadata(ProtoTable, 'FileName', '');

% Screen details
ProtoTable = prototypes_set_metadata(ProtoTable, 'ScreenDepth', get(0,'ScreenDepth'));
ProtoTable = prototypes_set_metadata(ProtoTable, 'ScreenPixelsPerInch', get(0,'ScreenPixelsPerInch'));
ProtoTable = prototypes_set_metadata(ProtoTable, 'Units', get(0,'Units'));




