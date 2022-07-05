% Measure the angle of the object on the z-axis aligned to the FIB, From the tilted SEM image.
% The angle between the measurement target section and the z-axis plane of the SEM is 54°.
% Ref: https://docs.opencv.org/4.x/d9/d0c/group__calib3d.html
% 2022 05 19
% Yuning Lei
%%
clear all;
close all;
clc;

% Inputs:
% Three-point image coordinates of the target angle
P1 = [368, 231];
P2 = [325.865, 354.733]; % The point corresponding to the target angle
P3 = [371.572, 323.459];

%% Parameters
Phi = pi/2+deg2rad(54); % Rotation around x-axis, The default setting is 90+54°.
Psi = 0; % Rotation around y-axis
Theta = 0; % Rotation around z-axis
x0 = 0; % Translation along x-axis
y0 = 0; % Translation along y-axis
z0 = 0; % Translation along z-axis
f = 5.1e3; % The focal length is the working distance of the SEM-FIB intersection position, in µm
dx = 120.7e-3; % Pixel length in µm
dy = 120.7e-3; % Pixel width in µm
u0 = 0; % Image plane center in u
v0 =0; % Image plane center in v

% step1: Convert world coordinates to camera coordinates, rotate and translate (rigid body transformation)
RT = rigbt(Phi, Psi, Theta, x0, y0, z0); % Rigid body transformation matrix
 
% step2: Converting camera coordinates to image coordinates (projection)
Projection_Matrix = proj(f); % Projection transformation matrix
 
% step3:Discrete sampling of image coordinates
Pixel_Matrix = pixel(dx,dy,u0,v0); % The pixel size can be obtained from the scale bar.

%% Conversion from pixel coordinates to image coordinates
P1i = Pixel_Matrix\[P1,1]';
P2i = Pixel_Matrix\[P2,1]';
P3i = Pixel_Matrix\[P3,1]';

% Inverse projection of image coordinates into camera coordinates
P1c = Projection_Matrix\P1i;
P2c = Projection_Matrix\P2i;
P3c = Projection_Matrix\P3i;

% Conversion from camera coordinates to world coordinates
P1w = RT\P1c;
P2w = RT\P2c;
P3w = RT\P3c;

%% Angle measurement in 3D using law of cosine
a2 = (P1w(1)-P2w(1))^2+(P1w(2)-P2w(2))^2+(P1w(3)-P2w(3))^2;
b2 = (P3w(1)-P2w(1))^2+(P3w(2)-P2w(2))^2+(P3w(3)-P2w(3))^2;
c2 = (P1w(1)-P3w(1))^2+(P1w(2)-P3w(2))^2+(P1w(3)-P3w(3))^2;
a = sqrt(a2); % The distance between 1st and 2nd points
b = sqrt(b2); % The distance between 2nd and 3rd points
c = sqrt(c2); % The distance between 3rd and 1st points

pos = (a2+b2-c2)/(2*a*b); % Calculate the cosine of the angle between a and b using the law of cosines
angle = acosd(pos) % Calculate angle in degrees with the inverse cosine value
