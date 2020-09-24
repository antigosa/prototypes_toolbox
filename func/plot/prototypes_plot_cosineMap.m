function prototypes_plot_cosineMap(CosineMap, ParticipantID, clim, dataType, opt)

if exist('prototypes_plot_image.m', 'file') ~= 0
    prototypes_plot_image(CosineMap)
end

if ~exist('ParticipantID', 'var')||isempty(ParticipantID); ParticipantID='group'; end
if ~exist('dataType', 'var')||isempty(dataType); dataType='W_SimixSubject'; end
if ~exist('clim', 'var')||isempty(clim); clim=[-1 1]; end

if ~isfield(CosineMap, dataType); dataType='W_CosineMap_mean';end

if ~strcmp(ParticipantID, 'group') && ~strcmp(CosineMap.ParticipantID, 'group')
    if ~ismember(ParticipantID, unique(CosineMap.ParticipantID))
        warning('This subject is not part of this group');
        return;
    end
    CSI_map = CosineMap.(dataType)(:, :, CosineMap.ParticipantID==ParticipantID);
else
    CSI_map = CosineMap.(dataType);
end

zoffset = 20;
ydim    = size(CSI_map, 1);
xdim    = size(CSI_map, 2);
x       = linspace(CosineMap.Properties.UserData.ShapeContainerRect(1),CosineMap.Properties.UserData.ShapeContainerRect(3), xdim);
y       = linspace(CosineMap.Properties.UserData.ShapeContainerRect(2),CosineMap.Properties.UserData.ShapeContainerRect(4), ydim);
[X,Y]   = meshgrid(x,y);
mesh(X, Y, CSI_map-zoffset);view(0, 90);%set(gca, 'YDir', 'reverse')
caxis(clim-zoffset);
% figure; imagesc(GroupCosineMaps.W_CosineMap_mean);
axis off;axis equal;
axis(CosineMap.Properties.UserData.ShapeContainerRect([1 3 2 4]));


rectPos = CosineMap.Properties.UserData.ShapeRect;

if strcmp(prototypes_get_metadata(CosineMap, 'StimulusType'), 'Circle')
    rectangle('Position', rectPos, 'Curvature', 1);
else
    rectangle('Position', rectPos);
end
ax              = gca;
ax.YDir         = prototypes_get_metadata(CosineMap, 'YDir');

% hold on; prototypes_plot_errorVectors(GroupData);

cb              = colorbar;
cb.Limits       = [clim(1) clim(2)]-zoffset;
cb.Ticks        = linspace(clim(1)-zoffset, clim(2)-zoffset,3);
cb.TickLabels   = linspace(clim(1), clim(2),3);

if strcmp(ParticipantID, 'group')
    ax.Units        = 'normalized';
    ax.Position     = [0.05 0.05 0.82 0.9];
end