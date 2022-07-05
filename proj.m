function [Projection_Matrix] = proj(f)
% Projection of camera coordinates into image coordinates
% Input parameters:
%   f                   SEM Camera focal length in µm
% Output parameters:
%   Projection_Matrix   Projection transformation matrix
Projection_Matrix = [f 0 0 0; 0 f 0 0; 0 0 1 0];
return