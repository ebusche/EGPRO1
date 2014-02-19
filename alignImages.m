function [alignment, stackOut] = alignImages(stack, bStackOut, dir_name, format, target_exposure)
%       This function will align images using Ward MTB algorithm
%
%       Input:
%           -stack: a stack (4D) containing all images.
%           -bStackOut: if it is sets to 1 it outputs an aligned stack in
%           stackOut. Otherwise, stackOut = [].
%           -dir_name: the folder name where the stack is stored. This flag
%           is valid if stack=[]
%           -format: the file format of the stack. This flag is valid if
%           stack=[].
%           -target_exposure: The index of the target exposure for aligning
%           images. If stack=[] the name of the target exposure for alignment.
%           If not provided the stack will be analyzed.
%
%       Output:
%           -alignment: a vector of shifting vector for aligning the stack
%           -stackOut: the aligned stack as output

alignment = [];
lst = [];

bStack = ~isempty(stack);

if(~bStack)
    lst = dir([dir_name,'/*.',format]);
    n = length(lst);
else
    [r,c,col,n] = size(stack);
end

if(n<=1)
    return;
end

if(~exist('target_exposure','var'))
    % Finding the best target exposure
    values = zeros(n,1);
    for i=1:n
        if(bStack)
            tmpImg = stack(:,:,:,i);
        else
            tmpImg = single(imread([dir_name,'/',lst(i).name]))/255;
        end
        [r,c,col] = size(tmpImg);
        values(i) = mean(tmpImg(:));
        clear('tmpImg');
    end
    [values,indx] = sort(values);
    
    target_exposure = indx(round(n/2));
else
    if(~bStack)
        tmpTarget_exposure = 1;
        
        for i=1:n
            if(strcmp(target_exposure,lst(i).name)==1)
                tmpTarget_exposure = i;
            end
        end
        target_exposure = tmpTarget_exposure;
    end
end

if(bStack)
    img = stack(:,:,:,target_exposure);
else
    img = single(imread([dir_name,'/',lst(target_exposure).name]))/255;
end

alignment = zeros(n,2);

stackOut = [];
if(bStackOut)
    stackOut = zeros(r,c,col,n);
    stackOut(:,:,:,target_exposure) = img;
end

for i=1:n
    shift_ret = [0, 0];
    
    if(i~=target_exposure)
        
        if(~bStack)
            imgWork = single(imread([dir_name,'/',lst(i).name]))/255;
        else
            imgWork = stack(:,:,:,i);
        end
        
        shift_ret = WardGetExpShift(img, imgWork);
        imWork_shifted = imshift(imgWork,shift_ret(1),shift_ret(2));
        
        [rot_ret, bCheck] = WardSimpleRot(imWork_shifted,img);
        if(bCheck)
            % disp(rot_ret);
            imWork_shifted = imrotate(imWork_shifted,rot_ret,'bilinear','crop');
            
            %final shift
            shift_ret = WardGetExpShift(img, imWork_shifted);
            imWork_shifted = imshift(imWork_shifted,shift_ret(1),shift_ret(2));
        end
        
        if(bStackOut)
            stackOut(:,:,:,i) = imWork_shifted;
        end
        
        if(~bStack)
            oldName = lst(i).name;
            name = strrep(lst(i).name, ['.',format], ['_shifted.',format]);
            if(strcmp(oldName,name)==1)
                name = [name,'_shifted.',format];
            end
            
            imwrite(imWork_shifted,[dir_name,'/',name]);
        end
        
        clear('imWork_shifted');
        clear('imgWork');
    end
    
    alignment(i,:) = shift_ret;
end

end


function [imgThr, imgEb] = WardComputeThreshold(img, wardPercentile, wardTolerance)
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

function cur_shift = WardGetExpShift(img1, img2, shift_bits, wardPercentile)
%       This function computes the Ward's MTB.
%
%       Input:
%           -img1: the target image
%           -img2: the image that needs to be aligned to img1
%
%       Output:
%           -cur_shift: shifting vector for aligning img2 into img1.

if(~exist('wardPercentile','var'))
    wardPercentile = 0.5;
end

if(~exist('shift_bits','var'))
    shift_bits = 6;
end

