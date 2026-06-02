function d = prototypes_load_data(fname, fullname_output)
% function d = prototypes_load_data(fname, fullname_output)
%
% if you provide fullname_output, the folder and fname of the dataset will
% be updated. 
%
% rt 02 May 2026
% THIS IS AN OLD FUNCTION THAT I USED IN THE PAST. NOT SURE I NEED IT, BUT
% I WILL KEEP IT FOR COMPATIBILITY (e.g., prototypes_eyeTracker).


if isfolder(fname)
    d = prototypes_load_data_dir(fname);
    if exist('fullname_output', 'var') && ~isempty(fullname_output)
        [data_folder, data_fname, ~] = fileparts(fullname_output);
        d.Properties.UserData.folder_output = data_folder;
        d.Properties.UserData.fname_output = data_fname;
    end
%     prototypes_check_prototable(d);
    return;
end


if ischar(fname)
%     check_existance_files(fname);
    if ~isfile(fname); error('The file does not exist');end
    load(fname);
    d=Trials;

    % check if the file name in the table is correct
    [data_folder, data_fname, ~] = fileparts(fname);
    
    if ~isempty(d.Properties.UserData)
    
        if ~strcmp(d.Properties.UserData.folder_output, data_folder)
            warning('something wrong with the data folder stored in the table, I will update the field, have a look if it is ok now');
            d.Properties.UserData.folder_output = data_folder;
        end

        if ~strcmp(d.Properties.UserData.fname_output, data_fname)
            warning('something wrong with the data fname stored in the table, I will update the field, have a look if it is ok now');
            d.Properties.UserData.fname_output = data_fname;
        end
        
    else
        d.Properties.UserData.folder_output = data_folder;
        d.Properties.UserData.fname_output = data_fname;
        
    end


    
elseif istable(fname)        
    folder_output   = groupStat.Properties.UserData.folder_output;
    fname_output    = groupStat.Properties.UserData.fname_output;
    fname           = fullfile(folder_output, fname_output);
    load(fname);
    d=Trials;    
end

if exist('fullname_output', 'var') && ~isempty(fullname_output)
    [data_folder, data_fname, ~] = fileparts(fullname_output);
    d.Properties.UserData.folder_output = data_folder;
    d.Properties.UserData.fname_output = data_fname;    
end

% add this in future versions
% prototypes_check_prototable(d);

function d = prototypes_load_data_dir(fname)

% files must be subjects, starting with S
pathToHere = pwd;
cd(fname);

fnames = dir('S*');

for f = 1:length(fnames)
   load(fnames(f).name)
   
   TrialsCell{f} = Trials;
    
end

d = prototypes_stack(TrialsCell, 1);
cd(pathToHere);