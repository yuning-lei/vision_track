close all;
clear all;
clc;
%% Load image file
[file,path] = uigetfile('*.*','Select a picture');
fileID = 1;
I = imread(fullfile(path,file));
choice = 1;

%% Mesure 1 point position changement
template = 40; % template size
Image = {};
FileID = [];
Position_x = [];
Position_y = [];

while choice == 1
    clf;
    imshow(I);
    hold on;

    [x1, y1] = ginput(1);
    plot(x1,y1,'x', 'MarkerSize', 15, 'MarkerEdgeColor','c','MarkerFaceColor', 'c','LineWidth',2);
    rectangle('Position',[x1-template y1-template template*2 template*2],'EdgeColor','w',...
        'LineWidth',2);
    point1 = single([x1, y1]);

    Image = [Image,file];
    FileID = [FileID;fileID];
    Position_x = [Position_x;x1];
    Position_y = [Position_y;y1];

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
T = table(Image,FileID,Position_x,Position_y);
disp(T)

%% Visualisation
psize_str = inputdlg({'Enter video pixel size in nm: '},'Pixel size');
psize = str2num(psize_str{1});

% Position displacement
x_change = zeros(length(T.Position_x),1);
y_change = zeros(length(T.Position_y),1);

for i = 2:length(T.Position_x)
    x_change(i) = psize*(T.Position_x(i)-T.Position_x(1))/1e3;
    y_change(i) = psize*(T.Position_y(i)-T.Position_y(1))/1e3;
end

figure;
plot(T.FileID,x_change,T.FileID,y_change,'LineWidth',2);
title('Position changes over frame');
xlabel('Frame');
ylabel('Displacement (µm)');
legend('X Displacement','Y Displacement');

T.x_Disp = x_change;
T.y_Disp = y_change;

return