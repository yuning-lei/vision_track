function [Pixel_Matrix] = pixel(dx,dy,u0,v0)
% Image coordinates are discretized and converted to pixel coordinates
% Input parameters:
%   dx      Resolution in x-axis direction, pixel size in µm
%   dy      Resolution in y-axis direction, pixel size in µm
%   (u0,v0) Reference coordinates, image plane center (Optional)
    if nargin==2
        u0 = 0;
        v0 = 0;
    end
Pixel_Matrix = [1/dx 0 u0; 0 1/dy v0; 0 0 1];
return