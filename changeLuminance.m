%
% Update the the RGB image with the new luminance values
%
% input
%   image: RGB input image
%   lOrg: matrix of original luminance values
%   lNew: matrix of the new luminance values
%
% output
%   imageOut: output image with the new luminance values
%
function imageOut = changeLuminance(image, lOrg, lNew)

col = size(image,3);

imageOut = zeros(size(image));
 
%update each of the color channels with the new luminence values
for i=1:col
    imageOut(:,:,i) = (image(:,:,i).*lNew)./lOrg;
end
        

imageOut = removeSpecials(imageOut);

end