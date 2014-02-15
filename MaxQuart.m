function ret=MaxQuart(matrix,percentile)
%
%
%       ret=MaxQuart(matrix,percentile)
%
%
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
