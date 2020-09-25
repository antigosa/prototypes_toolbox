function csm = prototypes_change_alpha(csm, newalpha)
% function csm = prototypes_change_alpha(csm, newalpha)
% NOTE SURE IT MAKES SENSE

nsubj = size(csm.SimixSubject, 3);

X0                      = csm.Properties.UserData.ShapeContainerRect(1);
Y0                      = csm.Properties.UserData.ShapeContainerRect(2);
FigureWidth             = csm.Properties.UserData.ShapeContainerRect(3);
FigureHeight            = csm.Properties.UserData.ShapeContainerRect(4);

figure_size             = [FigureHeight+abs(Y0)+1 FigureWidth+abs(X0)+1];


MaxDistance             = round(sqrt(FigureHeight^2 + FigureWidth^2));

weights                 = gausswin(MaxDistance*2,newalpha);
weights                 = [(1:MaxDistance)' weights(MaxDistance+1:end)];

W_SimixSubject          = zeros(figure_size);

for s = 1:nsubj
    
    for x =  X0:FigureWidth
        for y = Y0:FigureHeight
            
            i = x-X0+1;j= y-Y0+1;
            
            % assign a weight to each dot (based on the dot distance)
            index                   = round(ActDot2PrototypeLength)+1; % if index == 0 % The weights start in 1. % Index zero correspont to an index were actualpoint and predicted point is the same.
            index(isnan(index) | index >= MaxDistance)           = MaxDistance;
            
            CosEach                 = csm.SimixSubject(y, x, s);
            
            GausWeights             = weights(index,2);
            % Calculate the weightned index, depending on the distance of the actual dot to the suggested prototype (pixel based).
            csi_w                   = nansum(CosEach.*GausWeights)/nansum(GausWeights);
            
            W_SimixSubject(j,i)     = csi_w;
            
        end
    end
    
    
    
end

