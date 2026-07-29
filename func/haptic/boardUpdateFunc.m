function txt = boardUpdateFunc(~, event_obj, im, vals)

if nargin<4
    txt = sprintf('\nxyz: %.03f %.03f %.03f\nvertex: %d\n\n', event_obj.Position(1), event_obj.Position(2), event_obj.Position(3), knnsearch(im.Points, event_obj.Position));
else
    txt = sprintf('\nval: %d\nxyz: %.03f %.03f %.03f\nvertex: %d\n\n', vals(knnsearch(im.Points, event_obj.Position)), event_obj.Position(1), event_obj.Position(2), event_obj.Position(3), knnsearch(im.Points, event_obj.Position));
end
    

fprintf(txt);
