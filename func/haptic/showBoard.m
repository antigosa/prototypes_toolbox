function showBoard(im)
% MAYBE I DON'T NEED THIS

imshow(im);

% 1. Get the data cursor mode for the current figure
dcm = datacursormode(gcf);
set(dcm, 'Enable', 'on');


dcm.UpdateFcn = {@boardUpdateFunc, im};
