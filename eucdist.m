function dist = eucdist(x,y)
% Calculates the euclidean distance between coordinates
% Inputs:
% x - vector of length 3 with coordinates of point x
% y - vector of length 3 with coordinates of point y
%
% Outputs:
% dist - Euclidean distance between x and y

if(nargin<2 || nargin>2)
    error('Number of arguments must be equal to two');
end

dist = sqrt(sum((x-y).^2));

end