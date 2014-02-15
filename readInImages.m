%
% read in the images and store with corresponding exposure time
% assume image is in color with jpg format
%
% input
%  folder: folder where the images reside.
%
% output
%  images: the set of images stored in a 4 dimensional matrices
%	[row, col, channel, imageNumber] for imageNumber = 1:number of images.
%  expTimes: (number, 1) matrices, stores the exposure time in seconds.
%
%
function [images, expTimes] = readInImages(folder)
    images = [];
    expTimes = [];
    
    %get the image files from the folder
    %assume the format of the images is jpg
    files = dir([folder, '/*.JPG']);
    
    %get some intitializing info
    file = [folder, '/', files(1).name];
    info = imfinfo(file);
    number = length(files);
    numRows = info.Height;
    numCols = info.Width;
    images = zeros(numRows, numCols, 3, number);
    expTimes = zeros(number, 1);
    
    
   %store images
    for i = 1:number
        file = [folder, '/', files(i).name];
        image = imread(file);
        images(:,:,:,i) = image;

        info = exifread(file);
        expTimes(i) = info.ExposureTime;
    
    end
    
    
    
end

