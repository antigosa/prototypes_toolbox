function ProtoData = prototypes_stack(ProtoData_cell)
% function ProtoData = prototypes_stack(ProtoData_cell)
% 
% Stack two or more prototype tables or cosine maps structures



Trials = stack_T(ProtoData_cell);

if isfield(ProtoData_cell{1}, 'csimaps')
    CSImaps = stack_csimaps(ProtoData_cell);
else
    CSImaps = [];
end

ProtoData=prototypes_ProtoStructure(Trials, CSImaps);



function D_out = stack_T(D_in)

ncells = length(D_in);

D_out = table;

for i=1:ncells
    
    D_out = [D_out; D_in{i}.Trials];
end

function D_out = stack_csimaps(D_in)

ncells = length(D_in);

for i=1:ncells
    if i==1
        D_out = D_in{i}.csimaps;
        D_out.Properties.UserData;
    else
        
        fn = fieldnames(D_out);
        fn = setdiff(fn, 'Properties');
        
        for j = 1:length(fn)
            if length(size(D_out.(fn{j}))) == 3
                D_out.(fn{j}) = cat(3, D_out.(fn{j}), D_in{i}.csimaps.(fn{j}));
            elseif size(D_out.ParticipantID,1)==1
                D_out.(fn{j}) = horzcat(D_out.(fn{j}), D_in{i}.csimaps.(fn{j}));
            end
        end
        
        D_out.Properties.UserData       = cat(2, D_out.Properties.UserData, D_in{i}.csimaps.Properties.UserData);
        
        
    end
    
end