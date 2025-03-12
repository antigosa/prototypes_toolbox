function timeString = secondsToTimeString(seconds)
    % Convert seconds to hours, minutes, and seconds.
    hours = floor(seconds / 3600);
    seconds = mod(seconds, 3600);
    minutes = floor(seconds / 60);
    seconds = round(mod(seconds, 60)); % Round to nearest second.

    % Build the time string.
    timeString = '';
    if hours > 0
        timeString = [timeString, num2str(hours), ' hr '];
    end
    if minutes > 0
        timeString = [timeString, num2str(minutes), ' min '];
    end
    if seconds >= 0 || (hours == 0 && minutes == 0) %always show seconds if total time is less than one minute.
        timeString = [timeString, num2str(seconds), ' sec'];
    end
    %Remove trailing space if only seconds were present.
    if timeString(end) == ' '
        timeString = timeString(1:end-1);
    end
end