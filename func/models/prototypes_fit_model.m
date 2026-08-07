function param = prototypes_fit_model(ProtoTable, modelfun, param0, opt)
% function ProtoTable = prototypes_fit_model(ProtoTable, modelfun, opt)
%
% default model: prototypes_model_CAM

if nargin ==1 || isempty(modelfun); modelfun=@prototypes_model_CAM; end
if nargin<4; opt=[];end
if ~isfield(opt, 'fit_wOnly'); opt.fit_wOnly=0;end
if isfield(opt, 'prototypesXY'); opt.fit_wOnly=1;end
if ~isfield(opt, 'DisplayIter'); opt.DisplayIter='Off';end


errfun = @(param)  prototypes_errfun(modelfun, param, ProtoTable, opt);


switch func2str(modelfun)
    case 'prototypes_model_CAM_noBoundaries'
        % This is the simplest original model by Huttenlocher et al, 1991.
        % It does have 2 parameters:
        % w: is the weight given to the fine-grain memory
        % P: the prototypes locations
        %
        
        % PROBABLY I DON'T NEED THIS ANYMORE, I CAN JUST USE 'prototypes_model_CAM'
        param_init = [unique(param0.w) (reshape(cell2mat(param0.Prototype), [], 1))'];
        
        if opt.fit_wOnly
            param_init = unique(Param0.w);
        end
        
    case 'prototypes_model_CAM'
        % This is the simplest original model by Huttenlocher et al, 1991.
        % It does have 3 parameters:
        % w: is the weight given to the fine-grain memory
        % P: the prototypes locations
        % ST: the trunctation parameter
        %
        % note that the prototypes are treated as separated parameters
        if ~opt.fit_wOnly
            %         param_init = [param0.Param0.w reshape(param0.Param0.Prototype, 1, [])];
            param_init = [unique(param0.w_theta) unique(param0.w_r) reshape(param0.prototypesXY, 1, [])];
        else
            
            param_init = [unique(param0.w_theta) unique(param0.w_r)];
        end
        
        
    case 'prototypes_model_LCAM'
        % This is my version of the CA model. The difference with the
        % previous version is that it takes into account the fact that when
        % there is a landmark, errors close to the landmark are smaller.
        % This model have 3 parameters
        % w: is the weight given to the fine-grain memory
        % P: the prototypes locations
        % stdL0: the correction due to the landmark
        %
        
        param_init = [unique(param0.w) (reshape(cell2mat(param0.Prototype), [], 1))' unique(param0.stdL)];
        if opt.fit_wOnly
            param_init = [unique(param0.w) unique(param0.stdL)];
        end
        
end

% param_init = cell2mat(param_init);

[fP, fR, exitFlag, output] = fminsearch(errfun, param_init, optimset('Display',opt.DisplayIter, 'MaxIter', 5000, 'MaxFunEvals', prod(size(param_init))*500)); % iter
% [fP, fR, exitFlag, output] = fminsearchbnd(errfun, param_init, lb, ub, optimset('Display',opt.DisplayIter, 'MaxIter', 5000, 'MaxFunEvals', prod(size(param_init))*500)); % iter
% [fP, fR, exitFlag, output] = fminunc(errfun, param_init, optimset('Display',opt.DisplayIter, 'MaxIter', 5000, 'MaxFunEvals', prod(size(param_init))*500)); % iter

param = param0;
switch func2str(modelfun)
    
    case 'prototypes_model_CAM_noBoundaries'
        param.w                 = repmat(fP(1), size(param,1),1);
        
        if ~opt.fit_wOnly
            param.Prototype         = mat2cell(reshape(fP(2:end), [], 2), ones(size(param,1),1),2);
        else
            param.Prototype         = mat2cell(reshape(vertcat(opt.Param0.Prototype{:}), [], 2), ones(size(param,1),1),2);
        end
        
    case 'prototypes_model_CAM'
        param.w_theta               = repmat(fP(1), size(param,1),1);
        param.w_r                   = repmat(fP(2), size(param,1),1);
        %         param.Prototype         = {reshape(fP(2:3), 1, 2)};
        %         param.stdTRB            = fP(end);
        if ~opt.fit_wOnly            
            param.prototypesXY    = reshape(fP(3:end), [], 2);
        else
            %             param.Prototype         = mat2cell(reshape(vertcat(opt.Param0.Prototype{:}), [], 2), ones(size(param,1),1),2);
            %             param.Prototype         = mat2cell(reshape(vertcat(opt.Param0.Prototype{:}), [], 2), ones(size(param,1),1),2);
        end
        
    case 'prototypes_model_LCAM'
        param.w                 = repmat(fP(1), size(param,1),1);
        
        if ~opt.fit_wOnly
            param.Prototype         = mat2cell(reshape(fP(2:end-1), [], 2), ones(size(param,1),1),2);
        else
            param.Prototype         = mat2cell(reshape(vertcat(opt.Param0.Prototype{:}), [], 2), ones(size(param,1),1),2);
        end
        param.stdL              = repmat(fP(end), size(param,1),1);
        
end

% param.Err = repmat(fR, size(param,1),1);
param.Err = fR;
param.R2 = 1-param.Err;

N = size(ProtoTable,1);
k = length(fP);
param.R2_adj = 1-((1-param.R2).*(N-1))./(N-k-1);