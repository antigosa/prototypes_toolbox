function xy = prototypes_generate_grid(Shape, ShapeRect, n_dots_x, n_dots_y, multOf, grid_offset, dot_noise)

shape_width     = ShapeRect(1);
shape_height    = ShapeRect(2);

switch Shape
    case 'Circle'
        xy = prototypes_generate_grid_Circle(shape_width, shape_height, n_dots_x, n_dots_y, multOf, grid_offset, dot_noise);
        
    case 'Rectangle'
        xy = prototypes_generate_grid_Rectangle(shape_width, shape_height, n_dots_x, n_dots_y, multOf, grid_offset, dot_noise);
end


function xy = prototypes_generate_grid_Circle(shape_width, shape_height, n_dots_x, n_dots_y, multOf, grid_offset, dot_noise)
% function prototypes_generate_grid_Circle(shape_width, shape_height, n_dots_x, n_dots_y, multOf, grid_offset, dot_noise)
% it generates a mat file with the xy coordinates
%
%
% =========================================================================
% EXAMPLE CALLS
% =========================================================================
%
% use default parameters (see rows 31 to 41)
% - prototypes_generate_grid_Circle
%
% % create a circle 500x500 with 25 dots on the diameters
% shape_width=500; shape_height=500; n_dots_x=25;n_dots_y=25;
% prototypes_generate_grid_Circle(shape_width, shape_height, n_dots_x, n_dots_y)
%
% % create a circle 500x500 with 25 dots on the diameters and force the
% % number to be a multiple of 4 (for example, you want to divide
% % presentation in 4 blocks)
% shape_width=500; shape_height=500; n_dots_x=25;n_dots_y=25;multOf = 4;
% prototypes_generate_grid_Circle(shape_width, shape_height, n_dots_x, n_dots_y, multOf)
%
% % create a circle 500x500 with 25 dots on the diameters and force the
% % number to be a multiple of 4 and also change the offset from the
% % circle and the max noise a dot can have from the original position (put
% % zero if you do not want any noise).
% shape_width=500; shape_height=500; n_dots_x=25;n_dots_y=25;multOf=4;grid_offset=20; dot_noise=5;
% prototypes_generate_grid_Circle(shape_width, shape_height, n_dots_x, n_dots_y, multOf, grid_offset, dot_noise)
%
% % create a circle 500x500 with 25 dots on the diameters and force the
% % number to be a multiple of 4 and also change the offset from the
% % circle and the max noise a dot can have from the original position
% shape_width=505; shape_height=505; n_dots_x=26;n_dots_y=26;multOf=4;grid_offset=10; dot_noise=0;
% prototypes_generate_grid_Circle(shape_width, shape_height, n_dots_x, n_dots_y, multOf, grid_offset, dot_noise)

close all;

% be sure that the randomization is fine
rng('shuffle');


% =========================================================================
% window parameters
% =========================================================================

% window size in pixels
% [screen_width_px, screen_height_px]=Screen('WindowSize', 1 );

% window size in mm
% [screen_width_mm, screen_height_mm]=Screen('DisplaySize', 1);


if nargin == 0
    % =========================================================================
    % shape parameters
    % =========================================================================
    % Circle diameter in pixel
    shape_width     = 500;
    shape_height    = 500;
    
    % =========================================================================
    % grid parameters
    % =========================================================================
    n_dots_x        = 26;   % 25
    n_dots_y        = 26;   % 25
    grid_offset      = 5;    % it should be bigger than grid_offset so the borders are fine
    dot_noise       = 2;
    multOf          = 1;    % the final number of dots must be multiple of multOF. This is done if you want to have a division in blocks, for example
end

if nargin == 4
    grid_offset      = 5;    % it should be bigger than grid_offset so the borders are fine
    dot_noise       = 2;
    multOf          = 4;    % the final number of dots must be multiple of multOF. This is done if you want to have a division in blocks, for example
end

if nargin == 5
    grid_offset      = 5; % it should be bigger than grid_offset so the borders are fine
    dot_noise       = 2;
end

% =========================================================================
% generate grid
% =========================================================================
square_dim_x    = shape_width - grid_offset; %+grid_dim;
square_dim_y    = shape_height - grid_offset; %+grid_dim;

% x=grid_offset:grid_step:square_dim_x;
% y=grid_offset:grid_step:square_dim_y;
x = linspace(0, shape_width, n_dots_x);
y = linspace(0, shape_height, n_dots_y);

xy_y = repmat(y, 1 ,length(x))';
xy_x = reshape(repmat(x, length(y),1),1,[])';

xy = [xy_x, xy_y];

% new_xy = new_xy - grid_dim/2;

figure; scatter(xy(:,1), xy(:,2), 'Filled'); axis image;
rectangle('Position', [0 0 shape_width shape_height],'Curvature', 1);

n_dots = size(xy,1);


% offset for dots
xy=xy+random('norm', 0, dot_noise, n_dots, 2);
hold on; scatter(xy(:,1), xy(:,2), 'Filled'); axis image;


% =========================================================================
% exlude dots that are outside the mask (a circle or a square, for example)
% =========================================================================
% xc = shape_width/2; yc = shape_height/2;
xc = square_dim_x/2; yc = square_dim_y/2;


x = xy(:,1);
y = xy(:,2);

r = sqrt((x-xc-grid_offset/2).^2 + (y-yc-grid_offset/2).^2);
xy(r>xc, :)=[];
hold on; scatter(xy(:,1), xy(:,2), 'Filled'); axis image;
figure; scatter(xy(:,1), xy(:,2), 'Filled'); axis image;
rectangle('Position', [0 0 shape_width shape_height],'Curvature', 1);


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
save(sprintf('TrialList_imsize%dx%d_ndots%d_nblocks%d_offset%d_Circle', square_dim_x, square_dim_y, n_dots, multOf, dot_noise), 'xy',...
    'shape_width', 'shape_height');


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

function xy = prototypes_generate_grid_Rectangle(shape_width, shape_height, n_dots_x, n_dots_y, multOf, offsetXY, dot_noise)
% function xy = prototypes_generate_grid_Square(shape_width, shape_height, n_dots_x, n_dots_y, offsetXY)

x = linspace(0+offsetXY, shape_width-offsetXY, n_dots_x);
y = linspace(0+offsetXY, shape_height-offsetXY, n_dots_y);

xy_y = repmat(y, 1 ,length(x))';
xy_x = reshape(repmat(x, length(y),1),1,[])';

xy = [xy_x, xy_y];