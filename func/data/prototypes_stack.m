function D_out = prototypes_stack(D_in)
% function D_out = prototypes_stack(D_in)
% 
% Stack two or more prototype tables or cosine maps structures

if isstruct(D_in{1})
    % dataset is a cosine map (check)
    D_out = prototypes_stack_csimaps(D_in);
else
    D_out = prototypes_stack_T(D_in);
end


function D_out = prototypes_stack_csimaps(D_in)

% THIS COULD BE UPDATED, CHECK load_prototype_data.m

ncells = length(D_in);

for i=1:ncells
    if i==1
        D_out = D_in{i};
        D_out.Properties.UserData
    else
        D_out.SimixSubject(:, :, i)     = D_in{i}.SimixSubject;
        D_out.W_SimixSubject(:, :, i)   = D_in{i}.W_SimixSubject;
        D_out.ParticipantID(i)          = D_in{i}.ParticipantID;
        D_out.Properties.UserData(i)    = D_in{i}.Properties.UserData;
        D_out.alphavalue(i)             = D_in{i}.alphavalue;
    end
    
end

function D_out = prototypes_stack_T(D_in)

ncells = length(D_in);

D_out = table;

for i=1:ncells
    
    D_out = [D_out; D_in{i}];
end
