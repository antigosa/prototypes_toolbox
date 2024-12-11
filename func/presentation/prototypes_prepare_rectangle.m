function prototypes_prepare_rectangle(win, col, Rectcoord, showDotID)
% function prototypes_prepare_rectangle(win, col, Rectcoord, showDotID)
% col = [36 36 36]

if nargin==0
    whichScreen = 0 ;
    [fname,file_path] = uigetfile({'*.mat';}, 'Choose the dots');
    %     load('TrialList_grid300_offset 8.mat')
    load(fullfile(file_path, fname));
    dot_col = [256 256 256];
    showDotID=0;
    if showDotID
        dot_id = 1:size(xy,1);
        dot_id(dot_id>100) = dot_id(dot_id>100)-100;
        dotID_col   = [0 0 0];
        dot_col     = [0 0 0];
    end
    [win, col, Rectcoord] = get_test_parameters_proco_prepare_rectangle(shape_height, shape_width, whichScreen);

    if showDotID
        col = [256 256 256];
    end
end

% Screen('FillOval', win, col, Rectcoord)
Screen('FillRect', win, col, Rectcoord)
if nargin==0
    n_dots = size(xy, 1);
    for d = 1:n_dots
        Screen('DrawDots', win, xy (d,:), 10, dot_col, [Rectcoord(1) Rectcoord(2)], 2);

        if showDotID
            cur_rect = [Rectcoord(1) + xy(d,1), Rectcoord(2) + xy(d,2), Rectcoord(1) + xy(d,1) + 20, Rectcoord(2) + xy(d,2) + 20];
            [nx, ny, bbox] = DrawFormattedText(win, num2str(dot_id(d)), 'center', 'center', dotID_col, [], [], [], [], [], cur_rect);
            % Show computed text bounding box:
            % Screen('FrameRect', win, 0, cur_rect);
        end


    end

    Screen('Flip', win);KbWait;

    if showDotID
        current_display = Screen('GetImage', win);
        imwrite(current_display, 'dots.png')
    end


    ptb_close_window;


end

function [win, col, Rectcoord] = get_test_parameters_proco_prepare_rectangle(shape_height, shape_width, whichScreen)

[win, rect]     = ptb_open_window(0, whichScreen);
col             = [36 36 36];
Rectcoord       = prototypes_randomise_location(shape_width, shape_height, [], [], whichScreen);
save('Rectcoord', 'Rectcoord')

