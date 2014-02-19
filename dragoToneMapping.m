%
% Tone maps an HDR image using the algorithm described in:
%
%   F. Drago, K. Myszkowski, T. Annen, N. Chiba, Adaptive Logarithmic 
%       Mapping for Displaying High Contrast Scenes, Eurographics 2003. 
%
%
% input
%   image: HDR image
%   ldMax: maximum luminance of the display.  The default is 100 cd/m^2.
%   b: bias parameter. Usually between [0.7, 0.9] The default value is 0.85. 
%        
%
% output:
%   imageTM: tone mapped image
%           

function imageTM = dragoToneMapping( image, ldMax, b )

%sets to default parameters if necessary
if(~exist('ldMax'))
    ldMax= 100;
end

if(~exist('b'))
    b = 0.85;
end
colors = size(image,3);
%make sure this is an RGB image
if colors == 3
    
    %get the luminance of the image
    
    limage = luminance(image);
    
    %maximum luminance of the images
    lmax = max(limage(:));
    
    %calculate the world adaption luminance (lwa) with the logarithmic
    %average of the scene
    lwa = logMean(limage);
    
    %adjust lwa  the based on the bias b
    lwa = lwa/((1.0+b-0.85)^5);
    
    %scale limaga and lmax by lwa
    lwimage = limage/lwa; %Lw in paper
    lwmax = lmax/lwa;
    
    %equation 4 from the paper

    ld = (ldMax/100.0)/(log10(1+lwmax))*log(1.0+lwimage)./log(2.0+8.0*((lwimage/lwmax).^(log(b)/log(0.5))));
    
    %change luminance and get an RGB image again
    
    img = changeLuminance(image, limage, ld);
    
    %gamma correct the RGB image
    
    imageTM = gammaDrago(img);

else
    disp('Error: This was not an RGB image.');
end

end

