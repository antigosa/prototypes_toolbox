function fig=protoHaptic_figures(figname, csimaps, figpar)

if nargin<3;figpar=[];end

switch figname
    case {'csimaps'}
        fig=plot_maps(csimaps, '1x2', figpar);
        
end


function fig=plot_maps(csimaps, nbym, figpar)

mapnames = fieldnames(csimaps);
ax = [];


if ~isfield(figpar, 'clim'); figpar.clim=[-0.5 0.5];end
clim = figpar.clim;

switch nbym
    case '1x2'
        figure;fig=gcf;fig.Position=[113.8000 273 1300 650];
        
        for i = 1:length(mapnames)
            ax{i}=subplot(1, 2, i); imagesc(csimaps.(mapnames{i}).csimap); axis image; colormap('jet');axis off;
            title(mapnames{i});
            
            %             set(gca,'Clim', [-0.5 0.5]);
            set(gca,'Clim', clim);
            
            ax{i}.Children.AlphaData = ones(size(ax{i}.Children.CData));
            ax{i}.Children.AlphaData(ax{i}.Children.CData==0)=0;
            
            if isfield(csimaps.(mapnames{i}), 'boundaries')
                
                boundaries = csimaps.(mapnames{i}).boundaries;
                
                hold on;
                for k = 1:length(boundaries)
                    boundary = boundaries{k};
                    plot(boundary(:,2), boundary(:,1), 'k', 'LineWidth', 2); 
                end
                hold off;                
            end
            
            
        end
        
        % -------------------------------------------------------------------------
        % Adjust the figure
        % -------------------------------------------------------------------------
        %         Position1           = ax{1}.Position;
        %         % ax2.Units           = 'pixels';
        %         Position2           = ax{2}.Position;
        %         ax{2}.Position        = Position2;
        c=colorbar;
        

        
        %
        fig.Units           = 'Centimeters';
        fig.Position        = [3 7 16 6.5];
        ax{1}.Position      = [0 0 0.55 0.9];
        ax{2}.Position      = [0.4 0 0.55 0.9];


        c.Position([2 4])   = [0.25 0.5];
        c.Position(3)       = 0.02;
        c.Label.String      = 'CSI';
        % c.Label.Position    = [4 1 00];
        c.Label.Units       ='normalized';
        c.Label.Position    = [3.5 0.55 0];
        c.Label.Rotation    = 0;
        c.Label.FontSize    = 14;
        c.FontSize          = 11;        
        c.Ticks             = [clim(1) 0 clim(2)];        
        
        rectangle(ax{1}, 'Position', [ax{1}.XLim(1) ax{1}.YLim(1) ax{1}.XLim(2) ax{1}.YLim(2)], 'Curvature', 0);
        rectangle(ax{2}, 'Position', [ax{2}.XLim(1) ax{2}.YLim(1) ax{2}.XLim(2) ax{2}.YLim(2)], 'Curvature', 0);               
end