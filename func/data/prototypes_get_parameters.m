function par = prototypes_get_parameters(par)
% function par = prototype_get_parameters(par)

key = par(1:2:end);
val = par(2:2:end);
clear par;
for k = 1:length(key)
    par.(key{k}) = val{k};
end