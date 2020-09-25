function ProtoTable = prototypes_compute_errorVectors(ProtoTable)
% function ProtoTable = prototypes_compute_errorVectors(ProtoTable)
% 
% This function computes the error vectors between the actual targets and
% the responses (ProtoTable.errorXY). It also compute the errors' magnitudes
% (ProtoTable.errorMag).
%
% 

% To compute the error, the function needs the actual target positions and
% the responses
assert(any(strcmp(ProtoTable.Properties.VariableNames, 'ActualDots_xy')), ...
    'ActualDots_xy needed to compute error vectors');

assert(any(strcmp(ProtoTable.Properties.VariableNames, 'ResponseDots_xy')), ...
    'RespDots_xy needed to compute error vectors');

% compute the error vector (coordinates)
ProtoTable.errorXY      = ProtoTable.ResponseDots_xy - ProtoTable.ActualDots_xy;

% compute the magnitude
ProtoTable.errorMag     = sqrt(diag(ProtoTable.errorXY * ProtoTable.errorXY'));