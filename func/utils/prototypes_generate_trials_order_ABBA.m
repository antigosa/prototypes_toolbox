function trials_sequence = prototypes_generate_trials_order_ABBA(subjInfo, exp_param)
% function trials_sequence = prototypes_generate_trials_order_ABBA(subjInfo, exp_param)
%
% Organise trials into 4 blocks according to the ABBA rule. This means that
% you need at least two conditions to run this. 
%
% IMPORTANT: 
%  - The number of trials must be divisible by 4. 
%  - It is assumed that the first n dots are for condition A and the other
%    n+1 dots are for condition B
%
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
load(fname_TrialList, 'dot_id', 'screen_height_px', 'screen_width_px', 'shape_height', 'shape_width', 'xy');

% get info from the file name
grid_info           = regexp(fname_TrialList, '_', 'split');
imsize              = grid_info{2};imsize=strrep(imsize, 'imsize', '');
imsize              = str2double(regexp(imsize, 'x', 'split'));
ndots               = grid_info{3};ndots=str2double(strrep(ndots, 'ndots', ''));
nblocks             = grid_info{4};nblocks=str2double(strrep(nblocks, 'nblocks', ''));
offset              = grid_info{5};offset=str2double(strrep(offset, 'offset', ''));
RectHeight          = imsize(1);
RectWidth           = imsize(2);

% get the dots for the practise
npractice           = 5;
xy_practice         = xy(random('unid', size(xy,1), 1,npractice), :);           %#ok<NODEF>

% get the number of trials/dots
ntrials = size(xy,1);


% =========================================================================
% prepare the dots divided in blocks
% =========================================================================
% distribute the dots randomly in the various blocks
% NOTE THIS IS ONLY VALID WITH 200 DOTS AND TWO CONDITIONS!!

n = 100;

block_A         = repmat([1 4], n/2,1);
block_B         = repmat([2 3], n/2,1);

dots_id_A       = dot_id(1:n);
dots_id_B       = dot_id(n+(1:n));


ActualDots_xy_A = [dots_id_A xy(1:100,:)];
ActualDots_xy_B = [dots_id_B xy(101:200,:)];


idx_A           = randperm(length(dots_id_A));
idx_B           = randperm(length(dots_id_B));

ActualDots_xy_A = [ActualDots_xy_A(idx_A,:) block_A(:)];
ActualDots_xy_B = [ActualDots_xy_B(idx_B,:) block_B(:)];

ActualDots_xy_A = [array2table(ActualDots_xy_A(:,1), 'VariableNames', {'dot_id'}) table(ActualDots_xy_A(:,[2 3]), 'VariableNames', {'ActualDots_xy'}) array2table(ActualDots_xy_A(:,4), 'VariableNames', {'blocks_id'})];
ActualDots_xy_B = [array2table(ActualDots_xy_B(:,1), 'VariableNames', {'dot_id'}) table(ActualDots_xy_B(:,[2 3]), 'VariableNames', {'ActualDots_xy'}) array2table(ActualDots_xy_B(:,4), 'VariableNames', {'blocks_id'})];

Practise_Table  = [array2table(zeros(npractice,1), 'VariableNames', {'dot_id'}) table(xy_practice, 'VariableNames', {'ActualDots_xy'}) array2table(zeros(npractice,1), 'VariableNames', {'blocks_id'})];

% Reorganise the blocks
ActualDots_xy_blocks{1} = ActualDots_xy_A(1:n/2,:);
ActualDots_xy_blocks{4} = ActualDots_xy_A(n/2+(1:n/2),:);
ActualDots_xy_blocks{2} = ActualDots_xy_B(1:n/2,:);
ActualDots_xy_blocks{3} = ActualDots_xy_B(n/2+(1:n/2),:);

tmp = sortrows(vertcat(ActualDots_xy_blocks{:}), {'dot_id', 'blocks_id'}); tmp = tmp(:, {'dot_id', 'blocks_id'});


% get number of trials per block
ntrialsXblock = size(ActualDots_xy_blocks{1},1);

% create the blocks
block_names = {'blockA1', 'blockA2', 'blockB3', 'blockB4'}; %, 'block5'};


% here you can decide if you want to have the shape presented in different
% part of the screen, like in the four subquadrants, or in the center, etc.
% You have to set Rectcoord_FIRST and Rectcoord_SECOND accordingly. In this
% case, each block shows the shape in a different quadrant
quadrant_order      = Shuffle({'all_screen','all_screen','all_screen','all_screen'});
quadrant_sequence   = [];
Rectcoord_FIRST     = []; Rectcoord_SECOND = [];
for b = 1:nblocks
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
                rect_lim    = [1 1 screen_width_px screen_height_px]; % bottom-right
            else
                rect_lim    = [screen_x0_px screen_y0_px screen_width_px screen_height_px]; % bottom-right
            end
            
    end
    
    Rectcoord_FIRST         = [Rectcoord_FIRST; prototypes_randomise_location(shape_width, shape_height, rect_lim, ntrialsXblock)];
    Rectcoord_SECOND        = [Rectcoord_SECOND; prototypes_randomise_location(shape_width, shape_height, rect_lim, ntrialsXblock)];
    quadrant_sequence       = [quadrant_sequence;cellstr(repmat(quadrant_order{b}, ntrialsXblock, 1))];
end

Rectcoord_FIRST_Pract       = prototypes_randomise_location(shape_width, shape_height, rect_lim, size(xy_practice,1));
Rectcoord_SECOND_Pract      = prototypes_randomise_location(shape_width, shape_height, rect_lim, size(xy_practice,1));
quadrant_sequence_pract     = cellstr(repmat('all_screen', size(xy_practice,1), 1));

% =========================================================================
% complete the preparation for the colums
% =========================================================================
% it mostly means repeating the value for the number of rows the table
% has
ActualDots_xy           = vertcat(Practise_Table, ActualDots_xy_blocks{1,:});
nrows                   = size(ActualDots_xy,1);
trials_id               = vertcat(zeros(size(xy_practice,1),1), (1:size(xy,1))');
subj_id                 = repmat({subjInfo.subjNum}, nrows, 1);
age                     = repmat(subjInfo.Age, nrows, 1);
gender                  = repmat({subjInfo.Gender}, nrows, 1);
hand_preference         = repmat({subjInfo.HandPref}, nrows, 1);
run_fast                = repmat(run_fast, nrows, 1);
run_test                = repmat(run_test, nrows, 1);
stimulus_type           = repmat(stimulus_type, nrows, 1);
use_image               = repmat(use_image, nrows, 1);
RectHeight              = repmat(RectHeight, nrows, 1);
RectWidth               = repmat(RectWidth, nrows, 1);
RectCol                 = repmat(shape_color, nrows, 1);
target_color            = repmat(target_color, nrows, 1);
rotAngle                = repmat(rot_angle, nrows, 1);

Rectcoord_FIRST         = [Rectcoord_FIRST_Pract;Rectcoord_FIRST];
Rectcoord_SECOND        = [Rectcoord_SECOND_Pract;Rectcoord_SECOND];
quadrant_sequence       = [quadrant_sequence_pract;quadrant_sequence];

%breaks_id = zeros(ndots,1);
breaks_id = zeros(size(ActualDots_xy,1),1);

% =========================================================================
% create the table
% =========================================================================
trials_sequence = [table(subj_id, age, gender, hand_preference, trials_id, breaks_id), ActualDots_xy, table(RectHeight, RectWidth, ...
    quadrant_sequence, Rectcoord_FIRST, Rectcoord_SECOND, stimulus_type, RectCol, target_color, rotAngle, use_image, run_test, run_fast)];

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
