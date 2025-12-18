function choice = accept_corners


choice = questdlg('Are the corners ok?', ...
    '', 'Yes','No', 'No');

switch choice
    case 'Yes'
        fprintf('Great! Let''s move on\n');
    case 'No'
        fprintf('Ok, le''s take them manually\n');
                
end

