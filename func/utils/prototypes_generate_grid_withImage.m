function xy = prototypes_generate_grid_withImage(img, mask, n_dots_x, n_dots_y, grid_offset)
% function prototypes_generate_grid_withImage(img, mask, n_dots_x, n_dots_y, grid_offset)

close all;



% be sure that the randomization is fine
rng('shuffle');

% read the stimulus (the object in the middle)
% im_stim = imread('../img/stimulus2_800x800.png');
im_stim = imread(img);
im_stim = rgb2gray(im_stim);
% im_stim(im_stim>0)=255;

% read the stimulus (for example, if it is a circle, excludes the dots outside the circle)
% im_mask = imread('../img/perispace_mask800x800.png');
im_mask = imread(mask);
im_mask = rgb2gray(im_mask);
% im_mask(im_mask>0)=255;

% 
% grid_step       = 20;
grid_start      = 5; % it should be bigger than grid_offset so the borders are fine
% grid_offset     = 8;
% grid_dim        = 200;
% im = imtranslate(im, [grid_dim, grid_dim],'OutputView','full','FillValues',255);
figure; imagesc(im_stim);axis image;colormap('gray');
% xlim([0 square_dim_x]);ylim([0 square_dim_y]);


square_dim_x    = size(im_stim,2); %+grid_dim;
square_dim_y    = size(im_stim,1); %+grid_dim;
% n_dots_x        = 10; % 25
% n_dots_y        = 10; % 25
multOf          = 5;    % the final number of dots must be multiple of multOF. This is done if you want to have a division in blocks, for example
% x=grid_start:grid_step:square_dim_x;
% y=grid_start:grid_step:square_dim_y;
x = linspace(grid_start, square_dim_x-grid_start, n_dots_x);
y = linspace(grid_start, square_dim_y-grid_start, n_dots_y);

new_xy_y = repmat(y, 1 ,length(x))';
new_xy_x = reshape(repmat(x, length(y),1),1,[])';

new_xy = [new_xy_x, new_xy_y];

% new_xy = new_xy - grid_dim/2;

hold on; scatter(new_xy(:,1), new_xy(:,2), 'Filled'); axis image;


% =========================================================================
% exlude dots that are outside the mask (a circle or a square, for example)
% =========================================================================

% im = imtranslate(im, [-grid_dim/2, -grid_dim/2],'OutputView','full','FillValues',255);

% im(im>200)=NaN;
% imshow(im);
im_mask(im_mask>0)=255;
figure;imagesc(im_mask);axis image;colormap('gray')

% 255 means that the dots within the area (the person in this case) will
% be excluded
offset=10;
[xy, dotOutOfCircle]=protoperispace_refine_grid(im_mask, new_xy, 255, offset);
% [dotOutOfCircle, xy] = protoperispace_check_dots(im, new_xy, 255); % 255

hold on; scatter(xy(:,1), xy(:,2), 'Filled'); axis image;
fprintf('dot out of circle: %d\n', dotOutOfCircle);



% =========================================================================
% exlude dots that are inside the object
% =========================================================================
% zero means that the dots within the area (the object in this case) will
% be excluded
[xy, dotInPerson]=protoperispace_refine_grid(im_stim, xy, 0);

hold on; scatter(xy(:,1), xy(:,2), 'Filled'); axis image;
fprintf('dot in person: %d\n', dotInPerson);

%%
n_dots = size(new_xy,1);

% offset for dots that are not at the border
new_xy=xy+random('norm', 0, grid_offset, n_dots, 2);

[~, dotInPerson]=protoperispace_refine_grid(im_stim, new_xy, 0);

iter=1;
while dotInPerson && iter<1000
    new_xy=xy+random('norm', 0, grid_offset, n_dots, 2);
    [~, dotInPerson]=protoperispace_refine_grid(im_stim, new_xy, 0);
    iter=iter+1;
    clc; fprintf('iteration: %d\n', iter);
end

xy=new_xy;
xy = xy(~any(isnan(xy),2),:);


figure; imagesc(im_stim);axis image;colormap('gray');
hold on;scatter(xy(:,1), xy(:,2), 'Filled'); axis image;
xlim([0 square_dim_x]);ylim([0 square_dim_y]);


%%
n_dots = size(xy, 1);
fprintf('number of dots: %d\n', n_dots);

