function prototypes_prepare_rectangle(win, col, Rectcoord)
% function prototypes_prepare_rectangle(win, col, Rectcoord)
% col = [36 36 36]

if nargin==0; [win, col, Rectcoord] = get_test_parameters_proco_prepare_rectangle; end

Screen('FillRect', win, col, Rectcoord)
if nargin==0
    load('TrialList_grid300_offset8.mat')
    %     load('TrialList.mat'); new_xy_offset = xy;
    n_dots = size(xy, 1);
    for d = 1:n_dots
        Screen('DrawDots', win, xy (d,:),10,[256 256 256],[Rectcoord(1) Rectcoord(2)],2);
    end
    
    Screen('Flip', win);KbWait; ptb_close_window;
end

function [win, col, Rectcoord] = get_test_parameters_proco_prepare_rectangle

[win, rect]  = ptb_open_window;
col             = [36 36 36];
Rectcoord       = prototypes_randomise_location(960, 480);


