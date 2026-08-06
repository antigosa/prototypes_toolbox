function [ax, ax_img] = prototypes_plot_cosineMap(ProtoData, dataType, opt)
% function [ax, ax_img] = prototypes_plot_cosineMap(ProtoData, dataType, opt)
%
% dataType:
% - 'SimixSubject', 'W_SimixSubject', if csm is not statistical output

if nargin<2;dataType='W_SimixSubject';end
if nargin<3;opt = [];end
if ~isfield(opt, 'filter');opt.filter=[];end
if ~isfield(opt, 'title');opt.title=[];end
if ~isfield(opt, 'errorsColour');opt.errorsColour=[0 0 0];end

if ~isempty(opt.filter)
    
    key     = opt.filter.key;
    if iscell(key)
        key     = cell2mat(key);
    end
    vals    = opt.filter.vals;
    
    fprintf('Selecting %s:\n', key)
    for i = 1:length(vals)
        fprintf('\t%s\n', vals{i});
    end
    fprintf('\n')
    ProtoData = prototypes_slice(ProtoData, opt.filter.key, opt.filter.vals);
end


csm = ProtoData.csimaps;

if ~isfield(opt, 'subj_id'); opt.subj_id=csm.subj_id;end
if ~isfield(opt, 'clim'); opt.clim=[-1 1];end
if ~isfield(opt, 'useMesh'); opt.useMesh=0;end
if ~isfield(opt, 'showRect'); opt.showRect=1;end
if ~isfield(opt, 'showColorbar'); opt.showColorbar=1;end
if ~isfield(opt, 'showErrors'); opt.showErrors=0;end
if ~isfield(opt, 'plotShapeContainer'); opt.plotShapeContainer=0;end
if ~isfield(opt, 'showTitle'); opt.showTitle=1;end


subj_id = opt.subj_id;
clim = opt.clim;

% n = length(unique(csm.subj_id));
n = length(subj_id);
if n>1
    error('Please select one participant using the option .subj_id'); 
else
    if strcmp(unique(csm.subj_id), 'group')
        isgroupData = 1;
    else
        % it's one participant
        isgroupData = 0;
    end
end


if ~isgroupData
    if ~ismember(subj_id, unique(csm.subj_id))
        warning('This subject is not part of this group');
        return;
    end
    CSI_map = csm.(dataType)(:, :, ismember(csm.subj_id, subj_id));
else
    CSI_map = csm.(dataType);
end

% CHECK THIS!!
if length(csm.Properties.UserData)>1
    idx_participant = find(ismember(csm.subj_id, subj_id));    
else
    idx_participant = 1;
end

if opt.useMesh
    % I don't remember why I used the mesh...
    zoffset = 0;
    ydim    = size(CSI_map, 1);
    xdim    = size(CSI_map, 2);
    x       = linspace(csm.Properties.UserData(idx_participant).ShapeContainerRect(1),csm.Properties.UserData(idx_participant).ShapeContainerRect(3), xdim);
    y       = linspace(csm.Properties.UserData(idx_participant).ShapeContainerRect(2),csm.Properties.UserData(idx_participant).ShapeContainerRect(4), ydim);
    [X,Y]   = meshgrid(x,y);
    mesh(X, Y, CSI_map-zoffset);view(0, 90);%set(gca, 'YDir', 'reverse')
    caxis(clim-zoffset);
else
    imagesc(CSI_map);
end

axis equal;


ax              = gca;
ax.Tag          = 'csimap';



if exist('prototypes_plot_image.m', 'file') ~= 0
    ax_img = prototypes_plot_image(csm);
else
    ax_img=[];
end

shapeContainerRect = abs(csm.Properties.UserData(idx_participant).ShapeContainerRect);
ShapeRect = csm.Properties.UserData(idx_participant).ShapeRect;

rectPos = csm.Properties.UserData(idx_participant).ShapeRect;


if opt.plotShapeContainer
    ax.XLim = [0 shapeContainerRect(1)+ShapeRect(3)+shapeContainerRect(1)];
    ax.YLim = [0 shapeContainerRect(2)+ShapeRect(4)+shapeContainerRect(2)];
else
    ax.XLim = [shapeContainerRect(1) shapeContainerRect(1)+ShapeRect(3)];
    ax.YLim = [shapeContainerRect(2) shapeContainerRect(1)+ShapeRect(4)];
end

axis off;

rectPos([1 2]) = rectPos([1 2]) + abs(csm.Properties.UserData(idx_participant).ShapeContainerRect([1 2]));

StimulusType = prototypes_get_metadata(csm, 'StimulusType');
if iscell(StimulusType)
    StimulusType = cell2mat(StimulusType);
end

if opt.showRect
    switch StimulusType
        case {'Circle'}
            rectangle('Position', rectPos, 'Curvature', 1);
            
        case {'Square', 'Rectangle'}
            rectangle('Position', rectPos);
            
        case {'Face'}
            rectangle('Position', rectPos, 'Curvature', [1 0.9]);
            
        case {'Oval'}
            rectangle('Position', rectPos, 'Curvature', [1 0.9]);
    end
end
ax.YDir         = cell2mat(prototypes_get_metadata(csm, 'YDir'));
if ~isempty(ax_img)
    cb_im = colorbar(ax_img);
    cb_im.Visible='Off';
end

if opt.showColorbar
    cb              = colorbar(ax);
    if opt.useMesh
        cb.Limits       = [clim(1) clim(2)]-zoffset;
        cb.Ticks        = linspace(clim(1)-zoffset, clim(2)-zoffset,3);
        cb.TickLabels   = linspace(clim(1), clim(2),3);
    else
        cb.Limits       = [clim(1) clim(2)];
        cb.Ticks        = linspace(clim(1), clim(2),3);
        cb.TickLabels   = linspace(clim(1), clim(2),3);
    end
    
%     tmp_position = ax.Position;
    cb.Position([2 4])  = [0.25 0.5];
    cb.FontSize         = 11;
%     ax.Position=tmp_position;
    
end
% if strcmp(subj_id, 'group')
%     ax.Units        = 'normalized';
%     ax.Position     = [0.05 0.05 0.82 0.9];
%     
%     if ~isempty(ax_img)
%         ax_img.Units        = 'normalized';
%         ax_img.Position     = [0.05 0.05 0.82 0.9];
%     end
%     
% end

if opt.showErrors
    subjProtoData = prototypes_slice(ProtoData, 'subj_id', subj_id);
    ProtoTable = subjProtoData.Trials;
    
    
    ActDots         = ProtoTable.ActualDots_xy + abs(csm.Properties.UserData(idx_participant).ShapeContainerRect([1 2]));
    %     RespDots        = ProtoTable.ResponseDots_xy;
    
    errorVector     = ProtoTable.errorXY;
    hold on;
    
    q               = quiver(ActDots(:,1), ActDots(:,2), errorVector(:,1), errorVector(:,2),0); % Use S=0 to plot the arrows without the automatic scaling.
    q.Color         = 'k';
    q.LineWidth     = 1;
    q.Color         = opt.errorsColour;
    
    
end

if opt.showTitle
    
    if isempty(opt.title)
        tit = opt.subj_id;
        if iscell(tit); tit=tit{1};end
    else
        if isfield(ProtoData, opt.title)
            tit = ProtoData.(opt.title);
            if iscell(tit); tit=tit{1};end
        else
            tit = opt.title;
            if iscell(tit); tit=tit{1};end
        end
        
    end
    title(sprintf('%s', tit))
end