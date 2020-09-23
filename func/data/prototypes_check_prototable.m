function [missing_variables, missing_UDFields] = prototypes_check_prototable(Trials, verbose)
% function [missing_variables, missing_UDFields] = prototypes_check_prototable(Trials, verbose)

if nargin==1; verbose=0;end

missing_variables   = prototypes_check_prototable_Variables(Trials, verbose);
missing_UDFields    = prototypes_check_prototable_UserData(Trials, verbose);
prototypes_check_internal_consistency(Trials, verbose);



function missing_variables = prototypes_check_prototable_Variables(Trials, verbose)
VariableNames = Trials.Properties.VariableNames;
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


function missing_fields = prototypes_check_prototable_UserData(Trials, verbose)

% there can be more than one structure

missing_fields=[];
for i = 1:length(Trials.Properties.UserData)
    
    if iscell(Trials.Properties.UserData)
        UserData = Trials.Properties.UserData{i};
    else
        UserData = Trials.Properties.UserData;
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


function prototypes_check_internal_consistency(Trials, verbose)


if any(strcmp(Trials.Properties.VariableNames, 'errorXY'))
    
    % isequal do not work with NaNs
    tmp = Trials(~any(isnan(Trials.errorXY),2),:);
    
    % check error vectors
    assert(isequal(tmp.errorXY, tmp.RespDots_xy-tmp.ActualDots_xy), 'error vectors are not consistent with the response data');
    
    % check error magnitude
    assert(isequal(tmp.errorMag, sqrt(diag(tmp.errorXY*tmp.errorXY'))), 'error magnitudes are not consistent with the error vectors');
    
end

if isfield(Trials.Properties.UserData, 'cosine_map')
    
    % if 'W_SimixSubject' does not exist, it is 'W_SimixSubject_avg'
    if isfield(Trials.Properties.UserData.cosine_map, 'W_SimixSubject')
        nsubj1 = length(unique(Trials.subj_id));
        nsubj2 = size(Trials.Properties.UserData.cosine_map.W_SimixSubject, 3);
        assert(isequal(nsubj1, nsubj2), 'the number of participants in the table does not match the one of the cosine maps');
    end
    
    if ~isfield(Trials.Properties.UserData.cosine_map, 'subj_id')
        error('You now have to have a field .UserData.cosine_map.subj_id');
    end
    
    if ~isfield(Trials.Properties.UserData.cosine_map, 'alphavalue')
        error('You now have to have a field .UserData.cosine_map.alphavalue');        
    end    
    
    
      
end

% % check the rectangle 
% assert(Trials.Properties.UserData.RectWidth == (Trials.Properties.UserData.Rectangle(3) - abs(Trials.Properties.UserData.Rectangle(1))), ...
%     'something is wrong with the Width component of the Rectangle information');
% 
% assert(Trials.Properties.UserData.RectHeight == (Trials.Properties.UserData.Rectangle(4) - abs(Trials.Properties.UserData.Rectangle(2))), ...
%     'something is wrong with the Height component of the Rectangle information');

function proto_var = prototypes_variables
% function proto_var=prototypes_variables
% Variables
proto_var.FundamentalVariables      = {'ParticipantID', 'Trial', 'ActualDots_xy', 'ResponseDots_xy'};
proto_var.ImportantVariables        = {'Block', 'Error_xy', 'ErrorMag', 'DotID'};
proto_var.OptionalVariables         = {'MouseInitialLoc', 'ResponseDots_xy_relToScreen', 'ResponseDots_xy_relToShape', 'RectCoord_FIRST', 'RectCoord_SECOND'};

% Field of .UserData
proto_var.FundamentalUD             = {'ScreenRect', 'ShapeRect', 'ShapeContainerRect', 'YDir'};
proto_var.ImportantUD               = {'Experiment', 'StimulusType', 'StimulusFileName', 'FolderName', 'FileName', 'ScreenDepth', 'ScreenPixelsPerInch', 'Units'};
proto_var.OptionalUD                = {'CosineMap'};

