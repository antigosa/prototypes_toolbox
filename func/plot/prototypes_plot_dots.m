function [ax, ax_img]=prototypes_plot_dots(ProtoData, dataType, opt)
% function [ax, ax_img]=prototypes_plot_dots(ProtoData, subj_id, dataType, whichSpace)
% dataType: 'ActDots' | 'RespDots'

ProtoTable = ProtoData.Trials;

if exist('prototypes_plot_image.m', 'file') ~= 0
    ax_img = prototypes_plot_image(ProtoTable);
else
    ax_img=[];
end
ax=axes;

if nargin<2;dataType='both';end
if nargin<3;opt = [];end


if ~isfield(opt, 'whichSpace'); opt.whichSpace='cart';end
if ~isfield(opt, 'subj_id'); opt.subj_id=unique(ProtoTable.subj_id);end
if ~isfield(opt, 'trials'); opt.trials=[];end
if ~isfield(opt, 'trials_highlight'); opt.trials_highlight=[];end
if ~isfield(opt, 'dots'); opt.dots=[];end
if ~isfield(opt, 'dots_highlight'); opt.dots_highlight=[];end
if ~isfield(opt, 'showErrors'); opt.showErrors=1;end
if ~isfield(opt, 'showRect'); opt.showRect=1;end

subj_id = opt.subj_id;

% n = length(unique(ProtoTable.subj_id));
n = length(subj_id);
if n==1
    if strcmp(unique(ProtoTable.subj_id), 'group')
        isgroupData = 1;
    else
        % it's one participant
        isgroupData = 0;
    end
end


if ~isgroupData
    if ~ismember(subj_id, unique(ProtoTable.subj_id))
        warning('This subject is not part of this group');
        return;
    end
    
    % select a participant
    ProtoTable = ProtoTable(ismember(ProtoTable.subj_id, subj_id), :);
end

if ~isempty(opt.trials)
    
    tmp = ProtoTable(ismember(ProtoTable.trials_id, opt.trials),:);
    
    fprintf('Selecting trials:\n')
    for i = 1:length(tmp.trials_id)
        fprintf('\t%d - dot: %d\n', tmp.trials_id(i), tmp.dot_id(i) );
    end
    fprintf('\n')
    ProtoTable = ProtoTable(ismember(ProtoTable.trials_id, opt.trials),:);
end

if ~isempty(opt.dots)
    tmp = ProtoTable(ismember(ProtoTable.dot_id, opt.dots),:);
    
    fprintf('Selecting dots:\n')
    for i = 1:length(tmp.dot_id)
        fprintf('\t%d - trial: %d\n', tmp.dot_id(i), tmp.trials_id(i) );
    end
    fprintf('\n')
    ProtoTable = ProtoTable(ismember(ProtoTable.dot_id, opt.dots),:);
end


switch opt.whichSpace
    case 'cart'
        prototypes_plot_Resp_cartesian(ProtoTable, dataType, opt);
        
        if ~strcmp(dataType, 'errors')
            l           = legend({'Actual', 'Response'});
            l.Position  = [0.8 0.9 0.19 0.1];
            l.Box       = 'Off';
        end
        % prototypes_plot_setup(ProtoTable, l);
        
        axis off; axis equal;
%         ax_csimap = findobj(gcf, 'Type', 'axes', 'Tag', 'csimap');
%         
%         if ~isempty(ax_csimap)
%             ax.Units='pixels';
%             ax.Position = [66 66 726 726];
%             ax.XLim = [0 660];
%             ax.YLim = [0 660];
%         end
        
        ax.YDir     = prototypes_get_metadata(ProtoTable, 'YDir');
        axis(ProtoTable.Properties.UserData.ShapeRect([1 3 2 4]))
%         axis(ProtoTable.Properties.UserData.ShapeContainerRect([1 3 2 4]));
        
        rectPos     = [ProtoTable.Properties.UserData.ShapeRect([1 2]) ProtoTable.Properties.UserData.ShapeRect([3 4])-ProtoTable.Properties.UserData.ShapeRect([1 2])];
        
        switch cell2mat(prototypes_get_metadata(ProtoTable, 'StimulusType'))
            case {'Circle', 'circle'}
                rectangle('Position', rectPos, 'Curvature', 1);
                
            case {'Square', 'Rectangle', 'square', 'rectangle'}
                rectangle('Position', rectPos);
        end
