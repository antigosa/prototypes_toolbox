function prototypes_plot_errorVectors(Trials, ParticipantID)
% function prototypes_plot_errorVectors(Trials, ParticipantID)
% dataType: 'ActDots' | 'RespDots'

% if exist('prototypes_plot_image.m', 'file') ~= 0
%     prototypes_plot_image(Trials)
% end

if ~exist('ParticipantID', 'var')||isempty(ParticipantID); ParticipantID='group'; end

if ~strcmp(ParticipantID, 'group') && ~strcmp(Trials.ParticipantID, 'group')
    if ~ismember(ParticipantID, unique(Trials.ParticipantID))
        warning('This subject is not part of this group');
        return;
    end
    Trials = Trials(Trials.ParticipantID==ParticipantID, :);
end

ActDots         = Trials.ActualDots_xy;
errorVector     = Trials.errorXY;
q               = quiver(ActDots(:,1), ActDots(:,2), errorVector(:,1), errorVector(:,2),0); % Use S=0 to plot the arrows without the automatic scaling.
q.Color         = 'k';
q.LineWidth     = 1;

% l               = legend({'Actual', 'Response'});
% l.Position      = [0.8 0.9 0.19 0.1];
% l.Box           = 'Off';
% prototypes_plot_setup(Trials, l);

axis off;axis equal;
axis(Trials.Properties.UserData.ShapeContainerRect([1 3 2 4]));
rectPos     = [Trials.Properties.UserData.ShapeRect([1 2]) Trials.Properties.UserData.ShapeRect([3 4])-Trials.Properties.UserData.ShapeRect([1 2])];
if strcmp(prototypes_get_metadata(Trials, 'StimulusType'), 'Circle')
    rectangle('Position', rectPos, 'Curvature', 1);
else
    rectangle('Position', rectPos);
end
ax              = gca;
ax.YDir         = prototypes_get_metadata(Trials, 'YDir');
if strcmp(ParticipantID, 'group')
    ax.Units        = 'normalized';
    ax.Position     = [0.05 0.05 0.82 0.9];
end

% fig         = gcf;
% fig.Units   = 'centimeters';


if exist('prototypes_plot_shape.m', 'file') ~= 0
    prototypes_plot_shape(Trials);
end

