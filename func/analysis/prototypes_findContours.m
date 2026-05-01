function boundaries = prototypes_findContours(csimap)

binaryImage = csimap > 0; % Apply a threshold if it's a grayscale image

% Find the boundaries
boundaries = bwboundaries(binaryImage);