function prototypes_plot_errorMag(ProtoTable, clim, interpol, ParticipantID)
% function prototypes_plot_errorMag(ProtoTable, clim, interpol, ParticipantID)

if ~exist('ParticipantID', 'var') || isempty(ParticipantID); ParticipantID='group'; end
if ~exist('interpol', 'var'); interpol=0; end

if ~strcmp(ParticipantID, 'group') && ~strcmp(ProtoTable.ParticipantID, 'group')
    if ~ismember(ParticipantID, unique(ProtoTable.ParticipantID))
        warning('This subject is not part of this group');
        return;
    end
    ProtoTable = ProtoTable(ProtoTable.ParticipantID==ParticipantID, :);
end

prototypes_plot_errorMag_cartesian(ProtoTable, clim, interpol);
prototypes_plot_addTitle(ProtoTable, 'ErrorMag');
c=colorbar;
c.Position = [0.8 0.30 0.04 1-2*0.30];
c.FontSize = 14;c.Label.String='Error Magnitude';
c.Ticks = linspace(clim(1), clim(2),3);


function prototypes_plot_errorMag_cartesian(ProtoTable, clim, interpol)
ActDots         = ProtoTable.ActualDots_xy;
ErrorMag        = ProtoTable.errorMag;

nDots = size(ActDots,1);
cmap = jet(nDots);

ErrorMag            = ErrorMag/max(ErrorMag);
[~, ErrorMag_pos]   = sort(ErrorMag);
r = 1:length(ErrorMag);
r(ErrorMag_pos) = r;


switch interpol
    case 0
        for d = 1:nDots
            hold on; s_h = scatter(ActDots(d,1), ActDots(d,2), 'filled');
            s_h.MarkerFaceColor = cmap(r(d),:);
        end
        
    case 1
        xy_grid = ProtoTable.Properties.UserData.Rectangle;
        
        [xq,yq]     = meshgrid(xy_grid(1):1:xy_grid(3), xy_grid(2):1:xy_grid(4)); % step was 0.2
        vq          = griddata(ActDots(:,1),ActDots(:,2),ErrorMag,xq,yq);
        vq(isnan(vq))=0;
        vq          = imgaussfilt(vq, 20, 'Padding', 'replicate');
        vq          = vq/max(vq(:));
        imagesc(vq);
        colormap(jet);
        view(0,90);
        
end

axis image;

set(gca, 'YDir', 'reverse')
prototypes_plot_setup(ProtoTable);
prototypes_plot_shape(ProtoTable);
prototypes_plot_image(ProtoTable)
colormap('jet');c=colorbar;c.FontSize=12;c.Label.String='Error Magnitude';c.Label.FontSize=12;
% set(gca, 'CLim', [min(ErrorMag) max(ErrorMag)]);
set(gca, 'CLim', [clim(1), clim(2)]);


