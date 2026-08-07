function [R_x, R_y] = CAM_polar(mu_x, mu_y, sigmaM_theta, sigmaP_theta, p_theta, a_theta, b_theta, sigmaM_edge, sigmaM_center, sigmaP_r, p_r, a_r, b_r)

% mu_x and mu_y are the true Cartesian coordinates
% mu_r is the true radius; mu_theta is the true angle
[mu_theta, mu_r] = cart2pol(mu_x, mu_y);
mu_theta = rad2deg(mu_theta); % Work in degrees for easier quadrant handling
if mu_theta < 0, mu_theta = mu_theta + 360; end

mu_theta = mod(mu_theta, 360);

% --- Angular Model Parameters --- (Constant Uncertainty)
% lambda_theta = 0.8;  % Weight for angular memory
% sigmaM_theta = 10;   % Uncertainty in angular memory
% p_theta = 45;        % Angular prototype (center of quadrant)
% a_theta = 0;         % Lower quadrant boundary
% b_theta = 90;        % Upper quadrant boundary

% Standardize boundaries for Angle
a_star_t = (a_theta - mu_theta) ./ sigmaM_theta;
b_star_t = (b_theta - mu_theta) ./ sigmaM_theta;

% sigmaP_theta = 5;  % Uncertainty of the prototype itself [10]

w_theta = (sigmaP_theta^2) / (sigmaM_theta^2 + sigmaP_theta^2);

% Combined Equation for Angle 
expected_theta = (w_theta .* mu_theta) + ((1 - w_theta) .* p_theta) + ...
    (((normpdf(a_star_t) - normpdf(b_star_t)) .* sigmaM_theta .* w_theta) ./ ...
    (normcdf(b_star_t) - normcdf(a_star_t)));


% --- Radial Model Parameters --- (Variable Uncertainty)
% lambda_r = 0.94;      % Weight for radial memory
% sigmaM_r = 0.13;      % Uncertainty in radial memory
% p_r = 0.91;           % Radial prototype
% a_r = 0;              % Circle center boundary
% b_r = 1;              % Circumference boundary
% 
% sigmaM_edge = 0.05;   % Uncertainty at the circumference (r=1)
% sigmaM_center = 0.20; % Uncertainty at the center (r=0)
% sigmaP_r = 0.10;      % Uncertainty of the radial prototype

% Linearly interpolate sigmaM_r based on true radial location mu_r
current_sigmaM_r = sigmaM_edge + (sigmaM_center - sigmaM_edge) .* ((b_r - mu_r)/b_r);

% Standardize boundaries for Radius
% a_star_r = (a_r - mu_r) ./ sigmaM_r;
% b_star_r = (b_r - mu_r) ./ sigmaM_r;
a_star_r = (a_r - mu_r) ./ current_sigmaM_r;
b_star_r = (b_r - mu_r) ./ current_sigmaM_r;


% Dynamically calculate lambda_r based on the local uncertainty [3]
w_r = (sigmaP_r.^2) ./ (current_sigmaM_r.^2 + sigmaP_r.^2);

% Combined Equation for Radius
expected_r = (w_r .* mu_r) + ((1 - w_r) .* p_r) + ...
    (((normpdf(a_star_r) - normpdf(b_star_r)) .* current_sigmaM_r .* w_r) ./ ...
    (normcdf(b_star_r) - normcdf(a_star_r)));


[R_x, R_y] = pol2cart(deg2rad(expected_theta), expected_r);