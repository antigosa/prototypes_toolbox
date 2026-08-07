function data_type = prototypes_datatype(Data)

if isfield(Data, 'Trials') && isfield(Data, 'csimaps')
    data_type='ProtoData';
elseif istable(Data)
    data_type='Trials';
else
    data_type='csimaps';
end

