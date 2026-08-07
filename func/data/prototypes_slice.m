function Data = prototypes_slice(Data, varname, varvals, opt)
% function Data = prototypes_slice(Data, varname, varvals, opt)

if nargin<4;opt=[];end

data_type = prototypes_datatype(Data);

if iscell(varname);varname=varname{1};end

switch data_type
    case 'ProtoData'
                
        if ~isfield(opt, 'sliceCSImaps'); opt.sliceCSImaps=1;end
        
        
        idx = ismember(Data.Trials.(varname), varvals);
        Trials  = Data.Trials(idx, :);
        
        if ~isempty(Data.csimaps) && opt.sliceCSImaps
            % only subjects can be sliced for csimaps, otherwise, they need to be
            % recomputed (e.g., if trials are sliced)
            csimaps = prototypes_slice_csimap(Data.csimaps, varname, varvals);
            
        else
            csimaps=[];
        end
        
        Data                = prototypes_ProtoStructure(Trials, csimaps, struct('computeSummary', 0));
        
    case 'Trials'
        idx         = ismember(Data.(varname), varvals);
        Data        = Data(idx, :);        
        
    case 'csimaps'
        Data        = prototypes_slice_csimap(Data, varname, varvals);
        
end



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

if length(csimap.Properties.UserData)==1
    idx=1;
end
tmp.Properties.UserData = csimap.Properties.UserData(idx);
