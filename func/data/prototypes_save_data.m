function prototypes_save_data(Trials, appendInfo)
% function prototypes_save_data(Trials, appendInfo)

if ~exist('appendInfo', 'var');appendInfo=[]; end

% if isnumeric(Trials.subj_id)
if strcmp(Trials.Properties.UserData.data_level, 'subject')
    prototypes_save_data_subj(Trials, appendInfo);
else
    prototypes_save_data_group(Trials, appendInfo);
end

function prototypes_save_data_subj(Trials, appendInfo)

subjNum         = unique(Trials.subj_id);
folder_subject  = Trials.Properties.UserData.folder_output;
if ~isfolder(folder_subject); mkdir(folder_subject);end

fname_output = Trials.Properties.UserData.fname_output;
fname_output = strrep(fname_output, '.mat', '');

if isfield(Trials.Properties.UserData, 'cosine_map') && ~contains(fname_output, '_withCSI')
    fname_output = strcat(fname_output, '_withCSI');
end

if ~isempty(appendInfo); fname_output = strcat(fname_output, '_', appendInfo);end

save(fullfile(folder_subject, fname_output), 'Trials');

fprintf('Data saved in %s\n', folder_subject);
fprintf('filename: %s\n', fname_output);


function prototypes_save_data_group(Trials, appendInfo)

folder_subject  = Trials.Properties.UserData.folder_output;
%check_existance_directories(folder_subject, 1);
if ~isfolder(folder_subject); mkdir(folder_subject);end

fname_output = Trials.Properties.UserData.fname_output;

if isfield(Trials.Properties.UserData, 'cosine_map') && ~contains(fname_output, 'niter')
    
    if isfield(Trials.Properties.UserData.cosine_map, 'puncorr') & ~isempty(Trials.Properties.UserData.cosine_map.puncorr)
        puncorr = Trials.Properties.UserData.cosine_map.puncorr;
        fname_output = sprintf('%s_puncorr%s', fname_output, strrep(num2str(puncorr), '0.', ''));
    end
    
    if isfield(Trials.Properties.UserData.cosine_map, 'montecarlo_info')        
        cluster_stat = Trials.Properties.UserData.cosine_map.montecarlo_info.cluster_stat;
        niter = Trials.Properties.UserData.cosine_map.montecarlo_info.niter;
        fname_output = sprintf('%s_%s_niter%d', fname_output, cluster_stat, niter);
    end
end

if ~isempty(appendInfo); fname_output = strcat(fname_output, '_', appendInfo);end

save (fullfile(folder_subject, fname_output), 'Trials');
fprintf('Data saved in %s\n', folder_subject);
fprintf('filename: %s\n', fname_output);
