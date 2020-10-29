function prototypes_plot_image(Trials)
if isfield(Trials.Properties.UserData, 'StimulusFileName')

    if ischar(Trials.Properties.UserData.StimulusFileName)
        [img, ~, transparency] = imread(Trials.Properties.UserData.StimulusFileName);
        stimulus_img.img = img;
        stimulus_img.transparency = transparency;
    else
        stimulus_img   = Trials.Properties.UserData.StimulusFileName;      
    end
    
    hold on; imagesc(stimulus_img.img);ax=gca;%ax.YDir='reverse';
    ax_img = findobj(ax, 'Type', 'Image');
    ax_img(1).AlphaData = stimulus_img.transparency;
       
end
