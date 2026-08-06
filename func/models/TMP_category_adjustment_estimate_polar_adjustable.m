function [x_hat, y_hat] = TMP_category_adjustment_estimate_polar_adjustable(mx, my, R, theta_min, theta_max, sigma_m, truncation_scale)
    % CATEGORY_ADJUSTMENT_ESTIMATE_POLAR_ADJUSTABLE 
    % Adds a 'truncation_scale' parameter (0 to 1) to control the effective boundary strictness.
    %
    % Inputs:
    %   mx, my           - Noisy fine-grained memory coordinates
    %   R                - Radius of the circular space
    %   theta_min        - Lower angular boundary
    %   theta_max        - Upper angular boundary
    %   sigma_m          - Standard deviation of memory noise
    %   truncation_scale - Parameter controlling boundary strictness (default: 1.0)
    %                      Lower values shrink the effective boundary, increasing truncation effect.

    if nargin < 7
        truncation_scale = 1.0; 
    end

    % Adjust effective radius based on the parameter
    effective_R = R * truncation_scale;

    x_hat = zeros(size(mx));
    y_hat = zeros(size(my));

    for i = 1:numel(mx)
        cur_mx = mx(i);
        cur_my = my(i);

        likelihood_polar = @(r, theta) ...
            normpdf(r .* cos(theta), cur_mx, sigma_m) .* ...
            normpdf(r .* sin(theta), cur_my, sigma_m) .* r; 

        integrand_x = @(r, theta) (r .* cos(theta)) .* likelihood_polar(r, theta);
        integrand_y = @(r, theta) (r .* sin(theta)) .* likelihood_polar(r, theta);

        % Integrate using the scaled effective radius
        num_x = integral2(integrand_x, 0, effective_R, theta_min, theta_max);
        num_y = integral2(integrand_y, 0, effective_R, theta_min, theta_max);
        den   = integral2(likelihood_polar, 0, effective_R, theta_min, theta_max);

        if den > 0
            x_hat(i) = num_x / den;
            y_hat(i) = num_y / den;
        else
            r_mem = sqrt(cur_mx^2 + cur_my^2);
            if r_mem > effective_R
                x_hat(i) = cur_mx * (effective_R / r_mem);
                y_hat(i) = cur_my * (effective_R / r_mem);
            else
                x_hat(i) = cur_mx;
                y_hat(i) = cur_my;
            end
        end
    end
end