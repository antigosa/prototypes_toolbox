function trials_sequence = prototypes_generate_trials_order(project_path, subjInfo, exp_param)
% function trials_sequence = prototypes_generate_trials_order(project_path, subjInfo, exp_param)
%
%%% NOTE THIS IS ONLY VALID WITH 200 DOTS AND TWO CONDITIONS!!%%%%%%%

% =========================================================================
% gather parameters
% =========================================================================
subjNum             = subjInfo.subjNum;
fname_TrialList     = exp_param.metadata.fname_TrialList;
run_fast            = exp_param.metadata.runFast;
run_test            = exp_param.metadata.runTest;
stimulus_type       = exp_param.metadata.stimulusType;
use_image           = exp_param.metadata.useImage;
shape_color         = exp_param.metadata.shape_color;
target_color        = exp_param.metadata.target_color;
rot_angle           = exp_param.metadata.rot_angle;
blocks_order        = exp_param.design.blocks_order;
nrep                = exp_param.design.nrep; % each location

% =========================================================================
%Configure random number generator
% =========================================================================
configure_random_number_generator;

% =========================================================================
% prepare the output folder and the output filename
% =========================================================================
folder_subject  = subjInfo.folder; %   fullfile(project_path, 'results', sprintf('sub%02d', subjNum));
fname           = make_subject_file(folder_subject, subjNum);


% =========================================================================
% START THE GENERATION OF THE TRIAL SEQUENCE
% =========================================================================
fprintf('\n========================================================================================\n');
fprintf('generating the trial sequence for subject %s...', subjNum);

% =========================================================================
% dot positions
% =========================================================================
% load dots position (it contains xy, shape_width, shape_height)
load(fname_TrialList);

% get info from the file name
grid_info           = split_StringPairs(fname_TrialList);

imsize              = grid_info.imsize;
imsize              = str2double(regexp(imsize, 'x', 'split'));
ndots               = str2double(grid_info.ndots);
nblocks             = str2double(grid_info.nblocks);
offset              = str2double(grid_info.offset);
RectHeight          = imsize(1);
RectWidth           = imsize(2);

% get the dots for the practise
xy_practice         = xy(random('unid', size(xy,1), 1,5), :);           %#ok<NODEF>
ActualDots_xy       = xy;

% nrep=2;
% dot_id=(1:200)';

ActualDots_xy   = repmat(ActualDots_xy, nrep,1);
dot_id          = repmat(dot_id, nrep,1);

% get the number of trials/dots
ntrials         = size(ActualDots_xy,1);
block_type      = reshape(repmat(unique(blocks_order), ntrials/nrep, 1),[], 1);

block_names = unique(blocks_order);

D_tmp = table(dot_id, ActualDots_xy, block_type);

for i=1:length(block_names)
    
    D_tmp2 = D_tmp(strcmp(D_tmp.block_type, block_names{i}), :);
    
    nrows = height(D_tmp2);
    
    D_tmp(strcmp(D_tmp.block_type, block_names{i}), :)=D_tmp2(randsample(nrows, nrows, false),:);
    
end

dot_id          = D_tmp.dot_id;
ActualDots_xy   = D_tmp.ActualDots_xy;


% =========================================================================
% start preparing the various columns of the table
% =========================================================================
% trial id
trials_id = (1:size(ActualDots_xy,1))';

% block id
blocks_id = repmat(1:nblocks, ntrials/nblocks,1);blocks_id=blocks_id(:);

% table(trials_id, D_tmp.dot_id, D_tmp.ActualDots_xy, D_tmp.block_type, blocks_id)

% =========================================================================
% prepare the dots divided in blocks
% =========================================================================
trials_id_blocks = reshape(trials_id, [ntrials/nblocks, nblocks]);

% get number of trials per block
ntrialsXblock = size(trials_id_blocks,1);

ActualDots_xy_blocks    = cell(3, nblocks); % +1 because of practise

% create the blocks
block_names = {'A1', 'A2', 'B1', 'B2'}; %, 'block5'};

