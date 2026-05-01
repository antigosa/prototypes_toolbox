root_dir        = 'D:\Projects\Spatial cognition\Prototypes_Haptic';
toolbox_dir     = 'D:\Programs\toolbox\';

% root_dir        = 'C:\Users\rt03\Students\Birkbeck\2023_2024\Masters Projects (Conversion)\Heloise Walker';
% toolbox_dir     = 'C:\Users\rt03\Students\Birkbeck\2023_2024\Masters Projects (Conversion)\Heloise Walker\Toolboxes';

addpath(genpath(fullfile(toolbox_dir, 'prototypes_toolbox')));
addpath(genpath(fullfile(toolbox_dir, 'shadedErrorBar')));
addpath(genpath(fullfile(root_dir, 'func')));

expName = 'exp0102';

res_dir         = fullfile(root_dir, 'results', expName);
data_dir        = fullfile(root_dir, 'data', expName);
origdata_dir    = fullfile(data_dir, 'orig');
preprocdata_dir = fullfile(data_dir, 'preproc');
csidata_dir     = fullfile(data_dir, 'csimaps');
stats_dir       = fullfile(data_dir, 'stats');

if ~isfolder(origdata_dir); mkdir(origdata_dir);end
if ~isfolder(preprocdata_dir); mkdir(preprocdata_dir);end
if ~isfolder(csidata_dir); mkdir(csidata_dir);end
if ~isfolder(stats_dir); mkdir(stats_dir);end

dir_subjects = dir(fullfile(res_dir));
dir_subjects(~vertcat(dir_subjects(:).isdir))=[];
dir_subjects = {dir_subjects(:).name}';
dir_subjects = dir_subjects(3:end);

switch expName
    case 'exp01'
        dir_subjects(ismember(dir_subjects, {'sub-S001_block-1_order-HV', 'sub-S099_order-HV', 'sub-S100_order-HV', 'sub-S100_order-VH', 'sub-S006_order-HV - incomplete!'}))=[];
        
    case 'exp02'
        % exclude 'sub-S0011B_order-HV' for now. Denise realised that
        % for subject S011 the camera was not ok in block 4. So, she
        % repeated the experiment and collected only one block. The problem
        % is that dots are taken randomly, so the participant likely did
        % the same dots again.
        dir_subjects(ismember(dir_subjects, {'sub-S011_order-VH', 'sub-S0011B_order-HV'}))=[];
end
        