function [imgThr, imgEb] = WardComputeThreshold(img, wardPercentile, wardTolerance)
%
%
%       [imgThr, imgEb] = WardComputeThreshold(img, wardPercentile, wardTolerance)
%
%       This function computes the Ward's MTB.
%
%       Input:
%           -img: an input image
%           -wardPercentile: a value for thresholding the image. This is
%           typically set to 0.5.
%           -wardTolerance: a tolerance threshold for classifying pixels
%           falling around edges.
%
%       Output:
%           -imgThr: Ward's threshold image. This image is set to 1 if the
%           the pixel value is greater or equal to the median value.
%           -imgEb: a tolerance mask of pixels around edges of imgThr.

if(~exist('wardPercentile'))
    wardPercentile = 0.5;
end

if(~exist('wardTolerance'))
    wardTolerance = 4/256;
end

grey = [];

if(size(img,3)==1)
    grey = img;
else
    grey = (54*img(:,:,1) + 183*img(:,:,2) + 19*img(:,:,3)) / 256;
end

medVal = MaxQuart(grey, wardPercentile);
    
imgThr = zeros(size(grey));
imgThr(grey>medVal) = 1.0;

A = medVal-wardTolerance;
B = medVal+wardTolerance;
imgEb = ones(size(grey));
imgEb((grey>=A)&(grey<=B)) = 0.0;

end