function Rectcoord = prototypes_randomise_location(fig_width, fig_height, rect_lim, nrep, whichScreen)
% function Rectcoord = prototypes_randomise_location(fig_width, fig_height, rect_lim, nrep)
% randomize the location of a figure.
%
% =========================================================================
% EXAMPLE CALL
% =========================================================================
% fig_width=500; fig_height=500;nrep=10;
% rect_lim = [1 1 600 600]; % where the rectangle can appear
% Rectcoord = prototypes_randomise_location(fig_width, fig_height, rect_lim, nrep);

if nargin<5 || isempty(whichScreen); whichScreen = max(Screen('Screens'));end
[screen_width_px, screen_height_px]=Screen('WindowSize', whichScreen);
h = [1 1 screen_width_px, screen_height_px];

if nargin==2 || isempty(rect_lim)
    % if you did not define any constraints, the shape can appear anywhere
    % in the screen
    rect_lim = h;
    
    nrep = 1;
end

if nargin==3 || isempty(nrep); nrep = 1;end

% get screen dimensions
% h = get(0,'MonitorPositions');h=h(1,:);


Rectcoord = zeros(nrep, 4);

for i = 1:nrep
    x0 = rect_lim(1);y0 = rect_lim(2);
    screen_width = rect_lim(3); screen_height = rect_lim(4);
    
    
    x1=x0+random('unid', screen_width-fig_width-x0)-1;
    x2=x1+fig_width;
    
    y1=y0+random('unid', screen_height-fig_height-y0)-1;
    y2=y1+fig_height;
    
    % a rectangle is defined in ptb as [y1 x1 y2 x2];
    Rectcoord(i,:)=[x1 y1 x2 y2];
end
