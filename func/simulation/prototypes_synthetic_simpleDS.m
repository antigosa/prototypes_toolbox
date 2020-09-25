function ProtoTable = prototypes_synthetic_simpleDS(ndotsOrMat, figure_size, sd, nsubj, simulateBias, seed)
% function ProtoTable = prototypes_synthetic_simpleDS(ndotsOrMat, figure_size, sd, nsubj, simulateBias, seed)
%
% This function provides a very basic simulation of the responses. You can
% just decide if responses will be biased (simulateBias=1) or not (just
% random responses around the actual data). If you want to simulate more
% realistic responses, use prototypes_models.
%
% =========================================================================
% INPUT
% =========================================================================
% ndotsOrMat: 
% - scalar; it randomly creates ndotsOrMat dots
% - 2D matrix (ndots x 2); if you want to provide the actual dots 
% - 3D matrix (ndots x 2 x 2); if you want to provide the responses as well
%
% figure_size: 
% - vector (1 x 2); the figure (container) dimensions
% -- figure_size(1) is the width size (in pixel)
% -- figure_size(2) is the height size (in pixel)
%
% sd: 
% - scalar (%); the standard deviation used for create the responses (when 
%               requested)
%               
% nsubj:
% - scalar; number of participants
%
% simulateBias:
% - scalar; either 1 (simulate the bias) or 0 (do not simulate the bias)
%
% seed:
% - the seed used by the Matlab function 'rng'
%
% 20200831 - RT
rng('default')
if nargin==3;nsubj=1;simulateBias = 1;rng('shuffle');end
if nargin==4;simulateBias = 1;rng('shuffle');end
if nargin==5; rng('shuffle'); elseif nargin==6; rng(seed); end

% sd is given as percentage, and needs to be converted in pixels. There is
% one sd for each dimension
sd1 = figure_size(1)*sd; 
sd2 = figure_size(2)*sd;

% prepare output
ProtoTable=table;

% start the loop over subjects
for s=1:nsubj
    
    % create synthetic DS for a subject
    subjTable   = prototypes_synthetic_simpleDS_aSubj(ndotsOrMat, figure_size, sd1, sd2, s, simulateBias);        
    
    % append this to the main dataset (that contains all subjects)
    ProtoTable      = [ProtoTable; subjTable];
    
    % IMPORTANT: the actual dots MUST be the same for all participants, so
    % just use the one from participant one.
    if s==1; ndotsOrMat=ProtoTable.ActualDots_xy;end
end

% add fields that define a prototable
ProtoTable = prototypes_prototable(ProtoTable);
ProtoTable = prototypes_set_metadata(ProtoTable, 'Experiment', 'Synthetic data');
if figure_size(1) ~= figure_size(2)
    ProtoTable = prototypes_set_metadata(ProtoTable, 'StimulusType', 'Rectangle');
else
    ProtoTable = prototypes_set_metadata(ProtoTable, 'StimulusType', 'Square');
end
ProtoTable = prototypes_set_metadata(ProtoTable, 'ShapeRect', [0 0 figure_size]);
ProtoTable = prototypes_set_metadata(ProtoTable, 'ShapeContainerRect', [0-figure_size(1)*.1 0-figure_size(2)*.1 figure_size(1)+figure_size(1)*.1 figure_size(2)+figure_size(2)*.1]);

