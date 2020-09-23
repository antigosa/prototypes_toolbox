function prototypes_plot_cosineMap(Trials, clim, dataType, opt)
% function prototypes_plot_cosineMap(Trials, clim, dataType, opt)
%
% cosine map can be a matrix or a struct containing .W_SimixSubject
%
% dataType: 'W_SimixSubject', 'W_SimixSubject_avg', 'W_SimixSubject_T', 
%           'W_SimixSubject_STD', 'W_SimixSubject_SE', 'W_SimixSubject_Tcorr'
%           'W_SimixSubject_Tuncorr'

if nargin<2;clim = [];end
if nargin<3 || isempty(dataType);dataType='W_SimixSubject';end
if nargin<4; opt.plotErrors=0;opt.plotCenterOfMass=0;end
if ~isfield(opt, 'plotErrors'); opt.plotErrors=0;end
if ~isfield(opt, 'plotCenterOfMass'); opt.plotCenterOfMass=0;end


if isempty(clim)
    if contains(dataType, '_avg')
        clim = [-0.5 0.5];
        
    elseif regexp(dataType, '_T')
        clim = [-15 15];
       
    elseif regexp(dataType, '_STD')
        clim = [0 0.4];
        
    elseif regexp(dataType, '_SE')
        clim = [0 0.015];
        
    else
        clim = [-0.5 0.5];
        
    end
end

cname = strrep(strrep(dataType, 'W_SimixSubject_', ''), '_', ' ');

subjlist = unique(Trials.subj_id);
nsubj = length(subjlist);
if nsubj>1
    fig = gcf; fig.Position = [509 437 731 561];
    for s=1:nsubj
        subNum = subjlist(s);
        if nsubj>6;nrow = 3;else; nrow = 1;end
        if nsubj==20;nrow = 4;end
        if nsubj==19;nrow = 4;end
        if nsubj==18;nrow = 4;end
        if nsubj==17;nrow = 4;end
        ncol = ceil(nsubj/nrow);
        
        subplot(nrow, ncol, s);
        subjTrials = prototypes_select_subjects(Trials, subNum);
        prototypes_plot_cosineMap_aSubj(subjTrials, clim, dataType);
        ax=gca;ax.Position([3 4])=[0.15 0.28];
        if ismember(nsubj, [17 18 19 20])
            ax.Position(2)=ax.Position(2) - 0.05*ax.Position(2);
            fig.Position = [509 361 880 737];
        end
        
        colorbar off; %ax.Position([1 2]) = [0.1 0.7];
        title(sprintf('S%02d', subjlist(s)));
        
        if isfield(Trials.Properties.UserData, 'YDir')
            set(gca, 'YDir', Trials.Properties.UserData.YDir);
        else
            set(gca, 'YDir', 'reverse')
        end        
        if opt.plotErrors
            opt.doNotFormat=1;
            hold on; prototypes_plot_errorVectors(subjTrials, 'allSubj', 'together', opt);
%             rectangle('Position', [35 35 255 255]) % this can be removed
        end
        
        if opt.plotCenterOfMass
            if isfield(subjTrials.Properties.UserData, 'kmeans')
                
                A = subjTrials.Properties.UserData.cosine_map.W_SimixSubject;
                maximum = max(max(A));[y,x]=find(A==maximum);
                hold on; scatter(x, y, 'MarkerFaceColor', 'k', 'MarkerEdgeColor', 'k', 'SizeData', 60, 'Marker', 'diamond');
                
                clusterInfo = subjTrials.Properties.UserData.kmeans.clusterInfo;
                clusterInfo(clusterInfo.subj_id~=subNum, :)=[];
                hold on; scatter(clusterInfo.Centroid(:,1), clusterInfo.Centroid(:,2), 'MarkerFaceColor', [0.5 1 0], 'MarkerEdgeColor', 'k', 'SizeData', 20);
                

                
            end
            
        end
        
    end
    c = colorbar; c.Position = [0.92 0.3750+0.11/2 0.025 0.25];
    c.Ticks = linspace(clim(1), clim(2),3);
    c.FontSize=12;
else
    prototypes_plot_cosineMap_aSubj(Trials, clim, dataType);
    prototypes_plot_setup(Trials);
    c=colorbar;
    c.Position = [0.8 0.30 0.04 1-2*0.30];
    c.FontSize = 14;c.Label.String=cname;
    c.Ticks = linspace(clim(1), clim(2),3);

end



function prototypes_plot_cosineMap_aSubj(Trials, clim, dataType)

if isstruct(Trials)
    cosine_map  = Trials.(dataType);
end

if istable(Trials)
    if ismember(dataType, Trials.Properties.VariableNames)
        cosine_map = cell2mat(Trials.(dataType));
    else
        if ~isfield(Trials.Properties.UserData, 'cosine_map'); return; end
        cosine_map  = Trials.Properties.UserData.cosine_map.(dataType);
    end
end

if isnumeric(Trials)
    cosine_map = Trials;
end


imagesc(cosine_map); axis image;
prototypes_plot_image(Trials);
colormap('jet');
c=colorbar;set(gca,'CLim', clim);

axis off;

% colorbar
c.FontSize = 12;
c.Label.String = sprintf('SI');
c.Ticks = linspace(clim(1), clim(2),3);
set(gcf, 'Name', 'Cosine Similarity Index map');
