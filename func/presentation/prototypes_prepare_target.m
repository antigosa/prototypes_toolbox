function prototypes_prepare_target(win, xy, col, Rectcoord, rotationAngle)
% function prototypes_prepare_target(win, xy, col, Rectcoord, rotationAngle)
% updated method to show the dots: I am now using the centre of the rect
% (see lines 19 and 20)


% get the center of the square containing the image
[xCenter2, yCenter2]  = RectCenter(Rectcoord);

posX = xCenter2;
posY = yCenter2;

% prepare translation and rotation of the dots
Screen('glPushMatrix', win)
Screen('glTranslate', win, posX, posY)
Screen('glRotate', win, rotationAngle, 0, 0);
Screen('glTranslate', win, -posX, -posY)

Screen('DrawDots', win, xy, 10, col, [Rectcoord(1) Rectcoord(2)], 2);
% Screen('DrawDots', win, xy, 10, col, [xCenter2 yCenter2], 2);


% % draw the dots
% for d = 1:n_dots
%     Screen('DrawDots', win, new_xy_offset(d,:), 10, col,[Rectcoord(1) Rectcoord(2)],2);
% end
Screen('glPopMatrix', win)


