function [missing_variables, missing_UDFields] = prototypes_check_prototable(ProtoTable, verbose)
% function [missing_variables, missing_UDFields] = prototypes_check_prototable(ProtoTable, verbose)

if nargin==1; verbose=0;end

missing_variables   = prototypes_check_prototable_Variables(ProtoTable, verbose);
missing_UDFields    = prototypes_check_prototable_UserData(ProtoTable, verbose);
prototypes_check_internal_consistency(ProtoTable, verbose);



function missing_variables = prototypes_check_prototable_Variables(ProtoTable, verbose)
VariableNames = ProtoTable.Properties.VariableNames;
missing_variables=[];

proto_var=prototypes_variables;

check_fundamental_variables     = ismember(proto_var.FundamentalVariables, VariableNames);
check_important_variables       = ismember(proto_var.ImportantVariables, VariableNames);
check_optional_variables        = ismember(proto_var.OptionalVariables, VariableNames);
if any(check_fundamental_variables==0)
    missing_variables = proto_var.FundamentalVariables(~check_fundamental_variables);
    display(missing_variables);
    error('missing fundmental variables');
end

if verbose
    if any(check_important_variables==0)
        display(proto_var.ImportantVariables(~check_important_variables))
        warning('missing important variables');
    end
    
    if any(check_optional_variables==0)
        display(proto_var.OptionalVariables(~check_optional_variables))
        warning('missing optional variables');
    end
end


function missing_fields = prototypes_check_prototable_UserData(ProtoTable, verbose)

% there can be more than one structure

missing_fields=[];
for i = 1:length(ProtoTable.Properties.UserData)
    
    if iscell(ProtoTable.Properties.UserData)
        UserData = ProtoTable.Properties.UserData{i};
    else
        UserData = ProtoTable.Properties.UserData;
    end
    
    FieldNames = fieldnames(UserData);
    missing_fields=[];
    
    proto_var=prototypes_variables;
    
    check_fundamental_variables = ismember(proto_var.FundamentalUD, FieldNames);
    check_important_variables   = ismember(proto_var.ImportantUD, FieldNames);
    check_optional_variables    = ismember(proto_var.OptionalUD, FieldNames);
    if any(check_fundamental_variables==0)
        missing_fields = proto_var.FundamentalUD(~check_fundamental_variables);
        display(missing_fields);
        warning('missing fundamental variables: in future this will be an error');
    end
    
    if verbose
        if any(check_important_variables==0)
            display(proto_var.ImportantUD(~check_important_variables))
            warning('missing important variables');
        end
        
        if any(check_optional_variables==0)
            display(proto_var.OptionalUD(~check_optional_variables))
            warning('missing optional variables');
        end
    end
end


function prototypes_check_internal_consistency(ProtoTable, verbose)


if any(strcmp(ProtoTable.Properties.VariableNames, 'errorXY'))
    
    % isequal do not work with NaNs
    tmp = ProtoTable(~any(isnan(ProtoTable.errorXY),2),:);
    
    % check error vectors
    assert(isequal(tmp.errorXY, tmp.ResponseDots_xy-tmp.ActualDots_xy), 'error vectors are not consistent with the response data');
    
    % check error magnitude
    assert(isequal(tmp.errorMag, sqrt(diag(tmp.errorXY*tmp.errorXY'))), 'error magnitudes are not consistent with the error vectors');
    
end

if isfield(ProtoTable.Properties.UserData, 'cosine_map')
    
    % if 'W_SimixSubject' does not exist, it is 'W_SimixSubject_avg'
    if isfield(ProtoTable.Properties.UserData.cosine_map, 'W_SimixSubject')
        nsubj1 = length(unique(ProtoTable.subj_id));
        nsubj2 = size(ProtoTable.Properties.UserData.cosine_map.W_SimixSubject, 3);
        assert(isequal(nsubj1, nsubj2), 'the number of participants in the table does not match the one of the cosine maps');
    end
    
    if ~isfield(ProtoTable.Properties.UserData.cosine_map, 'subj_id')
        error('You now have to have a field .UserData.cosine_map.subj_id');
    end
    
    if ~isfield(ProtoTable.Properties.UserData.cosine_map, 'alphavalue')
        error('You now have to have a field .UserData.cosine_map.alphavalue');        
    end    
    
    
      
end

% % check the rectangle 
% assert(ProtoTable.Properties.UserData.RectWidth == (ProtoTable.Properties.UserData.Rectangle(3) - abs(ProtoTable.Properties.UserData.Rectangle(1))), ...
%     'something is wrong with the Width component of the Rectangle information');
% 
% assert(ProtoTable.Properties.UserData.RectHeight == (ProtoTable.Properties.UserData.Rectangle(4) - abs(ProtoTable.Properties.UserData.Rectangle(2))), ...
%     'something is wrong with the Height component of the Rectangle information');

function proto_var = prototypes_variables
% 
% - ParticipantID: numeric
% - ParticipantCODE: string
% function proto_var=prototypes_variables
% Variables
proto_var.FundamentalVariables      = {'ParticipantID', 'trial_id', 'ActualDots_xy', 'ResponseDots_xy', 'dot_id', 'shape_type'};
proto_var.ImportantVariables        = {'block_id', 'errorXY', 'errorMag'};
proto_var.OptionalVariables         = {'ParticipantCODE', 'MouseInitialLoc', 'ResponseDots_xy_relToScreen', 'ResponseDots_xy_relToShape', 'RectCoord_FIRST', 'RectCoord_SECOND'};
proto_var.Demographics              = {'age', 'gender', 'hand_preference', 'eye_preference'};
proto_var.Experiment                = {'experiment', 'rot_angle', 'use_image', 'target_color', 'modality', 'iti_duration', 'rect1_duration', 'dot_duration'};

% Field of .UserData
proto_var.FundamentalUD             = {'ScreenRect', 'ShapeRect', 'ShapeContainerRect', 'YDir', 'ShapeType'};
proto_var.ImportantUD               = {'Experiment', 'StimulusFileName', 'FolderName', 'FileName', 'ScreenDepth', 'ScreenPixelsPerInch', 'Units'};
proto_var.OptionalUD                = {'CosineMap'};
