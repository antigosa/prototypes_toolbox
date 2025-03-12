function [Trials, actual_timing_table, mouse_track] = prototypes_show_oneTrial(Trials, this_trial, exp_param, actual_timing_table, mouse_track)
% function [Trials, actual_timining_table, mouse_track] = prototypes_show_oneTrial(Trials, this_trial, exp_param, actual_timining_table, mouse_track)

%% get the parameters
param_show_oneTrial = exp_param.param_show_oneTrial;

% ExpPar              = this_trial.Properties.UserData.ExpPar;

% get the positions of the dots for this trial
ActualDots_xy       = this_trial.ActualDots_xy;

% get the subject
subject_id          = this_trial.subj_id{1};

% get the block
block_id            = this_trial.blocks_id;

% get the breaks info
break_id            = this_trial.breaks_id;

% get the nblocks
nblocks             = param_show_oneTrial.nblocks;

% get the trial
trial_id            = this_trial.trials_id;

if any(ismember(this_trial.Properties.VariableNames, 'Message'))
    Messages            = cell2mat(this_trial.Message);
else
    Messages            = [];
end

% % get the shape/image dimensions
% RectHeight          = this_trial.RectHeight;
% RectWidth           = this_trial.RectWidth;

% choose the color of the rectangle
rectangle_color     = this_trial.RectCol; %[36 36 36];

% choose the color of the rectangle
target_color        = this_trial.target_color;

% define the rotation angles of the figure when presented the second time
rotationAngle      = this_trial.rotAngle; %-90:10:90;

% get the window
win = exp_param.Screen.win;

% get the screen rect
screen_rect = exp_param.Screen.rect;

% get mouse rect
% mouse_rect = exp_param.Screen.mouse_rect;

randomiseMousLoc = exp_param.Mouse.randomiseMouseLoc;

% get the timing
timing = exp_param.param_show_oneTrial.timing;

% get the stimulus type
stimulusType    = exp_param.metadata.stimulusType;
useImage        = exp_param.metadata.useImage;

% screen center
screen_center   = exp_param.Screen.screen_center;
xCenter         = screen_center(1);
yCenter         = screen_center(2);


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

% is this haptic and you want to use the camera?
useCamera = exp_param.metadata.useCamera;

% Wait after response is given?
waitAferResponse = 0; % USEFUL FOR GSV

%% preliminary
% =========================================================================
% HIDE THE CURSOR
% =========================================================================
HideCursor;

Rectcoord_FIRST     = this_trial.Rectcoord_FIRST;
Rectcoord_SECOND    = this_trial.Rectcoord_SECOND;

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
if ~isempty(Messages)
    Screen(win,'TextSize',40); Screen(win,'TextFont','Times');DrawFormattedText(win, Messages, 'center','center', [0 0 0], 100,[],[],2); Screen(win,'Flip');
    KbWait;WaitSecs(1);
    return
end


if any(ismember(this_trial.Properties.VariableNames, 'GVS'))
    if this_trial.GVS ~= -1 && this_trial.breaks_id ~= 0
        
        GVS_code = this_trial.GVS;
        
        port = 'COM3';
        
        %Test Left
        SendGVSTrigger(GVS_code, port)
    end
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
    prototypes_prepare_shape = eval(sprintf('@prototypes_prepare_%s', cell2mat(stimulusType)));
    prototypes_prepare_shape(win, rectangle_color, Rectcoord_FIRST);
end
% actual_timing.rectangle1_onset = Screen('Flip', win, actual_timing.trial_start+timing.ITI_duration);
actual_timing.rectangle1_onset = Screen('Flip', win, actual_timing.trial_start+this_trial.ITI_duration);

% =========================================================================
% EVENT 2: SHOW THE TARGET (the dot inside the shape/around the image)
% =========================================================================
if useImage
    prototypes_prepare_image(win, rectangle_color, im_text_idx, Rectcoord_FIRST, rotationAngle)
else
    prototypes_prepare_shape(win, rectangle_color, Rectcoord_FIRST);
end
prototypes_prepare_target(win, ActualDots_xy, target_color, Rectcoord_FIRST, rotationAngle)


if useCamera && strcmp(this_trial.Modality, 'haptic')
    DrawFormattedText(win, sprintf('Prepare pin on board and then press a button (Trial %d out of %d)', this_trial.trials_id, exp_param.ntrials));
    xy              = this_trial.ActualDots_xy;
    Rectcoord       = this_trial.Rectcoord_SECOND;
    dotID_col       = [256 256 256];
    %     dot_id          = 1:100;
    
