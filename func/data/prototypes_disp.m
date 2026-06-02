function prototypes_disp(Trials, infoType)
% function prototypes_disp(Trials, infoType)
% 
% infoType:
% - 'generic'
% - 'model_fitting'
% - 'errMagVSecc'

if ~exist('infoType', 'var'); infoType='generic'; end

allowed_infoType = {'generic', 'prototypes', 'model_fitting', 'errMagVSecc'};

if ~ismember(infoType, allowed_infoType)
    warning('you can choose between the following:');
    disp(allowed_infoType);
end

switch infoType
    case 'generic'
        prototypes_disp_generic(Trials)
        
    case 'prototypes'
        
        % this work for the classical prototypes (Huttenlocher style) for now    
        prototypes_disp_prototypes(Trials)
        
    case 'model_fitting'
        prototypes_disp_modelFit(Trials)
        
    case 'errMagVSecc'
        prototypes_disp_errMagVSecc(Trials);
                
end


function prototypes_disp_generic(Trials)
VariableNames = Trials.Properties.VariableNames;
fprintf('===================\n');
fprintf('\tVariable Names:\n');
fprintf('===================\n');
disp(VariableNames');


% UserData = fieldnames(Trials.Properties.UserData);
UserData = Trials.Properties.UserData;

fprintf('===================\n');
fprintf('\tUser Data:\n');
fprintf('===================\n');
disp(UserData);

fprintf('===================\n');
fprintf('\tCosine Data:\n');
fprintf('===================\n');
if isfield(Trials.Properties.UserData, 'cosine_map')
    CosineData = fieldnames(Trials.Properties.UserData.cosine_map);
    disp(CosineData);
    
    if isfield(Trials.Properties.UserData.cosine_map, 'puncorr')
        fprintf('\t\tpuncorr: %04f\n', Trials.Properties.UserData.cosine_map.puncorr);
    end
    if isfield(Trials.Properties.UserData.cosine_map, 'montecarlo_info')
        
        montecarlo_info = Trials.Properties.UserData.cosine_map.montecarlo_info;
        disp(montecarlo_info);
    end
else
    fprintf('\tNot performed\n\n');
end

fprintf('===================\n');
fprintf('\tKDE Data:\n');
fprintf('===================\n');
if isfield(Trials.Properties.UserData, 'KDE')
    KDEData = fieldnames(Trials.Properties.UserData.KDE);
    disp(KDEData);
    
    if isfield(Trials.Properties.UserData.KDE, 'puncorr')
        fprintf('\t\tpuncorr: %04f\n', Trials.Properties.UserData.KDE.puncorr);
    end
    if isfield(Trials.Properties.UserData.KDE, 'montecarlo_info')
        
        montecarlo_info = Trials.Properties.UserData.KDE.montecarlo_info;
        disp(montecarlo_info);
    end
else
    fprintf('\tNot performed\n\n');
end

fprintf('===================\n');
fprintf('\tkmeans Data:\n');
fprintf('===================\n');
if isfield(Trials.Properties.UserData, 'kmeans')
    kmeansData = fieldnames(Trials.Properties.UserData.kmeans);
    disp(kmeansData);
    
    if isfield(Trials.Properties.UserData.kmeans, 'puncorr')
        fprintf('\t\tpuncorr: %04f\n', Trials.Properties.UserData.kmeansData.puncorr);
    end
    if isfield(Trials.Properties.UserData.kmeans, 'montecarlo_info')
        
        montecarlo_info = Trials.Properties.UserData.kmeans.montecarlo_info;
        disp(montecarlo_info);
    end
else
    fprintf('\tNot performed\n\n');
end

fprintf('===================\n');
fprintf('\tModel fitting:\n');
fprintf('===================\n');
if isfield(Trials.Properties.UserData, 'Models') && ~isempty(Trials.Properties.UserData.Models)
    Models = fieldnames(Trials.Properties.UserData.Models);
    disp(Models);
   
else
    fprintf('\tNot performed\n\n');
end


function prototypes_disp_prototypes(Trials)

fprintf('============================================================\n');
fprintf('\tPrototypes position based on similarity map:\n');
fprintf('============================================================\n');


prototypesInfo = Trials.Properties.UserData.cosine_map.prototypesInfo;
select_col = ismember(prototypesInfo.Properties.VariableNames, {'Centroid', 'Centroid_polar', 'WeightedCentroid', 'wCentroid_polar', 'PeakPos', 'Peak_polar', 'Quadrant'});
prototypesInfo=prototypesInfo(:,select_col);
prototypesInfo=prototypesInfo(:, [4 1 5 2 6 3 7]);
% prototypesInfo.Centroid_polar(:,1) = -1*rad2deg(prototypesInfo.Centroid_polar(:,1));
% prototypesInfo.wCentroid_polar(:,1) = -1*rad2deg(prototypesInfo.wCentroid_polar(:,1));
% prototypesInfo.Peak_polar(:,1) = -1*rad2deg(prototypesInfo.Peak_polar(:,1));

% pos_avg = varfun(@mean,pos);
% pos_avg.Properties.VariableNames = pos.Properties.VariableNames;
% pos_avg.Centroid(end,:) = [NaN NaN];
% pos = [pos;pos_avg];
prototypes_SimMap = prototypesInfo;

display(prototypes_SimMap);
fprintf('============================================================\n');
fprintf('\tPrototypes position based on error magnitude analysis:\n');
fprintf('============================================================\n');

ErrorMag = Trials.Properties.UserData.Bias.ErrorMag;
select_col = ismember(ErrorMag.Properties.VariableNames, {'Quadrant', 'Ymin_Val', 'Xmin_Val', 'Analysis'});
ErrorMag = ErrorMag(:, select_col);
prototypes_ErrorMag = ErrorMag;
display(prototypes_ErrorMag);


fprintf('============================================================\n');
fprintf('\tPrototypes position based on bias analysis:\n');
fprintf('============================================================\n');
Angular = Trials.Properties.UserData.Bias.Angular;
select_col = ismember(Angular.Properties.VariableNames, {'Quadrant', 'Roots', 'Analysis'});
Angular = Angular(:, select_col);
prototypes_Angular = Angular;
display(prototypes_Angular);


Radial = Trials.Properties.UserData.Bias.Radial;
select_col = ismember(Radial.Properties.VariableNames, {'Quadrant', 'Roots', 'Analysis'});
Radial = Radial(:, select_col);
prototypes_Radial = Radial;
display(prototypes_Radial);


function prototypes_disp_modelFit(Trials)

fprintf('==================================================================\n');
fprintf('\tModel fitting:\n');
fprintf('==================================================================\n');

if ~isfield(Trials.Properties.UserData, 'Models')
    fprintf('\tNot performed\n\n');
    return;
end

Models = Trials.Properties.UserData.Models;
model_names = fieldnames(Models);

for m = 1:length(model_names)
    fprintf('Model: %s\n',model_names{m});
%     R2 = Models.(model_names{m}).R2;
%     T = [Models.(model_names{m}).param table(R2)];
    T = Models.(model_names{m}).param;
    disp(T)    
end
fprintf('==================================================================\n');
fprintf('\tModel fitting\n');
fprintf('==================================================================\n');


function prototypes_disp_errMagVSecc(Trials)

fprintf('==================================================================\n');
fprintf('\tError Magnitude ~ Eccentricity:\n');
fprintf('==================================================================\n');

if ~isfield(Trials.Properties.UserData, 'errorMagVSeccentricity')
    fprintf('\tNot performed\n\n');
    return;
    
else
    % old version, it should not happen again in the future
    if isnumeric(Trials.Properties.UserData.errorMagVSeccentricity.Stat.Model)
        fprintf('\terrorMagVSeccentricity was computed with an old version, repeated the analysis again\n\n');
        return;
    end

end



errorMagVSecc = Trials.Properties.UserData.errorMagVSeccentricity.Stat;
c = coeffvalues(errorMagVSecc.Model);
fprintf('Y = %s\n', formula(errorMagVSecc.Model));
 
if length(c) == 2
    fprintf('Y = %.03f + %.02f*x\n', c(2), c(1));
elseif length(c) == 3
    fprintf('Y = %.03f + %.02f*x + %.02f*x^2\n', c(3), c(2), c(1));
elseif length(c) == 4
    fprintf('Y = %.03f + %.02f*x + %.02f*x^2 + %.02f*x^3 \n', c(4), c(3), c(2), c(1));    
end

fprintf('GOF (R2adj)= %.03f \n', errorMagVSecc.gof.adjrsquare);

fprintf('==================================================================\n');
fprintf('\tError Magnitude ~ Eccentricity\n');
fprintf('==================================================================\n');
