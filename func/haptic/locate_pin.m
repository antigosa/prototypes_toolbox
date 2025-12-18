function centroid = locate_pin(I, col, plotImage)

if nargin==1
    col = 'red'; % blue
    plotImage=0;
end

if nargin==2
    plotImage=0;
end


% 2. Extract color channels
redChannel      = double(I(:,:,1))./255;
greenChannel    = double(I(:,:,2))./255;
blueChannel     = double(I(:,:,3))./255;

% 3. Define "red" pixel criteria (adjust these thresholds as needed)
red_threshold_lower = 0.5; % Normalized range [0, 1]
red_threshold_upper = 1.0;
green_threshold_upper_for_red = 0.2;
blue_threshold_upper_for_red = 0.2;

is_red = (redChannel >= red_threshold_lower & redChannel <= red_threshold_upper) & ...
    (greenChannel <= green_threshold_upper_for_red) & ...
    (blueChannel <= blue_threshold_upper_for_red);

% figure; imshow(is_red)

% 4. Define "blue" pixel criteria (adjust these thresholds as needed)
blue_threshold_lower = 0.4; % Normalized range [0, 1]
blue_threshold_upper = 1.0;
red_threshold_upper_for_blue = 0.3;
green_threshold_upper_for_blue = 0.3;

is_blue = (blueChannel >= blue_threshold_lower & blueChannel <= blue_threshold_upper) & ...
    (redChannel <= red_threshold_upper_for_blue) & ...
    (greenChannel <= green_threshold_upper_for_blue);


% Create a mask for blue pixels
switch col
    case 'red'
        colMask = is_red;
    case 'blue'
        colMask = is_blue;
end

% Find the coordinates of blue pixels
[row, col] = find(colMask);

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

