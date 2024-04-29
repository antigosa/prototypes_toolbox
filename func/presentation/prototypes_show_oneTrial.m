function [Trials, actual_timing_table] = prototypes_show_oneTrial(Trials, this_trial, exp_param, actual_timing_table)
% function [Trials, actual_timining_table] = prototypes_show_oneTrial(Trials, this_trial, exp_param, actual_timining_table)

%% get the parameters
param_show_oneTrial = exp_param.param_show_oneTrial;

ExpPar              = this_trial.Properties.UserData.ExpPar;

% get the positions of the dots for this trial
ActualDots_xy       = this_trial.ActualDots_xy;

% get the subject
subject_id          = this_trial.subj_id;

% get the block
block_id            = this_trial.blocks_id;

% get the breaks info
break_id            = this_trial.breaks_id;

% get the nblocks
nblocks             = ExpPar.nblocks;

% get the trial
trial_id            = this_trial.trial_id;

% % get the shape/image dimensions
% RectHeight          = this_trial.RectHeight;
% RectWidth           = this_trial.RectWidth;

% choose the color of the rectangle
rectangle_color     = this_trial.RectCol; %[36 36 36];

% choose the color of the rectangle
target_color        = this_trial.TargetCol; 

% define the rotation angles of the figure when presented the second time
rotationAngle      = this_trial.RotAngle; %-90:10:90;

% get the window
win = exp_param.Screen.win;

% get the screen rect
screen_rect = exp_param.Screen.rect;

% get the timing
timing = exp_param.param_show_oneTrial.timing;

% get the stimulus type
stimulusType    = exp_param.metadata.stimulusType;
useImage        = exp_param.metadata.useImage;


% get the mouse type
mouse_type      = 'hand';% this_trial.mouse_type;

if useImage
    
    % get the textures (images) of the object/person
    im_text_idx         = param_show_oneTrial.text_info.im_text_idx;
    
    % get the rectangle that contains the texture
    rect_img            = param_show_oneTrial.text_info.rect_img;
    
    % get the img dimensions
    img_RectHeight      = param_show_oneTrial.text_info.img_RectHeight;
    img_RectWidth       = param_show_oneTrial.text_info.img_RectWidth;
end

% is it a test?
runFast = exp_param.metadata.runFast;
runTest = exp_param.metadata.runTest;


%% preliminary
% =========================================================================
% HIDE THE CURSOR
% =========================================================================
HideCursor;

Rectcoord_FIRST = this_trial.Rectcoord_FIRST;
Rectcoord_SECOND = this_trial.Rectcoord_SECOND;

% =========================================================================
% get the flip time of the initial trial
% =========================================================================
% CHECK IF I REALLY NEED THIS.
actual_timing.trial_start = Screen('Flip', win);
if trial_id==1
    actual_timing.experiment_start = actual_timing.trial_start;
elseif trial_id==0
    actual_timing.experiment_start = -1;
elseif trial_id>1
    actual_timing.experiment_start = Trials.experiment_start(end);
end



%% show info

% =========================================================================
% show the message at the end of the practice
% =========================================================================
if trial_id == 1
    Screen(win,'TextSize',40); Screen(win,'TextFont','Times');DrawFormattedText(win, 'End of the practice block.\n\nResponses will be recorded from now on.\n\nPress the bar when you feel ready to start.', 'center','center', [0 0 0], 100,[],[],2); Screen(win,'Flip');
    KbWait;WaitSecs(1);
end

% =========================================================================
% show the message at the end of the block
% =========================================================================
if break_id ~= 0 && ~runFast
    Screen(win,'TextSize',40); Screen(win,'TextFont','Times');DrawFormattedText(win, sprintf('End of Block %d (out of %d)\n\nPlease take a rest\n\nPress the bar when you feel ready to start.', break_id, nblocks), 'center','center', [0 0 0], 100,[],[],2); Screen(win,'Flip');
    KbWait;WaitSecs(1);
end


%% events
% =========================================================================
% EVENT 1: SHOW THE FIRST FIGURE (a circle, an image, or anything)
% =========================================================================
% this is the first shape which the target will appear onto.

if useImage
    prototypes_prepare_image(win, rectangle_color, im_text_idx, Rectcoord_FIRST, rotationAngle)
else
    % choose the function for the type of stimulus
    prototypes_prepare_shape = eval(sprintf('@prototypes_prepare_%s', stimulusType));
    prototypes_prepare_shape(win, rectangle_color, Rectcoord_FIRST);
end
actual_timing.rectangle1_onset = Screen('Flip', win, actual_timing.trial_start+timing.ITI_duration);

% =========================================================================
% EVENT 2: SHOW THE TARGET (the dot inside the shape/around the image)
% =========================================================================
if useImage
    prototypes_prepare_image(win, rectangle_color, im_text_idx, Rectcoord_FIRST, rotationAngle)
