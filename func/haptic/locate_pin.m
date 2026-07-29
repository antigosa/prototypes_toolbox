function centroid = locate_pin(I, threshold, plotImage)

if nargin==1
    col = 'red'; % blue
    plotImage=0;
end

if nargin==2
    plotImage=0;
end


% 2. Extract color channels
redChannel      = double(I(:,:,1));
greenChannel    = double(I(:,:,2));
blueChannel     = double(I(:,:,3));

colMask = (redChannel >= threshold.red(1) & redChannel <= threshold.red(2)) & ...
    (greenChannel >= threshold.green(1) & greenChannel <= threshold.green(2)) & ...
    (blueChannel >= threshold.blue(1) & blueChannel <= threshold.blue(2));


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

