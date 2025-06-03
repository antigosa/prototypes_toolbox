function [centroids, x_small_circle, y_small_circle] = prototypes_findCentroids(radius, center, subregions_radius, plotImage)

if nargin==0
    
    % Define the circle parameters
    radius = 1; % Example radius
    center = [0, 0]; % Example center coordinates [x, y]
    plotImage = 0;
end
% 1. Define the dividing lines (horizontal and vertical diameters)
% The horizontal diameter lies on the line y = center(2)
% The vertical diameter lies on the line x = center(1)

% 2. Determine the boundaries of the four subregions
% Region 1: x >= center(1) and y >= center(2) (Top Right)
% Region 2: x <= center(1) and y >= center(2) (Top Left)
% Region 3: x <= center(1) and y <= center(2) (Bottom Left)
% Region 4: x >= center(1) and y <= center(2) (Bottom Right)

% 3. Calculate the centroid of each subregion
% Due to symmetry, the centroids will be at the same distance from the center
% along the axes.

% Consider the first quadrant (x >= 0, y >= 0) of a unit circle.
% The centroid of a quarter circle is at (4*r/(3*pi), 4*r/(3*pi)).
% For a unit circle (r=1), this is (4/(3*pi), 4/(3*pi)).

centroid_distance = 4 * radius / (3 * pi);

centroid1 = center + [centroid_distance, centroid_distance];   % Top Right
centroid2 = center + [-centroid_distance, centroid_distance];  % Top Left
centroid3 = center + [-centroid_distance, -centroid_distance]; % Bottom Left
centroid4 = center + [centroid_distance, -centroid_distance];  % Bottom Right

centroids = [centroid1; centroid2; centroid3; centroid4];

% 4. Draw the original circle
theta       = linspace(0, 2*pi, 100);
x_circle    = radius * cos(theta) + center(1);
y_circle    = radius * sin(theta) + center(2);

if plotImage
    plot(x_circle, y_circle, 'b-', 'LineWidth', 1.5);
    hold on;
    axis equal; % Ensure the circle looks like a circle
    
    % 5. Draw the dividing lines (diameters)
    plot([center(1) - radius, center(1) + radius], [center(2), center(2)], 'k--'); % Horizontal
    plot([center(1), center(1)], [center(2) - radius, center(2) + radius], 'k--'); % Vertical
    
    % 6. Draw the centroids of the four subregions
    plot(centroids(:, 1), centroids(:, 2), 'r+', 'MarkerSize', 10, 'LineWidth', 2);
end
% 7. Draw the four new smaller circles centered at the centroids

if subregions_radius<1
    small_radius = subregions_radius * radius; % Adjust the size as needed
else
    small_radius = subregions_radius;
end

for i = 1:4
    x_small_circle(:,i) = small_radius * cos(theta) + centroids(i, 1);
    y_small_circle(:,i) = small_radius * sin(theta) + centroids(i, 2);
    if plotImage
        plot(x_small_circle(:,i), y_small_circle(:,i), 'g-', 'LineWidth', 1);
    end
end

if plotImage
    % Add labels and title
    xlabel('x');
    ylabel('y');
    title('Circle Divided into Four Regions with Centroid Circles');
    grid on;
    hold off;
end