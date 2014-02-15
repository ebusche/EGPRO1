%
% convert an image set into HDR, then tone mapping it.
%
% input:
%   folder: the (relative) path containing the image set.
%   lambda: smoothness factor for gsolve.
%   [srow scol]: the dimension of the resized image for sampling in gsolve.
%   prefix: output LDR's prefix
%
function main(folder, srow, scol)

    %%
    % handling default parameters
    if( ~exist('folder') )
	folder = 'capital9'; % no tailing slash!
    end
    if( ~exist('srow') )
	srow = 10;
    end
    if( ~exist('scol') )
	scol = 20;
    end
 
    warning off;
    
    % loading images
    [images, exposures] = readInImages(folder);
    [row, col, channel, number] = size(images);
    ln_t = log(exposures);
    
    % align images
    [alignment, images] = WardAlignment(images, 1, folder, 'jpg');
    images = floor(images);
    %
    % for i = 1: number
    %   img = images(:,:,:,i);
    %   i
    %end
    
    % sampling images
    simages = sample(images,srow,scol);

    % calculating gsolve for each color channel
    g = zeros(256, 3);
   
    w = weightingFunction();
    w = w/max(w);
    
    lambda = 10;

    for channel = 1:3
	rsimages = reshape(simages(:,:,channel,:), srow*scol, number);
	g(:,channel) = gsolve(rsimages, ln_t, lambda, w);
    end
    
    % constructing HDR radiance map
    imgHDR = hdrDebevec(images, g, ln_t, w);
    write_rgbe(imgHDR, [folder '.hdr']);

    %tone mapping and write tone mapped image
     imgTMO  = tmoReinhard02(imgHDR);
     imwrite(imgTMO, [folder '.png']);
    % imgTMO  = DragoTMO(imgHDR);
    % imwrite(imgTMO, [prefix '.png']);

end