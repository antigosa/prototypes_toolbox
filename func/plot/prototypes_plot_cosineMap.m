function [ax, ax_img] = prototypes_plot_cosineMap(csm, ParticipantID, clim, dataType, opt)
% function prototypes_plot_cosineMap(csm, ParticipantID, clim, dataType, opt)
% 
% dataType:
% - 'SimixSubject', 'W_SimixSubject', if csm is not statistical output



if ~exist('ParticipantID', 'var')||isempty(ParticipantID); ParticipantID='group'; end
if ~exist('dataType', 'var')||isempty(dataType); dataType='W_SimixSubject'; end
if ~exist('clim', 'var')||isempty(clim); clim=[-1 1]; end

if ~isfield(csm, dataType); dataType='W_CosineMap_mean';end

if ~strcmp(ParticipantID, 'group') && ~strcmp(csm.ParticipantID, 'group')
    if ~ismember(ParticipantID, unique(csm.ParticipantID))
        warning('This subject is not part of this group');
        return;
    end
    CSI_map = csm.(dataType)(:, :, csm.ParticipantID==ParticipantID);
else
    CSI_map = csm.(dataType);
end

zoffset = 0;
ydim    = size(CSI_map, 1);
xdim    = size(CSI_map, 2);
x       = linspace(csm.Properties.UserData.ShapeContainerRect(1),csm.Properties.UserData.ShapeContainerRect(3), xdim);
y       = linspace(csm.Properties.UserData.ShapeContainerRect(2),csm.Properties.UserData.ShapeContainerRect(4), ydim);
[X,Y]   = meshgrid(x,y);
mesh(X, Y, CSI_map-zoffset);view(0, 90);%set(gca, 'YDir', 'reverse')
caxis(clim-zoffset);
% figure; imagesc(Groupcsms.W_csm_mean);
axis off;axis equal;
axis(csm.Properties.UserData.ShapeContainerRect([1 3 2 4]));
ax              = gca;

if exist('prototypes_plot_image.m', 'file') ~= 0
    ax_img = prototypes_plot_image(csm);        
else
    ax_img=[];    
end

rectPos = csm.Properties.UserData.ShapeRect;

switch prototypes_get_metadata(csm, 'StimulusType')
    case 'Circle'
        rectangle('Position', rectPos, 'Curvature', 1);
        
    case {'Square', 'Rectangle'}
        rectangle('Position', rectPos);

    case 'Face'
        rectangle('Position', rectPos, 'Curvature', [1 0.9]);
        
    case 'Oval'
        rectangle('Position', rectPos, 'Curvature', [1 0.9]);        
end

ax.YDir         = prototypes_get_metadata(csm, 'YDir');
cb_im = colorbar(ax_img);
cb_im.Visible='Off';

cb              = colorbar(ax);
cb.Limits       = [clim(1) clim(2)]-zoffset;
cb.Ticks        = linspace(clim(1)-zoffset, clim(2)-zoffset,3);
cb.TickLabels   = linspace(clim(1), clim(2),3);

if strcmp(ParticipantID, 'group')
    ax.Units        = 'normalized';
    ax.Position     = [0.05 0.05 0.82 0.9];
    
    if ~isempty(ax_img)
        ax_img.Units        = 'normalized';
        ax_img.Position     = [0.05 0.05 0.82 0.9];
    end
    
end