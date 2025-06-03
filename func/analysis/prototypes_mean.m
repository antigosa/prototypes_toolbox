function DataStat = prototypes_mean(Data)
% function DataStat = prototypes_mean(Data)
%
% Data can be:
% - a ProtoTable
% - a csm (i.e. a 'cosine similarity map' structure)

if istable(Data)
    
%     Data        = prototypes_setDotID(Data);
%     DataStat    = prototypes_mean_Responses(Data, {'DotID'});
    
    DataStat    = prototypes_mean_Responses(Data, {'dot_id'});

else
    DataStat = prototypes_mean_CosineMaps(Data);
end


function GroupCosineMaps = prototypes_mean_CosineMaps(SubjectsCosineMaps)

GroupCosineMaps.CosineMap_mean          = mean(SubjectsCosineMaps.SimixSubject, 3);
GroupCosineMaps.W_CosineMap_mean        = mean(SubjectsCosineMaps.W_SimixSubject, 3);
GroupCosineMaps.W_CosineMap_sd          = std(SubjectsCosineMaps.W_SimixSubject, [], 3);
GroupCosineMaps.ParticipantID           = {'group'};
GroupCosineMaps.Properties.UserData     = SubjectsCosineMaps.Properties.UserData;


function TrialsStat = prototypes_mean_Responses(Trials, varNames)
% function TrialsStat = prototypes_mean_Responses(Trials, varNames)

ParticipantID = unique(Trials.ParticipantID);

ParticipantID_num = 1:length(ParticipantID);

Trials.ParticipantID_num = zeros(length(Trials.ParticipantID),1);

for i = 1:length(ParticipantID)
    Trials.ParticipantID_num(ismember(Trials.ParticipantID, ParticipantID{i})) = ParticipantID_num(i);
end

varTypes            = prototypes_variablesTypes(Trials);

varToRemove         = ismember(varTypes, {'cell', 'char'});

varToRemove         = Trials.Properties.VariableNames(varToRemove);

idx_cellVariables   = ismember(Trials.Properties.VariableNames, varToRemove);
Trials              = Trials(:, ~idx_cellVariables);

Trials              = sortrows(Trials, {'ParticipantID_num', 'dot_id'});

TrialsStat          = grpstats(Trials, varNames, {'nanmean'});

TrialsStat.Properties.VariableNames = strrep(TrialsStat.Properties.VariableNames, 'nanmean_GroupCount', 'N');

varToRemove         = {'nanmean_ParticipantID', 'nanmean_Trial', 'nanmean_Block', 'ParticipantID_num'};
idx_cellVariables   = ismember(TrialsStat.Properties.VariableNames, varToRemove);
TrialsStat          = TrialsStat(:, ~idx_cellVariables);

newVariableNames = strrep(TrialsStat.Properties.VariableNames, 'nanmean_', '');


TrialsStat.Properties.VariableNames = newVariableNames;
TrialsStat.Properties.UserData      = Trials.Properties.UserData;
TrialsStat.ParticipantID(:)         = {'group'};


function varTypes = prototypes_variablesTypes(Trials)
% function varTypes = prototypes_variablesTypes(Trials)

variableNames = Trials.Properties.VariableNames;
varTypes = cell(1, length(variableNames));
for v = 1:length(variableNames)
    varTypes{v} = class(Trials.(variableNames{v}));
end