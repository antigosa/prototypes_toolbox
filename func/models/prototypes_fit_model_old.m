function Trials = prototypes_fit_model(Trials, modelfun, opt)
% function Trials = prototypes_fit_model(Trials, modelfun, opt)
%
% default model: prototypes_model_CAM

if nargin ==1 || isempty(modelfun); modelfun=@prototypes_model_CAM; end
if nargin<3; opt=[];end
if ~isfield(opt, 'fit_wOnly'); opt.fit_wOnly=0;end

model_name = strrep(func2str(modelfun), 'prototypes_model_', '');
% Model = helper_initialize_modelStruc(Trials, model_name);


subjlist = unique(Trials.subj_id);
nsubj = length(subjlist);

Trials = prototypes_assignPrototypes2Targets(Trials, opt.Param0);
Model = Trials.Properties.UserData.Models.(model_name);

if nsubj>1
    % if there are many participants    

    Model.(model_name) = [];
    Model.(model_name).param = table;
    for s=1:nsubj
        subNum=subjlist(s);        
        subjTrials = prototypes_select_subjects(Trials, subNum);
               
        cat_ids = unique(Model.param.CategoryID);
    
        ncategories = length(cat_ids);


        param = cell(ncategories, 1);
        for c = 1:ncategories
            cat_id = cat_ids(c);
            Param0 = Model.param;

            Trials_toFit = subjTrials(subjTrials.CategoryID==cat_id,:);
            Trials_toFit.Properties.UserData.Models.(model_name).param(Trials_toFit.Properties.UserData.Models.(model_name).param.CategoryID~=cat_id, :)=[];
            Param0(Param0.CategoryID~=cat_id,:)=[];

            % fit the data
            param{c} = prototypes_fit_model_aSubj(Trials_toFit, modelfun, Param0, opt);
            param{c}.CategoryID = Param0.CategoryID;%unique(Trials_toFit.CategoryID);
        end

        param = vertcat(param{:});        
        
        
        subj_id = repmat(subNum, size(param,1),1);
        atable = [table(subj_id), param];        
        Model.(model_name).param = [Model.(model_name).param; atable];
    end
    
    if isfield(Trials.Properties.UserData.Models, model_name)
        warning('removing previous fit');
    end
    Trials.Properties.UserData.Models.(model_name).param = Model.(model_name).param;
    
%     Trials              = prototypes_denormalize_data(Trials);
        
else
    % =====================================================================
    % Fit data for a group (NOTE: CHECK IF IT ENTERS HERE ALSO WHEN THERE 
    % IS ONLY ONE PARTICIPANT).
    % =====================================================================
    
    
    % you have to fit the categories separately 
    
    cat_ids = unique(Model.param.CategoryID);
    
    ncategories = length(cat_ids);
           

    param = cell(ncategories, 1);
    for c = 1:ncategories
        cat_id = cat_ids(c);
        Param0 = Model.param;

        Trials_toFit = Trials(Trials.CategoryID==cat_id,:);
        Trials_toFit.Properties.UserData.Models.(model_name).param(Trials_toFit.Properties.UserData.Models.(model_name).param.CategoryID~=cat_id, :)=[];
        Param0(Param0.CategoryID~=cat_id,:)=[];
        
        % fit the data
        param{c} = prototypes_fit_model_aSubj(Trials_toFit, modelfun, Param0, opt);
        param{c}.CategoryID = Param0.CategoryID; %  unique(Trials_toFit.CategoryID);
    end
    
    param = vertcat(param{:});
    
    % this should be a group
    subj_id = repmat({'group'}, size(param,1),1);
    
    % output table
    atable = [table(subj_id), param];
    
    % add to the prototypes table
    if isfield(Trials.Properties.UserData.Models, model_name)
        warning('removing previous fit');
        Trials.Properties.UserData.Models.(model_name).param = [];
    end
%     Trials.Properties.UserData.Models.(model_name).param = Model.(model_name).param;    
    Trials.Properties.UserData.Models.(model_name).param = atable;
    Trials.Properties.UserData.Models.(model_name).Description = 'optimal parameters obtained by the fitting procedure';

end


function param = prototypes_fit_model_aSubj(Trials, modelfun, Param0, opt)

if ~isfield(opt, 'DisplayIter'); opt.DisplayIter='Off';end
errfun = @(param)  prototypes_errfun(modelfun, param, Trials, opt);


