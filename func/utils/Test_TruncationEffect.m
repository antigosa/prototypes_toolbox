figure; scatter(mu(:,1), mu(:, 2))

phi = @(x) exp((-x.^2)/sqrt(2*pi));


LocationLoc     = -2:0.1:3;
LocationSD      = 3;
B1 = -3;
B2 = 5;

B1s = (B1-LocationLoc)/LocationSD;
B2s = (B2-LocationLoc)/LocationSD;

ER = LocationLoc + ((phi(B2s)-phi(B1s))*LocationSD)/(normcdf(B2s)-normcdf(B1s));

Bias = ER - LocationLoc;

figure; plot(LocationLoc, Bias);



