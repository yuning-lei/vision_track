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
open vision_track_3_points.slx
uiwait(msgbox({'Please select the same video file in "From Multimedia File" block! ';'Click OK after you complete this step'},'Important!'));

%% Select tracking point and ROI
template = 40; % template size
roi = 100; % ROI size

imshow(frame_1);
hold on;
uiwait(msgbox('Select 3 points to track from the image: ','Tracking point'));
[x1, y1] = ginput(1);
plot(x1,y1,'x', 'MarkerSize', 15, 'MarkerEdgeColor','c','MarkerFaceColor', 'c','LineWidth',2);
%point1 = single([x1, y1]);
point1 = single(double(rgb2gray(imcrop(frame_1, [x1-template y1-template template*2 template*2])))./255);
[x2, y2] = ginput(1);
plot(x2,y2,'x', 'MarkerSize', 15, 'MarkerEdgeColor','y','MarkerFaceColor', 'y','LineWidth',2);
%point2 = single([x2, y2]);
point2 = single(double(rgb2gray(imcrop(frame_1, [x2-template y2-template template*2 template*2])))./255);
[x3, y3] = ginput(1);
plot(x3,y3,'x', 'MarkerSize', 15, 'MarkerEdgeColor','m','MarkerFaceColor', 'm','LineWidth',2);
%point3 = single([x3, y3]);
point3 = single(double(rgb2gray(imcrop(frame_1, [x3-template y3-template template*2 template*2])))./255);

% uiwait(msgbox('Select 3 rectangle ROI correspond t0 3 point from the image: (Double click the region to confirm)','ROI'));
% roi1 = imrect;
% position1 = wait(roi1);
position1 = [x1-roi y1-roi roi*2 roi*2];
position1 = single(position1);

% roi2 = imrect;
% position2 = wait(roi2);
position2 = [x2-roi y2-roi roi*2 roi*2];
position2 = single(position2);

% roi3 = imrect;
% position3 = wait(roi3);
position3 = [x3-roi y3-roi roi*2 roi*2];
position3 = single(position3);

%% Run simulink
sim('vision_track_3_points');

%% Measure displacement by image processing

psize_str = inputdlg({'Enter video pixel size in nm: '},'Pixel size');
psize = str2num(psize_str{1});
t = 0:1/fRate:time;

% Measure the 1st point location
x1_location = psize*(Location1(:,1)-int32(ones(length(Location1(:,1)),1)*point1(1)))/1e3;
y1_location = psize*(Location1(:,2)-int32(ones(length(Location1(:,2)),1)*point1(2)))/1e3;

figure;
set(gcf,'WindowState','maximized');
subplot(2,3,1);
plot(t,x1_location,t,y1_location);
title(['1st point''s X and Y displacement']);
xlabel('Time (s)');
ylabel(['Displacement (µm)']);
legend('x-location','y-location');

subplot(2,3,4);
plot(Location1(:,2),Location1(:,1))
set(gca,'XAxisLocation','top');   
set(gca,'YDir','reverse');
title('Tracking point trajectory of 1st point');
xlabel('x-direction pixel coordinate');
ylabel('y-direction pixel coordinate');

% Measure the 2nd point location
x2_location = psize*(Location2(:,1)-int32(ones(length(Location2(:,1)),1)*point2(1)))/1e3;
y2_location = psize*(Location2(:,2)-int32(ones(length(Location2(:,2)),1)*point2(2)))/1e3;

subplot(2,3,2);
plot(t,x2_location,t,y2_location);
title(['2nd point''s X and Y displacement']);
xlabel('Time (s)');
ylabel(['Displacement (µm)']);
legend('x-location','y-location');

subplot(2,3,5);
plot(Location2(:,2),Location2(:,1))
set(gca,'XAxisLocation','top');   
set(gca,'YDir','reverse');
title('Tracking point trajectory of 2nd point');
xlabel('x-direction pixel coordinate');
ylabel('y-direction pixel coordinate');

