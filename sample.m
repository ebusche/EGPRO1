%
% Create a matrices that samples same pixels throughout the image for
% all images.  The images are thought of as a grid and one point is 
% is sampled for each rectangle in the grid.
%
% input
%  images: the orignal set of images stored in a 4 dimensional matrices
%	[row, col, channel, imageNumber] for imageNumber = 1:number of images.
%
%  gRows: number of rows in the grid
%  gCols: number of columns in the grid
%
%
% output
%  sampleImages: the set of images stored in a 4 dimensional matrices
%	[row, col, channel, imageNumber] for imageNumber = 1:number of images.
%

function [ sampleImages ] = sample( images, gRows, gCols)
%UNTITLED Summary of this function goes here
%   Detailed explanation goes here

dim = size(images);

pgr = round(dim(1) / gRows);
pgc = round(dim(2) / gCols);

% create sample matrix
sampleImages = zeros(gRows, gCols, dim(3), dim(4));

    for i = 1:gRows
	
        for j = 1:gCols
            %randomly pick a row such that pgr*(i-1)< row <= pgr*i
            %randomly pick a col such that pgc*(j-1)< col <= pgc*j
            
            row = pgr*(i-1) + randi(pgr);
            col = pgc*(j-1)+ randi(pgc);
            %copy each channel into sampleImages
            for k = 1:dim(3)
                %copy each image
                for l = 1: dim(4)
                    sampleImages(i,j,k,l) = images(row, col, k, l);
                end
            end
            
        end
        
    end


end

