close all;
clear all;
clc;
%% Load video file

[file,path] = uigetfile('*.*','Select a video file to open');
video = VideoReader(fullfile(path,file));
nFrame = video.NumberOfFrame;
fRate = video.FrameRate;
time = video.Duration;
frame_1 = read(video,1);

% Manually select the same video file in simulink multimedia file source
open vision_track_point.slx
uiwait(msgbox({'Please select the same video file in "From Multimedia File" block';'Click OK after you complete this step'},'Important!'));

%% Select tracking point and ROI

imshow(frame_1);
hold on;
uiwait(msgbox('Select a point to track from the image: ','Tracking point'));
[x,y] = ginput(1);
plot(x,y,'x', 'MarkerSize', 15, 'MarkerEdgeColor','r','MarkerFaceColor', 'r','LineWidth',2);
point = single([x,y]);
uiwait(msgbox('Select a rectangle ROI from the image: (Double click the region to confirm)','ROI'));
roi = imrect;
position = wait(roi);
position = single(position);

%% Run simulink
sim('vision_track_point');

%% Measure displacement by image processing

psize_str = (inputdlg({'Enter video pixel size: ','Enter length unit: '},'Pixel size'));
psize = str2num(psize_str{1});
x_location = psize*(Location(:,1)-int32(ones(length(Location(:,1)),1)*point(1)));
y_location = psize*(Location(:,2)-int32(ones(length(Location(:,2)),1)*point(2)));
t = 0:1/fRate:time;

figure;
plot(t,x_location,t,y_location);
title(['X and Y displacement in ',psize_str{2}]);
xlabel('Time (s)');
ylabel(['Displacement (',psize_str{2},')']);
legend('x-location','y-location');

figure;
plot(Location(:,2),Location(:,1))
set(gca,'XAxisLocation','top');   
set(gca,'YDir','reverse');
title('Tracking point trajectory');
xlabel('x-direction pixel coordinate');
ylabel('y-direction pixel coordinate');

return



