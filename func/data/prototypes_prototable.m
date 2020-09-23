function T = prototypes_prototable(T)
% function T = prototypes_prototable(T)
%
% 
% =========================================================================
% Fundamental variables
% =========================================================================
% 'ParticipantID', 'Trial', 'DotID', Block, 'ActualDots_xy','ResponseDots_xy'

if nargin==0;T = table;end
% =========================================================================
% Fundamental Fields
% =========================================================================
T = prototypes_set_metadata(T, 'ScreenRect', get(0,'ScreenSize'));      % in px
T = prototypes_set_metadata(T, 'ShapeContainerRect', [0 0 nan nan]);    % in px
T = prototypes_set_metadata(T, 'ShapeRect', [0 0 nan nan]);             % in px
T = prototypes_set_metadata(T, 'YDir', 'normal');                       % 'normal' | 'reverse'
%
% T = prototypes_set_metadata(T, 'RectHeight', '');       % in px
% T = prototypes_set_metadata(T, 'RectWidth', '');        % in px



% =========================================================================
% Important Fields
% =========================================================================
% Experiment name
T = prototypes_set_metadata(T, 'Experiment', '');

% The type of stimulus (e.g. 'Circle', 'Rectangle', 'Body', 'Hand')
T = prototypes_set_metadata(T, 'StimulusType', '');

% The filename of the stimulus image
T = prototypes_set_metadata(T, 'StimulusFileName', '');

%T = prototypes_set_metadata(T, 'Rectangle', [0 0 nan nan]);

% Location to save the data
T = prototypes_set_metadata(T, 'FolderName', '');

% File name to save the data
T = prototypes_set_metadata(T, 'FileName', '');

% Screen details
T = prototypes_set_metadata(T, 'ScreenDepth', get(0,'ScreenDepth'));
T = prototypes_set_metadata(T, 'ScreenPixelsPerInch', get(0,'ScreenPixelsPerInch'));
T = prototypes_set_metadata(T, 'Units', get(0,'Units'));




