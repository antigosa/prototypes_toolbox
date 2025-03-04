function exp_param=set_camera(exp_param, useCamera, command)
%% set the camera
% =========================================================================
% Set the camera
% =========================================================================
if useCamera
    
    switch command
        case 'start'
            
            % use imaqhwinfo for a list of available ADAPTORNAMEs
            
            % Check if the camera is already open. This can happen if there is an
            % program stop because an error. The following line takes care of
            % this.
            objects = imaqfind;if ~isempty(objects);delete(objects);end
            
            % Configure the webcam input, with 1280x960 resolution
            theCamera = videoinput('winvideo',1,'MJPG_1920x1080'); % LAB
            %     theCamera = videoinput('winvideo',1,'MJPG_1280x720'); % HOME
            triggerconfig(theCamera, 'Manual');
            start(theCamera);
            
            disp('*** Set webcam focus to manual ***')
            input('PRESS THE RETURN BUTTON TO CONTINUE...');
            %     pause;
            
            exp_param.metadata.theCamera = theCamera;
            
        case 'stop'
            stop(exp_param.metadata.theCamera);
            
    end
end