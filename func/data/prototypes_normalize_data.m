function Trials = prototypes_normalize_data(Trials, dim)
% function Trials = prototypes_normalize_data(Trials, dim)
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

if isfield(Trials.Properties.UserData, 'orig')
    warning('this data seems already normalized! exiting...');
    return;
end

if isempty(dim)
    if Trials.Properties.UserData.ShapeRect(3) < Trials.Properties.UserData.ShapeRect(4)
        dim = 2;
        
    elseif Trials.Properties.UserData.ShapeRect(3) > Trials.Properties.UserData.ShapeRect(4)
        dim = 1;
    else
        dim = 'both';
    end
end

RectWidth   = ones(size(Trials, 1), 1)*Trials.Properties.UserData.ShapeRect(3);
RectHeight  = ones(size(Trials, 1), 1)*Trials.Properties.UserData.ShapeRect(4);

% center data to zero
ActualDots_xy = Trials.ActualDots_xy-[RectWidth/2 RectHeight/2];
RespDots_xy = Trials.ResponseDots_xy-[RectWidth/2 RectHeight/2];


% normalize
switch dim
    case {1}
        RectWidth   = ones(size(Trials, 1), 1)*Trials.Properties.UserData.ShapeRect(3);
        RectHeight  = RectWidth;
        
    case {2}
        RectHeight  = ones(size(Trials, 1), 1)*Trials.Properties.UserData.ShapeRect(4);
        RectWidth   = RectHeight;
        
    case 'both'        
        RectWidth   = ones(size(Trials, 1), 1)*Trials.Properties.UserData.ShapeRect(3);
        RectHeight  = ones(size(Trials, 1), 1)*Trials.Properties.UserData.ShapeRect(4);
end



ActualDots_xy(:,1) = ActualDots_xy(:,1)./(RectWidth/2);
ActualDots_xy(:,2) = ActualDots_xy(:,2)./(RectHeight/2);

RespDots_xy(:,1) = RespDots_xy(:,1)./(RectWidth/2);
RespDots_xy(:,2) = RespDots_xy(:,2)./(RectHeight/2);


% update table
Trials.ActualDots_xy        = ActualDots_xy;
Trials.ResponseDots_xy      = RespDots_xy;

Trials.Properties.UserData.orig.ShapeRect           = Trials.Properties.UserData.ShapeRect;
Trials.Properties.UserData.orig.ShapeContainerRect  = Trials.Properties.UserData.ShapeContainerRect;

switch dim
    case {1}
        Trials.Properties.UserData.ShapeRect                = [-1 -0.5 1 0.5];        
        
    case {2}
        Trials.Properties.UserData.ShapeRect                = [-0.5 -1 0.5 1];
        
    case 'both'
        Trials.Properties.UserData.ShapeRect                = [-1 -1 1 1];
        
end

Trials.Properties.UserData.ShapeContainerRect       = Trials.Properties.UserData.ShapeRect + Trials.Properties.UserData.ShapeRect.*0.10;

if any(strcmp(Trials.Properties.VariableNames, 'errorXY'))
    Trials = prototypes_compute_errorVectors(Trials);
end

% if any(strcmp(Trials.Properties.VariableNames, 'ActualDots_polar'))
%     Trials = prototypes_compute_polarData(Trials);
% end
%
% if isfield(Trials.Properties.UserData, 'kmeans')
%     RectWidth = RectWidth(1);
%     RectHeight = RectHeight(1);
%     dataTypes = fieldnames(Trials.Properties.UserData.kmeans);
%     for f = 1:length(dataTypes)
%         Trials.Properties.UserData.kmeans.(dataTypes{f}).clusterInfo.Centroid = Trials.Properties.UserData.kmeans.(dataTypes{f}).clusterInfo.Centroid-[RectWidth/2 RectHeight/2];
%         Trials.Properties.UserData.kmeans.(dataTypes{f}).clusterInfo.Centroid = Trials.Properties.UserData.kmeans.(dataTypes{f}).clusterInfo.Centroid./[RectWidth/2 RectHeight/2];
%     end
% end
%
% if isfield(Trials.Properties.UserData, 'Models')
%     RectWidth = RectWidth(1);
%     RectHeight = RectHeight(1);
%     model_list = fieldnames(Trials.Properties.UserData.Models);
%
%     % I SHOULD DO THIS FOR ALL PARTICIPANTS!!
%     for m = 1:numel(model_list)
%         prototypes_pos = (Trials.Properties.UserData.Models.(model_list{m}).param.prototypes{1}-[RectWidth/2 RectHeight/2]);
%         prototypes_pos = prototypes_pos./([RectWidth/2 RectHeight/2]);
%         Trials.Properties.UserData.Models.(model_list{m}).param.prototypes{1} = prototypes_pos;
%
%         if isfield(Trials.Properties.UserData.Models.(model_list{m}), 'PredictedResp_xy')
%             PredictedResp_xy = (Trials.Properties.UserData.Models.(model_list{m}).PredictedResp_xy-[RectWidth/2 RectHeight/2]);
%             PredictedResp_xy = PredictedResp_xy./([RectWidth/2 RectHeight/2]);
%             Trials.Properties.UserData.Models.(model_list{m}).PredictedResp_xy = PredictedResp_xy;
%         end
%
%
%     end
%
% end

