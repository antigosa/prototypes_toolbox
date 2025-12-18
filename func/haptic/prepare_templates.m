function cropped_img = prepare_templates(ax, I)

if nargin==0;ax=gca;end
if nargin<=1;I=ax.Children.CData;end



% Get user-defined rectangle
rect = getrect(ax); % gca for current axes

% Crop the image
x_min = round(rect(1));
y_min = round(rect(2));
width = round(rect(3));
height = round(rect(4));

%handle the edge cases
x_max = min(x_min + width, size(I, 2));
y_max = min(y_min + height, size(I, 1));

cropped_img = I(y_min:y_max, x_min:x_max, :);

% % Display the cropped image
% figure;
% imshow(cropped_img);

% Save the cropped image
%imwrite(cropped_img, 'cropped_image.png'); % Saves as PNG

