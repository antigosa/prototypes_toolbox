function csimap = prototypes_slice(csimap, idx)



if isfield(csimap, 'stats')
    csimap = rmfield(csimap, 'stats');
end
tmp = csimap;

fn = fieldnames(csimap);

n = length(idx);

for i = 1:length(fn)
    sz = size(csimap.(fn{i}));
    
    cur_dim = find(sz == n);
    if cur_dim==3
        tmp.(fn{i}) = csimap.(fn{i})(:,:, idx);
    elseif cur_dim==2
        tmp.(fn{i}) = csimap.(fn{i})(:, idx);
    elseif cur_dim==1
        tmp.(fn{i}) = csimap.(fn{i})(idx);
    end
end

sz = size(csimap.Properties.UserData);
cur_dim = find(sz == n);

if cur_dim==2
    tmp.Properties.UserData = csimap.Properties.UserData(:, idx);
elseif cur_dim==1
    tmp.Properties.UserData = csimap.Properties.UserData(idx);    
end