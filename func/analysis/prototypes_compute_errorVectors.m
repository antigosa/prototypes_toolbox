function Trials = prototypes_compute_errorVectors(Trials)
% function Trials = prototypes_compute_errorVectors(Trials)
% 
% This function computes the error vectors between the actual targets and
% the responses (Trials.errorXY). It also compute the errors' magnitudes
% (Trials.errorMag).
%
% 

% To compute the error, the function needs the actual target positions and
% the responses
assert(any(strcmp(Trials.Properties.VariableNames, 'ActualDots_xy')), ...
    'ActualDots_xy needed to compute error vectors');

assert(any(strcmp(Trials.Properties.VariableNames, 'ResponseDots_xy')), ...
    'RespDots_xy needed to compute error vectors');

% compute the error vector (coordinates)
Trials.errorXY      = Trials.ResponseDots_xy - Trials.ActualDots_xy;

% compute the magnitude
Trials.errorMag     = sqrt(diag(Trials.errorXY * Trials.errorXY'));