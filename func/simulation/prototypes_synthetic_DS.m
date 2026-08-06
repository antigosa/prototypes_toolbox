function ProtoTable = prototypes_synthetic_DS(ShapeType, opt)
% function ProtoTable = prototypes_synthetic_DS

if nargin<2; opt = [];end

if ~isfield(opt, 'ndots_x'); opt.ndots_x=20;end
if ~isfield(opt, 'ndots_y'); opt.ndots_y=20;end
if ~isfield(opt, 'grid_offset'); opt.grid_offset=20;end
if ~isfield(opt, 'dot_noise'); opt.dot_noise=0;end
if ~isfield(opt, 'multOf'); opt.multOf=4;end
if ~isfield(opt, 'ShapeDim'); opt.ShapeDim=[800 800];end
if ~isfield(opt, 'nsubj'); opt.nsubj=1;end
if ~isfield(opt, 'withImage'); opt.withImage=0;end
if ~isfield(opt, 'image_fn'); opt.image_fn='person_large_space.png';end


if ~isfield(opt, 'w'); opt.w=0.75;end
if ~isfield(opt, 'prototypes'); opt.prototypes=[0.25 0.25; 0.25 0.75; 0.75 0.25; 0.75 0.75].*opt.ShapeDim;end
if ~isfield(opt, 'method'); opt.method='CategoryPrototypes';end
if ~isfield(opt, 'stdNoise'); opt.stdNoise=5;end


ndots_x                 = opt.ndots_x;
ndots_y                 = opt.ndots_y;
ndots                   = ndots_x*ndots_y;
grid_offset             = opt.grid_offset;
dot_noise               = opt.dot_noise;
multOf                  = opt.multOf;
ShapeDim                = opt.ShapeDim;
nsubj                   = opt.nsubj;
withImage               = opt.withImage;
image_fn                = opt.image_fn;
%
% nrows                   = 10;
% ndotsXrow               = ndots/nrows;

% create synthetic data


if withImage
    % ActualDots_xy           = prototypes_generate_grid('Rectangle', ShapeDim, ndots_x, ndots_y, multOf, grid_offset, dot_noise);
    ActualDots_xy           = prototypes_generate_grid_withImage(image_fn, 'Mask_Circle.png', ndots_x, ndots_y, grid_offset, dot_noise);
    ProtoTable              = prototypes_synthetic_simpleDS(ActualDots_xy, ShapeType, ShapeDim, 0, nsubj);
    ProtoTable.Properties.UserData.StimulusType         = {ShapeType};
    ProtoTable.Properties.UserData.StimulusFileName     = {image_fn};
    
else
    ActualDots_xy           = prototypes_generate_grid(ShapeType, ShapeDim, ndots_x, ndots_y, multOf, grid_offset, dot_noise);
    ProtoTable              = prototypes_synthetic_simpleDS(ActualDots_xy, ShapeType, ShapeDim, 0, nsubj);    
    
    ProtoTable.Properties.UserData.StimulusType         = {ShapeType};
    ProtoTable.Properties.UserData.StimulusFileName     = {[]};    
    
end



% set the options for the CAM model
% opt.w                   = 0.75;
% opt.prototypes          = ;
% opt.method              = 'CategoryPrototypes';


% generate data
% opt.stdNoise            = 5;
ProtoTable                      = prototypes_model_CAM(ProtoTable, opt);

% DO I NEED TO ELIMINATE THESE??
ProtoTable.category_id          = [];
ProtoTable.prototypeXY          = [];
ProtoTable.category_name        = [];

oldVarNames = {'ParticipantID', 'Trial', 'DotID', 'Block', 'Age', 'Gender'};
newVarNames = {'subj_id', 'trial_id', 'dot_id', 'block_id', 'age', 'gender'};

ProtoData.Trials                = ProtoTable;
ProtoData                       = prototypes_update_varNames(ProtoData, oldVarNames, newVarNames);
ProtoTable                      = ProtoData.Trials;

ProtoTable.RectWidth(:)         = ShapeDim(1);
ProtoTable.RectHeight(:)        = ShapeDim(2);


fn = fieldnames(ProtoTable.Properties.UserData);

% isFieldChar = zeros(1, length(fn));
for i = 1:length(fn)
    if ischar(ProtoTable.Properties.UserData.(fn{i}))
        ProtoTable.Properties.UserData.(fn{i}) = {ProtoTable.Properties.UserData.(fn{i})};
    end
end

ProtoTable.stimulus_type(:) = {ShapeType};
