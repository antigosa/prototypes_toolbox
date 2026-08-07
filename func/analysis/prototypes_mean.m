function ProtoData = prototypes_mean(ProtoData)
% function DataStat = prototypes_mean(Data)
%
% Data can be:
% - a ProtoTable
% - a csm (i.e. a 'cosine similarity map' structure)

Trials = ProtoData.Trials;

if ~any(ismember(Trials.Properties.VariableNames, 'dot_id'))
    Trials    = prototypes_setDotID(Trials);
end
TrialsStat    = prototypes_mean_Responses(Trials, {'dot_id'});
TrialsStat    = prototypes_compute_errorVectors(TrialsStat);

if isfield(ProtoData, 'csimaps')
    csimaps     = ProtoData.csimaps;
    csimapsStat    = prototypes_mean_CosineMaps(csimaps);
else
    csimapsStat    = [];
end

% ProtoData.Trials    = TrialsStat;
% ProtoData.csimaps   = csimapsStat;
% ProtoData.nSubjects = 1;

TrialsStat.experiment(:)    = ProtoData.experiment;
TrialsStat.stimulus_type(:) = unique(Trials.stimulus_type);
TrialsStat(:, {'break_id', 'block_id', 'Rectcoord_FIRST', 'Rectcoord_SECOND'})=[];
TrialsStat.trials_id(:) = 1:size(TrialsStat, 1);
TrialsStat.Properties.RowNames(:)=[];

% TrialsStat.Properties.UserData Trials.Properties.UserData

opt = [];
opt.computeSummary=0;
ProtoData=prototypes_ProtoStructure(TrialsStat, csimapsStat, opt);
ProtoData.stat={'mean'};


function GroupCosineMaps = prototypes_mean_CosineMaps(SubjectsCosineMaps)

GroupCosineMaps.CosineMap_mean          = mean(SubjectsCosineMaps.SimixSubject, 3);
GroupCosineMaps.W_CosineMap_mean        = mean(SubjectsCosineMaps.W_SimixSubject, 3);
GroupCosineMaps.W_CosineMap_sd          = std(SubjectsCosineMaps.W_SimixSubject, [], 3);
% GroupCosineMaps.ParticipantID           = {'group'};
GroupCosineMaps.subj_id                 = {'group'};
GroupCosineMaps.Properties.UserData     = SubjectsCosineMaps.Properties.UserData;


function TrialsStat = prototypes_mean_Responses(Trials, varNames)
% function TrialsStat = prototypes_mean_Responses(Trials, varNames)

subj_id = unique(Trials.subj_id);

if ~isnumeric(subj_id)
    
    % TEST THIS!!!
    
    ParticipantID_num = 1:length(subj_id);
    
    Trials.ParticipantID_num = zeros(length(Trials.subj_id),1);
    
    for i = 1:length(subj_id)
        Trials.ParticipantID_num(ismember(Trials.subj_id, subj_id{i})) = ParticipantID_num(i);
    end
    
    Trials.subj_id = Trials.ParticipantID_num;
    
    Trials.ParticipantID_num = [];
    
end

varTypes            = prototypes_variablesTypes(Trials);

varToRemove         = ismember(varTypes, {'cell', 'char', 'string'});

varToRemove         = Trials.Properties.VariableNames(varToRemove);

idx_cellVariables   = ismember(Trials.Properties.VariableNames, varToRemove);
Trials              = Trials(:, ~idx_cellVariables);

Trials              = sortrows(Trials, {'subj_id', 'dot_id'});

TrialsStat          = grpstats(Trials, varNames, {'nanmean'});

TrialsStat.Properties.VariableNames = strrep(TrialsStat.Properties.VariableNames, 'nanmean_GroupCount', 'N');

varToRemove         = {'nanmean_ParticipantID', 'nanmean_Trial', 'nanmean_Block', 'subj_id'};
idx_cellVariables   = ismember(TrialsStat.Properties.VariableNames, varToRemove);
TrialsStat          = TrialsStat(:, ~idx_cellVariables);

newVariableNames = strrep(TrialsStat.Properties.VariableNames, 'nanmean_', '');


TrialsStat.Properties.VariableNames = newVariableNames;
TrialsStat.Properties.UserData      = Trials.Properties.UserData;

TrialsStat.Properties.UserData = rmfield(TrialsStat.Properties.UserData, 'folder_output');
TrialsStat.Properties.UserData = rmfield(TrialsStat.Properties.UserData, 'fname_output');
TrialsStat.Properties.UserData = rmfield(TrialsStat.Properties.UserData, 'experiment_dur_sec');
TrialsStat.Properties.UserData = rmfield(TrialsStat.Properties.UserData, 'day');
TrialsStat.Properties.UserData = rmfield(TrialsStat.Properties.UserData, 'expEnded');

TrialsStat.subj_id = [];

TrialsStat.subj_id(:)         = {'group'};


function varTypes = prototypes_variablesTypes(Trials)
% function varTypes = prototypes_variablesTypes(Trials)

variableNames = Trials.Properties.VariableNames;
varTypes = cell(1, length(variableNames));
for v = 1:length(variableNames)
    varTypes{v} = class(Trials.(variableNames{v}));
end