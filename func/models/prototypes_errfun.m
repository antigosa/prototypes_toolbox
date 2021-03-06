function err = prototypes_errfun(modelfun, param, ProtoTable, opt_in)
% function err = prototypes_errfun(modelfun, param, ProtoTable, opt_in)

%ncategories = size(opt_in.Param0,1);

model_name = strrep(func2str(modelfun), 'prototypes_model_', '');


opt.w           = param(1);

if opt_in.fit_wOnly==0
    switch model_name
        case 'CAM'
            prototypes      = param(2:end);
            
        case 'LCAM'
            prototypes      = param(2:end-1);
            opt.stdL        = param(end);
    end
elseif opt_in.fit_wOnly==1
    switch model_name
        case 'CAM'
            prototypes      = reshape(vertcat(opt_in.Param0.Prototype{:}), 1, []);
            
        case 'LCAM'
            prototypes      = reshape(vertcat(opt_in.Param0.Prototype{:}), 1, []);
            opt.stdL        = param(end);
    end    
    
end
        

opt.prototypes          = reshape(prototypes, [], 2);
opt.method              = 'CategoryPrototypes';


% Models              = ProtoTable.Properties.UserData.Models.(model_name).param;
% Models.Prototype    = mat2cell(prototypes, ones(ncategories, 1), 2); %{prototypes};
% Models.w            = repmat(opt.w, ncategories, 1);
% Models.Properties.UserData.Description = 'Prototype and w updated after optimization procedure';
% ProtoTable              = prototypes_assignPrototypes2Targets(ProtoTable, Models);

ProtoTablePredicted     = modelfun(ProtoTable, opt);

PredictedResponses  = ProtoTablePredicted.ResponseDots_xy;

R2                  = prototypes_R2(ProtoTable, PredictedResponses, 'SST', 0); % 'SST' | 'mvarCorr'
% R2 = prototypes_R2(ProtoTable, PredictedResponses, [], 'mvarCorr', 0); % 'SST' | 'mvarCorr'
err = 1-R2;


if isfield(opt_in, 'figure') & ~isempty(opt_in.figure) & opt_in.figure~=0
    figure(opt_in.figure);clf;    
    axis square; axis(ProtoTable.Properties.UserData.ShapeRect([1 3 2 4]));set(gca, 'YDir', ProtoTable.Properties.UserData.YDir)
    
    % plot actual dots
    hold on; scatter(ProtoTable.ActualDots_xy(:,1), ProtoTable.ActualDots_xy(:, 2), 'MarkerFaceColor', [0.8 0.8 0.8], 'MarkerEdgeColor', 'none');
    
    % plot observed responses
    hold on; scatter(ProtoTable.ResponseDots_xy(:,1), ProtoTable.ResponseDots_xy(:, 2), 'MarkerFaceColor', 'k', 'MarkerEdgeColor', 'none');
    
    % plot predicted responses
    hold on; scatter(PredictedResponses(:,1), PredictedResponses(:, 2), 'MarkerFaceColor', 'r', 'MarkerEdgeColor', 'none');
    
    % plot prototypes
    hold on; scatter(opt.prototypes(:,1), opt.prototypes(:, 2), 'MarkerFaceColor', 'g', 'MarkerEdgeColor', 'k');
    
    % compute error vectors
    ProtoTable = prototypes_compute_errorVectors(ProtoTable);
    
    % plot observed error vectors
    hold on; quiver(ProtoTable.ActualDots_xy(:,1), ProtoTable.ActualDots_xy(:, 2), ProtoTable.errorXY(:, 1), ProtoTable.errorXY(:, 2), 0);
    
    % plot predicted error vectors
    hold on; quiver(ProtoTable.ActualDots_xy(:,1), ProtoTable.ActualDots_xy(:, 2), PredictedResponses(:, 1)-ProtoTable.ActualDots_xy(:,1), PredictedResponses(:, 2)-ProtoTable.ActualDots_xy(:,2), 0);
    
    l=legend({'Actual', 'Observed', 'Predicted', 'Observed error'});
    l.Box='On';l.Position([1 2]) = [0.71 0.72];
    l.FontSize=11;l.AutoUpdate='Off';
        
    ax=gca; ax.FontSize=12;
    ax.Position([1, 3]) = ax.Position([1, 3])-0.08;
    drawnow;

end

if isfield(opt_in, 'DisplayParam') & opt_in.DisplayParam==1
    opt.Experiment  = ProtoTable.Properties.UserData.Experiment;
    opt.prototypes  = prototypes;
    opt.err         = err;
    opt.model       = func2str(modelfun);
%     opt.R2 = R2;
%     opt.R2_corr = R2_corr;
    disp(opt);    
end