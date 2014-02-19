function img=removeSpecials(img)
%
%
%       img=RemoveSpecials(img)
%
%
%       This function removes specials: Inf and NaN
%
%       Input:
%           -img: an image which can contain float special values
%
%       Output:
%           -img: the image without float special values

img(isnan(img)|isinf(img))=0;

end
