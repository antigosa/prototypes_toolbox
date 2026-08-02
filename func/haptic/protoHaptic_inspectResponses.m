function protoHaptic_inspectResponses(ProtoData, img_dir, opt)
% function protoHaptic_inspectResponses(ProtoData, opt)

opt.separatePlots=0;

opt.showLegend=0;



allpics_fnames = dir(fullfile(img_dir, 'img_withResp', '*.png'));
% allpics_fnames = fullfile({allpics_fnames(:).folder}, {allpics_fnames(:).name});
npics = length(allpics_fnames);
for i = 1:npics
    [subj_id, block_id(i), trial_id(i), dot_id(i)] = get_imgInfo(allpics_fnames(i).name);
end

if isfield(opt, 'dots_highlight') || isfield(opt, 'dots')
    if isfield(opt, 'dots_highlight')
        dots = opt.dots_highlight;
    end
    
    if isfield(opt, 'dots')
        dots = opt.dots;
    end
else
    dots = [];
end


if isfield(opt, 'trials_highlight') || isfield(opt, 'trials')
    if isfield(opt, 'trials_highlight')
        trials = opt.trials_highlight;
    end
    
    if isfield(opt, 'trials')
        trials = opt.trials;
    end
else
    trials = [];
end

if ~isempty(dots)
    idx_img = ismember(dot_id, dots);
    pic_fname = allpics_fnames(idx_img);
end

if ~isempty(trials)
    idx_img = ismember(trial_id, trials);
    pic_fname = allpics_fnames(idx_img);
end


ntrials = sum(idx_img);


if opt.separatePlots
    switch ntrials
        case 1
            figure('Position', [430 426 1343 553]);
            
        case 2
            figure('Position', [167 556 1606 423]);
    end
    
    subplot(1, ntrials+1, 1);prototypes_plot_dots(ProtoData, 'both', opt);
    
    idx_img = find(idx_img);
    
    for i = 1:ntrials
        I = imread(fullfile(pic_fname(i).folder, pic_fname(i).name));
        I = imresize(I, [660 660]);
        subplot(1, ntrials+1, i+1); imshow(I);
        title(sprintf('trial: %d - dot: %d', trial_id(idx_img(i)), dot_id(idx_img(i))))
    end
    
else
    switch ntrials
        case 1
            figure;
            
        case 2
            figure('Position', [430 426 1343 553]);
            
    end
    
    idx_img = find(idx_img);
    
    for i = 1:ntrials
        I = imread(fullfile(pic_fname(i).folder, pic_fname(i).name));
        I = imresize(I, [660 660]);
        subplot(1, ntrials, i); imshow(I);        
        hold on; prototypes_plot_dots(ProtoData, 'both', opt);
        title(sprintf('trial: %d - dot: %d', trial_id(idx_img(i)), dot_id(idx_img(i))))
        
    end    
    
    
end