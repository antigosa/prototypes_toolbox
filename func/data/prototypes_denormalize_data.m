function ProtoTable = prototypes_denormalize_data(ProtoTable, dim)
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


if nargin==1;dim=[];end

if isempty(dim)
    if ProtoTable.Properties.UserData.orig.ShapeRect(3) < ProtoTable.Properties.UserData.orig.ShapeRect(4)
        dim = 2;
        
    elseif ProtoTable.Properties.UserData.orig.ShapeRect(3) > ProtoTable.Properties.UserData.orig.ShapeRect(4)
        dim = 1;
    else
        dim = 'both';
    end
end


% center data to zero
ActualDots_xy = ProtoTable.ActualDots_xy;
RespDots_xy = ProtoTable.ResponseDots_xy;

% denormalize
switch dim
    case {1}
        RectWidth   = ones(size(ProtoTable, 1), 1)*ProtoTable.Properties.UserData.orig.ShapeRect(3);
        RectHeight  = RectWidth;
        
    case {2}
        RectHeight  = ones(size(ProtoTable, 1), 1)*ProtoTable.Properties.UserData.orig.ShapeRect(4);
        RectWidth   = RectHeight;
        
    case 'both'        
        RectWidth   = ones(size(ProtoTable, 1), 1)*ProtoTable.Properties.UserData.orig.ShapeRect(3);
        RectHeight  = ones(size(ProtoTable, 1), 1)*ProtoTable.Properties.UserData.orig.ShapeRect(4);
end



ActualDots_xy(:,1)  = ActualDots_xy(:,1).*(RectWidth/2);
ActualDots_xy(:,2)  = ActualDots_xy(:,2).*(RectHeight/2);

RespDots_xy(:,1)    = RespDots_xy(:,1).*(RectWidth/2);
RespDots_xy(:,2)    = RespDots_xy(:,2).*(RectHeight/2);



% center data to original space

RectWidth   = ones(size(ProtoTable, 1), 1)*ProtoTable.Properties.UserData.orig.ShapeRect(3);
RectHeight  = ones(size(ProtoTable, 1), 1)*ProtoTable.Properties.UserData.orig.ShapeRect(4);
ActualDots_xy       = ActualDots_xy+[RectWidth/2 RectHeight/2];
RespDots_xy         = RespDots_xy+[RectWidth/2 RectHeight/2];


% update table
ProtoTable.ActualDots_xy        = ActualDots_xy;
ProtoTable.ResponseDots_xy      = RespDots_xy;

ProtoTable.Properties.UserData.ShapeRect            = ProtoTable.Properties.UserData.orig.ShapeRect;
ProtoTable.Properties.UserData.ShapeContainerRect   = ProtoTable.Properties.UserData.orig.ShapeContainerRect;


if any(strcmp(ProtoTable.Properties.VariableNames, 'errorXY'))
    ProtoTable = prototypes_compute_errorVectors(ProtoTable);
end
