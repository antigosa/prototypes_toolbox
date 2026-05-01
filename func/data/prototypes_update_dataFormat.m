function T = prototypes_update_dataFormat(T)

% Define what to find and what to replace it with
oldStrings = {'Trial', 'DotID', 'Block', 'Age', 'Gender', 'subj_id'};
newStrings = {'trial_id', 'dot_id', 'block_id', 'age', 'gender', 'ParticipantID'};

% Replace in one go
T.Properties.VariableNames = replace(T.Properties.VariableNames, oldStrings, newStrings);

