function mouseClickCallback(~, ~)
    currentAxes = gca;
    coordinates = get(currentAxes, 'CurrentPoint');
    x = round(coordinates(1, 1)); % Round to nearest integer for pixel index
    y = round(coordinates(1, 2)); % Round to nearest integer for pixel index

    % Get image data
    img = getimage(currentAxes);

    % Check if the click is within the image bounds
    [rows, cols, ~] = size(img);
    if x >= 1 && x <= cols && y >= 1 && y <= rows
        pixelValue = img(y, x, :); % Pixel value at (x, y)
        fprintf('Mouse click at (x, y): (%d, %d)\n', x, y);
        fprintf('Pixel value: [%d, %d, %d]\n', pixelValue(1), pixelValue(2), pixelValue(3)); % Assuming RGB image
        hold on;
        plot(x, y, 'r*', 'MarkerSize', 10);
        hold off;
        
        % Store results in UserData
        userData = get(gcf, 'UserData');
        userData.x = x;
        userData.y = y;
        userData.pixelValue = squeeze(pixelValue)';
        set(gcf, 'UserData', userData);        
        
    else
        fprintf('Click outside image bounds.\n');
    end
end

% function mouseClickCallback(~, ~)
%     % Get the current axes
%     currentAxes = gca;
% 
%     % Get the coordinates of the mouse click
%     coordinates = get(currentAxes, 'CurrentPoint');
% 
%     % Extract x and y coordinates
%     x = coordinates(1, 1);
%     y = coordinates(1, 2);
% 
%     % Display the coordinates (you can customize this part)
%     fprintf('Mouse click at (x, y): (%f, %f)\n', x, y);
% 
%     % Optionally, mark the clicked point on the image
%     hold on;
%     plot(x, y, 'r*', 'MarkerSize', 10); % Red star marker
%     hold off;
% end