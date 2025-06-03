function ds=prototypes_simMap2cosmo(W_SimixSubject_allSubj)
% function ds=prototypes_simMap2cosmo(W_SimixSubject_allSubj)


nsubj = size(W_SimixSubject_allSubj,3);
% figure_height = size(W_SimixSubject_allSubj,2);
% figure_width = size(W_SimixSubject_allSubj,1);
figure_height = size(W_SimixSubject_allSubj,1);
figure_width = size(W_SimixSubject_allSubj,2);
ds = cell(1, nsubj);
for s=1:nsubj
%     ntarget             = 1;
    nfreq               = figure_height;
    ntime               = figure_width;
%     ndata = nfreq*ntarget*ntime;
    dim_labels          = {'freq','time'};
    dim_values          = {1:nfreq, 1:ntime};
    
    data=reshape(W_SimixSubject_allSubj(:,:,s), [1 nfreq ntime]);

%     size(data)
    
    ds{s}               = cosmo_flatten(data, dim_labels, dim_values,2);
    ds{s}.sa.subject    =s;
    cosmo_check_dataset(ds{s});
%     ds{s}.a
end

ds = cosmo_stack(ds);