else
    prototypes_prepare_shape(win, rectangle_color, Rectcoord_FIRST);
end
prototypes_prepare_target(win, ActualDots_xy, target_color, Rectcoord_FIRST, rotationAngle)
actual_timing.dot_onset = Screen('Flip', win, actual_timing.rectangle1_onset+timing.rect1_duration);

% =========================================================================
% EVENT 3: EVERYTHING DISAPPEAR
% =========================================================================
actual_timing.black_onset = Screen('Flip', win, actual_timing.dot_onset+timing.dot_duration);

% =========================================================================
% EVENT 4: SHOW THE SECOND FIGURE
% =========================================================================

% show SECOND Figure
if useImage
%     rotationAngle = angles(randperm(length(angles)));rotationAngle = rotationAngle(1);% 45;
    prototypes_prepare_image(win, rectangle_color, im_text_idx, Rectcoord_SECOND, rotationAngle)
else
    prototypes_prepare_shape(win, rectangle_color, Rectcoord_SECOND);
end

if runTest
%     rotationAngle = angles(randperm(length(angles)));rotationAngle = rotationAngle(1);% 45;
    prototypes_prepare_target(win, ActualDots_xy, target_color, Rectcoord_SECOND, rotationAngle)
end
actual_timing.rectangle2_onset = Screen('Flip', win, actual_timing.black_onset+timing.blank);

% =========================================================================
% EVENT 5: RESPONSE
% =========================================================================
% The mouse ap
MouseInitialLoc=[round(rand(1)*screen_rect(3)) round(rand(1)*screen_rect(4))];
SetMouse(MouseInitialLoc(1),MouseInitialLoc(2));

%Collect Response
ShowCursor(mouse_type);
if runFast
    
    % this is just for testing
    xy = prototypes_rotate_dots(ActualDots_xy, rotationAngle)+random('norm', 0, 10, 2, 1);                  % TEST
    mouse_resp.x_mouse_resp = xy(1)+ Rectcoord_SECOND(1); % TEST
    mouse_resp.y_mouse_resp = xy(2)+ Rectcoord_SECOND(2); % TEST   
else
    
    % if the second parameter is empty, it means that participants can click anywhere
    [~, mouse_resp.x_mouse_resp,mouse_resp.y_mouse_resp] = ptb_getMouseResponse_withTracking(win, Rectcoord_SECOND); % Rectcoord_SECOND
end
resp(1) = mouse_resp.x_mouse_resp(end);
resp(2) = mouse_resp.y_mouse_resp(end);


%% post trial

actual_timing_table         = [actual_timing_table; struct2table(actual_timing)];
experiment_start            = actual_timing.experiment_start;
trial_start                 = actual_timing.trial_start-actual_timing.experiment_start;
ev1_onset                   = actual_timing.rectangle1_onset - actual_timing.trial_start;
dot_onset                   = actual_timing.dot_onset - actual_timing.trial_start;
blank_onset                 = actual_timing.black_onset - actual_timing.trial_start;
ev2_onset                   = actual_timing.rectangle2_onset - actual_timing.trial_start;
RespDots_xy_relToShape      = resp - Rectcoord_SECOND([1 2]);
RespDots_xy  = prototypes_rotate_dots(RespDots_xy_relToShape, rotationAngle);
RespDots_xy_relToScreen(1)  = resp(:,1) + Rectcoord_SECOND(1);
RespDots_xy_relToScreen(2)  = resp(:,2) + Rectcoord_SECOND(2);
if size(RespDots_xy, 1)~=1; RespDots_xy=RespDots_xy';end
errorXY                 = RespDots_xy - ActualDots_xy;
errorMag                = sqrt(diag(errorXY * errorXY'));


this_trial = [this_trial, ...
    table(RespDots_xy_relToShape, RespDots_xy, RespDots_xy_relToScreen, ...
    errorXY, errorMag, screen_rect, MouseInitialLoc, experiment_start, trial_start, ev1_onset, dot_onset, blank_onset, ev2_onset)
    ];

% this_trial = table(subject_id, trial_id, ActualDots_xy, block_id, break_id, stimulusType, Rectcoord_FIRST, Rectcoord_SECOND, ...
%     RespDots_xy_relToShape, RespDots_xy_relToShape_rot, RespDots_xy_relToScreen, ...
%     errorXY, errorMag, rotationAngle, RectHeight, RectWidth, ...
%     screen_rect, MouseInitialLoc, experiment_start, trial_start, ev1_onset, dot_onset, blank_onset, ev2_onset, ...
%     useImage, mouse_type);

 Trials = prototypes_store_atrial(Trials, this_trial);

save (sprintf('sub%02d_actual_timing.mat', subject_id), 'actual_timing_table');
save (sprintf('sub%02d_mouse_track.mat', subject_id), 'mouse_resp');
save (sprintf('sub%02d_Resp_backup.mat', subject_id), 'Trials');
