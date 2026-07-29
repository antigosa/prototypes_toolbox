function ProtoData = prototypes_ProtoStructure(Trials, CSImaps)
% function ProtoData = prototypes_ProtoStructure(Trials, CSImaps)

if nargin<2;CSImaps=[];end

ProtoData                        = [];
ProtoData.Trials                 = Trials;
ProtoData.csimaps                = CSImaps;
ProtoData.expName                = unique(ProtoData.Trials.experiment);
ProtoData.blockName              = unique(ProtoData.Trials.blocks_name);
ProtoData.nSubjects              = length(unique(ProtoData.Trials.subj_id));
ProtoData.nTrials                = length(unique(ProtoData.Trials.trials_id));
ProtoData.nDots                  = length(unique(ProtoData.Trials.dot_id));
ProtoData.shape                  = unique(cellstr(ProtoData.Trials.stimulus_type));
ProtoData.shape_sizeXY           = [unique(ProtoData.Trials.RectWidth) unique(ProtoData.Trials.RectHeight)];

opt = [];
opt.verbose = 0;
[T_summary, T_demo, T_nTrialsXpart] = prototypes_summary(ProtoData.Trials, opt);

ProtoData.info.subject_summary  = T_summary;
ProtoData.info.subject_demo     = T_demo;
ProtoData.info.nTrialsXpart     = T_nTrialsXpart;