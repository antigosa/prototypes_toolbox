function pin = locate_pin_manually(fig)

if nargin==1;fig=gcf;end

fprintf('Select pin\n');

% Set up a callback function for mouse clicks
set(fig, 'WindowButtonDownFcn', @mouseClickCallback);

% Initialize UserData to store results
set(fig, 'UserData', struct('x', [], 'y', [], 'pixelValue', []));

% Wait for a mouse click or key press
waitforbuttonpress;

userData = get(gcf, 'UserData');
pin = [userData.x userData.y];