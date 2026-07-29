function [ax1, ax2]=prototypes_plot_subjects(ProtoData, nxm, opt)
% function [ax1, ax2]=prototypes_plot_subjects(ProtoData, nxm, opt)

if nargin<3;opt=[];end

if ~isfield(opt, 'showColorbar'); opt.showColorbar = 0;end
if ~isfield(opt, 'showErrors'); opt.showErrors = 1;end
if ~isfield(opt, 'showRect'); opt.showRect=1;end

subjects = unique(ProtoData.Trials.subj_id);

fprintf('\nPlotting\n')
t = tiledlayout(nxm(1), nxm(2));
for s = 1:length(subjects)
    fprintf('Plotting %s\n', subjects{s})
    
%     opt                 = [];
    opt.subj_id         = subjects(s);    
    nexttile(t);
    %     subplot(nxm(1), nxm(2), s);
    prototypes_plot_cosineMap(ProtoData, 'W_SimixSubject', opt);
    title(sprintf('%s', subjects{s}));
end
t.TileSpacing = 'none';
t.Padding = 'none';
fprintf('Done\n\n')