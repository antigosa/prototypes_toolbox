function [corr_with_group_mean_cond1, corr_with_group_mean_cond2] = within_between_similarity(img1, img2, analtype)
% function [corr_with_group_mean_cond1, corr_with_group_mean_cond2] = within_between_similarity(img1, img2, analtype)
% 
% Paired Comparison and Group Validation analyses
%
% Condition 1: img1
% Condition 2: img2
%
% -- Within-Subject Correlation (Paired Comparison) --
% This analysis computes the correlation between two distinct representation 
% maps (Condition 1 Map and Condition 2 Map) for each participant. 
% This is a paired, or dependent, correlation since both maps belong to the same subject.
%
% -- Across-Subject Correlation (Group Validation) --
% This analysis employs a Leave-One-Subject-Out (LOSO) cross-validation scheme
% to test the generalizability of the group map.
%
% In both of the following scenarios, one subject is withheld before the group map is estimated:
% 1. Within-Condition Validation: The withheld subject's Condition 1 Map 
%    is correlated with the group Map 1 estimated from the remaining N-1 subjects. 
%    (Repeated for Condition 2).
% 2. Across-Condition Validation: The withheld subject's Map A is 
%    correlated with the group Map B estimated from the remaining N-1 subjects.
%
% ========================================================================= 
% OUTPUT 
% ========================================================================= 
% corr_with_group_mean_cond1 (IndivCond1_vs_GroupCond2): 
% Each individual Cond1 map is correlated with the group Cond2 map. 
% This tests how well an individual's Cond1 representation is predicted by the group's Cond2 representation.
%
% corr_with_group_mean_cond2 (IndivCond2_vs_GroupCond1): 
% Each individual Cond2 map is correlated with the group Cond1 map. 
% This tests how well an individual's Cond2 representation is predicted by the group's Cond1 representation.

n_subjects = size(img1,3);% Your number of participants;
corr_with_group_mean_cond1 = zeros(n_subjects, 1);
corr_with_group_mean_cond2 = zeros(n_subjects, 1);

% Assuming your patterns are stored in a cell array: all_patterns{participant_index}(condition_index, :)

for i = 1:n_subjects
    
    pattern1_current = reshape(img1(:,:,i), [], 1)';
    pattern2_current = reshape(img2(:,:,i), [], 1)';
    
    % Calculate mean of others for condition 1
    other_patterns_cond1 = [];
    for j = 1:n_subjects
        if j ~= i
            switch analtype
                case 'within-conditions'
                    other_patterns_cond1 = [other_patterns_cond1; reshape(img1(:,:,j), [], 1)'];
                case 'between-conditions'
                    other_patterns_cond1 = [other_patterns_cond1; reshape(img2(:,:,j), [], 1)'];
            end
        end
    end
    mean_pattern_cond1_others = mean(other_patterns_cond1, 1);
    corr_group1 = corrcoef(pattern1_current', mean_pattern_cond1_others');
    corr_with_group_mean_cond1(i) = corr_group1(1, 2);
    
    % Calculate mean of others for condition 2
    other_patterns_cond2 = [];
    for j = 1:n_subjects
        if j ~= i
            switch analtype
                case 'within-conditions'
                    other_patterns_cond2 = [other_patterns_cond2; reshape(img2(:,:,j), [], 1)'];
                case 'between-conditions'
                    other_patterns_cond2 = [other_patterns_cond2; reshape(img1(:,:,j), [], 1)'];
            end
        end
    end
    mean_pattern_cond2_others = mean(other_patterns_cond2, 1);
    corr_group2 = corrcoef(pattern2_current', mean_pattern_cond2_others');
    corr_with_group_mean_cond2(i) = corr_group2(1, 2);
end

disp('Correlation with group mean (Condition 1):');
disp(corr_with_group_mean_cond1);
disp('Correlation with group mean (Condition 2):');
disp(corr_with_group_mean_cond2);

% Now you can compare within_subject_correlations with these new measures