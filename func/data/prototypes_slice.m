function ProtoData = prototypes_slice(ProtoData, varname, varvals, opt)
% function ProtoData = prototypes_slice(ProtoData, varname, varvals, opt)

if nargin<4;opt=[];end

if ~isfield(opt, 'sliceCSImaps'); opt.sliceCSImaps=1;end

if iscell(varname);varname=varname{1};end

idx = ismember(ProtoData.Trials.(varname), varvals);
Trials  = ProtoData.Trials(idx, :);

if ~isempty(ProtoData.csimaps) && opt.sliceCSImaps
    % only subjects can be sliced for csimaps, otherwise, they need to be
    % recomputed (e.g., if trials are sliced)
    csimaps = prototypes_slice_csimap(ProtoData.csimaps, varname, varvals);
        
else
    csimaps=[];
end

ProtoData                = prototypes_ProtoStructure(Trials, csimaps, struct('computeSummary', 0));




function tmp = prototypes_slice_csimap(csimap, varname, varvals)
% if isfield(csimap, 'stats')
%     csimap = rmfield(csimap, 'stats');
% end
tmp = csimap;

fn = fieldnames(csimap);

idx = find(ismember(csimap.(varname), varvals));

for i = 1:length(fn)
    sz = size(csimap.(fn{i}));
    
    if strcmp(fn{i}, 'Properties')
        continue;
    end
    
    if length(csimap.(fn{i}))==1
        continue;
    end
    
    cur_dim = length(sz);
    if cur_dim==3
        tmp.(fn{i}) = csimap.(fn{i})(:,:, idx);
    elseif cur_dim==2
        tmp.(fn{i}) = csimap.(fn{i})(:, idx);
    elseif cur_dim==1
        tmp.(fn{i}) = csimap.(fn{i})(idx);
    end
end

tmp.Properties.UserData = csimap.Properties.UserData(idx);
