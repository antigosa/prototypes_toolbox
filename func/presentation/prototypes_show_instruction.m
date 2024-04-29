function prototypes_show_instruction(win)
% function prototypes_show_instruction(win)
% Instructions
if nargin==0; win = get_test_protometa_show_instruction;end

%-------------------------------------------------------
% parameters
%-------------------------------------------------------
% warp at colum (vai a capo)
warpat=[]; % 100
vertical_space=1.8 ; 

Instructions= 'You will see a circle, followed by the appearance of a dot inside it. \n Shortly afterwards, both the dot and the circle will disappear. \n  Shortly afterwards, the circle will appear again but in a different location. \n\n Your task is to reproduce the location of the dot relative to the circle using the cursor of the mouse. \n Please be careful and precise with your responses. Your reaction time will not be  recorded.\n\n Between blocks you will be able to rest if you feel tired. \n\n You will have some practice trials at the beginning. \n\n\n  Press the bar when you feel ready to start.';
Screen(win,'TextSize',35); Screen(win,'TextFont','Times');[nx, ny, bbox] = DrawFormattedText(win, Instructions, 'center','center', [0 0 0], warpat,[],[],vertical_space); Screen(win,'Flip');
KbWait;WaitSecs(1.5) 

if nargin==0; ptb_close_window; end

function win = get_test_protometa_show_instruction
win = ptb_open_window(1);