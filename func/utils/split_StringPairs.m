function pairs = split_StringPairs(inputString)
    % Split the input string by underscores.
    parts = split(inputString, '_');

    pairs = {}; % Initialize an empty cell array to store the pairs.

    for i = 1:length(parts)
        % Split each part by hyphens.
        pair = split(parts{i}, '-');

        % Ensure that the part was split into two elements.
        if length(pair) == 2
%             pairs{end + 1} = pair; % Add the pair to the cell array.
            pairs.(pair{1}) = pair{2}; % Add the pair to the cell array.
        end
    end
end