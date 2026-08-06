function [x_hat, y_hat] = category_adjustment_estimate_2d(mx, my, Lx, Ux, Ly, Uy, sigma_m)
    % CATEGORY_ADJUSTMENT_ESTIMATE_2D Computes 2D estimates with boundary truncation.
    %
    % Inputs:
    %   mx, my  - Noisy fine-grained memory coordinates
    %   Lx, Ux  - Lower and upper bounds for X
    %   Ly, Uy  - Lower and upper bounds for Y
    %   sigma_m - Standard deviation of the fine-grained memory noise (isotropic)

    x_hat = zeros(size(mx));
    y_hat = zeros(size(my));

    for i = 1:numel(mx)
        cur_mx = mx(i);
        cur_my = my(i);

        % 2D Gaussian likelihood function: p(mx, my | x, y)
        likelihood = @(x, y) normpdf(x, cur_mx, sigma_m) .* normpdf(y, cur_my, sigma_m);

        % Perform 2D numerical integration over the bounded region [Lx, Ux] x [Ly, Uy]
        % Syntax: integral2(fun, xmin, xmax, ymin, ymax)
        num_x = integral2(@(x, y) x .* likelihood(x, y), Lx, Ux, Ly, Uy);
        num_y = integral2(@(x, y) y .* likelihood(x, y), Lx, Ux, Ly, Uy);
        den   = integral2(likelihood, Lx, Ux, Ly, Uy);

        if den > 0
            x_hat(i) = num_x / den;
            y_hat(i) = num_y / den;
        else
            % Fallback if probability mass outside integration bounds is extreme
            x_hat(i) = max(min(cur_mx, Ux), Lx);
            y_hat(i) = max(min(cur_my, Uy), Ly);
        end
    end
end