cur_shift = zeros(2,1);
shift_ret = zeros(2,1);

while(shift_bits > 0)
    %computing MTB
    sml_img1 = imresize(img1,2^(-shift_bits),'bilinear');
    sml_img2 = imresize(img2,2^(-shift_bits),'bilinear');
    
    [tb1,eb1] = WardComputeThreshold(sml_img1,wardPercentile);
    [tb2,eb2] = WardComputeThreshold(sml_img2,wardPercentile);

    [r,c,col] = size(sml_img1);

    min_err = r*c;

    tb1 = logical(tb1);
    eb1 = logical(eb1);

    for i=-1:1
        for j=-1:1
            xs = cur_shift(1) + i;
            ys = cur_shift(2) + j;

            shifted_tb2 = logical(imshift(tb2,xs,ys));
            shifted_eb2 = logical(imshift(eb2,xs,ys));

            diff_b = bitxor(tb1,shifted_tb2);
            diff_b = diff_b & eb1;
            diff_b = diff_b & shifted_eb2;

            err = sum(sum(diff_b));

            if (err < min_err)
                shift_ret = [xs;ys];
                min_err = err;
            end
        end
    end
    
    shift_bits = shift_bits - 1;
    cur_shift  = shift_ret*2;
end

end

function [angle_rot, bCheck] = WardSimpleRot(img1, img2)
%       This function computes the Ward's MTB.
%
%       Input:
%           -img1: the target image
%           -img2: the image that needs to be aligned to img1
%
%       Output:
%           -rot: rotation angle (degree) for aligning img2 into img1.

[r,c,col] = size(img1);

blocksY = 3;
blocksX = 4;
sizeY = round(r/blocksY);
sizeX = round(c/blocksX);

angle = [];

%Analysing blocks
for i=1:blocksY
    rect  = [sizeY*(i-1)+1,sizeY*i,1,sizeX];
    [tmpAngle,check] = WardSimpleRotAux(img1, img2, rect);
    if(check==1)
        angle = [angle, tmpAngle];
    end
end

%Final Merging
if(length(angle)<1)
    angle_rot = 0.0;
    bCheck = 0;
else
    rotThreshold = (0.07*180.0)/pi;
    npos = 0;
    nneg = 0;
    for i=1:length(angle)

        if(angle(i)>rotThreshold)
            npos = npos + 1;
        end

        if(angle(i)<-rotThreshold)
            nneg = nneg + 1;
        end
    end

    if(bitand(nneg,npos))
        angle_rot = 0.0;
        bCheck = 0;
    else
        angle_rot = mean(angle);
        bCheck = 1;
    end
end

end

function [angle, check] = WardSimpleRotAux(img1, img2, rect)
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

function ret=MaxQuart(matrix,percentile)
%       Input:
%           -matrix: a matrix
%           -percentile: the percentile
%
%       Output:
%           -ret: the percentile of the input matrix

[n,m]=size(matrix);

matrix=sort(reshape(matrix,n*m,1));

ret=matrix(round(n*m*percentile));

end

function imgOut = imshift(img, is_dx, is_dy)
%
%		 Input:
%           -img: an input image to be shifted
%           -is_dx: shift amount (in pixels) on the X-axis
%           -is_dy: shift amount (in pixels) on the Y-axis
%
%		 Output:
%			-imgOut: the final shifted image

if(~exist('is_dx'))
    is_dx = 0;
end

if(~exist('is_dy'))
    is_dy = 0;
end

imgOut = zeros(size(img));
imgTmp = zeros(size(img));

if(abs(is_dx)>0)
    if(is_dx>0)
        imgTmp(:,(is_dx+1):end,:) = img(:,1:(end-is_dx),:);
    else
        imgTmp(:,1:(end+is_dx),:) = img(:,(1-is_dx):end,:);    
    end
else
    imgTmp = img;
end

if(abs(is_dy)>0)
    
    if(is_dy>0)
        imgOut((is_dy+1):end,:,:) = imgTmp(1:(end-is_dy),:,:);
    else
        imgOut(1:(end+is_dy),:,:) = imgTmp((1-is_dy):end,:,:);    
    end
else
    imgOut = imgTmp;
end

end
