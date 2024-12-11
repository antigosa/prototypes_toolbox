toolbox_dir     = 'D:\Programs\toolbox';

addpath(genpath(fullfile(toolbox_dir, 'ptb_utils')));
addpath(genpath(fullfile(toolbox_dir, 'prototypes_toolbox')));

%% start ptb 
% you can skip initial test if you like, this is useful if you are using
% two monitors or some bad PC
skip_sync_tests = 1;

% open the ptb window. Note that it will use the monitor with the highest
% number identification (e.g. 2). If you want to change this, go inside
% ptb_open_window
[win, rect, screen_center] = ptb_open_window(skip_sync_tests);


%% get center information

% this is helpful if you are showing an image (not a shape like a circle)
xCenter = screen_center(1);
yCenter = screen_center(2);

%%
rectangle_color         = [36 36 36];
circle_size             = 650;          % in pixels


% Rectcoord           = [1107 38 1607 538];

x0                      = xCenter-circle_size/2;
y0                      = yCenter-circle_size/2;
Rectcoord               = [x0 y0 x0+circle_size y0+circle_size];

prototypes_prepare_rectangle(win, [0 0 255], Rectcoord);

prototypes_prepare_circle(win, rectangle_color, Rectcoord)

% NOT SURE WHAT THESE LINES ARE FOR, THEY DON'T WORK ANYWAY 
% % theta                   = deg2rad([0 180]);
% % rho                     = 75;
% % [x0_offset, y0_offset]  = pol2cart(theta, rho);
% % 
% % circle_size             = 500;
% % x0                      = xCenter-circle_size/2 + x0_offset;
% % y0                      = yCenter-circle_size/2 + y0_offset;
% % Rectcoord               = [x0 y0 x0+circle_size y0+circle_size];
% % prototypes_prepare_circle(win, [255 0 0], Rectcoord)

Screen('Flip', win)
KbWait;

%%
ptb_close_window;