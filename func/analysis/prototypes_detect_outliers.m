function [ProtoTable, T_details, T_summary, ProtoTable_outliers] = prototypes_detect_outliers(ProtoTable, opt)
% function [ProtoTable, T_details, T_summary, ProtoTable_outliers] = prototypes_detect_outliers(ProtoTable, opt)

if nargin < 2;    opt = [];end

if ~isfield(opt, 'sd');opt.sd = 3; end                          % Default standard deviation for outlier detection
if ~isfield(opt, 'removeOutliers');opt.removeOutliers = 0; end  % Do not remove outliers by default
if ~isfield(opt, 'verbose');opt.verbose = 1; end                % Do not remove outliers by default


subj_id     = unique(ProtoTable.subj_id);
nsubj       = length(subj_id);

ProtoTable.Outlier(:) = 0;
noutliers = zeros(nsubj, 1);
ErrorMag_mean = zeros(nsubj, 1);
ErrorMag_std = zeros(nsubj, 1);
ErrorMag_thresh = zeros(nsubj, 1);
for i = 1:nsubj
    
    idx = ismember(ProtoTable.subj_id, subj_id(i));
    currentSubjData     = ProtoTable(idx, :);
    meanValue           = mean(currentSubjData.errorMag);
    stdValue            = std(currentSubjData.errorMag);
    outlierThreshold    = meanValue + opt.sd * stdValue;
    
    ProtoTable.Outlier(idx) = ProtoTable.errorMag(idx) > outlierThreshold;
    noutliers(i)    = sum(ProtoTable.Outlier(idx));
    ErrorMag_mean(i)        = meanValue;
    ErrorMag_std(i)         = stdValue;
    ErrorMag_thresh(i)      = outlierThreshold;
        
end

T = table(subj_id, ErrorMag_mean, ErrorMag_std, ErrorMag_thresh);

fprintf('Detected %d outliers across all participants\n', sum(noutliers))
% disp(noutliers)

[~, ~, T_nTrialsXpart_pre] = prototypes_summary(ProtoTable, struct('verbose', 0));

ProtoTable.Properties.UserData.OutliersRemoved='yes';
ProtoTable.Properties.UserData.OutliersSD=opt.sd;

ProtoTable_clean    = ProtoTable(ProtoTable.Outlier==0,:);
ProtoTable_outliers = ProtoTable(ProtoTable.Outlier==1,:);


[~, ~, T_nTrialsXpart_post] = prototypes_summary(ProtoTable_clean, struct('verbose', 0));

% T_nTrialsXpart_pre.Properties.VariableNames(ismember(T_nTrialsXpart_pre.Properties.VariableNames, {'N_trials', 'Percent'})) = {'N_trials_orig', 'Percent_orig'};
T_nTrialsXpart_pre.Properties.VariableNames(ismember(T_nTrialsXpart_pre.Properties.VariableNames, {'N_trials'})) = {'N_trials_orig'};

T_details = outerjoin(T_nTrialsXpart_pre, T_nTrialsXpart_post, 'Type', 'left', 'Keys', {'subj_id', 'Group'}, 'MergeKeys', true);

if opt.removeOutliers
    T_details.Removed = T_details.N_trials_orig - T_details.N_trials;
    T_details.Removed_pct = T_details.Removed./T_details.N_trials_orig;
    T_summary = groupsummary(T_details, [], {'sum', 'mean'}, 'Removed');
else
    T_details.Detected = T_details.N_trials_orig - T_details.N_trials;
    T_details.Detected_pct = T_details.Detected./T_details.N_trials_orig;
    T_summary = groupsummary(T_details, [], {'sum', 'mean'}, 'Detected');
end

T_details=outerjoin(T_details, T, 'Type', 'left', 'Keys', {'subj_id'}, 'MergeKeys', true);


if opt.removeOutliers
    ProtoTable = ProtoTable_clean;
    fprintf('Outliers removed from the dataset\n')
end

if opt.verbose
    disp(T_details);
    disp(T_summary);
end