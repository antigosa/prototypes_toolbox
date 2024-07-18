function ProtoTable = prototypes_synthetic_DS
% function ProtoTable = prototypes_synthetic_DS
ndots_x                 = 20;
ndots_y                 = 10;
ndots                   = ndots_x*ndots_y;
grid_offset             = 20;
dot_noise               = 0;
multOf                  = 4;
ShapeDim                = [800 800];
nsubj                   = 2;

nrows                   = 10;
ndotsXrow               = ndots/nrows;

% create synthetic data
% ActualDots_xy           = prototypes_generate_grid('Rectangle', ShapeDim, ndots_x, ndots_y, multOf, grid_offset, dot_noise);
ActualDots_xy           = prototypes_generate_grid_withImage('person_large_space.png', 'Mask_Circle.png', ndots_x, ndots_y, grid_offset);
ProtoTable              = prototypes_synthetic_simpleDS(ActualDots_xy, ShapeDim, 0, nsubj);
ProtoTable.Properties.UserData.StimulusType         = 'Image';
ProtoTable.Properties.UserData.StimulusFileName     = 'person_large_space.png';

% set the options for the CAM model
opt.w                   = 0.75;
opt.prototypes          = [0.25 0.25; 0.25 0.75; 0.75 0.25; 0.75 0.75].*ShapeDim;
opt.method              = 'CategoryPrototypes';


% generate data
opt.stdNoise            = 5;
ProtoTable            = prototypes_model_CAM(ProtoTable, opt);

ProtoTable.CategoryID = [];
ProtoTable.CategoryPrototypes = [];