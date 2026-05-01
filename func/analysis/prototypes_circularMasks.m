function extracted_pixels = prototypes_circularMasks(yourImage, centroids, radius, subregions_radius, plotImage)

% yourImage = imread('your_image.jpg'); % Replace with your image file

% Get the dimensions of the image
[rows, cols, channels] = size(yourImage);

% Define the radius for the mask circles (adjust as needed)
mask_radius = subregions_radius * radius; % Smaller than the subregions

% Create an empty mask with the same size as the image
mask = false(rows, cols); % Logical mask (true inside, false outside)

% Loop through each centroid
for i = 1:size(centroids, 1)
    % Get the coordinates of the current centroid
    center_x = round(centroids(i, 1));
    center_y = round(centroids(i, 2));
    
    % Create a grid of coordinates for the image
    [X, Y] = meshgrid(1:cols, 1:rows);
    
    % Create a circular mask for the current centroid
    current_circle_mask = (X - center_x).^2 + (Y - center_y).^2 <= mask_radius^2;
    
    % Combine the current circle mask with the overall mask using logical OR
    % This ensures that the masked regions from all circles are included
    mask = mask | current_circle_mask;
end

% Now 'mask' is a logical array where 'true' corresponds to the areas
% covered by the four smaller circles.

% You can use this mask to modify your image. For example, to set the
% pixels outside the circles to a specific value (e.g., 0 for black):

maskedImage = yourImage; % Create a copy of the original image

if plotImage
    % For grayscale images:
    if channels == 1
        maskedImage(~mask) = 0;
        figure; imshow(maskedImage); title('Image with Circular Masks');
    end
    
    % For RGB images:
    if channels == 3
        % Replicate the mask for all color channels
        mask_rgb = repmat(mask, 1, 1, 3);
        maskedImage(~mask_rgb) = 0;
        figure; imshow(maskedImage); title('Image with Circular Masks');
    end
end
% Alternatively, you can use the mask to extract the pixel values within the circles:
extracted_pixels = yourImage(mask);
% This will give you a 1D array of all pixel values within the circles.

if plotImage
    % Or, to keep only the content within the circles and make the rest transparent
    % (if your image format supports transparency, like PNG with an alpha channel):
    if channels == 3
        alphaChannel = uint8(mask * 255); % Create an alpha channel (255 inside, 0 outside)
        maskedImageWithAlpha = cat(3, yourImage, alphaChannel);
        figure; imshow(maskedImageWithAlpha); title('Image with Transparent Background');
        % You would then need to save this as a format that supports alpha
        % imwrite(maskedImageWithAlpha, 'masked_image_transparent.png');
    end
end