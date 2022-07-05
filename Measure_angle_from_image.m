close all;
clear all;
clc;
%% Load image file
[file,path] = uigetfile('*.*','Select a picture');
fileID = 1;
I = imread(fullfile(path,file));
choice = 1;

%% Mesure angle by 3 points
template = 40; % template size
Image = {};
FileID = [];
Point1 = [];
Point2 = [];
Point3 = [];
Angle = [];


while choice == 1
    clf;
    imshow(I);
    hold on;
    %uiwait(msgbox('Select three points constitute the angle in the image: ','Measureing points'));
    [x1, y1] = ginput(1);
    plot(x1,y1,'x', 'MarkerSize', 15, 'MarkerEdgeColor','c','MarkerFaceColor', 'c','LineWidth',2);
    rectangle('Position',[x1-template y1-template template*2 template*2],'EdgeColor','w',...
        'LineWidth',2);
    point1 = single([x1, y1]);

    [x2, y2] = ginput(1);
    plot(x2,y2,'x', 'MarkerSize', 15, 'MarkerEdgeColor','y','MarkerFaceColor', 'y','LineWidth',2);
    rectangle('Position',[x2-template y2-template template*2 template*2],'EdgeColor','w',...
        'LineWidth',2);
    point2 = single([x2, y2]);

    [x3, y3] = ginput(1);
    plot(x3,y3,'x', 'MarkerSize', 15, 'MarkerEdgeColor','m','MarkerFaceColor', 'm','LineWidth',2);
    rectangle('Position',[x3-template y3-template template*2 template*2],'EdgeColor','w',...
        'LineWidth',2);
    point3 = single([x3, y3]);

    a2 = (x1-x2)*(x1-x2)+(y1-y2)*(y1-y2);
    b2 = (x3-x2)*(x3-x2)+(y3-y2)*(y3-y2);
    c2 = (x1-x3)*(x1-x3)+(y1-y3)*(y1-y3);
    a = sqrt(a2); % The distance between 1st and 2nd points
    b = sqrt(b2); % The distance between 2nd and 3rd points
    c = sqrt(c2); % The distance between 3rd and 1st points

    pos = (a2+b2-c2)/(2*a*b); % Calculate the cosine of the angle between a and b using the law of cosines
    angle = acos(pos); % Calculate radians with the cosine value
    realangle = angle*180/pi; % Convert radians to angles

    Image = [Image,file];
    FileID = [FileID;fileID];
    Point1 = [Point1;[x1 y1]];
    Point2 = [Point2;[x2 y2]];
    Point3 = [Point3;[x3 y3]];
    Angle = [Angle;realangle];

    gFrame = getframe;
    imwrite(gFrame.cdata,[num2str(fileID),'.png']);

    answer = questdlg(['Image ',num2str(fileID),': ',file,' has been processed successfully.',newline,...
        'Continue to measure the angle in next image?'],'Option Menu','Yes','No','No');
    % Handle response
    switch answer
        case 'Yes'
            [file,path] = uigetfile('*.*','Select a picture');
            fileID = fileID+1;
            I = imread(fullfile(path,file));
            choice = 1;
        case 'No'
            choice = 2;
    end
end

Image = Image';
T = table(Image,FileID,Point1,Point2,Point3,Angle);
disp(T)

%% Visualisation

figure;
plot(T.FileID,T.Angle);
title('Angle changes over frame');
xlabel('Frame');
ylabel('Angle(°)');

return