% Measure the 3rd point location
x3_location = psize*(Location3(:,1)-int32(ones(length(Location3(:,1)),1)*point3(1)))/1e3;
y3_location = psize*(Location3(:,2)-int32(ones(length(Location3(:,2)),1)*point3(2)))/1e3;

subplot(2,3,3);
plot(t,x3_location,t,y3_location);
title(['3rd point''s X and Y displacement']);
xlabel('Time (s)');
ylabel(['Displacement (µm)']);
legend('x-location','y-location');

subplot(2,3,6);
plot(Location3(:,2),Location3(:,1))
set(gca,'XAxisLocation','top');   
set(gca,'YDir','reverse');
title('Tracking point trajectory of 3rd point');
xlabel('x-direction pixel coordinate');
ylabel('y-direction pixel coordinate');

%% Measure the change of the angle corresponding to the second point over time

A = zeros(1,nFrame+1);
for i = 1:nFrame+1
    x1 = single(Location1(i,1));
    y1 = single(Location1(i,2));
    x2 = single(Location2(i,1));
    y2 = single(Location2(i,2));
    x3 = single(Location3(i,1));
    y3 = single(Location3(i,2));
    
    a2 = (x1-x2)*(x1-x2)+(y1-y2)*(y1-y2);
    b2 = (x3-x2)*(x3-x2)+(y3-y2)*(y3-y2);
    c2 = (x1-x3)*(x1-x3)+(y1-y3)*(y1-y3);
    a = sqrt(a2); % The distance between 1st and 2nd points
    b = sqrt(b2); % The distance between 2nd and 3rd points
    c = sqrt(c2); % The distance between 3rd and 1st points
    
    pos = (a2+b2-c2)/(2*a*b); % Calculate the cosine of the angle between a and b using the law of cosines
    angle = acos(pos); % Calculate radians with the cosine value
    realangle = angle*180/pi; % Convert radians to angles
    A(i) = realangle;
end

figure;
plot(t,A);
title('Angle changes over time');
xlabel('Time (s)');
ylabel('Angle(°)');

return

%% Afficher les valeurs en µm

figure;
set(gcf,'Position',[50 50 1500 400]);
subplot(1,3,1);
plot(t,x1_location/1e3,t,y1_location/1e3);
ylim([min([min(x1_location/1e3) min(x2_location/1e3) min(x3_location/1e3) min(y1_location/1e3) min(y2_location/1e3) min(y3_location/1e3)])...
 max([max(x1_location/1e3) max(x2_location/1e3) max(x3_location/1e3) max(y1_location/1e3) max(y2_location/1e3) max(y3_location/1e3)])]);
title('1st point''s X and Y displacement');
xlabel('Time (s)');
ylabel('coordinate (µm)');
legend('x-location','y-location','Location','northwest');

subplot(1,3,2);
plot(t,x2_location/1e3,t,y2_location/1e3);
ylim([min([min(x1_location/1e3) min(x2_location/1e3) min(x3_location/1e3) min(y1_location/1e3) min(y2_location/1e3) min(y3_location/1e3)])...
 max([max(x1_location/1e3) max(x2_location/1e3) max(x3_location/1e3) max(y1_location/1e3) max(y2_location/1e3) max(y3_location/1e3)])]);
title('2nd point''s X and Y displacement');
xlabel('Time (s)');
ylabel('coordinate (µm)');
legend('x-location','y-location','Location','northwest');

subplot(1,3,3);
plot(t,x3_location/1e3,t,y3_location/1e3);
ylim([min([min(x1_location/1e3) min(x2_location/1e3) min(x3_location/1e3) min(y1_location/1e3) min(y2_location/1e3) min(y3_location/1e3)])...
 max([max(x1_location/1e3) max(x2_location/1e3) max(x3_location/1e3) max(y1_location/1e3) max(y2_location/1e3) max(y3_location/1e3)])]);
title('3rd point''s X and Y displacement');
xlabel('Time (s)');
ylabel('coordinate (µm)');
legend('x-location','y-location','Location','northwest');

return

