function csm = prototypes_compute_cosineMap(ProtoTable, alphavalue, nproc, opt)
% function csm = prototypes_compute_cosineMap(ProtoTable, alphavalue, nproc, opt)
%
% Compute the cosine maps taking into account the error vectors that are
% supposed to be in 'ProtoTable'. ProtoTable is a 'prototable' type. 
% A cosine map will be computed separately for each participant. 
% =========================================================================
% INPUT
% =========================================================================
% ProtoTable: 
% - a prototable
% - mandatory fields:
% -- .ParticipantID
% -- .ActualDots_xy
% -- .ResponseDots_xy
% -- .Properties.UserData.ShapeContainerRect
% 
% alphavalue:
% - a scalar [typically 10]
% - size of the gaussian function that weights the dots based on the
%   distance
%
% nproc: 
% - a scalar [either 1 or 4 for now]
% - if larger than 1, it tries to use more processors to compute the maps 
%   (to speed up the process)
%
% opt: 
% - a structure
% - .pixStep; if 1, it uses all pixels as prototype. If you want to reduce
%   the resolution, you can use a value larger than 1
%
% =========================================================================
% OUTPUT
% =========================================================================
% 
% csm:
% - a structure
% - .SimixSubject; a 3D matrix (xdim, ydim, nsubjects) containing the
%   cosine similarity values (unweighted)
% - .W_SimixSubject; a 3D matrix (xdim, ydim, nsubjects) containing the
%   cosine similarity values (weighted)

% set default input
if ~exist('nproc', 'var'); nproc=1;end
if ~exist('opt', 'var'); opt=[];end

% get list of participants
subjlist    = unique(ProtoTable.ParticipantID);
nsubj       = length(subjlist);


csm_subj = cell(1, nsubj);

for s = 1:nsubj
    subjNum = subjlist(s);
    %ProtoTable_subj{s} = prototypes_select_subjects(ProtoTable, subjNum);
    Trial_subj = ProtoTable(ProtoTable.ParticipantID==subjNum, :);
    csm_subj{s} = prototypes_compute_cosineMap_aSubj(Trial_subj, alphavalue, nproc, opt);
    
    if s == 1
        csm.SimixSubject = zeros(size(csm_subj{s}.SimixSubject, 1), size(csm_subj{s}.SimixSubject, 2), nsubj);
        csm.W_SimixSubject = zeros(size(csm_subj{s}.W_SimixSubject, 1), size(csm_subj{s}.W_SimixSubject, 2), nsubj);
    end
    csm.SimixSubject(:, :, s) = csm_subj{s}.SimixSubject;
    csm.W_SimixSubject(:, :, s) = csm_subj{s}.W_SimixSubject;
end
csm.ParticipantID         = unique(ProtoTable.ParticipantID);
csm.Properties.UserData   = ProtoTable.Properties.UserData;
csm.alphavalue            = alphavalue;



function csm = prototypes_compute_cosineMap_aSubj(ProtoTable, alphavalue, nproc, opt)

if nargin==2;nproc=1;end

if ~exist('opt', 'var') || isempty(opt)
    opt.pixStep = 1;
end
pixStep = opt.pixStep;

X0      = ProtoTable.Properties.UserData.ShapeContainerRect(1);
Y0      = ProtoTable.Properties.UserData.ShapeContainerRect(2);
X1      = ProtoTable.Properties.UserData.ShapeContainerRect(3);
Y1      = ProtoTable.Properties.UserData.ShapeContainerRect(4);
Xm      = mean([X0, X1]);
Ym      = mean([Y0, Y1]);

if nproc==1
    x_toPix2Pix = X0:pixStep:X1;
    y_toPix2Pix = Y0:pixStep:Y1;    
    csm   = compute_cosine_map_singleWorker(ProtoTable, alphavalue, x_toPix2Pix, y_toPix2Pix);
    
else
        
    if isnumeric(unique(ProtoTable.ParticipantID))
        clc;fprintf('Computing cosine map for subject %d using %d processors...', unique(ProtoTable.ParticipantID),  nproc);
    else
        clc;fprintf('Computing cosine map for the group using %d processors...',  nproc);
    end
    
    x_toPix2Pix{1} = floor(X0:Xm);
    y_toPix2Pix{1} = floor(Y0:Ym);
    
    x_toPix2Pix{2} = floor(X0:Xm);
    y_toPix2Pix{2} = floor(Ym+1:Y1);
    
    
    x_toPix2Pix{3} = floor(Xm+1:X1);
    y_toPix2Pix{3} = floor(Y0:Ym);
    
    x_toPix2Pix{4} = floor(Xm+1:X1);
    y_toPix2Pix{4} = floor(Ym+1:Y1);
