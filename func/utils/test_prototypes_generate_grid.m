
%% Generate 400 dots
Shape           = 'Circle';
ShapeRect       = [500 500]; % px
n_dots_x        = 24;
n_dots_y        = 24;
multOf          = 4; % number of blocks
grid_offset     = 5;
dot_noise       = 3;

xy = prototypes_generate_grid(Shape, ShapeRect, n_dots_x, n_dots_y, multOf, grid_offset, dot_noise);

n_dots              = size(xy, 1);
shape_width         = ShapeRect(1);
shape_height        = ShapeRect(2);
screen_width_px     = 1285;
screen_height_px    = 865;
screen_x0_px        = 635;
screen_y0_px        = 215;
save(sprintf('TrialList_imsize%dx%d_ndots%d_nblocks%d_offset%d_Circle', ...
    ShapeRect(1), ShapeRect(1), n_dots, multOf, dot_noise), 'xy', 'shape_width', 'shape_height', 'screen_width_px', 'screen_height_px');

%% Generate 200 dots
Shape           = 'Circle';
ShapeRect       = [500 500]; % px
n_dots_x        = 19;
n_dots_y        = 19;
multOf          = 2; % number of blocks
grid_offset     = 54;
dot_noise       = 4;

xy = prototypes_generate_grid(Shape, ShapeRect, n_dots_x, n_dots_y, multOf, grid_offset, dot_noise);

n_dots              = size(xy, 1);
shape_width         = ShapeRect(1);
shape_height        = ShapeRect(2);
screen_width_px     = 1920;
screen_height_px    = 1080;

xy = [xy; xy];

save(sprintf('TrialList_imsize%dx%d_ndots%d_nblocks%d_offset%d_Circle', ...
    ShapeRect(1), ShapeRect(1), n_dots, multOf, dot_noise), 'xy', 'shape_width', 'shape_height', 'screen_width_px', 'screen_height_px');