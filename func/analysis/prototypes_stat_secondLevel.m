function groupStat = prototypes_stat_secondLevel(csm_or_cell, opt)
% function groupStat = prototypes_stat_secondLevel(csm, opt)
%
% If input is a csm, it indicates that maps will be compared to zero; if it
% is a cell of csms (max 2 elements), it indicates that the maps will be
% compared one with another. 
% 
% If you want to run a permutation analysis, you need to have the CoSMoMVPA
% toobox (http://cosmomvpa.org/download.html) in the path
%


if nargin==1;opt = [];end

if ~isfield(opt, 'runPermutation'); opt.runPermutation=0;end
if ~isfield(opt, 'null_data'); opt.null_data=[];end
if ~isfield(opt, 'niter'); opt.niter=5000;end
if ~isfield(opt, 'cluster_stat'); opt.cluster_stat='maxsum';end
if ~isfield(opt, 'dataType'); opt.dataType='W_SimixSubject';end

if iscell(csm_or_cell)
    testType = 'twoSamples';
else
    testType = 'oneSamples';
    
end

% Groups = unique(csm.Group);
switch testType
    case 'oneSamples'
        groupStat = prototypes_stat_secondLevel_oneSampleT(csm_or_cell, opt);
        groupStat.Properties.UserData = csm_or_cell.Properties.UserData;
        
    case 'twoSamples'
        groupStat = prototypes_stat_secondLevel_twoSamplesT(csm_or_cell, opt);
        groupStat.Properties.UserData = csm_or_cell{1}.Properties.UserData;
end



function groupStat = prototypes_stat_secondLevel_oneSampleT(csm, opt)

runPermutation=opt.runPermutation;


% =========================================================================
% descriptive
% =========================================================================
if isfield(opt, 'puncorr')
    puncorr = opt.puncorr;
else
    puncorr = 0.001;
end


ds              = prototypes_simMap2cosmo(csm.(opt.dataType));
removed_idx     = all(ds.samples==0);
ds_tmp          = cosmo_remove_useless_data(ds);

res = prototypes_stat_cosinemap(ds_tmp, 'method', 'ttest', 'test_type', 'onesampleT', 'puncorr', puncorr);

fn = res.Properties.VariableNames;
fn(strcmp(fn, 'df'))=[];
fn(strcmp(fn, 'ds'))=[];
res_tmp=[];
for fi = 1:length(fn)
    res_tmp.(fn{fi}) = cosmo_slice(ds,1);
    res_tmp.(fn{fi}).samples(~removed_idx) =  res.(fn{fi}).samples;
    res_tmp.(fn{fi}).sa = res.(fn{fi}).sa;
end
res_tmp.df = res.df;
res = res_tmp;clear res_tmp;

groupStat.W_SimixSubject_avg        = squeeze(cosmo_unflatten(res.ds_avg));
groupStat.W_SimixSubject_T          = squeeze(cosmo_unflatten(res.ds_t));
groupStat.W_SimixSubject_STD        = squeeze(cosmo_unflatten(res.ds_std));
groupStat.W_SimixSubject_SE         = squeeze(cosmo_unflatten(res.ds_se));
groupStat.W_SimixSubject_Tuncorr    = squeeze(cosmo_unflatten(res.ds_t_uncorr));

if exist('fdr_bh.m', 'file') ~= 0
    pvals                               = res.ds_p.samples;
    idx_corr                            = fdr_bh(pvals, 0.05, 'pdep', 'yes');
    res.ds_t.samples(~idx_corr)=0;
    groupStat.W_SimixSubject_Tfdr       = squeeze(cosmo_unflatten(res.ds_t));
end

% =========================================================================
% inferential
% =========================================================================
if runPermutation
    % =====================================================================
    % cosine similarity analysis (inferential)
    % =====================================================================
    %         niter=5000;cluster_stat='maxsum';
    niter=opt.niter;cluster_stat=opt.cluster_stat;
    res_tmp = prototypes_stat_cosinemap(ds_tmp, 'method', 'permutation', 'test_type', 'onesampleT', ...
        'cluster_stat', cluster_stat, 'p_uncorrected', puncorr, 'n_iteration', niter, 'null_data', opt.null_data);
    
    ds_z = cosmo_slice(ds,1);
    ds_z.samples(~removed_idx) =  res_tmp.ds_z.samples;
    ds_z.sa = res_tmp.ds_z.sa;
    
    res_tmp.ds_z = ds_z;
    
    %     if strcmp(cluster_stat, 'tfce')
    %         groupStat.puncorr = [];
    %     end
    
    % two tails
    ds_t_corr = res.ds_t;
    idx_corr = abs(res_tmp.ds_z.samples)>=norminv(1-0.025);
    ds_t_corr.samples(~idx_corr)=0;
    groupStat.W_SimixSubject_Tcorr          = squeeze(cosmo_unflatten(ds_t_corr));
    groupStat.montecarlo_info.niter         = niter;
    groupStat.montecarlo_info.cluster_stat  = cluster_stat;
    
    % one tail (pos)
    ds_t_corr = res.ds_t;
    idx_corr = res_tmp.ds_z.samples>=norminv(1-0.05);
    ds_t_corr.samples(~idx_corr)=0;
    groupStat.W_SimixSubject_Tcorr_posOneTail          = squeeze(cosmo_unflatten(ds_t_corr));
    
    % one tail (neg)
    ds_t_corr = res.ds_t;
    idx_corr = res_tmp.ds_z.samples<=norminv(0.05);
    ds_t_corr.samples(~idx_corr)=0;
    groupStat.W_SimixSubject_Tcorr_negOneTail          = squeeze(cosmo_unflatten(ds_t_corr));
    
end


KDEAnalysis=0;

if KDEAnalysis
    %     groupStat.Properties.UserData.cosine_map.W_SimixSubject_avg = nanmean(csm.Properties.UserData.cosine_map.(opt.dataType), 3);
    
    ds=prototypes_simMap2cosmo(csm.Properties.UserData.KDE.PDE_map);
    
    res = prototypes_stat_cosinemap(ds, 'method', 'ttest', 'test_type', 'onesampleT', 'puncorr', puncorr);
    
    
    groupStat.Properties.UserData.KDE.PDE_map_avg        = squeeze(cosmo_unflatten(res.ds_avg));
    groupStat.Properties.UserData.KDE.PDE_map_T          = squeeze(cosmo_unflatten(res.ds_t));
    groupStat.Properties.UserData.KDE.PDE_map_STD        = squeeze(cosmo_unflatten(res.ds_std));
    groupStat.Properties.UserData.KDE.PDE_map_SE         = squeeze(cosmo_unflatten(res.ds_se));
    groupStat.Properties.UserData.KDE.PDE_map_Tuncorr    = squeeze(cosmo_unflatten(res.ds_t_uncorr));
    groupStat.Properties.UserData.KDE.puncorr            = puncorr;
    groupStat.Properties.UserData.KDE.df                 = res.df;
    
    
    % =========================================================================
    % inferential
    % =========================================================================
    if runPermutation
        % =====================================================================
        % cosine similarity analysis (inferential)
        % =====================================================================
        niter=5000;cluster_stat='maxsum';
        res_tmp = prototypes_stat_cosinemap(ds, 'method', 'permutation', 'test_type', 'onesampleT',...
            'cluster_stat', cluster_stat, 'p_uncorrected', puncorr, 'n_iteration', niter, 'null_data', opt.null_data);
        ds_t_corr = res.ds_t;
        idx_corr = abs(res_tmp.ds_z.samples)>=norminv(1-0.025);
        ds_t_corr.samples(~idx_corr)=0;
        groupStat.Properties.UserData.cosine_map.W_SimixSubject_Tcorr          = squeeze(cosmo_unflatten(ds_t_corr));
        groupStat.Properties.UserData.cosine_map.montecarlo_info.niter         = niter;
        groupStat.Properties.UserData.cosine_map.montecarlo_info.cluster_stat  = cluster_stat;
        
    end
end


% add important info
groupStat.puncorr                   = puncorr;
groupStat.df                        = res.df;
groupStat.ParticipantID             = unique(csm.ParticipantID);
groupStat.alphavalue                = csm.alphavalue;

function groupStat = prototypes_stat_secondLevel_twoSamplesT(csm, opt)

runPermutation=opt.runPermutation;

csm1 = csm{1};
csm2 = csm{2};

% only perform cosine analysis if both datasets have cosine_map
cosineAnalysis = all([isfield(csm1.Properties.UserData, 'cosine_map') isfield(csm2.Properties.UserData, 'cosine_map')]);

Analysis = {strcat(csm1.Properties.UserData.Experiment, 'VS', csm2.Properties.UserData.Experiment)};

% =========================================================================
% descriptive
% =========================================================================
if isfield(opt, 'puncorr')
    puncorr = opt.puncorr;
else
    puncorr = 0.001;
end



testType = whichStatTest(csm1, csm2);

nSubj1 = length(unique(csm1.ParticipantID));
ds1=prototypes_simMap2cosmo(csm1.(opt.dataType));
%     ds1.sa.group = repmat(csm1.Group(1), nSubj1, 1);
ds1.sa.group = ones(nSubj1, 1);
ds1.sa.subject = unique(csm1.ParticipantID);

nSubj2 = length(unique(csm2.ParticipantID));
ds2=prototypes_simMap2cosmo(csm2.(opt.dataType));
%     ds2.sa.group = repmat(csm2.Group(1), nSubj2, 1);
ds2.sa.group = ones(nSubj2, 1)*2;
ds2.sa.subject = unique(csm2.ParticipantID);

ds = cosmo_stack({ds1, ds2}, 1);

ds = cosmo_remove_useless_data(ds);

res = prototypes_stat_cosinemap(ds, 'method', 'ttest', 'test_type', testType, 'puncorr', puncorr);
groupStat.W_SimixSubject_avg        = squeeze(cosmo_unflatten(res.ds_avg));
groupStat.W_SimixSubject_T          = squeeze(cosmo_unflatten(res.ds_t));
groupStat.W_SimixSubject_STD        = squeeze(cosmo_unflatten(res.ds_std));
groupStat.W_SimixSubject_SE         = squeeze(cosmo_unflatten(res.ds_se));
groupStat.W_SimixSubject_Tuncorr    = squeeze(cosmo_unflatten(res.ds_t_uncorr));
if exist('fdr_bh.m', 'file') ~= 0
    pvals = res.ds_p.samples;
    idx_corr = fdr_bh(pvals, 0.05, 'pdep', 'yes');
    res.ds_t.samples(~idx_corr)=0;
    groupStat.W_SimixSubject_Tfdr          = squeeze(cosmo_unflatten(res.ds_t));
end


%     groupStat = table(subj_id, Analysis, W_SimixSubject_avg, W_SimixSubject_T, W_SimixSubject_STD, W_SimixSubject_SE, W_SimixSubject_Tuncorr, puncorr, df);

% =========================================================================
% inferential
% =========================================================================
if runPermutation
    % =====================================================================
    % cosine similarity analysis (inferential)
    % =====================================================================
    niter=5000;cluster_stat='maxsum';
    res_tmp = prototypes_stat_cosinemap(ds, 'method', 'permutation', 'test_type', testType,...
        'cluster_stat', cluster_stat, 'p_uncorrected', puncorr, 'n_iteration', niter, 'null_data', opt.null_data);
    
    % two tails
    ds_t_corr   = res.ds_t;
    idx_corr    = abs(res_tmp.ds_z.samples)>=norminv(1-0.025);
    ds_t_corr.samples(~idx_corr)=0;
    groupStat.W_SimixSubject_Tcorr           = squeeze(cosmo_unflatten(ds_t_corr));
    groupStat.montecarlo_info.niter          = niter;
    groupStat.montecarlo_info.cluster_stat   = cluster_stat;
    
    % one tail (pos)
    ds_t_corr = res.ds_t;
    idx_corr = res_tmp.ds_z.samples>=norminv(1-0.05);
    ds_t_corr.samples(~idx_corr)=0;
    groupStat.W_SimixSubject_Tcorr_posOneTail          = squeeze(cosmo_unflatten(ds_t_corr));
    
    % one tail (neg)
    ds_t_corr = res.ds_t;
    idx_corr = res_tmp.ds_z.samples<=norminv(0.05);
    ds_t_corr.samples(~idx_corr)=0;
    groupStat.W_SimixSubject_Tcorr_negOneTail          = squeeze(cosmo_unflatten(ds_t_corr));
end


% add important info
groupStat.puncorr                   = puncorr;
groupStat.df                        = res.df;
groupStat.ParticipantID             = [unique(csm1.ParticipantID)';unique(csm2.ParticipantID)'];
groupStat.alphavalue                = csm1.alphavalue;

% end

function testType = whichStatTest(group_Trials1, group_Trials2)

subj_id1 = unique(group_Trials1.ParticipantID);
subj_id2 = unique(group_Trials2.ParticipantID);

if length(subj_id1) ~= length(subj_id2)
    % cannot be paired
    
    if any(ismember(subj_id1, subj_id2))
        error('same subjects cannot appear in the different groups as this seems to be an independent T test');
    else
        testType='independentT';
    end
    
else
    if all(ismember(subj_id1, subj_id2)==0)
        testType='independentT';
    else
        testType='pairedT';
    end
    
end

function ds = prototypes_stat_cosinemap(ds, varargin)
% function res = prototypes_stat_cosinemap(res, varargin)

par = prototypes_get_parameters(varargin);

func_name = strcat('prototypes_', par.method, '_', par.test_type);

% ds = prototypes_prepare_data(ds, par);

ds = feval(func_name, ds, par);

function res    = prototypes_ttest_onesampleT(ds, par) %#ok<DEFNU>
ds.sa.chunks    = ds.sa.subject;
ds.sa.targets   = ones(length(ds.sa.subject), 1);
ds_t            = cosmo_stat(ds, 't');
ds_t.sa.info    = {'tstat'};

ds_p            = cosmo_stat(ds, 't', 'p');
ds_p.sa.info    = {'pval'};
% res.stat.onesampleT.(ds_t.sa.info{1}).ds = ds_t;

ds_avg          = cosmo_fx(ds, @(x)nanmean(x,1));
ds_avg.sa.info  = {'mean'};
ds_std          = cosmo_fx(ds, @(x)nanstd(x,1));
ds_std.sa.info  = {'std'};
ds_se           = cosmo_fx(ds_std, @(x)x/size(ds.samples, 1));
ds_se.sa.info   = {'se'};
% ds_desc_stat = cosmo_stack({ds_avg, ds_std, ds_se});

% res.stat.('descriptive').ds = ds_desc_stat;

df = strrep(ds_t.sa.stats, 'Ttest(', '');
df = strrep(df, ')', '');


if isfield(par, 'puncorr')
    ds_t_uncorr = ds_t;
    idx_uncorr = abs(ds_t_uncorr.samples)>=tinv(1-par.puncorr, str2double(df{1}));
    ds_t_uncorr.samples(~idx_uncorr)=0;
    
    res = table(ds, ds_t, ds_p, ds_t_uncorr, ds_avg, ds_std, ds_se, df);
else
    res = table(ds, ds_t, ds_p, ds_avg, ds_std, ds_se, df);
end


function res    = prototypes_permutation_onesampleT(ds, par) %#ok<DEFNU>
% function ds_z = prototype_permutation_analysis_onesampleT(ds, par)

ds.sa.chunks  = ds.sa.subject;
ds.sa.targets = ones(length(ds.sa.subject), 1);

nbr = cosmo_cluster_neighborhood(ds, 'chan', false);

%%


opt                 = struct();
opt.cluster_stat    = par.cluster_stat;     %'maxsum';
if ~strcmp(par.cluster_stat, 'tfce')
    opt.p_uncorrected   = par.p_uncorrected;    % 0.001;
end
opt.niter           = par.n_iteration;        % 1000
opt.h0_mean         = 0;
opt.nproc           = 4;

if isfield(par, 'null_data')&&~isempty(par.null_data)
    opt.null = par.null_data;
end

% Apply cluster-based correction
ds_z=cosmo_montecarlo_cluster_stat(ds,nbr,opt);

if ~strcmp(par.cluster_stat, 'tfce')
    p_uncorrected = num2str(opt.p_uncorrected);p_uncorrected = p_uncorrected(3:end);
    ds_z.sa.info = {sprintf('stat%s_puncor%s_niter%d', upper(opt.cluster_stat), p_uncorrected, opt.niter)};
else
    ds_z.sa.info = {sprintf('stat%s_niter%d', upper(opt.cluster_stat), opt.niter)};
end


%% plot (just for checking)
%ds_z_unflatted = squeeze(cosmo_unflatten(ds_z));
%imagesc(ds_z_unflatted); axis square;

res = table(ds_z);


function res    = prototypes_ttest_pairedT(ds, par) %#ok<DEFNU>

ds.sa.chunks    = ds.sa.subject;
ds.sa.targets   = ds.sa.group;
ds_t            = cosmo_stat(ds, 't');
ds_t.sa.info    = {'tstat'};

ds_p            = cosmo_stat(ds, 't', 'p');
ds_p.sa.info    = {'pval'};

ds_avg          = cosmo_fx(ds, @(x)(diff(flip(x))), 'subject');
ds_avg          = cosmo_fx(ds_avg, @(x)nanmean(x,1));

% not sure how to calculate this yet
ds_avg.sa.info  = {'mean'};
ds_std          = cosmo_fx(ds, @(x)nanstd(x,1));
ds_std.sa.info  = {'std'};
ds_se           = cosmo_fx(ds_std, @(x)x/size(ds.samples, 1));
ds_se.sa.info   = {'se'};


df = strrep(ds_t.sa.stats, 'Ttest(', '');
df = strrep(df, ')', '');

if isfield(par, 'puncorr')
    ds_t_uncorr = ds_t;
    idx_uncorr = abs(ds_t_uncorr.samples)>=tinv(1-par.puncorr, str2double(df{1}));
    ds_t_uncorr.samples(~idx_uncorr)=0;
    
    res = table(ds, ds_t, ds_p, ds_t_uncorr, ds_avg, ds_std, ds_se, df);
else
    res = table(ds, ds_t, ds_p, ds_avg, ds_std, ds_se, df);
end


function res    = prototypes_ttest_independentT(ds, par) %#ok<DEFNU>

ds.sa.chunks    = ds.sa.subject;
ds.sa.targets   = ds.sa.group;
ds_t            = cosmo_stat(ds, 't2');
ds_t.sa.info    = {'tstat'};

ds_p            = cosmo_stat(ds, 't2', 'p');
ds_p.sa.info    = {'pval'};

ds_avg          = cosmo_fx(ds, @(x)nanmean(x,1), 'group');
ds_avg          = cosmo_fx(ds_avg, @(x)(diff(flip(x))));

ds_avg.sa.info  = {'mean'};
ds_std          = cosmo_fx(ds, @(x)nanstd(x,1));
ds_std.sa.info  = {'std'};
ds_se           = cosmo_fx(ds_std, @(x)x/size(ds.samples, 1));
ds_se.sa.info   = {'se'};


df = strrep(ds_t.sa.stats, 'Ttest(', '');
df = strrep(df, ')', '');

if isfield(par, 'puncorr')
    ds_t_uncorr = ds_t;
    idx_uncorr = abs(ds_t_uncorr.samples)>=tinv(1-par.puncorr, str2double(df{1}));
    ds_t_uncorr.samples(~idx_uncorr)=0;
    
    res = table(ds, ds_t, ds_p, ds_t_uncorr, ds_avg, ds_std, ds_se, df);
else
    res = table(ds, ds_t, ds_p, ds_avg, ds_std, ds_se, df);
end


function res    = prototypes_permutation_pairedT(ds, par) %#ok<DEFNU>
% function ds_z = prototype_permutation_analysis_onesampleT(ds, par)

ds.sa.chunks    = ds.sa.subject;
ds.sa.targets   = ds.sa.group;

nbr = cosmo_cluster_neighborhood(ds, 'chan', false);

%%


opt                 = struct();
opt.cluster_stat    = par.cluster_stat;     %'maxsum';
if ~strcmp(par.cluster_stat, 'tfce')
    opt.p_uncorrected   = par.p_uncorrected;    % 0.001;
end
opt.niter           = par.n_iteration;        % 1000
opt.nproc           = 4;

if isfield(par, 'null_data')&&~isempty(par.null_data)
    opt.null = par.null_data;
end


% Apply cluster-based correction
ds_z=cosmo_montecarlo_cluster_stat(ds,nbr,opt);

if ~strcmp(par.cluster_stat, 'tfce')
    p_uncorrected = num2str(opt.p_uncorrected);p_uncorrected = p_uncorrected(3:end);
    ds_z.sa.info = {sprintf('stat%s_puncor%s_niter%d', upper(opt.cluster_stat), p_uncorrected, opt.niter)};
else
    ds_z.sa.info = {sprintf('stat%s_niter%d', upper(opt.cluster_stat), opt.niter)};
end

%% plot (just for checking)
% ds_z_unflatted = squeeze(cosmo_unflatten(ds_z));
% imagesc(ds_z_unflatted); axis image;

res = table(ds_z);


function res    = prototypes_permutation_independentT(ds, par) %#ok<DEFNU>
% function ds_z = prototype_permutation_analysis_onesampleT(ds, par)

ds.sa.chunks    = ds.sa.subject;
ds.sa.targets   = ds.sa.group;

nbr = cosmo_cluster_neighborhood(ds, 'chan', false);

%%


opt                 = struct();
opt.cluster_stat    = par.cluster_stat;     %'maxsum';
if ~strcmp(par.cluster_stat, 'tfce')
    opt.p_uncorrected   = par.p_uncorrected;    % 0.001;
end
opt.niter           = par.n_iteration;        % 1000
opt.nproc           = 4;


if isfield(par, 'null_data')&&~isempty(par.null_data)
    opt.null = par.null_data;
end

% Apply cluster-based correction
ds_z=cosmo_montecarlo_cluster_stat(ds,nbr,opt);

if ~strcmp(par.cluster_stat, 'tfce')
    p_uncorrected = num2str(opt.p_uncorrected);p_uncorrected = p_uncorrected(3:end);
    ds_z.sa.info = {sprintf('stat%s_puncor%s_niter%d', upper(opt.cluster_stat), p_uncorrected, opt.niter)};
else
    ds_z.sa.info = {sprintf('stat%s_niter%d', upper(opt.cluster_stat), opt.niter)};
end

%% plot (just for checking)
% ds_z_unflatted = squeeze(cosmo_unflatten(ds_z));
% imagesc(ds_z_unflatted); axis image;

res = table(ds_z);