%     csm       = compute_cosine_map_singleWorker(ProtoTable, alphavalue, x_toPix2Pix{4}, y_toPix2Pix{4});
    
    sub_ProtoTable = cell(nproc, 1);
    parfor p=1:nproc        
        sub_ProtoTable{p} = compute_cosine_map_singleWorker(ProtoTable, alphavalue, x_toPix2Pix{p}, y_toPix2Pix{p}, 0);
        fprintf('Processor %d of %d processor has ended. Waiting for the other ones to finish...', p, nproc);
    end
    
    SimixSubject = zeros(Y1+abs(Y0)+1, X1+abs(X0)+1);
    W_SimixSubject = zeros(Y1+abs(Y0)+1, X1+abs(X0)+1);
    
    for p = 1:nproc
        SimixSubject = SimixSubject + sub_ProtoTable{p}.SimixSubject;
        W_SimixSubject = W_SimixSubject + sub_ProtoTable{p}.W_SimixSubject;
    end
    csm.SimixSubject      = SimixSubject;
    csm.W_SimixSubject    = W_SimixSubject;

    fprintf('Done\n');
end

function csm = compute_cosine_map_singleWorker(ProtoTable, alphavalue, x_toPix2Pix, y_toPix2Pix, showProgress)

if nargin<5; showProgress=1;end

ActDots                 = ProtoTable.ActualDots_xy;
RespDots                = ProtoTable.ResponseDots_xy;

idx_nan = any(isnan(RespDots),2);
ActDots(idx_nan,:)=[];
RespDots(idx_nan,:)=[];


X0                      = ProtoTable.Properties.UserData.ShapeContainerRect(1);
Y0                      = ProtoTable.Properties.UserData.ShapeContainerRect(2);
FigureWidth             = ProtoTable.Properties.UserData.ShapeContainerRect(3);
FigureHeight            = ProtoTable.Properties.UserData.ShapeContainerRect(4);

figure_size             = [FigureHeight+abs(Y0)+1 FigureWidth+abs(X0)+1];

% compute the error vector (in coords x and y)
ErrorXY                 = RespDots - ActDots;

% compute the error vecors length (Eucledian distance)
ErrorMag                = sqrt(diag(ErrorXY * ErrorXY'));

MaxDistance             = round(sqrt(FigureHeight^2 + FigureWidth^2)); 

weights                 = gausswin(MaxDistance*2,alphavalue);
weights                 = [(1:MaxDistance)' weights(MaxDistance+1:end)];

SimixSubject            = zeros(figure_size);
W_SimixSubject          = zeros(figure_size);

npixels                 = FigureHeight*FigureWidth;

n_tot_length            = round((FigureHeight*FigureWidth)/round(npixels/10))+1;

if isnumeric(unique(ProtoTable.ParticipantID))
    progress            = sprintf('Computing cosine similarity index map for subject %d: [', unique(ProtoTable.ParticipantID));
else
    progress            = sprintf('Computing cosine similarity index map for group: [');
end
progress                = [progress repmat('.', 1, n_tot_length+1) ']'];
if showProgress;fprintf('%s', progress);end
k = 1;
p = strfind(progress, '[')+1;

for x =  x_toPix2Pix
    for y = y_toPix2Pix

%         i = x+abs(x_toPix2Pix(1))+1;j= y+abs(y_toPix2Pix(1))+1;
        i = x-X0+1;j= y-Y0+1;
        
        % prepare a matrix for this location
        PredLoc                	= [repmat(x,length(RespDots),1), repmat(y,length(RespDots),1)];
        
        % compute the vector betweeb each dot and the predicted location
        PredVector              = PredLoc - ActDots;
        
        % compute the error magnitude for each dot
        ActDot2PrototypeLength  = sqrt(diag(PredVector * PredVector')); % you could also use the norm maybe??
        
        % compute the cosine similarity for each dot
        CosEach                 = dot(ErrorXY',PredVector')' ./  ( ErrorMag  .*   ActDot2PrototypeLength );
        
        % assign a weight to each dot (based on the dot distance)
        index                   = round(ActDot2PrototypeLength)+1; % if index == 0 % The weights start in 1. % Index zero correspont to an index were actualpoint and predicted point is the same.
        index(isnan(index) | index >= MaxDistance)           = MaxDistance;
        
        GausWeights             = weights(index,2);
        
        % We calculate the mean similarity. We use nanmean in case there is NaN values. For instace for Subject S09 the ActDots number 243 is the same as the PredDot, therefore the similarity value is NaN.
        csi                     = nanmean(CosEach);
        
        % Calculate the weightned index, depending on the distance of the actual dot to the suggested prototype (pixel based).
        csi_w                   = nansum(CosEach.*GausWeights)/nansum(GausWeights);
        
        SimixSubject(j,i)       = csi;
        W_SimixSubject(j,i)     = csi_w;
                      
        % update feedback
        if mod(k,round(npixels/10))==1
            progress(p)='#';p=p+1;
            clc;if showProgress;fprintf('%s', progress);end
        end
        k = k + 1;
    end
    
end

fprintf('\n');

csm.SimixSubject      = SimixSubject;
csm.W_SimixSubject    = W_SimixSubject;
