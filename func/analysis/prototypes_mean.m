function DataStat = prototypes_mean(Data)

if istable(Data)
    DataStat = prototypes_mean_Responses(Data, {'DotID'});
else
    DataStat = prototypes_mean_CosineMaps(Data);
end


function GroupCosineMaps = prototypes_mean_CosineMaps(SubjectsCosineMaps)

GroupCosineMaps.CosineMap_mean          = mean(SubjectsCosineMaps.SimixSubject, 3);
GroupCosineMaps.W_CosineMap_mean        = mean(SubjectsCosineMaps.W_SimixSubject, 3);
GroupCosineMaps.W_CosineMap_sd          = std(SubjectsCosineMaps.W_SimixSubject, [], 3);
GroupCosineMaps.ParticipantID           = 'group';
GroupCosineMaps.Properties.UserData     = SubjectsCosineMaps.Properties.UserData;


function TrialsStat = prototypes_mean_Responses(Trials, varNames)
% function TrialsStat = prototypes_mean_Responses(Trials, varNames)

varTypes            = prototypes_variablesTypes(Trials);

varToRemove         = ismember(varTypes, {'cell', 'char'});

varToRemove         = Trials.Properties.VariableNames(varToRemove);

idx_cellVariables   = ismember(Trials.Properties.VariableNames, varToRemove);
Trials              = Trials(:, ~idx_cellVariables);

Trials              = sortrows(Trials, {'ParticipantID', 'DotID'});

TrialsStat          = grpstats(Trials, varNames, {'nanmean'});

TrialsStat.Properties.VariableNames = strrep(TrialsStat.Properties.VariableNames, 'nanmean_GroupCount', 'N');

varToRemove         = {'nanmean_ParticipantID', 'nanmean_Trial', 'nanmean_Block'};
idx_cellVariables   = ismember(TrialsStat.Properties.VariableNames, varToRemove);
TrialsStat          = TrialsStat(:, ~idx_cellVariables);


newVariableNames = strrep(TrialsStat.Properties.VariableNames, 'nanmean_', '');


TrialsStat.Properties.VariableNames = newVariableNames;
TrialsStat.Properties.UserData      = Trials.Properties.UserData;


function varTypes = prototypes_variablesTypes(Trials)
% function varTypes = prototypes_variablesTypes(Trials)

variableNames = Trials.Properties.VariableNames;
varTypes = cell(1, length(variableNames));
for v = 1:length(variableNames)
    varTypes{v} = class(Trials.(variableNames{v}));
end