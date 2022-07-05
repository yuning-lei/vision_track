function [RT] = rigbt(Phi, Psi, Theta, x0, y0, z0)
% Transformation from world coordinate system to camera coordinate system
% Rigid body transformation
% Input parameters:
%   ?=Phi       Angle of rotation around x-axis
%   ?=Psi       Angle of rotation around y-axis
%   ?=Theta     Angle of rotation around z-axis
% Output parameters:
%    RT Rigid body transformation (rotation + translation) of the coordinate system into a new coordinate system
%
% Program
R1 = [1 0 0; 0 cos(Phi) sin(Phi); 0 -sin(Phi) cos(Phi)];% Rotation around X-axis
R2 = [cos(Psi) 0 -sin(Psi); 0 1 0; sin(Psi) 0 cos(Psi)];% Rotation around Y-axis
R3 = [cos(Theta) sin(Theta) 0;-sin(Theta) cos(Theta) 0; 0 0 1 ];% Rotation around Z-axis
R = R3 * R1 * R2;% Rotation matrix (part of rigid body transformation)
T = [x0; y0; z0];% Translation matrix
RT=[R T;0 0 0 1];% Rigid body transformation matrix
return