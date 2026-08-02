function txt = prototypes_UpdateFunc(~, event_obj, ProtoData)


ActualDots_xy = round(ProtoData.Trials.ActualDots_xy,3);
ResponseDots_xy = round(ProtoData.Trials.ResponseDots_xy,3);

idx_a = find(all(abs(round(event_obj.Position,3)-ActualDots_xy)<0.01,2));
idx_r = find(all(abs(round(event_obj.Position,3)-ResponseDots_xy)<0.01,2));

if ~isempty(idx_a) || ~isempty(idx_r)
    if ~isempty(idx_a)
        idx = idx_a;
    else
        idx = idx_r;
    end
end

dot_id          = ProtoData.Trials.dot_id(idx);

if diff(dot_id)~=0
    fprintf('I found %d dots, something is wrong\n', length(dot_id));
else
    idx = idx(1); % there might be repetitions of the same dot
end


ActualDot_xy    = unique(ProtoData.Trials.ActualDots_xy(idx,:), 'rows'); % there might be repetitions
ResponseDot_xy  = ProtoData.Trials.ResponseDots_xy(idx,:);
dot_id          = ProtoData.Trials.dot_id(idx);


txt = sprintf('\nxyz: %.03f %.03f\nActual: %.03f %.03f\nResponse: %.03f %.03f\nDot: %d\n\n', ...
    event_obj.Position(1), event_obj.Position(2), ...
    ActualDot_xy(1), ActualDot_xy(2),...
    ResponseDot_xy(1), ResponseDot_xy(2), ...
    dot_id);


fprintf(txt);
