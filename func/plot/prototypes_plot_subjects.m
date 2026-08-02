function [ax1, ax2]=prototypes_plot_subjects(ProtoData, nxm, opt)
% function [ax1, ax2]=prototypes_plot_subjects(ProtoData, nxm, opt)

if nargin<3;opt=[];end

if ~isfield(opt, 'showColorbar'); opt.showColorbar = 0;end
if ~isfield(opt, 'showErrors'); opt.showErrors = 1;end
if ~isfield(opt, 'showRect'); opt.showRect=1;end
if ~isfield(opt, 'plotCSImaps'); opt.plotCSImaps=1;end

subjects = unique(ProtoData.Trials.subj_id);

fprintf('\nPlotting\n')
t = tiledlayout(nxm(1), nxm(2));
for s = 1:length(subjects)
    fprintf('Plotting %s\n', subjects{s})
    
%     opt                 = [];
    opt.subj_id         = subjects(s);    
    nexttile(t);
    %     subplot(nxm(1), nxm(2), s);
    
    if opt.plotCSImaps
        prototypes_plot_cosineMap(ProtoData, 'W_SimixSubject', opt);
    else
        prototypes_plot_dots(ProtoData, 'both', opt);
    end
%     title(sprintf('%s', subjects{s})); % already implemented in prototypes_plot_dots
end
t.TileSpacing = 'none';
t.Padding = 'none';
fprintf('Done\n\n')