%     Screen('FillRect', win, [0 0 0], Rectcoord)
%     cur_rect        = [Rectcoord(1) + xy(1), Rectcoord(2) + xy(2), Rectcoord(1) + xy(1) + 20, Rectcoord(2) + xy(2) + 20];
    cur_rect        = [Rectcoord_FIRST(1) + xy(1), Rectcoord_FIRST(2) + xy(2), Rectcoord_FIRST(1) + xy(1) + 20, Rectcoord_FIRST(2) + xy(2) + 20];
    [nx, ny, bbox]  = DrawFormattedText(win, num2str(this_trial.dot_id), 'center', 'center', dotID_col, [], [], [], [], [], cur_rect);
    actual_timing.dot_onset = Screen('Flip', win);
    KbWait;
    
else
    % actual_timing.dot_onset = Screen('Flip', win, actual_timing.rectangle1_onset+timing.rect1_duration);
    actual_timing.dot_onset = Screen('Flip', win, actual_timing.rectangle1_onset+this_trial.rect1_duration);
end



% =========================================================================
% EVENT 3: EVERYTHING DISAPPEAR
% =========================================================================
if useCamera && strcmp(this_trial.Modality, 'haptic')
    sound(MakeBeep(8000, 0.1, 41000));
    DrawFormattedText(win, 'Tell participant to explore the board')
    Screen('Flip', win);
    WaitSecs(this_trial.dot_duration); % Exploration time
    
    sound(MakeBeep(8000, 0.1, 41000));
    DrawFormattedText(win, 'Tell participant to stop exploring the board, place an empty board and press a button to continue')
    actual_timing.black_onset = Screen('Flip', win);
    WaitSecs(1);
    KbWait;

else
    % actual_timing.black_onset = Screen('Flip', win, actual_timing.dot_onset+timing.dot_duration);
    actual_timing.black_onset = Screen('Flip', win, actual_timing.dot_onset+this_trial.dot_duration);    
    
end

% =========================================================================
% EVENT 4: SHOW THE SECOND FIGURE
% =========================================================================

% show SECOND Figure
if useImage    
    prototypes_prepare_image(win, rectangle_color, im_text_idx, Rectcoord_SECOND, rotationAngle)
else
    prototypes_prepare_shape(win, rectangle_color, Rectcoord_SECOND);
end

if runTest    
    prototypes_prepare_target(win, ActualDots_xy, target_color, Rectcoord_SECOND, rotationAngle)
end

if useCamera && strcmp(this_trial.Modality, 'haptic')
    DrawFormattedText(win, 'Tell participant to place the pin and then press a button')
    actual_timing.rectangle2_onset = Screen('Flip', win);
    WaitSecs(1);
    KbWait;
    
else  
    % actual_timing.rectangle2_onset = Screen('Flip', win, actual_timing.black_onset+timing.blank);
    actual_timing.rectangle2_onset = Screen('Flip', win, actual_timing.black_onset+this_trial.blank);
    
    
end

% =========================================================================
% EVENT 5: RESPONSE
% =========================================================================
% The mouse ap
% MouseInitialLoc=[round(rand(1)*screen_rect(3)) round(rand(1)*screen_rect(4))];
% MouseInitialLoc=[round(rand(1)*mouse_rect(3)) round(rand(1)*mouse_rect(4))];
MouseInitialLoc = [xCenter yCenter];

if randomiseMousLoc
    
    theta                   = deg2rad(random('unid', 360, 1,1));
    % theta                   = deg2rad([0 180]);
    % rho                     = 75;
    rho                     = random('unid', 15, 1,1);
    [x0_offset, y0_offset]  = pol2cart(theta, rho);
    MouseInitialLoc         = [MouseInitialLoc(1)+x0_offset MouseInitialLoc(2)+y0_offset];
end

SetMouse(MouseInitialLoc(1),MouseInitialLoc(2));

%Collect Response
ShowCursor(mouse_type);
if runFast
    
    % this is just for testing
    % ADDED [0, 0], I CANNOT REMEMBER WHAT TO ADD THERE
    xy = prototypes_rotate_dots(ActualDots_xy, rotationAngle, [0, 0])+random('norm', 0, 10, 2, 1);                  % TEST
    mouse_resp.x_mouse_resp = xy(1)+ Rectcoord_SECOND(1); % TEST
    mouse_resp.y_mouse_resp = xy(2)+ Rectcoord_SECOND(2); % TEST
