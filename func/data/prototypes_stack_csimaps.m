function D_out = prototypes_stack_csimaps(D_in)

ncells = length(D_in);

for i=1:ncells
    if i==1
        D_out = D_in{i};
        D_out.Properties.UserData;
    else
        
        fn = fieldnames(D_out);
        fn = setdiff(fn, 'Properties');
        
        for j = 1:length(fn)
            if (length(size(D_out.(fn{j}))) == 3 || length(size(D_out.(fn{j}))) == 2) & ~any(size(D_out.(fn{j}))==1)
                D_out.(fn{j}) = cat(3, D_out.(fn{j}), D_in{i}.(fn{j}));
            elseif size(D_out.ParticipantID,1)==1
                D_out.(fn{j}) = horzcat(D_out.(fn{j}), D_in{i}.(fn{j}));
            end
        end
        
        D_out.Properties.UserData       = cat(2, D_out.Properties.UserData, D_in{i}.Properties.UserData);
        
        
    end
    
end