function uniformImg = correctImage(img) 

% NOT WORKING

uniformImg = correctImage_CLAHE(img);

figure; imshow(uniformImg);


function uniformImg = correctImage_CLAHE(img)

% Contrast-Limited Adaptive Histogram Equalization (CLAHE)

% 1. Convert to L*a*b* space
labImg = rgb2lab(img);

% 2. Extract the L (Luminance) channel
L = labImg(:,:,1);

% 3. Apply CLAHE to the L channel
% Divide by 100 because L is [0 100], and adapthisteq expects [0 1]
L_normalized = adapthisteq(L / 100, 'NumTiles', [8 8], 'ClipLimit', 0.02) * 100;

% 4. Replace the original L channel with the normalized one
labImg(:,:,1) = L_normalized;

% 5. Convert back to RGB
uniformImg = lab2rgb(labImg);

uniformImg = im2uint8(uniformImg);







function correctImage_gradient

% 1. Convert to grayscale to get intensity
grayImg = im2double(im2gray(img));

% 2. Create the "lighting map" by heavy Gaussian blurring
% Sigma should be large enough to blur out the objects (e.g., 50+)
background = imgaussfilt(grayImg, 50);

% figure; imshow(background);

% 3. Divide image by background to remove shading
% (Add a small epsilon to avoid division by zero)
correctedIntensity = grayImg ./ (background + 0.1);

% figure; imshow(correctedIntensity);

% 4. Rescale to standard [0 1] range
correctedIntensity = rescale(correctedIntensity);

% 5. Apply this correction to the original RGB
% We multiply the original channels by the ratio of correction
% This preserves the colour while fixing the intensity
ratio = correctedIntensity ./ (grayImg + eps);
% figure; imshow(uint8(ratio));

uniformImg = uint8(double(img) .* ratio);


% % Add 0.1 to every pixel (range 0 to 1)
% uniformImg = uniformImg + 10;
% 
% % Clip values
% uniformImg(uniformImg > 255) = 255;



figure; imshow(uniformImg);