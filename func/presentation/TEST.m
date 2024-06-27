load('TrialList_imsize500x500_ndots468_nblocks4_offset2_Circle')

figure; scatter(xy(:, 1), xy(:, 2)); axis equal;


%% prototypes_randomise_location

shape_width     = 500;
shape_height    = 500;
rect_lim        = [635 215 1285 865];
ntrialsXblock   = 10;
all_rect        = prototypes_randomise_location(shape_width, shape_height, rect_lim, ntrialsXblock);

figure; rectangle('Position',rect_lim,'EdgeColor','r')
hold on; 
rectangle('Position',all_rect(1,:))
axis([0 10 0 10])


