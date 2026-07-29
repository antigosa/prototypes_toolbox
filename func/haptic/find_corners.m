function corners = find_corners(I, threshold, offset, grayImage, ROI, plotImages)

% if nargin<2;threshold=230;end
if nargin<3;offset=0;end
if nargin<4;grayImage=0;end
if nargin<5;ROI=0;end
if nargin<6;plotImages=0;end


if grayImage
    % If a gray image is used, the threshold is a unique value
    I = im2gray(I);
end


Is =imgaussfilt(I, 3);
%figure;imshow(Is);rectangle('Position', ROI.rect, 'EdgeColor', 'g', 'LineWidth', 2);
% figure;surf(Is);shading flat; axis equal;ax=gca;ax.YDir='reverse';
% 

if ~isempty(ROI)
    % Create an empty mask of the same size as the image (all zeros)
    mask = false(size(Is, 1), size(Is, 2));

    % Set the rectangle region to true (1)
    % Note: MATLAB uses (row, col) indexing
    mask(ROI.rect(2):ROI.rect(2)+ROI.rect(4)-1, ROI.rect(1):ROI.rect(1)+ROI.rect(3)-1) = true;

    % 5. Apply the mask
    % If the image is grayscale:
    Is = Is .* uint8(mask);
    %figure;imshow(maskedImg);
end


cols = {'red', 'green', 'blue'};
if length(size(I))==3
    mask = zeros(size(I,1), size(I, 2), size(I,3));
    max_vals=zeros(1, 3);
    for i=1:3
        mask(:,:,i) = Is(:,:,i)>=threshold.(cols{i})(1) & Is(:,:,i)<=threshold.(cols{i})(2);
        tmp=Is(:,:,i);tmp=tmp(:);
        max_vals(i) = max(tmp);                
    end
    fprintf('max vals: %d %d %d\n', max_vals(1), max_vals(2), max_vals(3));
    
    mask = all(mask, 3);
    Is = im2gray(Is);
else
    mask = Is>=threshold;
end
% figure;imshow(mask);

% 2. Label the connected components
% This assigns a unique ID to each blob (1, 2, 3, 4...)
[labeledImg, numBlobs] = bwlabel(mask);

fprintf('Number of blobs found: %d\n', numBlobs);

% 3. Calculate the weighted centres of mass
% 'img' is passed to calculate intensity-based weighting
stats = regionprops(labeledImg, Is, 'WeightedCentroid');

% 4. Extract the coordinates
centroids = cat(1, stats.WeightedCentroid);

centroids_mean = mean(centroids);



corners = [];
corners.br_xy = centroids(centroids(:,1) > centroids_mean(1) & centroids(:,2) > centroids_mean(2),:);
corners.bl_xy = centroids(centroids(:,1) < centroids_mean(1) & centroids(:,2) > centroids_mean(2),:);
corners.tr_xy = centroids(centroids(:,1) > centroids_mean(1) & centroids(:,2) < centroids_mean(2),:);
corners.tl_xy = centroids(centroids(:,1) < centroids_mean(1) & centroids(:,2) < centroids_mean(2),:);

% % 5. Visualise
% figure;imshow(Igreys, []); hold on;
% plot(centroids(:,1), centroids(:,2), 'r+', 'MarkerSize', 15, 'LineWidth', 2);

% offset = 11;

corners.br_xy = corners.br_xy + [offset offset];
corners.bl_xy = corners.bl_xy + [-offset offset];
corners.tr_xy = corners.tr_xy + [offset -offset];
corners.tl_xy = corners.tl_xy + [-offset -offset];

if plotImages
    % Display the results
    figure;
    imshow(I); title('Original Image');
    hold on; plot(corners.br_xy(1), corners.br_xy(2), '+b')
    hold on; plot(corners.bl_xy(1), corners.bl_xy(2), '*b')
    hold on; plot(corners.tr_xy(1), corners.tr_xy(2), '+r')
    hold on; plot(corners.tl_xy(1), corners.tl_xy(2), '*r')
end