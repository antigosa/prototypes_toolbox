function [T_summary, T_demo, T_nTrialsXpart] = prototypes_summary(T_in, opt)

if nargin<2
    opt = [];
end
if ~isfield(opt, 'verbose'); opt.verbose = 1;end
if~isfield(opt, 'group_by'); opt.group_by = [];end

if ischar(opt.group_by)
    opt.group_by = cellstr(opt.group_by);
end

if isempty(opt.group_by)
    T_in.Group(:) = {'P'};
    opt.group_by = {'Group'};
end

% 2. Find Groups based on the combination of 'Gender' and 'City'
[G, UniqueGroups] = findgroups(T_in(:, opt.group_by));

% 3. Split the Table
Index = (1:height(T_in))';
SplitTables = splitapply(@(idx) {T_in(idx,:)}, Index, G);


varnames = UniqueGroups.Properties.VariableNames;
for i = 1:length(SplitTables)
    [T_summary{i}, T_demo{i}, T_nTrialsXpart{i}] = prototypes_summary_helper(SplitTables{i}, opt);

    for j = 1:length(varnames)
        T_summary{i}.(varnames{j}) = UniqueGroups.(varnames{j})(i);
        T_demo{i}.(varnames{j}) = repmat(UniqueGroups.(varnames{j})(i), size(T_demo{i}, 1), 1);
        T_nTrialsXpart{i}.(varnames{j}) = repmat(UniqueGroups.(varnames{j})(i), size(T_demo{i}, 1), 1);
    end
end

T_summary = vertcat(T_summary{:});
T_demo = vertcat(T_demo{:});
T_nTrialsXpart = vertcat(T_nTrialsXpart{:});




function [T_summary, T_demo, T_nTrialsXpart] = prototypes_summary_helper(T_in, opt)

verbose     = opt.verbose;
group_by    = opt.group_by;

T_Unique = unique(T_in(:, horzcat(group_by, {'subj_id', 'trials_id'})), 'rows');

T_nTrialsXpart = groupcounts(T_Unique, horzcat(group_by, {'subj_id'}));
T_nTrialsXpart.Properties.VariableNames{strcmp(T_nTrialsXpart.Properties.VariableNames, 'GroupCount')} = 'N_trials';



nTrials_mean = groupsummary(T_nTrialsXpart, group_by, {'mean', 'std'}, 'N_trials');
nTrials_mean = nTrials_mean.mean_N_trials;

% T_demo = unique(T_in(:, {'subj_id', 'age', 'gender', 'hand_preference'}));
T_demo = unique(T_in(:, horzcat(group_by, {'subj_id', 'age', 'gender', 'hand_preference'})));


% nTrials_mean = groupsummary(T_demo, group_by2, {'mean', 'std'}, 'age');


% nTrials_count = groupcounts(T_demo, 'gender');

N = size(T_demo,1);

Age_mean    = mean(T_demo.age);
Age_std     = std(T_demo.age);

n_men       = sum(strcmp(T_demo.gender, 'M'));
n_women     = sum(strcmp(T_demo.gender, 'F'));

n_rightHand = sum(strcmp(T_demo.hand_preference, 'rh'));
n_leftHand  = sum(strcmp(T_demo.hand_preference, 'lh'));

T_summary = table(N, Age_mean, Age_std, n_men, n_women, n_rightHand, n_leftHand, nTrials_mean);

if verbose
    disp(T_summary)
end
