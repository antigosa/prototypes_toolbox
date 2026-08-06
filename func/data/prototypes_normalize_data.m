function ProtoTable = prototypes_normalize_data(ProtoTable, opt)
% function ProtoTable = prototypes_normalize_data(ProtoTable, dim)
%
% Target and Response dots will be scaled in axis [-1 1 -1 1];
%
% Other fields will be also transformed:
% .ShapeRect            = [-1 1 -1 1]
% .ShapeContainerRect   = [-1.1 -1.1 1.1 1.1]
%
% Note that this function also recompute the errors
% It also recompute the polar data, if present
%
% The original dimensions are saved in .orig
%
% If .kmeans is present, it also rescales the centroid
% If .Models is present, it also rescale the parameters (prototypes
% position) and the predicted responses.
%
% To denormalize, use prototypes_denormalize_data
%
% RT 20200915


if nargin<2;opt=[];end
if ~isfield(opt, 'dim'); opt.dim=[];end
if ~isfield(opt, 'centreOnly'); opt.centreOnly=0;end


dim=opt.dim;

if isfield(ProtoTable.Properties.UserData, 'orig')
    warning('this data seems already normalized! exiting...');
    return;
end

if isempty(dim)
    if ProtoTable.Properties.UserData.ShapeRect(3) < ProtoTable.Properties.UserData.ShapeRect(4)
        dim = 2;
        
    elseif ProtoTable.Properties.UserData.ShapeRect(3) > ProtoTable.Properties.UserData.ShapeRect(4)
        dim = 1;
    else
        dim = 'both';
    end
end

RectWidth   = ones(size(ProtoTable, 1), 1)*ProtoTable.Properties.UserData.ShapeRect(3);
RectHeight  = ones(size(ProtoTable, 1), 1)*ProtoTable.Properties.UserData.ShapeRect(4);

% center data to zero
ActualDots_xy = ProtoTable.ActualDots_xy-[RectWidth/2 RectHeight/2];
RespDots_xy = ProtoTable.ResponseDots_xy-[RectWidth/2 RectHeight/2];


% normalize
switch dim
    case {1}
        RectWidth   = ones(size(ProtoTable, 1), 1)*ProtoTable.Properties.UserData.ShapeRect(3);
        RectHeight  = RectWidth;
        
    case {2}
        RectHeight  = ones(size(ProtoTable, 1), 1)*ProtoTable.Properties.UserData.ShapeRect(4);
        RectWidth   = RectHeight;
        
    case 'both'
        RectWidth   = ones(size(ProtoTable, 1), 1)*ProtoTable.Properties.UserData.ShapeRect(3);
        RectHeight  = ones(size(ProtoTable, 1), 1)*ProtoTable.Properties.UserData.ShapeRect(4);
end


if ~opt.centreOnly
    ActualDots_xy(:,1) = ActualDots_xy(:,1)./(RectWidth/2);
    ActualDots_xy(:,2) = ActualDots_xy(:,2)./(RectHeight/2);
    
    RespDots_xy(:,1) = RespDots_xy(:,1)./(RectWidth/2);
    RespDots_xy(:,2) = RespDots_xy(:,2)./(RectHeight/2);
end

% update table
ProtoTable.ActualDots_xy        = ActualDots_xy;
ProtoTable.ResponseDots_xy      = RespDots_xy;

ProtoTable.Properties.UserData.orig.ShapeRect           = ProtoTable.Properties.UserData.ShapeRect;
ProtoTable.Properties.UserData.orig.ShapeContainerRect  = ProtoTable.Properties.UserData.ShapeContainerRect;
ProtoTable.Properties.UserData.orig.centreOnly          = opt.centreOnly;


switch dim
    case {1}
        % TO COMPLETE
        ProtoTable.Properties.UserData.ShapeRect                = [-1 -0.5 1 0.5];
        
    case {2}
        % TO COMPLETE
        ProtoTable.Properties.UserData.ShapeRect                = [-0.5 -1 0.5 1];
        
    case 'both'
        if ~opt.centreOnly
            ProtoTable.Properties.UserData.ShapeRect                = [-1 -1 1 1];
        else
            ProtoTable.Properties.UserData.ShapeRect                = ProtoTable.Properties.UserData.ShapeRect-[ProtoTable.Properties.UserData.ShapeRect(3)/2 ProtoTable.Properties.UserData.ShapeRect(4)/2 ProtoTable.Properties.UserData.ShapeRect(3)/2 ProtoTable.Properties.UserData.ShapeRect(4)/2];
        end
        
end
ProtoTable.Properties.UserData.ShapeContainerRect       = ProtoTable.Properties.UserData.ShapeRect + ProtoTable.Properties.UserData.ShapeRect.*0.10;

if any(strcmp(ProtoTable.Properties.VariableNames, 'errorXY'))
    ProtoTable = prototypes_compute_errorVectors(ProtoTable);
end

if ismember('prototypeXY', ProtoTable.Properties.VariableNames)
    ProtoTable.prototypeXY = (ProtoTable.prototypeXY -[RectWidth/2 RectHeight/2]);
    
    if ~opt.centreOnly
        ProtoTable.prototypeXY(:,1) = ProtoTable.prototypeXY(:,1)./(RectWidth/2);
        ProtoTable.prototypeXY(:,2) = ProtoTable.prototypeXY(:,2)./(RectHeight/2);
    end
end