isMultOf = mod(n_dots,multOf);
if isMultOf>0
    idx2remove = randperm(n_dots);idx2remove=idx2remove(1:isMultOf);
    idx2keep = setdiff(1:n_dots, idx2remove);
    xy = xy(idx2keep,:);
    n_dots = size(xy, 1);
    fprintf('removing %d dots such that number of dots is multiple of: %d\n', isMultOf, multOf);
    fprintf('number of dots: %d\n', n_dots);
end

% save
% save(sprintf('TrialList_imsize%dx%d_ndots%d_offset%d', square_dim_x, square_dim_y, n_dots, grid_offset), 'xy');

% shape_width = size(im_stim, 2);
% shape_height = size(im_stim, 1);
% 
% % window size in pixels
% [screen_width_px, screen_height_px]=Screen('WindowSize', 1 );
% 
% % window size in mm
% [screen_width_mm, screen_height_mm]=Screen('DisplaySize', 1);
% 
% save(sprintf('TrialList_imsize%dx%d_ndots%d_nblocks%d_offset%d_withImage', square_dim_x, square_dim_y, n_dots, multOf, grid_offset), 'xy',...
% 'shape_width', 'shape_height', 'screen_width_px', 'screen_height_px');


function xy=rotate_dots(xy, theta)
% function xy=rotate_dots(xy, theta)
% x = 1:10;
% y = 1:10;
% create a matrix of these points, which will be useful in future calculations
v = xy';

% choose a point which will be the center of rotation
x_center = 400; % x(3);
y_center = 400; %y(3);

% create a matrix which will be used later in calculations
center = repmat([x_center; y_center], 1, size(xy,1));

% define a 60 degree counter-clockwise rotation matrix
theta = deg2rad(theta); % pi/3;       % pi/3 radians = 60 degrees
R = [cos(theta) -sin(theta); sin(theta) cos(theta)];

% do the rotation...
s = v - center;     % shift points in the plane so that the center of rotation is at the origin
so = R*s;           % apply the rotation about the origin
vo = so + center;   % shift again so the origin goes back to the desired center of rotation

% this can be done in one line as:
% vo = R*(v - center) + center
% pick out the vectors of rotated x- and y-data
% x_rotated = vo(1,:);
% y_rotated = vo(2,:);
% make a plot
% plot(v(1,:), v(2,:), 'k-', x_rotated, y_rotated, 'r-', x_center, y_center, 'bo');
% axis equal
xy = vo;

function y = deg2rad(x)
y = x * pi/180;

function [xy, dotOutOfCircle]=protoperispace_refine_grid(im, xy, val2remove, offset)
% function [xy, dotOutOfCircle]=protoperispace_refine_grid(im, xy, val2remove, offset)

ndots = size(xy,1);
dotOutOfCircle=0;

if ~exist('offset', 'var');offset =10;end

for d = 1:ndots
    curdot = round(xy(d,:));
    if any(isnan(curdot)); continue;end
    curvec       = zeros(offset*2+1, 2);
    curvec(:,1)  = [(curdot(1)-offset):curdot(1) (curdot(1)+1):(curdot(1)+offset)]';
    curvec(:,2)  = [(curdot(2)-offset):curdot(2) (curdot(2)+1):(curdot(2)+offset)]';
    
    idxneg = any(curvec<=0,2);
    curvec=curvec(~idxneg,:);
    
    idxbig = any(curvec(:,1)>size(im,2),2) | any(curvec(:,2)>size(im,1),2);
    curvec=curvec(~idxbig,:);
    
    
    %    if im(curdot(2), curdot(1))==val2remove
    if any(any(im(curvec(:,2), curvec(:,1))==val2remove))
%         if any(any(im(curvec(:,2), curvec(:,1))==val2remove))
        dotOutOfCircle=dotOutOfCircle+1;
        xy(d,:)=NaN;
    end
    
end




function plot_deg(d, FigureHeight, FigureWidth, col, listy)
% function plot_deg(d, FigureHeight, FigureWidth, col, listy)

x0 = FigureWidth/2; y0 = FigureHeight/2;

theta1 = deg2rad(d);
rho1 = round(sqrt(FigureHeight^2 + FigureWidth^2))/2;

axis([0 FigureHeight 0 FigureWidth]);
fig=gcf;
fig.Position=[-750   276   560   420]; 
[x, y] = pol2cart(theta1, rho1);

line([x0 x+x0], [y0 y+y0], 'Color', col, 'LineWidth', 2, 'LineStyle', listy);axis([0 FigureWidth 0 FigureHeight])