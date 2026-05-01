function [subj_id, block_id, trial_id, dot_id] = get_imgInfo(fname)

imgInfo = regexp(fname, '_', 'split');

trial_id    = str2double(cell2mat(regexp(imgInfo{4}, '\d{1,3}', 'match')));
block_id    = str2double(cell2mat(regexp(imgInfo{3}, '\d{1,3}', 'match')));
dot_id      = str2double(cell2mat(regexp(imgInfo{5}, '\d{1,3}', 'match')));
subj_id     = imgInfo{1};