% add demo info
ndots = length(unique(ProtoTable.DotID));
ProtoTable.Age        = reshape(repmat(round(random('norm', 30, 5, nsubj, 1)), 1, ndots)', [],1);
Gender     = reshape(repmat(random('unid', 2, nsubj, 1), 1, ndots)', [],1);
ProtoTable.Gender     = cell(length(ProtoTable.Age), 1);
ProtoTable.Gender(Gender==1)     = {'Female'};
ProtoTable.Gender(Gender==2)     = {'Male'};




function ProtoTable = prototypes_synthetic_simpleDS_aSubj(ndotsOrMat, figure_size, sd1, sd2, subjNum, simulateBias)

% =========================================================================
% initial setup
% =========================================================================

% get figure width
figure_width    = figure_size(1);

% get figure height
figure_height   = figure_size(2);

% the position of the bias is at 25% of each dimension
bias_pos_x = figure_width*0.25;
bias_pos_y = figure_height*0.25;

% combine the two dimensions
bias_pos = [bias_pos_x bias_pos_y];

% main dataset
ProtoTable = [];

% if ndotsOrMat is a not a scalar, get the number of dots that was
% requested
if numel(ndotsOrMat)~=1
    
    % get number of dots
    ndots = size(ndotsOrMat,1);
else
    
    % otherwise, use the provided number
    ndots = ndotsOrMat;
end

% =========================================================================
% set main variables
% =========================================================================

% subject ID
ProtoTable.ParticipantID    = ones(ndots, 1)*subjNum;

% trial ID
ProtoTable.Trial            = (1:ndots)';

% dot ID (each dot is identified with a number)
ProtoTable.DotID            = (1:ndots)';

% block ID
ProtoTable.Block            = ones(ndots, 1);


% =========================================================================
% prepare data
% =========================================================================
if numel(ndotsOrMat)==1         % if ndotsOrMat is a scalar
    
    % create a 2D cloud of randomly organized dots
    ProtoTable.ActualDots_xy      = prototypes_simulate_actDots(figure_width, figure_height, ndotsOrMat, 1);
    
    % if you do not want to simulate the response bias, it means that you
    % expect the responses to be randomly distributed around the actual
    % dots (with a certain error defined by sd)
    if ~simulateBias
        RespDots_x              = ProtoTable.ActualDots_xy(:,1) + random('norm', 0, sd1, size(ProtoTable.ActualDots_xy, 1),1);
        RespDots_y              = ProtoTable.ActualDots_xy(:,2) + random('norm', 0, sd2, size(ProtoTable.ActualDots_xy, 1),1);      
        ProtoTable.ResponseDots_xy  = [RespDots_x RespDots_y];
    end
else                            % if ndotsOrMat is a matrix
    ActualDots_x                = ndotsOrMat(:, 1, 1);
    ActualDots_y                = ndotsOrMat(:, 2, 1);
    ProtoTable.ActualDots_xy        = [ActualDots_x ActualDots_y];
    
    if length(size(ndotsOrMat))~=3
        ProtoTable.ResponseDots_xy      = ProtoTable.ActualDots_xy + random('norm', 0, 3, size(ProtoTable.ActualDots_xy));
        
    elseif length(size(ndotsOrMat))==3
        ProtoTable.ResponseDots_xy      = [ndotsOrMat(:, 1, 2) ndotsOrMat(:, 2, 2)];
    end
%     ndotsOrMat=size(ndotsOrMat,1);
end

% =========================================================================
% simulate reponse bias
% =========================================================================
% if Responses have not been provided as an input, and it is requested to
% simulate the response bias (simulateBias==1), add a 'simple' bias. This
% means that the bias (where participants tend to respond) is expected to
% be at the centre of each subquadrant

if length(size(ndotsOrMat))~=3 && simulateBias
    
    % add simple bias (topleft)
    idx_topleft             = ProtoTable.ActualDots_xy(:,1)<=figure_width/2 & ProtoTable.ActualDots_xy(:,2)<=figure_height/2;
    ProtoTable.ResponseDots_xy(idx_topleft, 1) = bias_pos(1) + random('norm', 0, sd1, sum(idx_topleft), 1);
    ProtoTable.ResponseDots_xy(idx_topleft, 2) = bias_pos(2) + random('norm', 0, sd2, sum(idx_topleft), 1);
    
    % add simple bias (topright)
    idx_topright            = ProtoTable.ActualDots_xy(:,1)>=figure_width/2+1 & ProtoTable.ActualDots_xy(:,2)<=figure_height/2;
    ProtoTable.ResponseDots_xy(idx_topright, 1) = figure_width-bias_pos(1) + random('norm', 0, sd1, sum(idx_topright), 1);
    ProtoTable.ResponseDots_xy(idx_topright, 2) = bias_pos(2) + random('norm', 0, sd2, sum(idx_topright), 1);
    
    
    % add simple bias (bottomleft)
    idx_bottomleft          = ProtoTable.ActualDots_xy(:,1)<=figure_width/2 & ProtoTable.ActualDots_xy(:,2)>=figure_height/2+1;
    ProtoTable.ResponseDots_xy(idx_bottomleft, 1) = bias_pos(1) + random('norm', 0, sd1, sum(idx_bottomleft), 1);
    ProtoTable.ResponseDots_xy(idx_bottomleft, 2) = figure_height-bias_pos(2) + random('norm', 0, sd2, sum(idx_bottomleft), 1);
    
    % add simple bias (bottomright)
    idx_bottomright         = ProtoTable.ActualDots_xy(:,1)>=figure_width/2+1 & ProtoTable.ActualDots_xy(:,2)>=figure_height/2+1;
    ProtoTable.ResponseDots_xy(idx_bottomright, 1) = figure_width-bias_pos(1) + random('norm', 0, sd1, sum(idx_bottomright), 1);
    ProtoTable.ResponseDots_xy(idx_bottomright, 2) = figure_height-bias_pos(2) + random('norm', 0, sd2, sum(idx_bottomright), 1);
end

% =========================================================================
% ending
% =========================================================================
% Returns the data as a table
ProtoTable = struct2table(ProtoTable);

% ADD ADDITIONAL INFORMATION
if length(size(ndotsOrMat))~=3 && simulateBias
    ProtoTable.Properties.UserData.Simulated_bias = [figure_width-bias_pos(1) bias_pos(2); bias_pos(1) bias_pos(2); bias_pos(1) figure_width-bias_pos(2); figure_width-bias_pos(1) figure_width-bias_pos(2)];
end

% prototypes_check_prototable(ProtoTable);


% ProtoTable = prototypes_compute_errorVectors(ProtoTable);


function ActualDots = prototypes_simulate_actDots(figure_width, figure_height, ndotsOrMat, sd)
% function ActualDots = prototypes_simulate_actDots(figure_width, figure_height, ndotsOrMat)

% simulate the x dimension (sample from a uniform distribution)
ActualDots_x    = random('unid', figure_width, ndotsOrMat, sd);

% simulate the y dimension (sample from a uniform distribution)
ActualDots_y    = random('unid', figure_height, ndotsOrMat, sd);

% combine the two dimensions
ActualDots      = [ActualDots_x ActualDots_y];

% we do not want overlapping dots, so sample new numbers until there are
% exaclty the requested number of dots
ActualDots_unique   = unique(ActualDots, 'rows');
nUniqueDots         = size(ActualDots_unique,1);

while nUniqueDots<ndotsOrMat
    ActualDots_x    = random('unid', figure_width, ndotsOrMat, sd);
    ActualDots_y    = random('unid', figure_height, ndotsOrMat, sd);
    ActualDots      = [ActualDots_x ActualDots_y];
        
    ActualDots_unique = unique(ActualDots, 'rows');
    nUniqueDots = size(ActualDots_unique,1);
end