else
    
    if useCamera && strcmp(this_trial.Modality, 'haptic')
        DrawFormattedText(win, 'Press the mouse button within the rectanle to take a picture')
        prototypes_prepare_shape(win, rectangle_color, Rectcoord_SECOND);
        Screen('Flip', win);
    end
    
    % if the second parameter is empty, it means that participants can click anywhere
    [~, mouse_resp.x_mouse_resp,mouse_resp.y_mouse_resp] = ptb_getMouseResponse_withTracking(win, Rectcoord_SECOND); % Rectcoord_SECOND
    
    if useCamera && strcmp(this_trial.Modality, 'haptic')
        theImage = getsnapshot(exp_param.metadata.theCamera);
        img_name = sprintf('%s_block-%d_trial-%d_dot-%d.jpg', exp_param.subjInfo.subjNum, this_trial.blocks_id, this_trial.trials_id, this_trial.dot_id);
        imwrite(theImage, fullfile(exp_param.subjInfo.folder, img_name),'JPEG');
    end
    
    
end

% response_relToTrialStart = GetSecs-actual_timing.trial_start;

resp(1) = mouse_resp.x_mouse_resp(end);
resp(2) = mouse_resp.y_mouse_resp(end);


%% Wait after response
% CHECK THIS!!!!!
% THIS IS IF YOU WANT A FIX TIME FOR EACH TRIAL, INDEPENDENTLY OF HOW LONG
% THE PARTICIPANT TOOK TO RESPOND. IT WAS IMPORTANT FOR THE GVS EXPERIMENT.

if waitAferResponse
    Trial_dur = 6; % THIS IS NOT VALID ANYMORE, SHOULD BE DYNAMICALLY UPDATED
    
    TimeLeft = Trial_dur-(GetSecs-actual_timing.trial_start);
    
    % Wait until 6 secs
    while TimeLeft>0
        TimeLeft = Trial_dur-(GetSecs-actual_timing.trial_start);
        %     disp(TimeLeft)
    end
end

%% post trial
experiment_start            = actual_timing.experiment_start;
trial_start                 = actual_timing.trial_start-actual_timing.experiment_start;
ev1_onset                   = actual_timing.rectangle1_onset - actual_timing.trial_start;
dot_onset                   = actual_timing.dot_onset - actual_timing.trial_start;
blank_onset                 = actual_timing.black_onset - actual_timing.trial_start;
ev2_onset                   = actual_timing.rectangle2_onset - actual_timing.trial_start;
trial_dur                   = GetSecs-actual_timing.trial_start;
RespDots_xy_relToShape      = resp - Rectcoord_SECOND([1 2]);
RespDots_xy                 = prototypes_rotate_dots(RespDots_xy_relToShape, rotationAngle, [0 0]); % UPDATE [0, 0], OR IT'S GOING TO BE VERY WRONG!!
RespDots_xy_relToScreen(1)  = resp(:,1) + Rectcoord_SECOND(1);
RespDots_xy_relToScreen(2)  = resp(:,2) + Rectcoord_SECOND(2);
if size(RespDots_xy, 1)~=1; RespDots_xy=RespDots_xy';end
errorXY                     = RespDots_xy - ActualDots_xy;
errorMag                    = sqrt(diag(errorXY * errorXY'));

actual_timing.trial_end     = GetSecs;
actual_timing.trial_dur     = trial_dur;
actual_timing_table         = [actual_timing_table; struct2table(actual_timing)];

this_trial = [this_trial, ...
    table(RespDots_xy_relToShape, RespDots_xy, RespDots_xy_relToScreen, ...
    errorXY, errorMag, screen_rect, MouseInitialLoc, experiment_start, trial_start, trial_dur, ev1_onset, dot_onset, blank_onset, ev2_onset)
    ];


Trials = prototypes_store_atrial(Trials, this_trial);


mouse_track = [mouse_track; table({mouse_resp.x_mouse_resp}, {mouse_resp.y_mouse_resp}, 'VariableNames', {'x', 'y'})];

% ADD OUTPUT FOLDER HERE!!
if ~isfolder('backup'); mkdir('backup');end
save (fullfile('backup', sprintf('%s_backup.mat', subject_id)), 'actual_timing_table', 'mouse_track', 'Trials');
