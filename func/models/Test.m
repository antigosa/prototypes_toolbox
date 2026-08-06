
close all;
% --- 1. Define Experimental Parameters ---
R = 100;                  % Radius of the circular space
% theta_min = 0;            % First quadrant: 0 radians
% theta_max = pi/2;         % First quadrant: pi/2 radians


category='bottom_left';

true_x_abs = 55;
true_y_abs = 55;

switch category
    case 'top_right'
        % top-right
        theta_min = cart2pol(1,0);
        theta_max = cart2pol(0, 1);
        
        % --- 2. Define a True Stimulus Location (e.g., x = 40, y = 30) ---
        true_x = true_x_abs;
        true_y = true_y_abs;
        
        x_line_min = [0, R];
        y_line_min = [0, 0];
        x_line_max = [0, 0];
        y_line_max = [0, R];
        
    case 'top_left'
        % top-left
        theta_min = cart2pol(0, 1);
        theta_max = cart2pol(-1, 0);
        true_x = -true_x_abs;
        true_y = true_y_abs;
        
        x_line_min = [0, 0];
        y_line_min = [0, R];
        x_line_max = [-R, 0];
        y_line_max = [0, 0];        
        
    case 'bottom_right'
        % top-right
        theta_min = cart2pol(0, -1);
        theta_max = cart2pol(1, 0);
        true_x = true_x_abs;
        true_y = -true_y_abs;
        
        x_line_min = [0, 0];
        y_line_min = [0, -R];
        x_line_max = [0, R];
        y_line_max = [0, 0];        
        
    case 'bottom_left'
        % top-left
        theta_min = -cart2pol(-1, 0);
        theta_max = cart2pol(0, -1);
        true_x = -true_x_abs;
        true_y = -true_y_abs;
        
        x_line_min = [0, -R];
        y_line_min = [0, 0];
        x_line_max = [0, 0];
        y_line_max = [0, -R];        
end


sigma_m = 30;             % Standard deviation of fine-grained memory noise



% --- 3. Simulate Noisy Memory Traces (mx, my) ---
% In an experiment, memory is imperfect, so mx and my scatter around the true location.
% Let's simulate 100 noisy trials for this single true location.
num_trials = 200;
mx = true_x + sigma_m * randn(num_trials, 1);
my = true_y + sigma_m * randn(num_trials, 1);

% --- 4. Apply the Category-Adjustment Model ---
[x_hat, y_hat] = TMP_category_adjustment_estimate_polar(mx, my, R, theta_min, theta_max, sigma_m);

% --- 5. Visualize the Results ---
figure;
hold on;
axis equal;
viscircles([0, 0], R, 'Color', 'k', 'LineWidth', 1.5); % Draw circular boundary
% line([0, R], [0, 0], 'Color', 'k', 'LineStyle', '--'); % Quadrant axis X
% line([0, 0], [0, R], 'Color', 'k', 'LineStyle', '--'); % Quadrant axis Y
line(x_line_min, y_line_min, 'Color', 'k', 'LineStyle', '--'); % Quadrant axis X
line(x_line_max, y_line_max, 'Color', 'k', 'LineStyle', '--'); % Quadrant axis Y


% Plot true location
plot(true_x, true_y, 'gp', 'MarkerSize', 12, 'MarkerFaceColor', 'g', 'DisplayName', 'True Stimulus');

% Plot final model responses (x_hat, y_hat)
plot(x_hat, y_hat, 'ro', 'MarkerSize', 5, 'MarkerFaceColor', 'r', 'DisplayName', 'Model Responses (x\_hat, y\_hat)');

legend('Location', 'northeast');
xlabel('X coordinate');
ylabel('Y coordinate');
title('Category-Adjustment Model: Polar Truncation');
box on;
grid on;
hold off;