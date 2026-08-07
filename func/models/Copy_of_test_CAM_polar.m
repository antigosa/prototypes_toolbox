close all;

% --- Angular Model Parameters ---
w_theta         = 1;          % Weight for angular memory
sigmaM_theta    = 3;           % Uncertainty in angular memory


category='bottom_right';

switch category
    case 'top_right'
        a_theta         = 0;            % Lower quadrant boundary
        b_theta         = 90;           % Upper quadrant boundary
        p_theta         = 30;           % Angular prototype (center of quadrant)
        actual_theta    = 0;
    case 'top_left'
        a_theta         = 90;            % Lower quadrant boundary
        b_theta         = 180;           % Upper quadrant boundary
        p_theta         = 120;           % Angular prototype (center of quadrant)
        actual_theta    = 175;
    case 'bottom_left'
        a_theta         = 180;            % Lower quadrant boundary
        b_theta         = 270;           % Upper quadrant boundary
        p_theta         = 210;           % Angular prototype (center of quadrant)
        actual_theta    = 185;
    case 'bottom_right'
        a_theta         = 270;            % Lower quadrant boundary
        b_theta         = 360;           % Upper quadrant boundary
        p_theta         = 300;           % Angular prototype (center of quadrant)
        actual_theta    = 275;
end

% --- Radial Model Parameters ---

figure_size = 100;

w_r             = 1;                    % Weight for radial memory [12]
sigmaM_r        = 0.13*figure_size;     % Uncertainty in radial memory [12]
p_r             = 0.5*figure_size;      % Radial prototype [5]
a_r             = 0;                    % Circle center boundary
b_r             = 1*figure_size;        % Circumference boundary
actual_r        = 0.5*figure_size;


ndots = 10;

r = actual_r+random('norm', 0, 0.05*figure_size, ndots, 1);
theta = deg2rad(actual_theta+random('norm', 0, 10, ndots, 1));

figure; polarscatter(theta, r, 'k');
hold on; polarscatter(deg2rad(p_theta), p_r, 'g');
ax=gca;ax.RLim=[0 1].*figure_size;


[mu_x, mu_y] = pol2cart(theta, r);
% figure; scatter(mu_x, mu_y, 'k');axis equal;axis([-1 1 -1 1]);rectangle('Position', [-1 -1 2 2], 'Curvature', 1);
% 
% R_x = zeros(ndots, 1);
% R_y = zeros(ndots, 1);
% for i = 1:ndots
%     [R_x(i), R_y(i)] = CAM_polar(mu_x(i), mu_y(i), lambda_theta, sigmaM_theta, p_theta, a_theta, b_theta, lambda_r, sigmaM_r, p_r, a_r, b_r);
% end

[R_x, R_y] = CAM_polar(mu_x, mu_y, w_theta, sigmaM_theta, p_theta, a_theta, b_theta, w_r, sigmaM_r, p_r, a_r, b_r);

[R_theta, R_radius] = cart2pol(R_x, R_y);
polarscatter(R_theta, R_radius, 'r');