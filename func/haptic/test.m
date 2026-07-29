
% 2. Load/Generate your grayscale image
% img = imread('your_figure.png');
% img = im2gray(img);

Igrey = im2gray(I);

figure; imshow(Igrey); hold on;

imshow(template);

figure;surf(Igrey)
shading flat

Igreys =imgaussfilt(Igrey, 4);
figure;surf(Igreys)
shading flat; axis equal;

figure;imshow(Igreys);

%%
mask = Igreys>230;
figure;imshow(mask);

% 2. Label the connected components
% This assigns a unique ID to each blob (1, 2, 3, 4...)
[labeledImg, numBlobs] = bwlabel(mask);

% 3. Calculate the weighted centres of mass
% 'img' is passed to calculate intensity-based weighting
stats = regionprops(labeledImg, Igreys, 'WeightedCentroid');

% 4. Extract the coordinates
centroids = cat(1, stats.WeightedCentroid);

% 5. Visualise
figure;imshow(Igreys, []); hold on;
plot(centroids(:,1), centroids(:,2), 'r+', 'MarkerSize', 15, 'LineWidth', 2);






% 2. Get the coordinates of all local maxima
[r, c] = find(mask);
vals = Igreys(mask); % Get the actual values at those peaks

% 3. Sort these peaks by value
[sortedVals, sortIdx] = sort(vals, 'descend');
topR = r(sortIdx(1:4));
topC = c(sortIdx(1:4));

% 4. Visualise
figure;imshow(Igreys, []); hold on;
plot(topC, topR, 'ro', 'MarkerSize', 10, 'LineWidth', 2);


%%
% 1. Get the top 4 values and their linear indices
[values, linearIndices] = maxk(Igreys(:), 4);

% 2. Convert linear indices to (row, col) coordinates
[rows, cols] = ind2sub(size(Igreys), linearIndices);

% 3. Display
for i = 1:4
    fprintf('Peak %d: Value = %.2f at [%d, %d]\n', i, values(i), rows(i), cols(i));
end

%%

% 1. Create the template (Top-Left Corner Detector)
% This creates a 5x5 kernel
template = ones(5,5);
template(:, 4:5) = 0;
template(4:5, :) = 0;

% figure; imshow(Igreys); hold on;
% h_fg = imshow(im2gray(template));
% set(h_fg, 'XData', [150 150+w-1], 'YData', [100 100+h-1]);


% 3. Apply the filter (Convolution)
% 'same' ensures the output is the same size as the input
correlationMap = conv2(double(Igreys), template, 'same');
correlationMap = normxcorr2(template, Igreys);


figure; imshow(correlationMap); hold on;

% 4. Find the 'corner'
% The maximum value in correlationMap indicates the best fit
[maxVal, idx] = max(correlationMap(:));
[row, col] = ind2sub(size(correlationMap), idx);

% 5. Visualise
figure; imshow(Igrey); hold on;
plot(col, row, 'ro', 'MarkerSize', 10);