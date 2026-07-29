function [w, h, rect, corners]=find_corners_manually(points, fig, offset)

if nargin<2;fig=gcf;end
if nargin<3;offset=11;end

% Set up a callback function for mouse clicks
set(fig, 'WindowButtonDownFcn', @mouseClickCallback);

% Initialize UserData to store results
set(fig, 'UserData', struct('x', [], 'y', [], 'pixelValue', []));

corners = [];

npoints = length(points);

for j = 1:npoints
    
    fprintf('Select Point %s\n', points{j});
    
    % Wait for a mouse click or key press
    waitforbuttonpress;
    
    userData = get(fig, 'UserData');
        
    corners.(points{j}) = [userData.x userData.y];        
end

% Estimate (ideal) width and height of the board

corners.br_xy = corners.br_xy + [offset offset];
corners.bl_xy = corners.bl_xy + [-offset offset];
corners.tr_xy = corners.tr_xy + [offset -offset];
corners.tl_xy = corners.tl_xy + [-offset -offset];

w = corners.br_xy(1) - corners.bl_xy(1);
h = corners.br_xy(2) - corners.tr_xy(2);

% draw an ideal rect around the board
rect = [corners.tl_xy w h];
rectangle('Position', rect, 'EdgeColor', 'r', 'LineWidth', 2);
