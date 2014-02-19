%      
%
% This applies gamma correction to the RGB image.
%
% input
%   image: an RGB image that needs gamma correction
%   gamma: default 2.2
%   slope: elevation ratio of the tangent line to the gamma curve (default 4.5)
%   start: is the abscissa at the point of tangency (default 0.018)
%
% output:
%    imageOut: gamma corrected RGB image
%

function imageOut = gammaDrago(image,gamma, slope, start)
if(~exist('gamma','var'))
    gamma = 2.2;
end

if(~exist('slope','var'))
    slope = 4.5;

if(~exist('start','var'))
    start = 0.018;
end

%determine which indices contain values <= start 
indLS = find(image<=start);
%determine which indices contain values > start 
indGS = find(image> start);

%gamma correct based on the values
image(indLS) =  image(indLS)*slope;
image(indGS) = (image(indGS).^(0.9/gamma))*1.099-0.099;


%making sure all of the values are between [0.0, 1.0]
image(image < 0.0) = 0.0;
image(image > 1.0) = 1.0;
 
%output image
imageOut = image;

end