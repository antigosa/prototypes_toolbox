function Info = prototypes_info(T, k)
% function prototypes_info(T)
disp(T.Properties.UserData)
Participants.ParticipantIDs     = unique(T.ParticipantID)';
Participants.N                  = length(Participants.ParticipantIDs);

if isfield(T, 'Gender')
end

if any(strcmp(T.Properties.VariableNames, 'Age'))
    Participants.MeanAge = mean(unique(T.Age));
end

disp(Participants);

Dots.Ndots = length(unique(T.dot_id));

disp(Dots);

if nargin >1
    switch k
        case 'Properties'
            Info = T.Properties.UserData;
            
        case 'Participants'
            Info = Participants;
            
        case 'Dots'            
            Info = Dots;
    end
end