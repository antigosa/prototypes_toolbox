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
win(1) = exp_param.Screen.win(1);
win(2) = exp_param.Screen.win(2);

% get the screen rect
screen_rect(1,:) = exp_param.Screen.rect(1,:);
screen_rect(2,:) = exp_param.Screen.rect(2,:);

% get mouse rect
% mouse_rect = exp_param.Screen.mouse_rect;

randomiseMousLoc = exp_param.Mouse.randomiseMouseLoc;

% get the timing
timing = exp_param.param_show_oneTrial.timing;

% get the stimulus type
stimulusType    = exp_param.metadata.stimulusType;
useImage        = exp_param.metadata.useImage;

% screen center
screen_center(1,:)    = exp_param.Screen.screen_center(1,:);
screen_center(2,:)    = exp_param.Screen.screen_center(2,:);
xCenter(1)          = screen_center(1);
yCenter(1)          = screen_center(2);
xCenter(2)          = screen_center(1);
yCenter(2)          = screen_center(2);


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
actual_timing.trial_start = Screen('Flip', win(1));
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
    Screen(win(1),'TextSize',40); Screen(win(1),'TextFont','Times');DrawFormattedText(win(1), 'End of the practice block.\n\nResponses will be recorded from now on.\n\nPress the bar when you feel ready to start.', 'center','center', [0 0 0], 100,[],[],2); Screen(win(1),'Flip');
    KbWait;WaitSecs(1);
end

% =========================================================================
% show the message at the end of the block
% =========================================================================
if trial_id ~= 1
    if break_id == 1 && ~runFast
        Screen(win(1),'TextSize',40); Screen(win(1),'TextFont','Times');DrawFormattedText(win(1), sprintf('End of Block %d (out of %d)\n\nPlease take a rest\n\nPress the bar when you feel ready to start.', break_id, nblocks), 'center','center', [0 0 0], 100,[],[],2); Screen(win(1),'Flip');
        KbWait;WaitSecs(1);
    end

    if break_id == 2 && ~runFast
        Screen(win(1),'TextSize',40); Screen(win(1),'TextFont','Times');DrawFormattedText(win(1), sprintf('Please take a rest\n\nPress the bar when you feel ready to start.'), 'center','center', [0 0 0], 100,[],[],2); Screen(win(1),'Flip');
        KbWait;WaitSecs(1);
    end

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
    prototypes_prepare_image(win(1), rectangle_color, im_text_idx, Rectcoord_FIRST, rotationAngle)
else
    % choose the function for the type of stimulus
    prototypes_prepare_shape = eval(sprintf('@prototypes_prepare_%s', stimulusType));

    if strcmp(this_trial.Modality, 'haptic2vision')
        prototypes_prepare_shape(win(2), rectangle_color, Rectcoord_FIRST);
    elseif strcmp(this_trial.Modality, 'vision2haptic') || strcmp(this_trial.Modality, 'vision')
        prototypes_prepare_shape(win(1), rectangle_color, Rectcoord_FIRST);
    end
end
if strcmp(this_trial.Modality, 'haptic2vision')
    Screen('Flip', win(1));
    actual_timing.rectangle1_onset = Screen('Flip', win(2), actual_timing.trial_start+this_trial.ITI_duration);

elseif strcmp(this_trial.Modality, 'vision2haptic') || strcmp(this_trial.Modality, 'vision')    
    actual_timing.rectangle1_onset = Screen('Flip', win(1), actual_timing.trial_start+this_trial.ITI_duration);
end

% =========================================================================
% EVENT 2: SHOW THE TARGET (the dot inside the shape/around the image)
% =========================================================================
if useImage
    prototypes_prepare_image(win(1), rectangle_color, im_text_idx, Rectcoord_FIRST, rotationAngle)
else
    if strcmp(this_trial.Modality, 'haptic2vision')
        prototypes_prepare_shape(win(2), rectangle_color, Rectcoord_FIRST);
    elseif strcmp(this_trial.Modality, 'vision2haptic') || strcmp(this_trial.Modality, 'vision')
        prototypes_prepare_shape(win(1), rectangle_color, Rectcoord_FIRST);
    end
end
if strcmp(this_trial.Modality, 'haptic2vision')
    prototypes_prepare_target(win(2), ActualDots_xy, target_color, Rectcoord_FIRST, rotationAngle)
elseif strcmp(this_trial.Modality, 'vision2haptic') || strcmp(this_trial.Modality, 'vision')
    prototypes_prepare_target(win(1), ActualDots_xy, target_color, Rectcoord_FIRST, rotationAngle)
end


