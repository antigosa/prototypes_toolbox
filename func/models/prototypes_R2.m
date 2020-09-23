function R2 = prototypes_R2(ActualData, Predicted_xy, method, doPlot)
% function ActualData = prototypes_R2(ActualData, Predicted_xy, model_name, method, doPlot)

if nargin<4 || ~exist('doPlot', 'var') || isempty(doPlot);doPlot=0;end
if nargin<3 || ~exist('method', 'var') || isempty(method);method='mvarCorr';end

% get the responses
RespDots_xy     = ActualData.ResponseDots_xy;

% get the targets
ActualDots_xy   = ActualData.ActualDots_xy;

% get the predicted responses
% Predicted_xy = ActualData.Properties.UserData.Models.(model_name).PredictedResp_xy;

switch method
    case 'SST'
        [R2, C, SST, SSR, SSM] = prototypes_R2_SST(ActualDots_xy, RespDots_xy, Predicted_xy, doPlot);
        
    case 'mvarCorr'
        [R2, C, SST, SSR, SSM] = prototypes_R2_mvarCorr(ActualDots_xy, RespDots_xy, Predicted_xy, doPlot);
        
    case 'euclideanDist'
        [R2, C, SST, SSR, SSM] = prototypes_R2_mvarEuclidean(ActualDots_xy, RespDots_xy, Predicted_xy, doPlot);
end


function [R2, C, SST, SSR, SSM] = prototypes_R2_SST(ActualDots_xy, RespDots_xy, Predicted_xy, doPlot)
% =========================================================================
% Compute R2
% =========================================================================

% prepare the origin vector
Orig = repmat([0 0], size(ActualDots_xy,1), 1);

% compute the real response errors
errorsAR = RespDots_xy(:) - ActualDots_xy(:);

% compute the predicted response errors
errorsAP = Predicted_xy(:)-ActualDots_xy(:);

% compute the residuals
errorsPR = Predicted_xy(:)-RespDots_xy(:);


% compute the total sum of squares
SST = nansum(errorsAR.^2);

% compute the residual sum of squares
SSR = nansum(errorsPR.^2);

% compute the model sum of squares
SSM = SST - SSR;

% compute R2
R2 = SSM/SST;

errorsAR = reshape(errorsAR, length(errorsAR)/2, 2);
errorsAP = reshape(errorsAP, length(errorsAP)/2, 2);
errorsPR = reshape(errorsPR, length(errorsPR)/2, 2);
[~,C] = kmeans(errorsAR(all(~isnan(errorsAR),2),:), 1);



if doPlot
    
    dotlist = 1:size(errorsAR, 1);
    
    % plot real response
    figure(100);clf; scatter(errorsAR(dotlist,1), errorsAR(dotlist, 2), 'filled');
    
    % plot predicted response
    hold on; scatter(errorsAP(dotlist,1), errorsAP(dotlist, 2), 'filled'); axis image;
    
    % plot real response error
    hold on; q=quiver(Orig(dotlist, 1), Orig(dotlist,2), errorsAR(dotlist,1), errorsAR(dotlist, 2), 0);
    q.LineStyle='-'; q.Color=[0.6 0.6 0.6];
    
    % plott predicted response error
    hold on; q=quiver(errorsAR(dotlist, 1), errorsAR(dotlist,2), errorsPR(dotlist,1), errorsPR(dotlist, 2), 0);
    q.LineStyle='-'; q.Color=[0.1 0.1 0.1];
    
    
    
    maxVal = max(max([errorsAR(dotlist,:); errorsAP(dotlist,:); errorsPR(dotlist,:)]));
    minVal= min(min([errorsAR(dotlist, :); errorsAP(dotlist, :)]));
    maxAx = max([maxVal abs(minVal)]) + 0.1*max([maxVal abs(minVal)]);
    axis([-maxAx maxAx -maxAx maxAx]);
    
    fig=gcf; fig.Position=[623 382 617 455];
    
    hold on; scatter(C(1), C(2), 'SizeData', 30, 'MarkerFaceColor', 'g', 'MarkerEdgeColor', 'k');
    
    l=legend({'Responses', 'Predicted', 'Data variance', 'Residuals', 'Centroid'});
    l.Box='Off';l.Position([1 2]) = [0.75 0.75];
    l.FontSize=12;l.AutoUpdate='Off';
    ax=gca;ax.FontSize=11;
%     ax.XTick=[round(ax.XLim(1))/2 round(mean(ax.XLim)) round(ax.XLim(2))/2];
%     ax.YTick=[round(ax.YLim(1))/2 round(mean(ax.YLim)) round(ax.YLim(2))/2];
    
    display(R2);
    
    text(-0.9*maxAx, 0.9*maxAx, sprintf('R^2: %.04f', R2), 'FontSize', 14);
    
    plot([-maxAx maxAx], [0 0], 'Color', [0.8 0.8 0.8], 'LineStyle', '--');
    plot([0 0], [-maxAx maxAx],  'Color', [0.8 0.8 0.8], 'LineStyle', '--');
end


function [R2, C, SST, SSR, SSM] = prototypes_R2_mvarCorr(ActualDots_xy, RespDots_xy, Predicted_xy, doPlot)

C=[];
SST = []; SSR = []; SSM = [];

% compute the real response errors
errorsAR = RespDots_xy - ActualDots_xy;

% compute the predicted response errors
errorsAP = Predicted_xy-ActualDots_xy;

%
errorsAP = zscore(errorsAP, 1);
errorsAR = zscore(errorsAR, 1);

[R,P] = corr(errorsAR(:), errorsAP(:));
R2=R^2;

if doPlot
    figure(100);clf;
    hold on; scatter(errorsAP(:), errorsAR(:), 'filled');
    axis square; drawnow;
    title(sprintf('R^2: %.04f', R2));
end


function [R2, C] = prototypes_R2_mvarEuclidean(ActualDots_xy, RespDots_xy, Predicted_xy, doPlot)

C=[];

% compute the real response errors
errorsAR = RespDots_xy - ActualDots_xy;

% compute the predicted response errors
errorsAP = Predicted_xy-ActualDots_xy;

R2 = pdist([errorsAR(:)'; errorsAP(:)'],'seuclidean');

if doPlot
    figure; scatter(errorsAR(:), errorsAP(:), 'filled');
    title(sprintf('R^2: %.04f', R2));
end

