function [ax1, ax2]=prototypes_plot_subjects(ProtoData)
% function [ax1, ax2]=prototypes_plot_subjects(ProtoData)

subjects = unique(ProtoData.Trials.subj_id);

fprintf('\nPlotting\n')
t = tiledlayout(3, 5);
nt=cell(1, length(subjects));ax1=cell(1, length(subjects));ax2=cell(1, length(subjects));
for s = 1:length(subjects)
    fprintf('Plotting %s\n', subjects{s})
    
    opt = [];
    opt.subj_id = subjects(s);
    opt.showColorbar=0;
    nt{s} = nexttile(t);
    ax1{1}=prototypes_plot_cosineMap(ProtoData, 'W_SimixSubject', opt);
    hold(nt{s}, 'on'); ax2{s}=prototypes_plot_dots(ProtoData, 'errors', opt);
    ax2{s}.Position=nt{s}.Position;
    hold(nt{s}, 'off');
    title(sprintf('%s', subjects{s}));
end
t.TileSpacing = 'compact';
t.Padding = 'compact';
for s = 1:length(subjects)
    ax2{s}.Position=nt{s}.Position;
%     linkaxes([ax1{s} ax2{s}], 'xy');
end
fprintf('Done\n\n')