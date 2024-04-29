function Trials = prototypes_store_atrial(Trials, atrial)

if nargin==0; [Trials, atrial] = get_test_parameters_prototypes_store_atrial; end

if ~istable(atrial)
    atrial=struct2table(atrial);
end

Trials = [Trials;atrial];


function [Trials, atrial] = get_test_parameters_prototypes_store_atrial

% a = (1:4)';
% b = {'1', '2', '3', '4'}';
% 
% Trials = table(a, b);
% 
% atrial = {1, '5'};

trial   = 1;
subject = 10;

ActualDots_xy = [11 12];

Trials = table(trial, subject, ActualDots_xy);

atrial = struct(...
    'trial', 2, ...
    'subject', 10, ...
    'ActualDots_xy',[10 15]...
);