if strcmp(this_trial.Modality, 'haptic') || strcmp(this_trial.Modality, 'haptic2vision')
    DrawFormattedText(win(2), sprintf('Prepare pin on board and then press a button (Trial %d out of %d)', this_trial.trials_id, exp_param.ntrials));
    xy              = this_trial.ActualDots_xy;
    % Rectcoord       = this_trial.Rectcoord_SECOND;
    dotID_col       = [256 256 256];
    %     dot_id          = 1:100;

    %     Screen('FillRect', win, [0 0 0], Rectcoord)
    %     cur_rect        = [Rectcoord(1) + xy(1), Rectcoord(2) + xy(2), Rectcoord(1) + xy(1) + 20, Rectcoord(2) + xy(2) + 20];
    cur_rect        = [Rectcoord_FIRST(1) + xy(1), Rectcoord_FIRST(2) + xy(2), Rectcoord_FIRST(1) + xy(1) + 20, Rectcoord_FIRST(2) + xy(2) + 20];
    [nx, ny, bbox]  = DrawFormattedText(win(2), num2str(this_trial.dot_id), 'center', 'center', dotID_col, [], [], [], [], [], cur_rect);
    actual_timing.dot_onset = Screen('Flip', win(2));
    KbWait;

elseif strcmp(this_trial.Modality, 'vision2haptic') || strcmp(this_trial.Modality, 'vision')
    % actual_timing.dot_onset = Screen('Flip', win, actual_timing.rectangle1_onset+timing.rect1_duration);
    actual_timing.dot_onset = Screen('Flip', win(1), actual_timing.rectangle1_onset+this_trial.rect1_duration);
end



% =========================================================================
% EVENT 3: EVERYTHING DISAPPEAR
% =========================================================================
if strcmp(this_trial.Modality, 'haptic') || strcmp(this_trial.Modality, 'haptic2vision')
    sound(MakeBeep(8000, 0.1, 41000));
    DrawFormattedText(win(2), 'Tell participant to explore the board')
    Screen('Flip', win(2));
    WaitSecs(this_trial.dot_duration); % Exploration time

    sound(MakeBeep(8000, 0.1, 41000));
    if strcmp(this_trial.Modality, 'haptic')
        DrawFormattedText(win(2), 'Tell participant to stop exploring the board, place an empty board and press a button to continue')
    elseif strcmp(this_trial.Modality, 'haptic2vision')
        DrawFormattedText(win(2), 'Tell participant to stop exploring the board, remove the board and press a button to continue')
    end
    actual_timing.black_onset = Screen('Flip', win(2));
    WaitSecs(1);
    KbWait;

elseif strcmp(this_trial.Modality, 'vision2haptic') || strcmp(this_trial.Modality, 'vision')
    % actual_timing.black_onset = Screen('Flip', win, actual_timing.dot_onset+timing.dot_duration);
    actual_timing.black_onset = Screen('Flip', win(1), actual_timing.dot_onset+this_trial.dot_duration);

end

% =========================================================================
% EVENT 4: SHOW THE SECOND FIGURE
% =========================================================================

% show SECOND Figure
if useImage
    %     rotationAngle = angles(randperm(length(angles)));rotationAngle = rotationAngle(1);% 45;
    prototypes_prepare_image(win(1), rectangle_color, im_text_idx, Rectcoord_SECOND, rotationAngle)
else
    prototypes_prepare_shape(win(1), rectangle_color, Rectcoord_SECOND);
end

if runTest
    %     rotationAngle = angles(randperm(length(angles)));rotationAngle = rotationAngle(1);% 45;
    prototypes_prepare_target(win(1), ActualDots_xy, target_color, Rectcoord_SECOND, rotationAngle)
end

if strcmp(this_trial.Modality, 'haptic') || strcmp(this_trial.Modality, 'vision2haptic')
    DrawFormattedText(win(2), 'Tell participant to place the pin and then press a button')
    actual_timing.rectangle2_onset = Screen('Flip', win(2));
    WaitSecs(1);
    KbWait;

elseif strcmp(this_trial.Modality, 'haptic2vision')
    % actual_timing.rectangle2_onset = Screen('Flip', win, actual_timing.black_onset+timing.blank);
    actual_timing.rectangle2_onset = Screen('Flip', win(1), actual_timing.black_onset+this_trial.blank);

elseif strcmp(this_trial.Modality, 'vision')
    % actual_timing.rectangle2_onset = Screen('Flip', win, actual_timing.black_onset+timing.blank);
    actual_timing.rectangle2_onset = Screen('Flip', win(1), actual_timing.black_onset+this_trial.blank);
end

% =========================================================================
% EVENT 5: RESPONSE
% =========================================================================
% The mouse appears in a random location, then the participant can respond
MouseInitialLoc             = [xCenter yCenter];

