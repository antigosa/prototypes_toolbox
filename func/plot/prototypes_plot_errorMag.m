function prototypes_plot_errorMag(Trials, clim, interpol, subj_id)
% function prototypes_plot_errorMag(Trials, subj_id, interpol)

if ~exist('subj_id', 'var') || isempty(subj_id); subj_id='group'; end
if ~exist('interpol', 'var'); interpol=0; end

if ~strcmp(subj_id, 'group') && ~strcmp(Trials.subj_id, 'group')
    if ~ismember(subj_id, unique(Trials.subj_id))
        warning('This subject is not part of this group');
        return;
    end
    Trials = Trials(Trials.subj_id==subj_id, :);
end

prototypes_plot_errorMag_cartesian(Trials, clim, interpol);
prototypes_plot_addTitle(Trials, 'ErrorMag');
c=colorbar;
c.Position = [0.8 0.30 0.04 1-2*0.30];
c.FontSize = 14;c.Label.String='Error Magnitude';
c.Ticks = linspace(clim(1), clim(2),3);


function prototypes_plot_errorMag_cartesian(Trials, clim, interpol)
ActDots         = Trials.ActualDots_xy;
ErrorMag        = Trials.errorMag;

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
        xy_grid = Trials.Properties.UserData.Rectangle;
        
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
prototypes_plot_setup(Trials);
prototypes_plot_shape(Trials);
prototypes_plot_image(Trials)
colormap('jet');c=colorbar;c.FontSize=12;c.Label.String='Error Magnitude';c.Label.FontSize=12;
% set(gca, 'CLim', [min(ErrorMag) max(ErrorMag)]);
set(gca, 'CLim', [clim(1), clim(2)]);


