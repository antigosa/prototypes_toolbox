function [x_hat, y_hat] = category_adjustment_estimate_polar(mx, my, R, theta_min, theta_max, sigma_m)
    % CATEGORY_ADJUSTMENT_ESTIMATE_POLAR Computes 2D estimates with a circular boundary 
    % using polar coordinates (r, theta) for numerical integration.
    %
    % Inputs:
    %   mx, my    - Noisy fine-grained memory coordinates (Cartesian)
    %   R         - Radius of the circular space
    %   theta_min - Lower angular boundary of the sector (in radians, e.g., 0)
    %   theta_max - Upper angular boundary of the sector (in radians, e.g., pi/2)
    %   sigma_m   - Standard deviation of the fine-grained memory noise (isotropic)

    x_hat = zeros(size(mx));
    y_hat = zeros(size(my));

    for i = 1:numel(mx)
        cur_mx = mx(i);
        cur_my = my(i);

        % Transform the evaluation point into the integrand.
        % Cartesian coordinates inside the integrand expressed in terms of polar (r, theta):
        % x = r * cos(theta)
        % y = r * sin(theta)
        
        % 2D Gaussian likelihood in polar coordinates, multiplied by the Jacobian (r)
        % Note: integral2 in MATLAB treats the first variable as 'xmin/xmax' (here r) 
        % and the second variable as 'ymin/ymax' (here theta).
        %   "Assuming the dot was flashed at this location, how likely is it 
        %   that I would get the blurry memory trace (cur_mx, cur_my) that I 
        %   currently have?"
        % loops through every possible tree in the forest ($r$ and $\theta$), 
        % tests how well each tree explains the footprint you found 
        % (cur_mx, cur_my), and gives a score to every single one. 
        % Spots close to your footprint get a high score; 
        % spots far away get a score close to zero
        likelihood_polar = @(r, theta) ...
            normpdf(r .* cos(theta), cur_mx, sigma_m) .* ...
            normpdf(r .* sin(theta), cur_my, sigma_m) .* r; % Don't forget the Jacobian 'r'!

        % Integrands for expected values of X and Y mapped back to Cartesian outputs
        integrand_x = @(r, theta) (r .* cos(theta)) .* likelihood_polar(r, theta);
        integrand_y = @(r, theta) (r .* sin(theta)) .* likelihood_polar(r, theta);

        % Perform 2D numerical integration over [0, R] x [theta_min, theta_max]
        % Syntax: integral2(fun, r_min, r_max, theta_min, theta_max)
        num_x = integral2(integrand_x, 0, R, theta_min, theta_max); % circular truncation boundary
        num_y = integral2(integrand_y, 0, R, theta_min, theta_max); % circular truncation boundary
        den   = integral2(likelihood_polar, 0, R, theta_min, theta_max);

        if den > 0
            x_hat(i) = num_x / den;
            y_hat(i) = num_y / den;
        else
            % Fallback: clamp original Cartesian memory to circle bounds if density is zero
            r_mem = sqrt(cur_mx^2 + cur_my^2);
            if r_mem > R
                x_hat(i) = cur_mx * (R / r_mem);
                y_hat(i) = cur_my * (R / r_mem);
            else
                x_hat(i) = cur_mx;
                y_hat(i) = cur_my;
            end
        end
    end
end