if randomiseMousLoc
    theta                   = deg2rad(random('unid', 360, 1,1));
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

    % if the response needs to be given haptically, the experimenter should
    % press the mouse button to take the picture
    if useCamera && strcmp(this_trial.Modality, 'haptic') || strcmp(this_trial.Modality, 'vision2haptic')
        DrawFormattedText(win(2), 'Press the mouse button within the rectanle to take a picture')
        prototypes_prepare_shape(win(2), rectangle_color, Rectcoord_SECOND);
        Screen('Flip', win(2));
    end

    if useCamera && strcmp(this_trial.Modality, 'haptic')
        % If it is just haptic, the second rectangle will appear in win1:
        % there should be only one screen and the experimenter should press
        % the button. 
        [~, mouse_resp.x_mouse_resp,mouse_resp.y_mouse_resp] = ptb_getMouseResponse_withTracking(win(1), Rectcoord_SECOND); % Rectcoord_SECOND
    elseif strcmp(this_trial.Modality, 'vision2haptic')
        % If it is vision2haptic, the second rectangle will appear in win2:
        % the experimenter only should see the message and should press the
        % button
        [~, mouse_resp.x_mouse_resp,mouse_resp.y_mouse_resp] = ptb_getMouseResponse_withTracking(win(2), Rectcoord_SECOND); % Rectcoord_SECOND
    else
        % The alternative are 'vision' or 'haptic2vision', and in both
        % cases the response should be given by the participant. So, the
        % response is collected in win1. 
        [~, mouse_resp.x_mouse_resp,mouse_resp.y_mouse_resp] = ptb_getMouseResponse_withTracking(win(1), Rectcoord_SECOND); % Rectcoord_SECOND
    end

    if useCamera && strcmp(this_trial.Modality, 'haptic') || strcmp(this_trial.Modality, 'vision2haptic')
        % Only if the camera is on and the response is haptic, a screenshot
        % should be taken. 
        theImage = getsnapshot(exp_param.metadata.theCamera);
        img_name = sprintf('%s_block-%d_trial-%d_dot-%d.jpg', exp_param.subjInfo.subjNum, this_trial.blocks_id, this_trial.trials_id, this_trial.dot_id);
        imwrite(theImage, fullfile(exp_param.subjInfo.folder, img_name),'JPEG');

        % Now, send a message to confirm photo has been taken and ask for a
        % button press to continue.
        if useCamera && strcmp(this_trial.Modality, 'haptic')
            DrawFormattedText(win(1), 'The screenshow has been taken. Press a button to continue...')
        elseif useCamera && strcmp(this_trial.Modality, 'vision2haptic')
            DrawFormattedText(win(2), 'The screenshow has been taken. Press a button to continue...')
        end
        KbWait;
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
actual_timing_table         = [actual_timing_table; struct2table(actual_timing)];
experiment_start            = actual_timing.experiment_start;
trial_start                 = actual_timing.trial_start-actual_timing.experiment_start;
ev1_onset                   = actual_timing.rectangle1_onset - actual_timing.trial_start;
dot_onset                   = actual_timing.dot_onset - actual_timing.trial_start;
blank_onset                 = actual_timing.black_onset - actual_timing.trial_start;
ev2_onset                   = actual_timing.rectangle2_onset - actual_timing.trial_start;
trial_end                   = GetSecs-actual_timing.trial_start;
RespDots_xy_relToShape      = resp - Rectcoord_SECOND([1 2]);
RespDots_xy                 = prototypes_rotate_dots(RespDots_xy_relToShape, rotationAngle, [0 0]); % UPDATE [0, 0], OR IT'S GOING TO BE VERY WRONG!!
RespDots_xy_relToScreen(1)  = resp(:,1) + Rectcoord_SECOND(1);
RespDots_xy_relToScreen(2)  = resp(:,2) + Rectcoord_SECOND(2);
if size(RespDots_xy, 1)~=1; RespDots_xy=RespDots_xy';end
errorXY                     = RespDots_xy - ActualDots_xy;
errorMag                    = sqrt(diag(errorXY * errorXY'));


this_trial = [this_trial, ...
    table(RespDots_xy_relToShape, RespDots_xy, RespDots_xy_relToScreen, ...
    errorXY, errorMag, screen_rect(2,:), MouseInitialLoc, experiment_start, trial_start, trial_end, ev1_onset, dot_onset, blank_onset, ev2_onset)
    ];

Trials = prototypes_store_atrial(Trials, this_trial);


mouse_track = [mouse_track; table({mouse_resp.x_mouse_resp}, {mouse_resp.y_mouse_resp}, 'VariableNames', {'x', 'y'})];

% ADD OUTPUT FOLDER HERE!!
if ~isfolder('backup'); mkdir('backup');end
save (fullfile('backup', sprintf('%s_actual_timing.mat', subject_id)), 'actual_timing_table', 'mouse_track', 'Trials');