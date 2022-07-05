function [Camera_Parameters] = camera_parameters()
% Parameters for converting world coordinates to pixel coordinates

Phi = pi/2+deg2rad(54); % Rotation around x-axis, The default setting is 90+54°.
Psi = 0; % Rotation around y-axis
Theta = 0; % Rotation around z-axis
x0 = 0; % Translation along x-axis
y0 = 0; % Translation along y-axis
z0 = 0; % Translation along z-axis
f = 5.1e3; % The focal length is the working distance of the SEM-FIB intersection position
dx = 120.7e-3; % Pixel length
dy = 120.7e-3; % Pixel width
u0 = 0; % Image plane center in u
v0 =0; % Image plane center in v
 
% step1: Convert world coordinates to camera coordinates, rotate and translate (rigid body transformation)
RT = rigbt(Phi, Psi, Theta, x0, y0, z0); % Rigid body transformation matrix
 
% step2: Converting camera coordinates to image coordinates (projection)
Projection_Matrix = proj(f); % Projection transformation matrix
 
% step3:Discrete sampling of image coordinates
Pixel_Matrix = pixel(dx,dy,u0,v0); % The pixel size can be obtained from the scale bar.

%% Data Integration
Camera_Internal_Parameters = Pixel_Matrix * Projection_Matrix;
Camera_External_Parameters = RT;
% Clear unused variables
clearvars -except Camera_Internal_Parameters Camera_External_Parameters
% Camera Parameters
Camera_Parameters = Camera_Internal_Parameters*Camera_External_Parameters; 
clearvars -except Camera_Parameters
