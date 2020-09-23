function CosineMap = prototypes_compute_cosineMap(Trials, alphavalue, nproc, opt)
% function CosineMap = prototypes_compute_cosineMap(Trials, alphavalue, nproc, opt)
%
% Compute the cosine maps taking into account the error vectors that are
% supposed to be in 'Trials'. Trials is a prototable. A cosine map will be
% computed separately for each participant. 
% =========================================================================
% INPUT
% =========================================================================
% Trials: 
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
% CosineMap:
% - a structure
% - .SimixSubject; a 3D matrix (xdim, ydim, nsubjects) containing the
%   cosine similarity values (unweighted)
% - .W_SimixSubject; a 3D matrix (xdim, ydim, nsubjects) containing the
%   cosine similarity values (weighted)

% set default input
if ~exist('nproc', 'var'); nproc=1;end
if ~exist('opt', 'var'); opt=[];end

% get list of participants
subjlist    = unique(Trials.ParticipantID);
nsubj       = length(subjlist);


CosineMap_subj = cell(1, nsubj);

for s = 1:nsubj
    subjNum = subjlist(s);
    %Trials_subj{s} = prototypes_select_subjects(Trials, subjNum);
    Trial_subj = Trials(Trials.ParticipantID==subjNum, :);
    CosineMap_subj{s} = prototypes_compute_cosineMap_aSubj(Trial_subj, alphavalue, nproc, opt);
    
    if s == 1
        CosineMap.SimixSubject = zeros(size(CosineMap_subj{s}.SimixSubject, 1), size(CosineMap_subj{s}.SimixSubject, 2), nsubj);
        CosineMap.W_SimixSubject = zeros(size(CosineMap_subj{s}.W_SimixSubject, 1), size(CosineMap_subj{s}.W_SimixSubject, 2), nsubj);
    end
    CosineMap.SimixSubject(:, :, s) = CosineMap_subj{s}.SimixSubject;
    CosineMap.W_SimixSubject(:, :, s) = CosineMap_subj{s}.W_SimixSubject;
end
CosineMap.ParticipantID         = unique(Trials.ParticipantID);
CosineMap.Properties.UserData   = Trials.Properties.UserData;
CosineMap.alphavalue            = alphavalue;



function CosineMap = prototypes_compute_cosineMap_aSubj(Trials, alphavalue, nproc, opt)

if nargin==2;nproc=1;end

if ~exist('opt', 'var') || isempty(opt)
    opt.pixStep = 1;
end
pixStep = opt.pixStep;

X0      = Trials.Properties.UserData.ShapeContainerRect(1);
Y0      = Trials.Properties.UserData.ShapeContainerRect(2);
X1      = Trials.Properties.UserData.ShapeContainerRect(3);
Y1      = Trials.Properties.UserData.ShapeContainerRect(4);
Xm      = mean([X0, X1]);
Ym      = mean([Y0, Y1]);

if nproc==1
    x_toPix2Pix = X0:pixStep:X1;
    y_toPix2Pix = Y0:pixStep:Y1;    
    CosineMap   = compute_cosine_map_singleWorker(Trials, alphavalue, x_toPix2Pix, y_toPix2Pix);
    
else
        
    if isnumeric(unique(Trials.ParticipantID))
        clc;fprintf('Computing cosine map for subject %d using %d processors...', unique(Trials.ParticipantID),  nproc);
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
%     CosineMap       = compute_cosine_map_singleWorker(Trials, alphavalue, x_toPix2Pix{4}, y_toPix2Pix{4});
    
    sub_Trials = cell(nproc, 1);
    parfor p=1:nproc        
        sub_Trials{p} = compute_cosine_map_singleWorker(Trials, alphavalue, x_toPix2Pix{p}, y_toPix2Pix{p}, 0);
        fprintf('Processor %d of %d processor has ended. Waiting for the other ones to finish...', p, nproc);
    end
    
    SimixSubject = zeros(Y1+abs(Y0)+1, X1+abs(X0)+1);
    W_SimixSubject = zeros(Y1+abs(Y0)+1, X1+abs(X0)+1);
    
    for p = 1:nproc
        SimixSubject = SimixSubject + sub_Trials{p}.SimixSubject;
        W_SimixSubject = W_SimixSubject + sub_Trials{p}.W_SimixSubject;
    end
    CosineMap.SimixSubject      = SimixSubject;
    CosineMap.W_SimixSubject    = W_SimixSubject;

    fprintf('Done\n');
end

function CosineMap = compute_cosine_map_singleWorker(Trials, alphavalue, x_toPix2Pix, y_toPix2Pix, showProgress)

if nargin<5; showProgress=1;end

ActDots                 = Trials.ActualDots_xy;
RespDots                = Trials.ResponseDots_xy;

idx_nan = any(isnan(RespDots),2);
ActDots(idx_nan,:)=[];
RespDots(idx_nan,:)=[];


X0                      = Trials.Properties.UserData.ShapeContainerRect(1);
Y0                      = Trials.Properties.UserData.ShapeContainerRect(2);
FigureWidth             = Trials.Properties.UserData.ShapeContainerRect(3);
FigureHeight            = Trials.Properties.UserData.ShapeContainerRect(4);

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

if isnumeric(unique(Trials.ParticipantID))
    progress        = sprintf('Computing cosine similarity index map for subject %d: [', unique(Trials.ParticipantID));
else
    progress        = sprintf('Computing cosine similarity index map for group: [');
end
progress        = [progress repmat('.', 1, n_tot_length+1) ']'];
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

CosineMap.SimixSubject      = SimixSubject;
CosineMap.W_SimixSubject    = W_SimixSubject;
