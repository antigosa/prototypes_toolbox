function Trials = prototypes_denormalize_data(Trials)
% function Trials = prototypes_denormalize_data(Trials)
%
% Target and Response dots will be rescaled to the original axis as defined
% in .orig. It won't work if this field is not present.
%
% Other fields will be also transformed:
% .Axis         = .orig.Axis
% .Rectangle    = .orig.Rectangle
% .RectWidth    = .orig.RectWidth
% .RectHeight   = .orig.RectHeight
%
% Note that this function also recompute the errors
% It also recompute the polar data, if present
%
% The .orig field will be removed
%
% If .kmeans is present, it also rescales the centroid
% If .Models is present, it also rescale the parameters (prototypes
% position) and the predicted responses.
%
% To normalize, use prototypes_normalize_data
%
% RT 20190409


RectWidth = Trials.Properties.UserData.orig.RectWidth;
RectHeight = Trials.Properties.UserData.orig.RectHeight;

ActualDots_xy = Trials.ActualDots_xy;
RespDots_xy = Trials.RespDots_xy;

% denormalize

ActualDots_xy(:,1) = ActualDots_xy(:,1).*(RectWidth/2);
ActualDots_xy(:,2) = ActualDots_xy(:,2).*(RectHeight/2);

RespDots_xy(:,1) = RespDots_xy(:,1).*(RectWidth/2);
RespDots_xy(:,2) = RespDots_xy(:,2).*(RectHeight/2);


% center data to original center
ActualDots_xy = ActualDots_xy+[RectWidth/2 RectHeight/2];
RespDots_xy = RespDots_xy+[RectWidth/2 RectHeight/2];



% update table
Trials.ActualDots_xy    = ActualDots_xy;
Trials.RespDots_xy      = RespDots_xy;

Trials.Properties.UserData.RectWidth   = RectWidth;
Trials.Properties.UserData.RectHeight  = RectHeight;

Trials.Properties.UserData.Rectangle   = Trials.Properties.UserData.orig.Rectangle;
if isfield(Trials.Properties.UserData, 'Axis')
    Trials.Properties.UserData.Axis        = Trials.Properties.UserData.orig.Axis;
else
    warning('future version will want Trials.Properties.UserData.axis');
end

if any(strcmp(Trials.Properties.VariableNames, 'errorXY'))
    Trials = prototypes_compute_errorVectors(Trials);
end

if any(strcmp(Trials.Properties.VariableNames, 'ActualDots_polar'))
    Trials = prototypes_compute_polarData(Trials);
end

if isfield(Trials.Properties.UserData, 'Models')
        
    model_list = fieldnames(Trials.Properties.UserData.Models);
    for m = 1:length(model_list)
        
        for s=1:size(Trials.Properties.UserData.Models.(model_list{m}).param,1)
            prototypes = Trials.Properties.UserData.Models.(model_list{m}).param.prototypes{s};
            prototypes = prototypes.*[RectWidth/2 RectHeight/2];
            prototypes = prototypes+[RectWidth/2 RectHeight/2];
            Trials.Properties.UserData.Models.(model_list{m}).param.prototypes{s} = prototypes;
            
            if any(strcmp(Trials.Properties.UserData.Models.(model_list{m}).param.Properties.VariableNames, 'landmark'))
                landmark = Trials.Properties.UserData.Models.(model_list{m}).param.landmark;
                
                landmark = landmark.*[RectWidth/2 RectHeight/2];
                landmark = landmark+[RectWidth/2 RectHeight/2];
                
                Trials.Properties.UserData.Models.(model_list{m}).param.landmark = landmark;
            end
            
            if isfield(Trials.Properties.UserData.Models.(model_list{m}), 'PredictedResp_xy')
                PredictedResp_xy = Trials.Properties.UserData.Models.(model_list{m}).PredictedResp_xy;
                PredictedResp_xy = PredictedResp_xy.*([RectWidth/2 RectHeight/2]);
                PredictedResp_xy = (PredictedResp_xy+[RectWidth/2 RectHeight/2]);                
                Trials.Properties.UserData.Models.(model_list{m}).PredictedResp_xy = PredictedResp_xy;
            end                
        end
    end
end

if isfield(Trials.Properties.UserData, 'kmeans')
    RectWidth = RectWidth(1);
    RectHeight = RectHeight(1);
    dataTypes = fieldnames(Trials.Properties.UserData.kmeans);
    for f = 1:length(dataTypes)
        Trials.Properties.UserData.kmeans.(dataTypes{f}).clusterInfo.Centroid = Trials.Properties.UserData.kmeans.(dataTypes{f}).clusterInfo.Centroid.*[RectWidth/2 RectHeight/2];
        Trials.Properties.UserData.kmeans.(dataTypes{f}).clusterInfo.Centroid = Trials.Properties.UserData.kmeans.(dataTypes{f}).clusterInfo.Centroid+[RectWidth/2 RectHeight/2];
    end
end


Trials.Properties.UserData = rmfield(Trials.Properties.UserData, 'orig');