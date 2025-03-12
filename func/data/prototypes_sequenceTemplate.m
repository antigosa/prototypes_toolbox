function ts_template = prototypes_sequenceTemplate(trials_sequence)

variableTypes   = varfun(@class, trials_sequence, 'OutputFormat', 'cell');
variableSize    = varfun(@size, trials_sequence, 'OutputFormat', 'cell');
VariableNames   = trials_sequence.Properties.VariableNames;


ts_template=table;
for i=1:length(VariableNames)
    switch variableTypes{i}
        case 'cell'
            ts_template.(VariableNames{i})={''};
            
        case 'char'
            ts_template.(VariableNames{i})={''};
            
        case 'double'
            ts_template.(VariableNames{i})=zeros(1, variableSize{i}(2));
            
    end
    
end