switch func2str(modelfun)
    case 'prototypes_model_CAM_noBoundaries'
        % This is the simplest original model by Huttenlocher et al, 1991.
        % It does have 2 parameters:
        % w: is the weight given to the fine-grain memory
        % P: the prototypes locations
        %        
        
        lb = [0 repmat(-Inf, 1, size(Param0.Prototype,1))];
        ub = [1 repmat(Inf, 1, size(Param0.Prototype,1))];
        param_init = [unique(Param0.w) (reshape(cell2mat(Param0.Prototype), [], 1))'];
        
        if opt.fit_wOnly
            param_init = unique(Param0.w);
            lb = [0];
            ub = [1];
        end
        
    case 'prototypes_model_CAM'
        % This is the simplest original model by Huttenlocher et al, 1991.
        % It does have 2 parameters:
        % w: is the weight given to the fine-grain memory
        % P: the prototypes locations
        % ST: the trunctation parameter
        %
        % note that the prototypes are treated as separated parameters
        
        lb = [0 -Inf -Inf 0];
        ub = [1 Inf Inf Inf];        
        param_init = [Param0.w Param0.Prototype(:)' Param0.stdTRB];
        
        
        
    case 'prototypes_model_LCAM'
        % This is my version of the CA model. The difference with the
        % previous version is that it takes into account the fact that when
        % there is a landmark, errors close to the landmark are smaller.
        % This model have 3 parameters
        % w: is the weight given to the fine-grain memory
        % P: the prototypes locations
        % stdL0: the correction due to the landmark
        %
        lb = [0 repmat(-Inf, 1, size(Param0.Prototype,1)) 0];
        ub = [1 repmat(Inf, 1, size(Param0.Prototype,1)) Inf];        
%         lb = [0 -Inf -Inf 0];
%         ub = [1 Inf Inf Inf];
        param_init = [unique(Param0.w) (reshape(cell2mat(Param0.Prototype), [], 1))' unique(Param0.stdL)];
        if opt.fit_wOnly
            param_init = [unique(Param0.w) unique(Param0.stdL)];
            lb = [0 0];
            ub = [1 300]; % 100 is already almost 4 STD, I should compute this better
        end
        
end

% param_init = cell2mat(param_init);

[fP, fR, exitFlag, output] = fminsearch(errfun, param_init, optimset('Display',opt.DisplayIter, 'MaxIter', 5000, 'MaxFunEvals', prod(size(param_init))*500)); % iter
% [fP, fR, exitFlag, output] = fminsearchbnd(errfun, param_init, lb, ub, optimset('Display',opt.DisplayIter, 'MaxIter', 5000, 'MaxFunEvals', prod(size(param_init))*500)); % iter
% [fP, fR, exitFlag, output] = fminunc(errfun, param_init, optimset('Display',opt.DisplayIter, 'MaxIter', 5000, 'MaxFunEvals', prod(size(param_init))*500)); % iter

param = Param0;
switch func2str(modelfun)
    
    case 'prototypes_model_CAM_noBoundaries'
        param.w                 = repmat(fP(1), size(param,1),1);
        
        if ~opt.fit_wOnly
            param.Prototype         = mat2cell(reshape(fP(2:end), [], 2), ones(size(param,1),1),2);
        else
            param.Prototype         = mat2cell(reshape(vertcat(opt.Param0.Prototype{:}), [], 2), ones(size(param,1),1),2);
        end
    
    case 'prototypes_model_CAM'
        param.w                 = fP(1);
        param.Prototype         = {reshape(fP(2:3), 1, 2)};
        param.stdTRB            = fP(end);
	
    case 'prototypes_model_LCAM'
        param.w                 = repmat(fP(1), size(param,1),1);
        
        if ~opt.fit_wOnly
            param.Prototype         = mat2cell(reshape(fP(2:end-1), [], 2), ones(size(param,1),1),2);            
        else
            param.Prototype         = mat2cell(reshape(vertcat(opt.Param0.Prototype{:}), [], 2), ones(size(param,1),1),2);
        end
        param.stdL              = repmat(fP(end), size(param,1),1);

end

param.Err = repmat(fR, size(param,1),1);
param.R2 = 1-param.Err;

N = size(Trials,1);
k = length(fP);
param.R2_adj = 1-((1-param.R2).*(N-1))./(N-k-1);



function [Trials, opt] = helper_normalize_data(Trials, opt)


if ~isfield(Trials.Properties.UserData, 'orig')
    
    Trials = prototypes_normalize_data(Trials);
    
    orig = Trials.Properties.UserData.orig;
    
    opt.P0 = opt.P0 - [orig.RectWidth/2 orig.RectHeight/2];
    opt.P0 = opt.P0 ./ [orig.RectWidth/2 orig.RectHeight/2];
    
    if isfield(opt, 'landmark')
        opt.landmark = opt.landmark - [orig.RectWidth/2 orig.RectHeight/2];
        opt.landmark = opt.landmark ./ [orig.RectWidth/2 orig.RectHeight/2];
    end
end

function Model = helper_initialize_modelStruc(Trials, model_name)

% check if already exists a model fit for this dataset
if isfield(Trials.Properties.UserData, 'Models')
    if isfield(Trials.Properties.UserData.Models, model_name)        
        Model.(model_name).param = Trials.Properties.UserData.Models.(model_name).param;
    else
        Model = Trials.Properties.UserData.Models;
        Model.(model_name).param = table;
    end
else
    Model.(model_name).param = table;
end

warning('For the moment, it is not allow to provide .param for the same model');
Model.(model_name).param = table;
