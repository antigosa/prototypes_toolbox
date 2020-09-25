function prototypes_plot_dots(ProtoTable, ParticipantID, dataType, whichSpace)
% function prototypes_plot_dots(ProtoTable, ParticipantID, dataType, whichSpace)
% dataType: 'ActDots' | 'RespDots'

if exist('prototypes_plot_image.m', 'file') ~= 0
    prototypes_plot_image(ProtoTable)
end

if ~exist('whichSpace', 'var')||isempty(whichSpace); whichSpace='cart'; end
if ~exist('ParticipantID', 'var')||isempty(ParticipantID); ParticipantID='group'; end
if ~exist('dataType', 'var'); dataType='both'; end

if ~strcmp(ParticipantID, 'group') && ~strcmp(ProtoTable.ParticipantID, 'group')
    if ~ismember(ParticipantID, unique(ProtoTable.ParticipantID))
        warning('This subject is not part of this group');
        return;
    end
    ProtoTable = ProtoTable(ProtoTable.ParticipantID==ParticipantID, :);
end

switch whichSpace
    case 'cart'
        prototypes_plot_Resp_cartesian(ProtoTable, dataType);
        % set(gca, 'YDir', 'reverse')
        l           = legend({'Actual', 'Response'});
        l.Position  = [0.8 0.9 0.19 0.1];
        l.Box       = 'Off';
        % prototypes_plot_setup(ProtoTable, l);
        
        axis off; axis equal;
        axis(ProtoTable.Properties.UserData.ShapeContainerRect([1 3 2 4]));
        
        rectPos     = [ProtoTable.Properties.UserData.ShapeRect([1 2]) ProtoTable.Properties.UserData.ShapeRect([3 4])-ProtoTable.Properties.UserData.ShapeRect([1 2])];        
        if strcmp(prototypes_get_metadata(ProtoTable, 'StimulusType'), 'Circle')
            rectangle('Position', rectPos, 'Curvature', 1);
        else
            rectangle('Position', rectPos);
        end
        ax          = gca;
        ax.YDir     = prototypes_get_metadata(ProtoTable, 'YDir');
        
        if strcmp(ParticipantID, 'group')
            ax.Units    = 'normalized';
            ax.Position = [0.05 0.05 0.82 0.9];
        end
        
        % fig         = gcf;
        % fig.Units   = 'centimeters';
        
        
    case 'polar'
        prototypes_plot_Resp_polar(ProtoTable, dataType);
        
end

% prototypes_plot_addTitle(ProtoTable);



function prototypes_plot_Resp_cartesian(ProtoTable, dataType)
ActDots         = ProtoTable.ActualDots_xy;
RespDots        = ProtoTable.ResponseDots_xy;

ax = gca;
ax.Units = 'Pixel';
DotSize = ax.Position(3)/20;
switch dataType
    case 'ActDots'
        hold on; sh1=scatter(ActDots(:,1), ActDots(:,2), 'filled');
        sh1.MarkerFaceColor='k';
        %sh1.SizeData=20;
    case 'RespDots'
        hold on; sh2=scatter(RespDots(:,1), RespDots(:,2), 'filled');
        sh2.MarkerFaceColor='r';
        %sh2.SizeData=20;
    case 'both'
        sh1=scatter(ActDots(:,1), ActDots(:,2), 'filled');
        hold on; sh2=scatter(RespDots(:,1), RespDots(:,2), 'filled');
        sh1.MarkerFaceColor='k';
        sh1.SizeData=DotSize;
        sh2.MarkerFaceColor='r';
        sh2.SizeData=DotSize;
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
