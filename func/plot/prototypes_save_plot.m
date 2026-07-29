function prototypes_save_plot(opt)
% function prototypes_save_plot(plotType, Trials, img_type, appendInfo)
% 
% plotType: used to make the name of the image file

if ~exist('img_type', 'var'); img_type='png';end

folder_subject  = Trials.Properties.UserData.folder_output;
% check_existance_directories(folder_subject, 1);
assert(isfolder(folder_subject));

fname_output = Trials.Properties.UserData.fname_output;

[~, fname_output] = fileparts(fname_output);
if isempty(fname_output)
    img_fname = plotType;
else
    img_fname = strcat(fname_output, '_data-', plotType);
end
if exist('appendInfo', 'var') && ~isempty(appendInfo)
    img_fname = strcat(img_fname, '_', appendInfo);
end
img_fname = fullfile(folder_subject, img_fname);

switch img_type
    case 'png'
        print(img_fname, '-r300', '-dpng');
    case 'enhanced'
        print(img_fname,'-dmeta','-painters');
    case 'svg'
        print(img_fname,'-dsvg','-painters');
        
    case 'all'
%         print(img_fname,'-dmeta','-painters');
        print(img_fname, '-r300', '-dpng');
        print(img_fname,'-dsvg','-painters');
        
    otherwise
        error('You can select only ''png'', ''enhanced'', ''svg'', or ''all''');
end

fprintf('Plot saved in %s\n', folder_subject);
fprintf('filename: %s\n', img_fname);