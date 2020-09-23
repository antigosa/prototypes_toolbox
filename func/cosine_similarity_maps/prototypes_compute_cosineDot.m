function Trials=prototypes_compute_cosineDot(Trials, CosineMap, dataType)
% function T=prototypes_compute_cosineDot(T, dataType)

if ~exist('dataType', 'var')
    dataType = 'W_SimixSubject';
end

subjlist = unique(Trials.ParticipantID);

if ischar(subjlist) && strcmp(subjlist, 'group')
    Trials = prototypes_compute_cosineDot_asubj(Trials, CSI_map);
else
    nsubj = length(subjlist);
    T_new = table;
    for s = 1:nsubj
        ParticipantID = subjlist(s);
        if ~ismember(ParticipantID, unique(CosineMap.ParticipantID))
            warning('This subject is not part of this group');
            return;
        end
        CSI_map = CosineMap.(dataType)(:, :, CosineMap.ParticipantID==ParticipantID);
        T_subj  = Trials(Trials.ParticipantID==ParticipantID, :);
        
        T_subj = prototypes_compute_cosineDot_asubj(T_subj, CSI_map);
        
        T_new = [T_new; T_subj];
    end
    T_new.Properties.UserData=Trials.Properties.UserData;
    Trials=T_new;
end


function T=prototypes_compute_cosineDot_asubj(T, CSI_map)
% add the cosine value to each dot
CosineDot = nan(size(T, 1), 1);
for d =1:size(T, 1)
    act_dot = ceil([T.ActualDots_xy(d, 1), T.ActualDots_xy(d, 2)]);
    if any(isnan(act_dot)); continue; end
    CosineDot(d)= CSI_map(act_dot(2), act_dot(1));
end
T.CosineDot=CosineDot;