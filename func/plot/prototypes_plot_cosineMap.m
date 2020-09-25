function prototypes_plot_cosineMap(csm, ParticipantID, clim, dataType, opt)
% function prototypes_plot_cosineMap(csm, ParticipantID, clim, dataType, opt)

if exist('prototypes_plot_image.m', 'file') ~= 0
    prototypes_plot_image(csm)
end

if ~exist('ParticipantID', 'var')||isempty(ParticipantID); ParticipantID='group'; end
if ~exist('dataType', 'var')||isempty(dataType); dataType='W_SimixSubject'; end
if ~exist('clim', 'var')||isempty(clim); clim=[-1 1]; end

if ~isfield(csm, dataType); dataType='W_csm_mean';end

if ~strcmp(ParticipantID, 'group') && ~strcmp(csm.ParticipantID, 'group')
    if ~ismember(ParticipantID, unique(csm.ParticipantID))
        warning('This subject is not part of this group');
        return;
    end
    CSI_map = csm.(dataType)(:, :, csm.ParticipantID==ParticipantID);
else
    CSI_map = csm.(dataType);
end

zoffset = 20;
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


rectPos = csm.Properties.UserData.ShapeRect;

if strcmp(prototypes_get_metadata(csm, 'StimulusType'), 'Circle')
    rectangle('Position', rectPos, 'Curvature', 1);
else
    rectangle('Position', rectPos);
end
ax              = gca;
ax.YDir         = prototypes_get_metadata(csm, 'YDir');

% hold on; prototypes_plot_errorVectors(GroupData);

cb              = colorbar;
cb.Limits       = [clim(1) clim(2)]-zoffset;
cb.Ticks        = linspace(clim(1)-zoffset, clim(2)-zoffset,3);
cb.TickLabels   = linspace(clim(1), clim(2),3);

if strcmp(ParticipantID, 'group')
    ax.Units        = 'normalized';
    ax.Position     = [0.05 0.05 0.82 0.9];
end