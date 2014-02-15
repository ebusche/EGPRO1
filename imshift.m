function imgOut = imshift(img, is_dx, is_dy)
%
%		 imgOut = imshift(img, is_dx, is_dy)
%
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