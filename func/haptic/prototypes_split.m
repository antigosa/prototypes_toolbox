function D_out = prototypes_split(D_in)


if ~istable(D_in)
    % dataset is a cosine map (check)
    D_out = prototypes_split_csimaps(D_in);
else
    D_out = prototypes_stack_T(D_in);
end


function D_out = prototypes_split_csimaps(D_in)

ncells = length(D_in.ParticipantID);

D_out = cell(1, ncells);

for i=1:ncells
    D_out{i}.SimixSubject           = D_in.SimixSubject(:,:,i);
    D_out{i}.W_SimixSubject         = D_in.W_SimixSubject(:,:,i);
    D_out{i}.ParticipantID          = D_in.ParticipantID(i);
    D_out{i}.Properties.UserData    = D_in.Properties.UserData(i);
    D_out{i}.alphavalue             = D_in.alphavalue(i);
end

%D_out{i}.Modality               = D_in.Modality{i};