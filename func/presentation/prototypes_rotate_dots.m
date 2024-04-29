function xy=prototypes_rotate_dots(xy, theta, axisRect)
% function xy=prototypes_rotate_dots(xy, theta, axisRect)
%
% xy can be a vector (ndotsX2) or a prototable. If it is a prototable,
% theta and the axis are already in the table.
%
% theta is the rotation angle
% axisRect is the axis used to compute the centre that is use as a rotation
% point. If xy is not a table, axisRect can be a 2-elements vector
% (indicating the centre coordinate) or a 4-elements vector (indicating the
% axis).

if istable(xy)
    Trials      = xy;
    xy          = Trials.RespDots_xy;
    theta       = Trials.RotationAngle;
    axisRect    = Trials.Properties.UserData.Axis;
    axCenter(1) = mean([axisRect(1) axisRect(2)]);
    axCenter(2) = mean([axisRect(3) axisRect(4)]);
    if any(strcmp(Trials.Properties.VariableNames, 'RespDots_xy_noRot'))
       warning('This dataset is already rotated! Exiting...'); 
        xy = Trials;
       return;
    end
else
    if length(axisRect)==2
        axCenter = axisRect;
    else
        axCenter(1) = mean([axisRect(1) axisRect(3)]);
        axCenter(2) = mean([axisRect(2) axisRect(4)]);        
    end
end

for p = 1:size(xy,1)
    xy(p,:)        = prototypes_rotate_adot(xy(p,:), -theta(p), axCenter);
    %     hold on; scatter(RespDots(p,1), RespDots(p,2), 'fill', 'k');
end

if exist('Trials', 'var')
    Trials.RespDots_xy_noRot = Trials.RespDots_xy;
    Trials.RespDots_xy = xy;
    xy = Trials;
end

function xy=prototypes_rotate_adot(xy, theta, axCenter)

% create a matrix of these points, which will be useful in future calculations
v = xy';

% choose a point which will be the center of rotation
x_center = axCenter(1); % 400; % x(3);
y_center = axCenter(2); % 400; %y(3);

% create a matrix which will be used later in calculations
center = repmat([x_center; y_center], 1, size(xy,1));

% define a 60 degree counter-clockwise rotation matrix
theta = deg2rad(theta); % pi/3;       % pi/3 radians = 60 degrees
R = [cos(theta) -sin(theta); sin(theta) cos(theta)];

% do the rotation...
s = v - center;     % shift points in the plane so that the center of rotation is at the origin
so = R*s;           % apply the rotation about the origin
vo = so + center;   % shift again so the origin goes back to the desired center of rotation

% this can be done in one line as:
% vo = R*(v - center) + center
% pick out the vectors of rotated x- and y-data
% x_rotated = vo(1,:);
% y_rotated = vo(2,:);
% make a plot
% plot(v(1,:), v(2,:), 'k-', x_rotated, y_rotated, 'r-', x_center, y_center, 'bo');
% axis equal
xy = vo;

function y = deg2rad(x)
y = x * pi/180;