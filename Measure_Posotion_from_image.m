close all;
clear all;
clc;
%% Load image file
% [file,path] = uigetfile('*.*','Select a picture');
path = uigetdir;
imgDir = dir([path '\*.tif']);

template = 40; % template size
Image = {};
FileID = [];
Position = [];
Point = [];
N_Mesure = [];
Repeat = [];

%% Mesure position of 1 point
for i = 1:length(imgDir)
    I = imread([path '\' imgDir(i).name]);
    fileID = i;
    % I = imread(fullfile(path,file)); choice = 1;
    % while choice == 1
    clf;
    imshow(I);
    hold on;
    set(gcf, 'Name', [num2str(i) '/' num2str(length(imgDir)) ': ' imgDir(i).name]);
    
    if strcmpi(get(gcf,'CurrentCharacter'),'q') % tape q to quit the loop
        break;
    end
    
    %uiwait(msgbox('Select a point in the image: ','Measureing points'));
    [x1, y1] = ginput(1);
    plot(x1,y1,'x', 'MarkerSize', 15, 'MarkerEdgeColor','c','MarkerFaceColor', 'c','LineWidth',2);
    rectangle('Position',[x1-template y1-template template*2 template*2],'EdgeColor','w',...
        'LineWidth',2);
    point1 = single([x1, y1]);
    
    Image = [Image,imgDir(i).name];
    cell_str = strsplit(imgDir(i).name,'_');
    N_Re = strsplit(cell_str{1,3},'.');
    FileID = [FileID;fileID];
    Point = [Point;cell_str{1,1}];
    N_Mesure = [N_Mesure;str2num(N_Re{1,1})];
    Repeat = [Repeat;str2num(cell_str{1,2})];
    Position = [Position;[x1 y1]];
    
    
    gFrame = getframe;
    imwrite(gFrame.cdata,[num2str(fileID),'.png']);
    
end

Image = Image';
T = table(Image,FileID,Point,N_Mesure,Repeat,Position);
disp(T)

%% Visualisation

figure;
scatter(T.Position(:,1),T.Position(:,2),10*T.Repeat,T.N_Mesure);
title('Quantification of the positioning repeatability');
xlabel('x coordinate (pixel)');
ylabel('y coordinate (pixel)');
hold on;

std_x = std(T.Position(:,1)); % standard deviation of x
std_y = std(T.Position(:,2)); % standard deviation of y
mean_x = mean(T.Position(:,1)); % Average of x
mean_y = mean(T.Position(:,2)); % Average of x

%% Difference from initial values

p_size = 121.9; % Pixel size in nm

x_init = (T.Position(1,1)+T.Position(2,1)+T.Position(3,1)+ ...
    T.Position(4,1)+T.Position(5,1))/5;
y_init = (T.Position(1,2)+T.Position(2,2)+T.Position(3,2)+ ...
    T.Position(4,2)+T.Position(5,2))/5;
diff_x = zeros(max(T.Repeat),1);
diff_y = zeros(max(T.Repeat),1);
dist = zeros(max(T.Repeat),1);

for i = 1:1:max(T.Repeat)
    nb_begin = 5*(i-1)+1; % Image number at the start of each position
    diff_x(i,1) = ((T.Position(nb_begin,1)+T.Position(nb_begin+1,1)+T.Position(nb_begin+2,1)+ ...
        T.Position(nb_begin+3,1)+T.Position(nb_begin+4,1))/5 - x_init)*p_size;
    diff_y(i,1) = ((T.Position(nb_begin,2)+T.Position(nb_begin+1,2)+T.Position(nb_begin+2,2)+ ...
        T.Position(nb_begin+3,2)+T.Position(nb_begin+4,2))/5 - y_init)*p_size;
    dist(i,1) = sqrt(diff_x(i,1)^2+diff_y(i,1)^2);
end

figure;
set(gcf,'Position',[10 10 600 600])
sz = 120; % Mark size
subplot(3,1,1);
scatter(linspace(1,20,20),diff_x,sz,'*');
title('X displacement from the first position');
ylabel('x displacement (nm)');
xlabel('Number of repetitions');

subplot(3,1,2);
scatter(linspace(1,20,20),diff_y,sz,'*');
title('Y displacement from the first position');
ylabel('y displacement (nm)');
xlabel('Number of repetitions');

subplot(3,1,3);
scatter(linspace(1,20,20),dist,sz,'*');
title('Distances to the first position');
ylabel('Distance (nm)');
xlabel('Number of repetitions');

return

%% Distribution of points to the mean
dist = [];
for i = 1:1:length(T.FileID)
    x_dist = T.Position(i,1) - mean_x;
    y_dist = T.Position(i,2) - mean_y;
    dist = [[x_dist y_dist]*p_size ; dist];
end

figure;
scatter(dist(:,1),dist(:,2),100,'*','LineWidth',1);
xlabel('X (nm)');
ylabel('Y (nm)');
xlim([-800 800]);
ylim([-800 800]);
