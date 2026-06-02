function [ax, ax_img] = prototypes_plot_cosineMap(csm, subj_id, clim, dataType, opt)
% function [ax, ax_img] = prototypes_plot_cosineMap(csm, subj_id, clim, dataType, opt)
%
% dataType:
% - 'SimixSubject', 'W_SimixSubject', if csm is not statistical output

if ~exist('subj_id', 'var')||isempty(subj_id); subj_id='group'; end
if ~exist('dataType', 'var')||isempty(dataType); dataType='W_SimixSubject'; end
if ~exist('clim', 'var')||isempty(clim); clim=[-1 1]; end
if nargin<5; opt=[];end

if ~isfield(opt, 'useMesh'); opt.useMesh=0;end

if ~isfield(csm, dataType); dataType='W_CosineMap_mean';end

isgroupData = 0;
n = length(unique(csm.subj_id));
if n==1
    if strcmp(unique(csm.subj_id), 'group')
        isgroupData = 1;
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

idx_participant = find(ismember(csm.subj_id, subj_id));

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

axis off;axis equal;
axis(csm.Properties.UserData(idx_participant).ShapeContainerRect([1 3 2 4]));
ax              = gca;

if exist('prototypes_plot_image.m', 'file') ~= 0
    ax_img = prototypes_plot_image(csm);
else
    ax_img=[];
end

rectPos = csm.Properties.UserData(idx_participant).ShapeRect;

StimulusType = prototypes_get_metadata(csm, 'StimulusType');
if iscell(StimulusType)
    StimulusType = cell2mat(StimulusType);
end

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

ax.YDir         = prototypes_get_metadata(csm, 'YDir');
if ~isempty(ax_img)
    cb_im = colorbar(ax_img);
    cb_im.Visible='Off';
end

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

if strcmp(subj_id, 'group')
    ax.Units        = 'normalized';
    ax.Position     = [0.05 0.05 0.82 0.9];
    
    if ~isempty(ax_img)
        ax_img.Units        = 'normalized';
        ax_img.Position     = [0.05 0.05 0.82 0.9];
    end
    
end