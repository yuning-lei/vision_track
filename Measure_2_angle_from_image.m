close all;
clear all;
clc;
%% Load image file
% [file,path] = uigetfile('*.*','Select a picture');
% fileID = 1;
% I = imread(fullfile(path,file));
% choice = 1;
path = uigetdir;
imgDir = dir([path '\*.tif']);

template = 40; % template size
Image = {};
FileID = [];
Point = [];
N_Mesure = [];
Repeat = [];
Point1 = [];
Point2 = [];
Point3 = [];
Point4 = [];
Angle = [];


%% Mesure angle by 3 points


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
    
    [x4, y4] = ginput(1);
    plot(x4,y4,'x', 'MarkerSize', 15, 'MarkerEdgeColor','g','MarkerFaceColor', 'g','LineWidth',2);
    rectangle('Position',[x4-template y4-template template*2 template*2],'EdgeColor','w',...
        'LineWidth',2);
    point4 = single([x4, y4]);

    a2 = (x1-x2)*(x1-x2)+(y1-y2)*(y1-y2);
    b2 = (x3-x2)*(x3-x2)+(y3-y2)*(y3-y2);
    c2 = (x1-x3)*(x1-x3)+(y1-y3)*(y1-y3);
    d2 = (x3-x4)*(x3-x4)+(y3-y4)*(y3-y4);
    e2 = (x2-x4)*(x2-x4)+(y2-y4)*(y2-y4);
    a = sqrt(a2); % The distance between 1st and 2nd points
    b = sqrt(b2); % The distance between 2nd and 3rd points
    c = sqrt(c2); % The distance between 3rd and 1st points
    d = sqrt(d2); % The distance between 3rd and 4th points
    e = sqrt(e2); % The distance between 2nd and 4th points

    pos_2 = (a2+b2-c2)/(2*a*b); % Calculate the cosine of the angle between a and b using the law of cosines
    angle_2 = acos(pos_2); % Calculate radians with the cosine value
    realangle_2 = angle_2*180/pi; % Convert radians to angles -- theta 2
%     realangle_2 = 180-realangle_2; % theta_2 positive
    realangle_2 = realangle_2-180; % theta_2 negative
    
    
    pos_1 = (b2+d2-e2)/(2*b*d); % Calculate the cosine of the angle between a and b using the law of cosines
    angle_1 = acos(pos_1); % Calculate radians with the cosine value
    realangle_1 = angle_1*180/pi; % Convert radians to angles -- theta 1

    Image = [Image,imgDir(i).name];
    cell_str = strsplit(imgDir(i).name,'_');
    N_Re = strsplit(cell_str{1,3},'.'); % Number of measurements with suffix
    FileID = [FileID;fileID];
    Point = [Point;cell_str{1,1}]; % Point name
    N_Mesure = [N_Mesure;str2num(N_Re{1,1})]; % Number of measurements taken at the same position
    Repeat = [Repeat;str2num(cell_str{1,2})]; % Number of repetitions
    Point1 = [Point1;[x1 y1]];
    Point2 = [Point2;[x2 y2]];
    Point3 = [Point3;[x3 y3]];
    Point4 = [Point4;[x4 y4]];
    Angle = [Angle;[realangle_1 realangle_2]];

    gFrame = getframe;
    imwrite(gFrame.cdata,[num2str(fileID),'.png']);

%     answer = questdlg(['Image ',num2str(fileID),': ',file,' has been processed successfully.',newline,...
%         'Continue to measure the angle in next image?'],'Option Menu','Yes','No','No');
%     % Handle response
%     switch answer
%         case 'Yes'
%             [file,path] = uigetfile('*.*','Select a picture');
%             fileID = fileID+1;
%             I = imread(fullfile(path,file));
%             choice = 1;
%         case 'No'
%             choice = 2;
%     end
end

Image = Image';
T = table(Image,FileID,Point,N_Mesure,Repeat,Point1,Point2,Point3,Point4,Angle);
disp(T)

%% Visualisation

figure;
plot(T.FileID,T.Angle(:,1),T.FileID,T.Angle(:,2),'LineWidth',2);
title('Angle changes over frame');
xlabel('Frame');
ylabel('Angle(°)');
legend('\theta_1','\theta_2');

figure;
scatter(T.Angle(:,1),T.Angle(:,2),10*T.Repeat,T.N_Mesure);
title('Repeatability: Differences between angles');
xlabel('\theta_1 (°)');
ylabel('\theta_2 (°)' );
hold on;

std_1 = std(T.Angle(:,1)); % standard deviation of theta 1
std_2 = std(T.Angle(:,2)); % standard deviation of theta 2

%% Difference from initial values

theta_1_init = (T.Angle(1,1)+T.Angle(2,1)+T.Angle(3,1)+ ...
    T.Angle(4,1)+T.Angle(5,1))/5;
theta_2_init = (T.Angle(1,2)+T.Angle(2,2)+T.Angle(3,2)+ ...
    T.Angle(4,2)+T.Angle(5,2))/5;
diff_1 = zeros(max(T.Repeat),1);
diff_2 = zeros(max(T.Repeat),1);


for i = 1:1:max(T.Repeat)
    nb_begin = 5*(i-1)+1; % Image number at the start of each position
    diff_1(i,1) = ((T.Angle(nb_begin,1)+T.Angle(nb_begin+1,1)+T.Angle(nb_begin+2,1)+ ...
        T.Angle(nb_begin+3,1)+T.Angle(nb_begin+4,1))/5 - theta_1_init);
    diff_2(i,1) = ((T.Angle(nb_begin,2)+T.Angle(nb_begin+1,2)+T.Angle(nb_begin+2,2)+ ...
        T.Angle(nb_begin+3,2)+T.Angle(nb_begin+4,2))/5 - theta_2_init);
end

figure;
set(gcf,'Position',[10 10 600 400])
sz = 120; % Mark size
subplot(2,1,1);
scatter(linspace(1,max(T.Repeat),max(T.Repeat)),diff_1,sz,'*','LineWidth',1);
title('Evolution of \theta_1 : Difference from initial value');
ylabel('\theta_1 (°)');
xlabel('Repetition Number');

subplot(2,1,2);
scatter(linspace(1,max(T.Repeat),max(T.Repeat)),diff_2,sz,'*','LineWidth',1,'MarkerFaceColor',[0.85 0.33 0.10],...
    'MarkerEdgeColor',[0.85 0.33 0.10]);
title('Evolution of \theta_2 : Difference from initial value');
ylabel('\theta_2 (°)');
xlabel('Repetition Number');



return