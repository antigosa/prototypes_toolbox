function [w, h, rect, corners]=find_corners_manually(points, fig)

if nargin==1;fig=gcf;end

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
w = corners.bl_xy(1) - corners.br_xy(1);
h = corners.tr_xy(2) - corners.br_xy(2);

% draw an ideal rect around the board
rect = [corners.br_xy w h];
rectangle('Position', rect, 'EdgeColor', 'r', 'LineWidth', 2);
