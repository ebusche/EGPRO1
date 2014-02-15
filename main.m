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
	folder = '../capital9'; % no tailing slash!
    end
    if( ~exist('srow') )
	srow = 10;
    end
    if( ~exist('scol') )
	scol = 20;
    end
 
    disp('loading images');
    [images, exposures] = readInImages(folder);
    [row, col, channel, number] = size(images);
    ln_t = log(exposures);

    disp('sampling images');
    
    simages = sample(images,srow,scol);

    disp('calculating gsolve for each color channel.');
    g = zeros(256, 3);
   
    w = weightingFunction();
    w = w/max(w);
    
    lamda = 10;

    for channel = 1:3
	rsimages = reshape(simages(:,:,channel,:), srow*scol, number);
	g(:,channel) = gsolve(rsimages, ln_t, lambda, w);
    end
    
    tokens = strsplit('/', folder);
	prefix = char(tokens(end));

    disp('constructing HDR radiance map.');
    imgHDR = hdrDebevec(images, g, ln_t, w);
    write_rgbe(imgHDR, [prefix '.hdr']);

    disp('tone mapping');
    imgTMO = tmoReinhard02(imgHDR, 'global', alpha_, 1e-6, white_);
    write_rgbe(imgTMO, [prefix '_tone_mapped.hdr']);
    imwrite(imgTMO, [prefix '_tone_mapped.png']);

    disp('done!'m);
    %exit();
end