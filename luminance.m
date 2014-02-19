%
% Takes an image and computes the luminance for all of the pixels
% in the image.
% 
% input
%   image: an image in RGB
%
% output
%   lImage: the luminance of the image
%

function lImage = luminance( image )

lImage = 0.2126*image(:,:,1)+0.7152*image(:,:,2)+0.0722*image(:,:,3);

end

