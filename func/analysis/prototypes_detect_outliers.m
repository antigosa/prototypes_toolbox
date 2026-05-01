function [ProtoTable, T_details, T_summary] = prototypes_detect_outliers(ProtoTable, opt)
% function [ProtoTable, T_details, T_summary] = prototypes_detect_outliers(ProtoTable, opt)

if nargin < 2
    opt.sd = 3; % Default standard deviation for outlier detection
    opt.removeOutliers = 0; % Do not remove outliers by default
end


subj_id     = unique(ProtoTable.subj_id);
nsubj       = length(subj_id);

ProtoTable.Outlier(:) = 0;
noutliers = zeros(1, nsubj);
for i = 1:nsubj
    currentSubjData = ProtoTable(ProtoTable.subj_id == subj_id(i), :);
    meanValue       = mean(currentSubjData.errorMag);
    stdValue        = std(currentSubjData.errorMag);
    outlierThreshold = meanValue + opt.sd * stdValue;

    ProtoTable(ProtoTable.subj_id == subj_id(i), 'Outlier') = ProtoTable(ProtoTable.subj_id == subj_id(i), 'errorMag') > outlierThreshold;
    noutliers(i) = sum(ProtoTable.Outlier(ProtoTable.subj_id == subj_id(i)));
end

fprintf('Detected %d outliers across all participants\n', sum(noutliers))
disp(noutliers)

[~, ~, T_nTrialsXpart_pre] = prototypes_summary(ProtoTable, struct('verbose', 0));

if opt.removeOutliers
    fprintf('Outliers removed from the dataset\n')
    ProtoTable(ProtoTable.Outlier==1,:) = [];
end

[~, ~, T_nTrialsXpart_post] = prototypes_summary(ProtoTable, struct('verbose', 0));

T_nTrialsXpart_pre.Properties.VariableNames(ismember(T_nTrialsXpart_pre.Properties.VariableNames, {'N_trials', 'Percent'})) = {'N_trials_orig', 'Percent_orig'};

T_details = outerjoin(T_nTrialsXpart_pre, T_nTrialsXpart_post, 'Type', 'left', 'Keys', 'subj_id', 'MergeKeys', true);
T_details.Removed = T_details.N_trials_orig - T_details.N_trials;
T_summary = groupsummary(T_details, [], {'sum', 'mean'}, 'Removed');

disp(T_details);
disp(T_summary);