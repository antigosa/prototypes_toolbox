function prototypes_prepare_circle(win, col, Rectcoord)
% function prototypes_prepare_circle(win, col, Rectcoord)
% col = [36 36 36]


if nargin==0
    whichScreen = 0 ;
    [fname,file_path] = uigetfile({'*.mat';}, 'Choose the dots');
    %     load('TrialList_grid300_offset 8.mat')
    load(fullfile(file_path, fname));
    [win, col, Rectcoord] = get_test_parameters_proco_prepare_rectangle(shape_height, shape_width, whichScreen);
end

Screen('FillOval', win, col, Rectcoord)
if nargin==0            
    n_dots = size(xy, 1);
    for d = 1:n_dots
        Screen('DrawDots', win, xy (d,:),10,[256 256 256],[Rectcoord(1) Rectcoord(2)],2);
    end
    
    Screen('Flip', win);KbWait; ptb_close_window;
end

function [win, col, Rectcoord] = get_test_parameters_proco_prepare_rectangle(shape_height, shape_width, whichScreen)

[win, rect]     = ptb_open_window(0, whichScreen);
col             = [36 36 36];
Rectcoord       = prototypes_randomise_location(shape_width, shape_height, [], [], whichScreen);


