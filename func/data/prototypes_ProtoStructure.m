function ProtoData = prototypes_ProtoStructure(Trials, CSImaps, opt)
% function ProtoData = prototypes_ProtoStructure(Trials, CSImaps, opt)

if nargin<2;CSImaps=[];end
if nargin<3;opt=[];end

if ~isfield(opt, 'computeSummary');opt.computeSummary=1;end

ProtoData                                   = [];
ProtoData.Trials                            = Trials;
ProtoData.csimaps                           = CSImaps;
ProtoData.expName                           = unique(ProtoData.Trials.experiment);

if contains(Trials.Properties.VariableNames, 'blocks_name')
    ProtoData.blockName                         = unique(ProtoData.Trials.blocks_name);
end
ProtoData.nSubjects                         = length(unique(ProtoData.Trials.subj_id));
ProtoData.nTrials                           = length(unique(ProtoData.Trials.trials_id));
ProtoData.nDots                             = length(unique(ProtoData.Trials.dot_id));
ProtoData.shape                             = unique(ProtoData.Trials.stimulus_type);
ProtoData.shape_sizeXY                      = [unique(ProtoData.Trials.RectWidth) unique(ProtoData.Trials.RectHeight)];

if opt.computeSummary
    [T_summary, T_demo, T_nTrialsXpart]         = prototypes_summary(ProtoData.Trials, struct('verbose', 0));
    
    ProtoData.info_subjects.subject_summary     = T_summary;
    ProtoData.info_subjects.subject_demo        = T_demo;
    ProtoData.info_subjects.nTrialsXpart        = T_nTrialsXpart;
end