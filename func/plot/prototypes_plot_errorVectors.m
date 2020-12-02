function ax=prototypes_plot_errorVectors(ProtoTable, ParticipantID)
% function prototypes_plot_errorVectors(ProtoTable, ParticipantID)
% dataType: 'ActDots' | 'RespDots'

if exist('prototypes_plot_image.m', 'file') ~= 0
     ax_img = prototypes_plot_image(ProtoTable);  
end
ax=axes;

if ~exist('ParticipantID', 'var')||isempty(ParticipantID); ParticipantID='group'; end

if ~strcmp(ParticipantID, 'group') && ~strcmp(ProtoTable.ParticipantID, 'group')
    if ~ismember(ParticipantID, unique(ProtoTable.ParticipantID))
        warning('This subject is not part of this group');
        return;
    end
    ProtoTable = ProtoTable(ProtoTable.ParticipantID==ParticipantID, :);
end

ActDots         = ProtoTable.ActualDots_xy;
errorVector     = ProtoTable.errorXY;
q               = quiver(ActDots(:,1), ActDots(:,2), errorVector(:,1), errorVector(:,2),0); % Use S=0 to plot the arrows without the automatic scaling.
q.Color         = 'k';
q.LineWidth     = 1;

% l               = legend({'Actual', 'Response'});
% l.Position      = [0.8 0.9 0.19 0.1];
% l.Box           = 'Off';
% prototypes_plot_setup(ProtoTable, l);

axis off;axis equal;
axis(ProtoTable.Properties.UserData.ShapeContainerRect([1 3 2 4]));
rectPos     = [ProtoTable.Properties.UserData.ShapeRect([1 2]) ProtoTable.Properties.UserData.ShapeRect([3 4])-ProtoTable.Properties.UserData.ShapeRect([1 2])];
switch prototypes_get_metadata(ProtoTable, 'StimulusType')
    case 'Circle'
        rectangle('Position', rectPos, 'Curvature', 1);
        
    case {'Square', 'Rectangle'}
        rectangle('Position', rectPos);
end
% ax              = gca;
ax.YDir         = prototypes_get_metadata(ProtoTable, 'YDir');
if strcmp(ParticipantID, 'group')
    ax.Units        = 'normalized';
    ax.Position     = [0.05 0.05 0.82 0.9];
    if ~isempty(ax_img)
        ax_img.Units = ax.Units;
        ax_img.Position = ax.Position;
    end
end

% fig         = gcf;
% fig.Units   = 'centimeters';


if exist('prototypes_plot_shape.m', 'file') ~= 0
    prototypes_plot_shape(ProtoTable);
end

