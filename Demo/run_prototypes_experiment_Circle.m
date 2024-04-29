%% setup
clear;
project_dir     = pwd;
toolbox_dir     = 'D:\Programs\toolbox';
addpath(genpath(fullfile(toolbox_dir, 'prototypes_toolbox')));
addpath(genpath(fullfile(toolbox_dir, 'ptb_utils')));

% if you want run a test runFast = 1;
runFast             = 1;
runTest             = 1;
showImageInCenter   = 0;
useImage            = 0;
fname_TrialList     = 'TrialList_imsize500x500_ndots468_nblocks4_offset2_Circle';

% 'rectangle' | 'circle'
stimulusType        = 'circle';


%% set experiment info
exp_param.metadata.project_path     = project_dir;
exp_param.metadata.fname_TrialList  = fname_TrialList;
exp_param.metadata.runFast          = runFast;
exp_param.metadata.runTest          = runTest;
exp_param.metadata.useImage         = useImage;
exp_param.metadata.stimulusType     = stimulusType;
exp_param.metadata.shape_color      = [36 36 36];
exp_param.metadata.target_color     = [256 256 256];
exp_param.metadata.rot_angle        = 0;


%% initialisation
ptb_clean_screen;

% REMOVE THIS WHEN YOU FIX THE PROBLEM: The external text renderer plugin failed to render the text string for some reason!
Screen('Preference', 'TextRenderer', 0);

%% subject and trial sequence information
% gather some info about the subject
subjInfo=get_subject_info(project_dir);

% Here, I am generating the trial sequence. This section can be changed
% based on the experiment. What is important is to have a table called
% 'trial_sequence' with the following columns:
% - subj_id, trial_id, blocks_id, breaks_id, ActualDots_xy
% the program puts breaks whenever breaks_id is equal to 1
trials_sequence = prototypes_generate_trials_order_inQuadrants(project_dir, subjInfo, exp_param);

% just for testing: show less trials
if runTest
    trials_sequence=trials_sequence([6 112 123 239 240 356 357 473],:);
    nbreaks = sum(trials_sequence.breaks_id~=0);
    trials_sequence.breaks_id(trials_sequence.breaks_id~=0) = 1:nbreaks;
end


%% set and get the timing

% if you want to change the duration of the various phases, enter into
% prototypes_set_timing. 
timing = prototypes_set_timing(fname_TrialList, trials_sequence);


%% prepare variables
ntrials             = size(trials_sequence,1); %  bettern than infoExperiment.nExpTrials because it takes catch trials into account;
block_list          = unique(trials_sequence.blocks_id);block_list(block_list==0)=[];
break_list          = unique(trials_sequence.breaks_id);break_list(break_list==0)=[];
nblocks             = length(break_list);


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


%% set the screen parameters

% put the screen parameters in a structure so I can use them in functions
exp_param.Screen.win            = win;
exp_param.Screen.rect           = rect;
exp_param.Screen.screen_center  = screen_center;


%% get image info

% this is useful only if you want to show an image instead of a shape
if useImage
    % note that the name of the image to be used is inside the function for
    % now. 
    text_info = prototypes_get_textures(win, xCenter, yCenter);
end


%% instruction

% show the instructions, you can modify the instructions inside prototypes_show_instruction
 prototypes_show_instruction(win);


%% set the trial parameters
if useImage
    exp_param.param_show_oneTrial.text_info         = text_info;
end
exp_param.param_show_oneTrial.showImageInCenter     = showImageInCenter;
exp_param.param_show_oneTrial.timing                = timing;
exp_param.param_show_oneTrial.nblocks               = nblocks;


%% start trial sequence

% the results will be saved in the table Trials
Trials = table;
actual_timing_table = table;

% start the look over the trials (note that a copy of the results is saved
% at each trial)
for trial=1:ntrials
    
    % select a trial
    this_trial = trials_sequence(trial, :);
    
    % show the selected trial
    [Trials, actual_timing_table] = prototypes_show_oneTrial(Trials, this_trial, exp_param, actual_timing_table);
end


%% operation to do at the end of the session

% get the experiment duration
experiment_dur                                  = GetSecs - Trials.experiment_start(end);
exp_param.experiment_dur_sec                    = experiment_dur;
exp_param.day                                   = date;

formatOut                                       = 'yyyymmdd';daystr=datestr(now,formatOut);
formatOut                                       = 'HHMM';timestr=datestr(now,formatOut);
Trials.Properties.UserData.folder_output        = fullfile(project_dir, 'results', sprintf('sub%02d', unique(Trials.subj_id)));
Trials.Properties.UserData.fname_output         = sprintf('res_S%02d_nDots%d_%s_%s', unique(Trials.subj_id), nDots, daystr, timestr);
Trials.Properties.UserData.fname_TrialList      = fname_TrialList;
Trials.Properties.UserData.experiment_dur_sec   = experiment_dur;
Trials.Properties.UserData.day                  = date;
Trials.Properties.UserData.expEnded             = datestr(datetime('now'));


% save the data (besides the backup copy)
prototypes_save_data(Trials, 'noSimMap');

% close the ptb window
WaitSecs(1);
ptb_close_window;

% compute the experimental duration
hr = floor(experiment_dur/60/60);
mi = floor(experiment_dur/60)-hr*60;
fprintf('the experiment lasted %d hour and %d min\n', hr, mi);


% %% plot results
% Trials.Properties.UserData.StimulusType='Circle';
% Trials.Properties.UserData.Rectangle=[0 0 500 500];
% subNum = unique(Trials.subj_id);
% % =========================================================================
% % response dots with actual dots
% % =========================================================================
% figure; prototypes_plot_Resp(Trials);
% prototypes_save_plot('Resp', Trials, exp_param);
% 
% % =========================================================================
% % error vectors
% % =========================================================================
% figure; prototypes_plot_errorVectors(Trials)
% prototypes_save_plot('Quiver', Trials, exp_param);
% 

%% compute_cosine similarity
alphavalue = 10;
Trials = prototypes_compute_cosine_map(Trials, alphavalue);
prototypes_save_data(Trials);
figure; prototypes_plot_cosineMap(Trials)
prototypes_save_plot('SimMap', Trials, exp_param);


