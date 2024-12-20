function [trials_sequence, timing] = prototypes_set_timing(grid_file, trials_sequence, timing)
% function [trials_sequence, timing] = prototypes_set_timing(grid_file, trials_sequence, timing)

trials_sequence_tmp = trials_sequence(trials_sequence.trials_id>0,:);
% =========================================================================
% define the time of the various event types
% =========================================================================
runFast = trials_sequence_tmp.run_fast(1);
if runFast
    
    % this is just used for testing
    timing.ITI_duration     = 0.001;
    timing.rect1_duration   = 0.001;
    timing.dot_duration     = 0.001;
    timing.blank            = 0.001;
    timing.locate_dots      = 0.001;
    
else
    
    if nargin<3
        % this is the real timing
        %     timing.ITI_duration     = 1;
        %     timing.rect1_duration   = 0.1;
        %     timing.dot_duration     = 0.4;
        %     timing.blank            = 1;
        %     timing.locate_dots      = 2;
        
        % Typical timing
        timing.ITI_duration     = 1;
        timing.rect1_duration   = 1;
        timing.dot_duration     = 1;
        timing.blank            = 1;
        timing.locate_dots      = 2;
    end
    
end
% timing.rate_performance = 3;

% =========================================================================
% Add timing to the sequence
% =========================================================================
event_names = fieldnames(timing);

nrows = size(trials_sequence,1);
for e=1:length(event_names)
    trials_sequence.(event_names{e}) = repmat(timing.(event_names{e}), nrows, 1);
end





% =========================================================================
% compute and show the experiment duration
% =========================================================================
trial_duration = 0;

for e=1:length(event_names)
    trial_duration = trial_duration+timing.(event_names{e});
end

fprintf ('A trial might last around %.02f seconds\n', trial_duration);


trial_list_fname = grid_file; %'TrialList_grid324_offset2';% 'TrialList_grid300_offset8'; % 'TrialList'
load(trial_list_fname);
block_list          = unique(trials_sequence_tmp.blocks_id);block_list(block_list==0)=[];
n_blocks             = length(block_list);
n_trials = size(trials_sequence_tmp, 1)/n_blocks;

tot_time = trial_duration*n_trials*n_blocks;
fprintf ('There are %d trials per %d blocks, so the experiment will last at least %.02f seconds', n_trials, n_blocks, tot_time);
tot_time_hour = floor(tot_time/60/60);
tot_time_min = floor(tot_time/60);
tot_time_sec = round(60*(tot_time/60-floor(tot_time/60)));
fprintf ('(%d h %d m %d s)\n', tot_time_hour, tot_time_min, tot_time_sec);