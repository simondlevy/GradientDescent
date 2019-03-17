function [x,y] = discpoints(cx, cy, r, n)
% DISCPOINTS   Random points within a disc.
%    [X,Y] = DISCPOINTS(CX, CY, R, N) returns N randomly generated points 
%    with coordinates (X,Y) contained in a disc of radius R centered at 
%    (CX,CY) of radius R.  

% generate 2N points in a square whose center is the center of the circle
% and whose side is twice the radius
x = randpts(cx, r, 2*n);
y = randpts(cy, r, 2*n);

% take points from the disc centered inside the square
d = sqrt((x-cx).^2 + (y-cy).^2);
x = x(find(d<r));
y = y(find(d<r));

% keep N points from the circle
x = x(1:n);
y = y(1:n);

% local function generating N random points in line segment whose midpoint
% is C and whose length is 2N
function x = randpts(c, r, n)
x = c + rand(1,n) * r*2 - r;
