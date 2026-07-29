function D_out = prototypes_stack_T(D_in)

ncells = length(D_in);

D_out = table;

for i=1:ncells
    
    D_out = [D_out; D_in{i}];
end