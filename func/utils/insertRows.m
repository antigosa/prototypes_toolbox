function sequence = insertRows(sequence, new_rows, row_index)
% function sequence = insertRow(sequence, new_rows, row_index)
%
% Insert a new table into another table with same variable names. The new
% table is inserted in the row indicated by 'row_index' and the previous
% data at that location are shifted below by the number of rows of the new
% table (new_rows). 
% If row_index is less than 1, the table is inserted at the beginning; if
% it is more than 1, the table is inserted at the end

if row_index<=1
    row_index=1;
elseif row_index > size(sequence,1)+1
    row_index=size(sequence,1)+1;
end

A = sequence(1:row_index-1,:);
B = sequence(row_index:end,:);
sequence = [A; new_rows; B];