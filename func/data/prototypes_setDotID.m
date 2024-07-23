function Trials = prototypes_setDotID(Trials)

ActualDots_xy = unique(Trials.ActualDots_xy, 'rows');


DotID = 1:size(ActualDots_xy,1);

Trials.DotID = zeros(size(Trials.ActualDots_xy,1),1);

for i = 1:length(DotID)
    Trials.DotID(all(ismember(Trials.ActualDots_xy, ActualDots_xy(i,:)),2)) = DotID(i);
end