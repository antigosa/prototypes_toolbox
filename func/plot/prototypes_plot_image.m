function ax=prototypes_plot_image(Trials)
% IMAGE MUST HAVE ALPHA CHANNEL
if isfield(Trials.Properties.UserData, 'StimulusFileName')
    
    if ischar(Trials.Properties.UserData.StimulusFileName)
        [img, ~, transparency] = imread(Trials.Properties.UserData.StimulusFileName);
        stimulus_img.img = img;
        stimulus_img.transparency = transparency;
    else
        stimulus_img.img   = Trials.Properties.UserData.StimulusFileName;
    end
    
    ax_img = findobj(gcf, 'Type', 'Image');
    if ~isempty(ax_img)
        ax=ax_img.Parent;        
    else
        %     hold on; imagesc(stimulus_img.img);ax=gca;%ax.YDir='reverse';
        ax=axes; imagesc(stimulus_img.img);%ax=gca;%ax.YDir='reverse';
        axis image;axis off;
        ax_img = findobj(ax, 'Type', 'Image');
        ax_img(1).AlphaData = stimulus_img.transparency.*0.1;
        colormap(ax, 'gray');
    end
    
else
    ax=[];
    
end
