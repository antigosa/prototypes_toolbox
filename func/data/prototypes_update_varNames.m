function ProtoData = prototypes_update_varNames(ProtoData, oldVarNames, newVarNames)
% function ProtoData = prototypes_update_varNames(ProtoData, oldVarNames, newVarNames)

if nargin == 1
    % Define what to find and what to replace it with
    oldVarNames = {'Trial', 'DotID', 'Block', 'Age', 'Gender', 'subj_id'};
    newVarNames = {'trial_id', 'dot_id', 'block_id', 'age', 'gender', 'ParticipantID'};
end

% Replace in one go
ProtoData.Trials.Properties.VariableNames = replace(ProtoData.Trials.Properties.VariableNames, oldVarNames, newVarNames);

if isfield(ProtoData, 'csimaps')
    fn_old = fieldnames(ProtoData.csimaps);
    
    fn_new = replace(fn_old, oldVarNames, newVarNames);
    
    tmp = [];
    for i = 1:length(fn_old)
        tmp.(fn_new{i}) = ProtoData.csimaps.(fn_old{i});
    end
    ProtoData.csimaps = tmp;
end

