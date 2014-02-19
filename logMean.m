%
% returns the logarithmic average of the image
%   
% input
%   image: input image as luminance values
%
% output
%   la: the logarithmic average of the image's luminance values
%

function la=logMean(image)

%the step size d
d = 1e-6;

%compute the log of the luminance values
img_delta = log(image+d);

%find the logarithmic average
la = exp(mean(img_delta(:)));

end