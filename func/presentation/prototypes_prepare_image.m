function prototypes_prepare_image(win, col, im_text_idx, Rectcoord, rotationAngle)
% function prototypes_prepare_image(win, col, im_text_idx, Rectcoord, rotationAngle)
% if no input, run an example
%
% if you want to create a new grid which is expanded or compressed, you
% have to set the variable 'save_new_grid' to 1 and to change the variable
% 'exp_factor' as desired.
% NOTE that I have changed the way I am referring to the dots, when I plot.
% Before I was using one of the corner of the square that enclosed the dots, now I am
% using the center of the square as reference point (0, 0). The new files
% are like that, the old one (TrialList_imsize800x800_ndots460_offset8.mat)
% is not. This means that I also have to change the main script (protoperispace4_prepare_target.m)
% for drawing the dots.
%
% Update: it was actually less intuitive to use the center of the rectangle
% as reference (because also when plotting in Matlab you have to use the
% corner), so I will bring back everything to the corner of the rect
if nargin==0; [win, col, im_text_idx, Rectcoord, rotationAngle] = get_test_parameters_proco_prepare_image; end

% get the center of the square containing the image
[xCenter2, yCenter2]  = RectCenter(Rectcoord);

% Set blend function for alpha blending
Screen('BlendFunction', win, 'GL_SRC_ALPHA', 'GL_ONE_MINUS_SRC_ALPHA');

% draw the texture with the rotation
Screen('DrawTexture', win, im_text_idx, [], Rectcoord, rotationAngle);
% Rectcoord

[xcenter_rect, ycenter_rect] = RectCenter(Rectcoord);
% xcenter_rect


% if you wanna have a look to the dots as well
if nargin==0
    
    % take the usual grid (e.g. TrialList_imsize800x800_ndots460_offset8),
    % change reference point to the center and expand/compress the grid
    save_new_grid = 0;
    
    change_reference_to_center = 0;
    
    % change reference from center to corner
    change_reference_to_corner = 0;
    
    exp_factor=1;
    if ~save_new_grid;exp_factor=1;end
            
    Rectcoord2 = Rectcoord;
    Rectcoord2([3 4]) = Rectcoord([3 4])*exp_factor;
    Rectcoord2 = AlignRect(Rectcoord2, Rectcoord, 'center', 'center');
%     % plot the square of the image
%     Screen('FrameRect', win, [], Rectcoord);
%     Screen('FrameRect', win, [], Rectcoord2);
    
    % get the center of the square rotating the image
    posX = xCenter2;
    posY = yCenter2;
    
    % get the clouds of dots around the person
    load('TrialList_imsize284x883_ndots250_offset3.mat')
%     load('TrialList_imsize800x800_ndots535_offset8.mat')
    new_xy_offset = xy*exp_factor;
    
    if change_reference_to_center
        new_xy_offset(:,1) = new_xy_offset(:,1) - xcenter_rect*exp_factor + Rectcoord(1)*exp_factor;
        new_xy_offset(:,2) = new_xy_offset(:,2) - ycenter_rect*exp_factor + Rectcoord(2)*exp_factor;
    end
    
    
    if change_reference_to_corner
        new_xy_offset(:,1) = new_xy_offset(:,1) + xcenter_rect*exp_factor - Rectcoord(1)*exp_factor;
        new_xy_offset(:,2) = new_xy_offset(:,2) + ycenter_rect*exp_factor - Rectcoord(2)*exp_factor;
    end
    
    if save_new_grid
        % SAVE THE NEW GRID BASED ON TrialList_imsize800x800_ndots460_offset8.mat
        xy = new_xy_offset;
        %         save('TrialList_imsize800x800_ndots460_offset8_expanded.mat', 'xy')
        save('TrialList_imsize800x800_ndots535_offset8_new.mat', 'xy')
    end
    %     new_xy_offset = xy;
    n_dots = size(new_xy_offset, 1);
    
    % draw the dots
    for d = 1:n_dots
        prototypes_prepare_target (win, new_xy_offset(d,:), col, Rectcoord, rotationAngle)
        %         Screen('DrawDots', win, new_xy_offset(d,:), 10, col,[Rectcoord(1) Rectcoord(2)],2);
    end
    
    
    % Show the dots
    Screen('Flip', win);KbWait; ptb_close_window;
end

function [win, col, im_text_idx, Rectcoord, rotationAngle] = get_test_parameters_proco_prepare_image

%% get image info
figure_name     = 'hand_arm.png';
% im              = imread(figure_name);
[im, ~, alpha] = imread(figure_name);
im(:,:,4) = alpha;
im_width    = size(im, 2);
im_length   = size(im, 1);

%%
randomise_location = 0;
[win, ~, screen_centre]        = ptb_open_window(1);
col             = [0 256 0];
Rectcoord       = prototypes_randomise_location(im_width, im_length); %(800, 800);

if ~randomise_location
    Rectcoord       = CenterRectOnPointd(Rectcoord,screen_centre(1),screen_centre(2));
end
rotationAngle   = 0; %-60;

% prepare texture
im_text_idx = Screen('MakeTexture', win, im);