%         ax          = gca;
        
        
        if strcmp(subj_id, 'group')
            ax.Units    = 'normalized';
            ax.Position = [0.05 0.05 0.82 0.9];
            if ~isempty(ax_img)
                ax_img.Units = ax.Units;
                ax_img.Position = ax.Position;
            end
        end
        
        % fig         = gcf;
        % fig.Units   = 'centimeters';
        
        
    case 'polar'
        prototypes_plot_Resp_polar(ProtoTable, dataType);
        
end




% prototypes_plot_addTitle(ProtoTable);



function prototypes_plot_Resp_cartesian(ProtoTable, dataType, opt)
ActDots         = ProtoTable.ActualDots_xy;
RespDots        = ProtoTable.ResponseDots_xy;

ax              = gca;
ax.Units        = 'Pixel';
DotSize         = ax.Position(3)/20;
switch dataType
    case {'ActDots', 'ActualDots'}
        hold on; sh1=scatter(ActDots(:,1), ActDots(:,2), 'filled');
        sh1.MarkerFaceColor='k';
        %sh1.SizeData=20;
    case {'RespDots', 'ResponseDots'}
        hold on; sh2=scatter(RespDots(:,1), RespDots(:,2), 'filled');
        sh2.MarkerFaceColor='r';
        %sh2.SizeData=20;
    case {'both', 'errors'}
        sh1=scatter(ActDots(:,1), ActDots(:,2), 'filled');
        hold on; sh2=scatter(RespDots(:,1), RespDots(:,2), 'filled');
        sh1.MarkerFaceColor='k';
        sh1.SizeData=DotSize;
        sh2.MarkerFaceColor='r';
        sh2.SizeData=DotSize;
        
        if strcmp(dataType, 'errors')
            sh1.Visible='off';
            sh2.Visible='off';
        end
end
if ~isempty(opt.trials_highlight) || ~isempty(opt.dots_highlight)
    
    if ~isempty(opt.trials_highlight)
        tmp = ProtoTable(ismember(ProtoTable.trials_id, opt.trials_highlight),:);
        fprintf('Selecting trials:\n')
        for i = 1:length(tmp.trials_id)
            fprintf('\t%d - dot: %d\n', tmp.trials_id(i), tmp.dot_id(i) );
        end
        fprintf('\n')        
        
        idx = find(ismember(ProtoTable.trials_id, opt.trials_highlight));
    elseif ~isempty(opt.dots_highlight)
        
        tmp = ProtoTable(ismember(ProtoTable.dot_id, opt.dots_highlight),:);

        fprintf('Selecting dots:\n')
        for i = 1:length(tmp.dot_id)
            fprintf('\t%d - trial: %d\n', tmp.dot_id(i), tmp.trials_id(i) );
        end
        fprintf('\n')        
        idx = find(ismember(ProtoTable.dot_id, opt.dots_highlight));
    end
    
    hold on; sh2=scatter(RespDots(idx,1), RespDots(idx,2), 'filled');
    sh2.MarkerFaceColor='g';
    sh2.SizeData=DotSize;
end

if opt.showErrors
    
    errorVector     = ProtoTable.errorXY;
    idx             = 1:size(errorVector, 1);
    if ~isempty(opt.trials_highlight) || ~isempty(opt.dots_highlight)
        if ~isempty(opt.trials_highlight)
            idx = find(ismember(ProtoTable.trials_id, opt.trials_highlight));
        elseif ~isempty(opt.dots_highlight)
            idx = find(ismember(ProtoTable.dot_id, opt.dots_highlight));
        end
    end
    hold on;
    
    q               = quiver(ActDots(idx,1), ActDots(idx,2), errorVector(idx,1), errorVector(idx,2),0); % Use S=0 to plot the arrows without the automatic scaling.
    q.Color         = 'k';
    q.LineWidth     = 1;
end

ax.Units = 'Normalized';

if exist('prototypes_plot_shape.m', 'file') ~= 0
    prototypes_plot_shape(ProtoTable);
end




function prototypes_plot_Resp_polar(ProtoTable, dataType)
ActDots         = ProtoTable.ActualDots_polar;
RespDots        = ProtoTable.RespDots_polar;


switch dataType
    case 'ActDots'
        polarscatter(ActDots(:,1), ActDots(:,2), 'filled');
        
    case 'RespDots'
        polarscatter(RespDots(:,1), RespDots(:,2), 'filled');
        
    case 'both'
        polarscatter(ActDots(:,1), ActDots(:,2), 'filled');
        hold on; polarscatter(RespDots(:,1), RespDots(:,2), 'filled');
end



ax=gca;
ax.RLim=[0 1.05];

fig=gcf;
fig.Position = [708 344 500 500];
% l=legend({'Actual', 'Response'});
% l.FontSize=12;
% l.Box = 'Off';
