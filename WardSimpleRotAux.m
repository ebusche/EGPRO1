function [angle, check] = WardSimpleRotAux(img1, img2, rect)
%
%
%       rot = WardSimpleRotAux(img1, img2, rect)
%
%       This function computes the Ward's MTB.
%
%       Input:
%           -img1: the target image
%           -img2: the image that needs to be aligned to img1
%
%       Output:
%           -rot: rotation angle (degree) for aligning img2 into img1.

[r,c,col] = size(img1);

maxDivergence = 0.005;

%First block
r_img1  = img1(rect(1):rect(2),rect(3):rect(4),:);
r_img2  = img2(rect(1):rect(2),rect(3):rect(4),:);
r1_shift = WardGetExpShift(r_img1, r_img2);

%Mirror block
rect_mirror(1) = r - rect(2)+1;
rect_mirror(2) = r - rect(1)+1;
rect_mirror(3) = c - rect(4)+1;
rect_mirror(4) = c - rect(3)+1;

r_img1  = img1(rect_mirror(1):rect_mirror(2),rect_mirror(3):rect_mirror(4),:);
r_img2  = img2(rect_mirror(1):rect_mirror(2),rect_mirror(3):rect_mirror(4),:);
r2_shift = WardGetExpShift(r_img1, r_img2);

dx = rect_mirror(3) - rect(3);
dy = rect_mirror(1) - rect(1);

dxr = dx + 0.5*(r2_shift(1) - r1_shift(1));
dyr = dy + 0.5*(r2_shift(2) - r1_shift(2));

value = abs(sqrt((dxr*dxr + dyr*dyr)/(dx*dx + dy*dy)) - 1.0);

if(value<=maxDivergence)
    angle = atan2(dyr,dxr) - atan2(dy,dx);
    angle = (angle*180.0)/pi;
    check = 1;
else
    angle = 0.0;
    check = 0;
end    

end