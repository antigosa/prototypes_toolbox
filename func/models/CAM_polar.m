function [R_x, R_y] = CAM_polar(mu_x, mu_y, w_theta, sigmaM_theta, p_theta, a_theta, b_theta, w_r, sigmaM_r, p_r, a_r, b_r)

% mu_x and mu_y are the true Cartesian coordinates
% mu_r is the true radius; mu_theta is the true angle
[mu_theta, mu_r] = cart2pol(mu_x, mu_y);
mu_theta = rad2deg(mu_theta); % Work in degrees for easier quadrant handling
if mu_theta < 0, mu_theta = mu_theta + 360; end

mu_theta = mod(mu_theta, 360);

% --- Angular Model Parameters ---
% lambda_theta = 0.8;  % Weight for angular memory
% sigmaM_theta = 10;   % Uncertainty in angular memory
% p_theta = 45;        % Angular prototype (center of quadrant)
% a_theta = 0;         % Lower quadrant boundary
% b_theta = 90;        % Upper quadrant boundary

% Standardize boundaries for Angle
a_star_t = (a_theta - mu_theta) ./ sigmaM_theta;
b_star_t = (b_theta - mu_theta) ./ sigmaM_theta;

% Combined Equation for Angle
expected_theta = (w_theta .* mu_theta) + ((1 - w_theta) .* p_theta) + ...
    (((normpdf(a_star_t) - normpdf(b_star_t)) .* sigmaM_theta .* w_theta) ./ ...
    (normcdf(b_star_t) - normcdf(a_star_t)));


% --- Radial Model Parameters ---
% lambda_r = 0.94;     % Weight for radial memory [12]
% sigmaM_r = 0.13;     % Uncertainty in radial memory [12]
% p_r = 0.91;          % Radial prototype [5]
% a_r = 0;             % Circle center boundary
% b_r = 1;             % Circumference boundary

% Standardize boundaries for Radius
a_star_r = (a_r - mu_r) ./ sigmaM_r;
b_star_r = (b_r - mu_r) ./ sigmaM_r;

% Combined Equation for Radius
expected_r = (w_r .* mu_r) + ((1 - w_r) .* p_r) + ...
    (((normpdf(a_star_r) - normpdf(b_star_r)) .* sigmaM_r .* w_r) ./ ...
    (normcdf(b_star_r) - normcdf(a_star_r)));



[R_x, R_y] = pol2cart(deg2rad(expected_theta), expected_r);




% mu: The true location of the stimulus.
% p: The prototype location for that category.
% lambda: The shrinkage coefficient (the weight given to the recollection).
% sigmaM: The standard deviation of memory uncertainty.
% a and b: The physical locations of the category boundaries.


% % % % 2. Standardizing the Boundaries
% % % % The mathematical model uses standardized boundary units. You calculate these relative to the true location and the memory uncertainty
% % % a_star = (a - mu) / sigmaM;
% % % b_star = (b - mu) / sigmaM;
% % % ​
% % %
% % % % 3. Implementing the Combined Equation
% % % % The expected value of a report, E(R∣C=c), combines the Prototype Model (weighting) and the Boundary Model (truncation)
% % %
% % %
% % % % In MATLAB code, this is expressed as:
% % % % % Calculate phi (Standard Normal Density)
% % % phi_a = normpdf(a_star, 0, 1);
% % % phi_b = normpdf(b_star, 0, 1);
% % %
% % % % Calculate Phi (Standard Normal Cumulative Distribution)
% % % Phi_a = normcdf(a_star, 0, 1);
% % % Phi_b = normcdf(b_star, 0, 1);
% % %
% % % % Calculate the Expected Value E(R)
% % % expected_report = (lambda * mu) + ((1 - lambda) * p) + ...
% % %     (((phi_a - phi_b) * sigmaM * lambda) / (Phi_b - Phi_a));
% % %
% % % % Calculate the Total Bias
% % % total_bias = expected_report - mu;