function corrected_image=undistortBoard(original_image, corners, square_size, plotImage)



bottom_side = corners.bl_xy(1)-corners.br_xy(1);
top_side    = corners.tl_xy(1)-corners.tr_xy(1);

if nargin==2
    square_size=min([bottom_side,top_side]);
end

if nargin<=3
    plotImage=0;
end

% distorted_points = [x1, y1;
%                     x2, y2;
%                     x3, y3;
%                     x4, y4];

distorted_points = [corners.tl_xy;
                    corners.tr_xy;
                    corners.br_xy;
                    corners.bl_xy];

% square_size = 200; % Example size

corrected_points = [1, 1;
                    square_size, 1;
                    square_size, square_size;
                    1, square_size];
                
tform = estimateGeometricTransform2D(distorted_points, corrected_points, 'projective');                



corrected_image = imwarp(original_image, tform);

corrected_image=imrotate(corrected_image, 180);

if plotImage
    figure;imshow(corrected_image);
end