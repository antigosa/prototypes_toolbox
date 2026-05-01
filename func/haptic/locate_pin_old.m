function centroid = locate_pin(I, hue_range, plotImage)

if nargin==1
    hue_range = [0.55 0.75]; % blue
%     hue_range = [0 0.03]; % red
    plotImage=0;
end

if nargin==2
    plotImage=0;
end

% Convert to HSV
hsvImage = rgb2hsv(I);

% Define the blue hue range
hue = hsvImage(:, :, 1);
saturation = hsvImage(:, :, 2);

% Define the Hue range for blue.
% lowerHue = 0.55; % Adjust these values as needed
% upperHue = 0.75;
lowerHue = hue_range(1); % Adjust these values as needed
upperHue = hue_range(2);

% Create a mask for blue pixels
blueMask = (hue >= lowerHue) & (hue <= upperHue) & (saturation > 0.3); % add saturation filter to remove greyish blues.

% Find the coordinates of blue pixels
[row, col] = find(blueMask);

% Calculate the centroid
if ~isempty(row)
    centroid_row = mean(row);
    centroid_col = mean(col);
    centroid = [centroid_col, centroid_row]; % Centroid as [x, y]
    disp(['Centroid: [' num2str(centroid_col) ', ' num2str(centroid_row) ']']);

    % Optionally, visualize the centroid on the image
    if plotImage
        figure;
        imshow(I);
        hold on;
        plot(centroid_col, centroid_row, 'r+', 'MarkerSize', 10); % Mark the centroid
        title('Blue Objects with Centroid');
        hold off;
    end
else
    disp('No blue pixels found.');
    centroid = [];
end

% Get the pixel coordinates.
blue_pixel_coords = [col, row]; % pixel coordinates as [x,y]