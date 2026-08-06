function Trials = prototypes_assignPrototypes2Targets(Trials, Model, opt)
% function Trials = prototypes_assignPrototypes2Targets(Trials, Model, opt)

if nargin<3;opt = [];end

if ~isfield(opt, 'assignmentMethod'); opt.assignmentMethod='CategoryPrototypes';end
if ~isfield(opt, 'Shape'); opt.Shape=[];end

if ~isempty(opt.Shape)
    Trials = prototypes_assignPrototypes2Targets_boundedCategories(Trials, Model);
    
else
    switch opt.assignmentMethod
        case 'CategoryPrototypes'
            Trials = prototypes_assignPrototypes2Targets_unboundedCategories(Trials, Model);
            
        case 'ClosestPrototypes'
            Trials = prototypes_assignPrototypes2Targets_closestPrototypes(Trials, Model);
    end
    
end

% % % MAYBE I DO NOT NEED THIS
% Trials.Properties.UserData.Categories = Model;
% modelName = Model.Properties.UserData.ModelName;
% Trials.Properties.UserData.Models.(modelName).param = Model;
% Trials.Properties.UserData.Models.(modelName).Description = Model.Properties.UserData.Description;


function Trials = prototypes_assignPrototypes2Targets_boundedCategories(Trials, Model)

shape = Model.Properties.UserData.Shape;

switch shape
    case {'Circle', 'circle'}
%         warning('fix this');
        % if it is on the category boundary
        boundariesVal       = vertcat(Model.Boundaries{:});
        boundariesVal       = [unique(boundariesVal(~isinf(boundariesVal(:,1)),1)) unique(boundariesVal(~isinf(boundariesVal(:,2)),2))];        
        idxOnBoundariesX    = find(Trials.ActualDots_xy(:,1)==boundariesVal(1));
        idxOnBoundariesY    = find(Trials.ActualDots_xy(:,2)==boundariesVal(2));
        
        for t = 1:length(idxOnBoundariesX)
            if rand<0.5
                Trials.ActualDots_xy(idxOnBoundariesX(t),1)=Trials.ActualDots_xy(idxOnBoundariesX(t),1)-1;
            else
                Trials.ActualDots_xy(idxOnBoundariesX(t),1)=Trials.ActualDots_xy(idxOnBoundariesX(t),1)+1;
            end
        end
        for t = 1:length(idxOnBoundariesY)
            if rand<0.5
                Trials.ActualDots_xy(idxOnBoundariesY(t),2)=Trials.ActualDots_xy(idxOnBoundariesY(t),2)-1;
            else
                Trials.ActualDots_xy(idxOnBoundariesY(t),2)=Trials.ActualDots_xy(idxOnBoundariesY(t),2)+1;
            end            
        end        
        
%         categoryNames = unique(Model.Name);
        categoryNames = Model.Name;
        ncategories = length(categoryNames);
        
        
        Trials.CategoryPrototypes   = zeros(size(Trials, 1), 2);
        Trials.CategoryNames        = cell(size(Trials, 1), 1);
        Trials.CategoryID           = zeros(size(Trials, 1), 1);
        Trials.w                    = zeros(size(Trials, 1), 1);
        for c = 1:ncategories
            idx_x = Trials.ActualDots_xy(:,1)>Model.Boundaries{c}(1,1) & Trials.ActualDots_xy(:,1)<Model.Boundaries{c}(1,2);
            idx_y = Trials.ActualDots_xy(:,2)>Model.Boundaries{c}(2,1) & Trials.ActualDots_xy(:,2)<Model.Boundaries{c}(2,2);
            idx = idx_x&idx_y;
            Trials.CategoryPrototypes(idx,:)    = repmat(Model.Prototype{c}, sum(idx), 1);
            Trials.CategoryNames(idx)           = categoryNames(c);
            Trials.CategoryID(idx)              = repmat(Model.CategoryID(c), sum(idx), 1);
            Trials.w(idx)                       = repmat(Model.w(c), sum(idx), 1);
        end        
        

        
    case {'Hand'}
        
        categoryNames = unique(Model.Name);
        ncategories = length(categoryNames);
        
        
        Trials.CategoryPrototypes   = zeros(size(Trials, 1), 2);
        Trials.CategoryNames        = cell(size(Trials, 1), 1);
        Trials.CategoryID           = zeros(size(Trials, 1), 1);
        Trials.w                    = zeros(size(Trials, 1), 1);
        for c = 1:ncategories
            idx_x = Trials.ActualDots_xy(:,1)>Model.Boundaries{c}(1,1) & Trials.ActualDots_xy(:,1)<Model.Boundaries{c}(1,2);
            idx_y = Trials.ActualDots_xy(:,2)>Model.Boundaries{c}(2,1) & Trials.ActualDots_xy(:,2)<Model.Boundaries{c}(2,2);
            idx = idx_x&idx_y;
            Trials.CategoryPrototypes(idx,:)    = repmat(Model.Prototype{c}, sum(idx), 1);
            Trials.CategoryNames(idx)           = categoryNames(c);
            Trials.CategoryID(idx)              = repmat(Model.CategoryID(c), sum(idx), 1);
            Trials.w(idx)                       = repmat(Model.w(c), sum(idx), 1);
        end
        
end


function Trials = prototypes_assignPrototypes2Targets_unboundedCategories(Trials, Model)


categoryNames = unique(Model.category_name);
ncategories = length(categoryNames);

if ~iscell(Model.prototypesXY)
    Model.prototypesXY = mat2cell(Model.prototypesXY, ones(size(Model.prototypesXY, 1), 1), 2);
end


Trials.prototypesXY         = zeros(size(Trials, 1), 2);
Trials.category_name        = cell(size(Trials, 1), 1);
Trials.category_id          = zeros(size(Trials, 1), 1);
Trials.w                    = zeros(size(Trials, 1), 1);
for c = 1:ncategories
    idx_x = Trials.ActualDots_xy(:,1)>Model.boundary{c}(1,1) & Trials.ActualDots_xy(:,1)<Model.boundary{c}(1,2);
    idx_y = Trials.ActualDots_xy(:,2)>Model.boundary{c}(2,1) & Trials.ActualDots_xy(:,2)<Model.boundary{c}(2,2);
    idx = idx_x&idx_y;
    Trials.prototypesXY(idx,:)          = repmat(Model.prototypesXY{c}, sum(idx), 1); % it was Model.Prototype{c}
    Trials.category_name(idx)           = categoryNames(c);
    Trials.category_id(idx)             = repmat(Model.category_id(c), sum(idx), 1);
    Trials.w(idx)                       = repmat(Model.w(c), sum(idx), 1);
end


function Trials = prototypes_assignPrototypes2Targets_closestPrototypes(Trials, Model)

% NOT READY!!!
categoryNames = unique(Model.Name);
ncategories = length(categoryNames);

if ~iscell(Model.Prototype)
    Model.Prototype = mat2cell(Model.Prototype, ones(size(Model.Prototype, 1), 1), 2);
end

for c = 1:ncategories
    curPrototype = Model.Prototype{c}
end