% here you can decide if you want to have the shape presented in different
% part of the screen, like in the four subquadrants, or in the center, etc.
% You have to set Rectcoord_FIRST and Rectcoord_SECOND accordingly. In this
% case, each block shows the shape in a different quadrant
quadrant_order = Shuffle({'all_screen','all_screen','all_screen','all_screen'});
quadrant_sequence = [];
Rectcoord_FIRST = []; Rectcoord_SECOND = [];
for b = 1:nblocks
    cur_trials_id = trials_id_blocks(:,b);
    ActualDots_xy_blocks{1,b} = block_names{b};
    ActualDots_xy_blocks{2,b} = ActualDots_xy(cur_trials_id,:);
    ActualDots_xy_blocks{3,b} = dot_id(cur_trials_id,:);
    
    switch quadrant_order{b}
        case 'top_left'
            rect_lim        = [1 1 screen_width_px/2 screen_height_px/2]; % top-left
        case 'top_right'
            rect_lim        = [screen_width_px/2 1 screen_width_px screen_height_px/2]; % top-right
        case 'bottom_left'
            rect_lim        = [1 screen_height_px/2 screen_width_px/2 screen_height_px]; % bottom-left
        case 'bottom_right'
            rect_lim        = [screen_width_px/2 screen_height_px/2 screen_width_px screen_height_px]; % bottom-right
        case 'all_screen'
            rect_lim        = [1 1 screen_width_px screen_height_px]; % bottom-right
            % TEMPORARY!!!!
            if ~exist('screen_x0_px', 'var')
                rect_lim                    = [1 1 screen_width_px screen_height_px]; % bottom-right
            else
                rect_lim                    = [screen_x0_px screen_y0_px screen_width_px screen_height_px]; % bottom-right
            end
            
    end
    

    Rectcoord_FIRST         = [Rectcoord_FIRST; prototypes_randomise_location(shape_width, shape_height, rect_lim, ntrialsXblock)];
    Rectcoord_SECOND        = [Rectcoord_SECOND; prototypes_randomise_location(shape_width, shape_height, rect_lim, ntrialsXblock)];
    quadrant_sequence       = [quadrant_sequence;cellstr(repmat(quadrant_order{b}, ntrialsXblock, 1))];
end

