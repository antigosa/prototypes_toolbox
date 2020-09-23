function T = prototypes_set_metadata(T, k, v)
% function T = prototypes_set_metadata(T, k, v)
%
% T is a prototable
%
% Typical metadata (EXAMPLE)
% ===================
% 	User Data:
% ===================
%   StimulusType: 'body_top'
%   StimulusImg: [1×1 struct]
%   Rectangle: [0 0 800 800]
%   folder_output: 'D:\Projects\2018\Protoperispace\Analysis\Reports\20190206'
%   fname_output: 'groupData_nDots463_body_top'
%   cosine_map: [1×1 struct]
%   RectHeight: 800
%   RectWidth: 800
%   RemovedData: [1×1 struct]
%   Shape: 'Circle'

fn_noOK     = {
    'CosineMap', ...
    'DemoInfo', ...
    'Models', ...
    'History', ...
    'RemovedData'
    };

fn_ok       = {
    'ShapeContainerRect', ...
    'Experiment', ...
    'ShapeRect', ...
    'StimulusFileName', ...
    'StimulusType',...
    'FileName', ...
    'FolderName', ...
    'ScreenRect', ...
    'YDir', ...
    'Shape', ...
    'ScreenDepth', ...
    'ScreenPixelsPerInch', ...
    'Units'
    };


%==========================================================================
% Check if k is a private name
%==========================================================================
idx_notAllowed = ismember(fn_noOK, k);

if any(idx_notAllowed)
    s=[];    
    for f = 1:length(fn_ok)
        s=[s sprintf('\t%s\n', fn_ok{f})];
    end
    warning('You cannot add the field ''%s'' like this, you have to use the appropriate function. Allowed fieldnames are:\n', k);
    return
end


%==========================================================================
% Check if k is an unwanted name (do I really need this?)
%==========================================================================
if ~ismember(fn_ok, k)
    s=[];
    for f = 1:length(fn_ok)
        s=[s sprintf('\t%s\n', fn_ok{f})];
    end
    warning('You cannot add the field ''%s'' like this. Allowed fieldnames are:\n%s', k, s);
    return
end

T.Properties.UserData.(k) = v;

if strcmp(k, 'Rectangle')
    T.Properties.UserData.RectWidth = v(3);
    T.Properties.UserData.RectHeight = v(4);    
end