% prepare the same information for the practise (will be concatenated later
% to the main table. 

% if ~exist('screen_x0_px', 'var')
%     rect_lim                    = [1 1 screen_width_px screen_height_px]; % bottom-right
% else
%     rect_lim                    = [screen_x0_px screen_y0_px screen_width_px screen_height_px]; % bottom-right
% end

if(strcmp(horzcat(blocks_order{:}), 'ABBA'))
    ActualDots_xy_blocks=ActualDots_xy_blocks(:, [1 3 4 2]);
end

Rectcoord_FIRST_Pract       = prototypes_randomise_location(shape_width, shape_height, rect_lim, size(xy_practice,1));
Rectcoord_SECOND_Pract      = prototypes_randomise_location(shape_width, shape_height, rect_lim, size(xy_practice,1));
quadrant_sequence_pract     = cellstr(repmat('all_screen', size(xy_practice,1), 1));

% =========================================================================
% complete the preparation for the colums
% =========================================================================
% it mostly means repeating the value for the number of rows the table
% has

% do this before modifying ActualDots_xy_blocks
block_type  = reshape(repmat(horzcat(ActualDots_xy_blocks(1,:)), length(blocks_id)/length(blocks_order), 1), [], 1);
dot_id      = reshape(horzcat(ActualDots_xy_blocks{3,:}), [], 1);



ActualDots_xy_blocks    = horzcat({'practise';xy_practice;[0 0 0 0 0]'}, ActualDots_xy_blocks);
trials_id               = vertcat(zeros(size(xy_practice,1),1), trials_id);
blocks_id               = vertcat(zeros(size(xy_practice,1),1), blocks_id);
dot_id                  = vertcat(zeros(size(xy_practice,1),1), dot_id);
block_type              = vertcat(cell(size(xy_practice,1),1), block_type);
subj_id                 = repmat({subjInfo.subjNum}, length(blocks_id), 1);
age                     = repmat(subjInfo.Age, length(blocks_id), 1);
gender                  = repmat({subjInfo.Gender}, length(blocks_id), 1);
hand_preference         = repmat({subjInfo.HandPref}, length(blocks_id), 1);
ActualDots_xy           = vertcat(ActualDots_xy_blocks{2,:});
run_fast                = repmat(run_fast, length(blocks_id), 1);
run_test                = repmat(run_test, length(blocks_id), 1);
stimulus_type           = repmat(stimulus_type, length(blocks_id), 1);
use_image               = repmat(use_image, length(blocks_id), 1);
RectHeight              = repmat(RectHeight, length(blocks_id), 1);
RectWidth               = repmat(RectWidth, length(blocks_id), 1);
RectCol                 = repmat(shape_color, length(blocks_id), 1);
target_color            = repmat(target_color, length(blocks_id), 1);
rotAngle                = repmat(rot_angle, length(blocks_id), 1);

Rectcoord_FIRST         = [Rectcoord_FIRST_Pract;Rectcoord_FIRST];
Rectcoord_SECOND        = [Rectcoord_SECOND_Pract;Rectcoord_SECOND];
quadrant_sequence       = [quadrant_sequence_pract;quadrant_sequence];

% here you can decide where to put the breaks. Breaks are at the end of
% each block for now, but this can be different
% breaks_id = mod(trials_id, ntrialsXblock+1);breaks_id(trials_id==0)=-1;breaks_id(breaks_id~=0)=-1;
% breaks_id(breaks_id==0)=1;breaks_id(breaks_id==-1)=0;breaks_id(end) = 2;
ntrialsXbreak = ndots/2;
npracticeDots = size(xy_practice,1);
%breaks_id = zeros(ndots,1);
breaks_id = zeros(size(ActualDots_xy,1),1);
% idx_breaks = 1:ntrialsXbreak:ndots;idx_breaks=idx_breaks(2:end);
% breaks_id(idx_breaks)=1:length(idx_breaks);
% breaks_id = [zeros(npracticeDots,1); breaks_id];

% =========================================================================
% create the table
% =========================================================================
trials_sequence = table(subj_id, age, gender, hand_preference, trials_id, blocks_id, block_type, breaks_id, dot_id, ActualDots_xy, RectHeight, RectWidth, ...
    quadrant_sequence, Rectcoord_FIRST, Rectcoord_SECOND, stimulus_type, RectCol, target_color, rotAngle, use_image, run_test, run_fast);

% =========================================================================
% save the table
% =========================================================================
save (fullfile(folder_subject, fname),'trials_sequence', 'ActualDots_xy','ActualDots_xy_blocks','ntrials','RectHeight','RectWidth');
fprintf('done!\nI have created %d trials (%d trials for %d blocks)\n', ntrials, ntrialsXblock, nblocks);
fprintf('other info: RectLength %d; RectWidth: %d; nDots: %d; offset: %d\n\n', RectHeight(1), RectWidth(1), ndots, offset);
fprintf('file saved in %s\n', fullfile(folder_subject, fname));
fprintf('========================================================================================\n');

function fname = make_subject_file(folder_subject, subjNum)
%check_existance_directories(folder_subject, 1);
if ~isfolder(folder_subject); mkdir(folder_subject);end
fname = [subjNum '_infoExperiment.mat'];
%fexist=check_existance_files(fullfile(folder_subject, fname),0);
fexist=isfile(fname);
if fexist
    choice = questdlg('experiment information already exists for this subject. Do you want to delete them?', ...
        'Warning!', ...
        'Yes','Load (not working)', 'Exit', 'Yes');
    
    switch choice
        case 'Yes'
            warning('deleting old data...');
            delete(fullfile(folder_subject, fname));
            
        case 'Load' % NOT WORKING
            warning('loading data...');
            infoExperiment = load(fullfile(folder_subject, fname));display(infoExperiment);
            return;
            
        case 'Exit'
            error('you wanted to exit')
            
    end
    
end
