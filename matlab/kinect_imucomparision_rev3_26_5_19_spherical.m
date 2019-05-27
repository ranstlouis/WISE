%Joint angles from the Kinect and the IMU's are processed in a single
%script for viewing 
clear all; 
close all; 
clc;
tt = 0;
flag = 0;
cd('F:\github\wearable-jacket\matlab\kinect+imudata\');
telapsed = 0;
% strfile = sprintf('wearable+kinecttesting_%s.txt', datestr(now,'mm-dd-yyyy HH-MM'));
% fid = fopen(strfile,'wt');
% fprintf( fid, '%s,%s,%s,%s,%s,%s,%s,%s,%s,%s,%s,%s,%s,%s,%s,%s,%s\n','Timestamp','Kinect_LS_E-F','IMU_LS_E-F','Kinect_LS_aB-aD','IMU_LS_aB-aD','Kinect_LS_I-E','IMU_LS_I-E','Kinect_LElbow','IMU_LElbow','Kinect_RS_E-F','IMU_RS_E-F','Kinect_RS_aB-aD','IMU_RS_aB-aD','Kinect_RS_I-E','IMU_RS_I-E','Kinect_RElbow','IMU_RElbow');
%Kinect initialization script
addpath('F:\github\wearable-jacket\matlab\KInectProject\Kin2');
addpath('F:\github\wearable-jacket\matlab\KInectProject\Kin2\Mex');
addpath('F:\github\wearable-jacket\matlab\KInectProject');
k2 = Kin2('color','depth','body');
% images sizes
d_width = 512; d_height = 424; outOfRange = 4000;
c_width = 1920; c_height = 1080;
% Color image is to big, let's scale it down
COL_SCALE = 1.0;
% Create matrices for the images
depth = zeros(d_height,d_width,'uint16');
color = zeros(c_height*COL_SCALE,c_width*COL_SCALE,3,'uint8');
% depth stream figure
d.h = figure;
d.ax = axes;
d.im = imshow(zeros(d_height,d_width,'uint8'));
%hold on;
title('Depth Source (press q to exit)')
set(gcf,'keypress','k=get(gcf,''currentchar'');'); % listen keypress
% color stream figure
c.h = figure;
c.ax = axes;
c.im = imshow(color,[]);
title('Color Source (press q to exit)');
set(gcf,'keypress','k=get(gcf,''currentchar'');'); % listen keypress
k=[];
                        %COM Port details
                        delete(instrfind({'Port'},{'COM15'}))
                        ser = serial('COM15','BaudRate',115200);
                        ser.ReadAsyncMode = 'continuous';
%quaternion variables
qC = [1,0,0,0];qD = [1,0,0,0];qA = [1,0,0,0];qB = [1,0,0,0];qE = [1,0,0,0];qAC = [1,0,0,0];qCE = [1,0,0,0];qDE = [1,0,0,0];qBD = [1,0,0,0];
Cal_A = [0 0 0 0];Cal_B = [0 0 0 0];Cal_C = [0 0 0 0];Cal_D = [0 0 0 0];Cal_E = [0 0 0 0];
imustr = strcat('IMU');
calib = strcat('Calibration status');
kntstr = strcat('KINECT');
lftstr = strcat('Left hand angles');
rgtstr = strcat('Right hand angles');
efstr = strcat('E-F');
bdstr = strcat('aB-aD');
iestr = strcat('I-E');
stext = strcat('Shoulder');
etext = strcat('Elbow');             
limuefangle = 0;rimuefangle = 0;lkinefangle = 0;rkinefangle = 0;
limubdangle = 5;rimubdangle = 5;lkinbdangle = 5;rkinbdangle = 5;
limuieangle = 10;rimuieangle = 10;lkinieangle = 10;rkinieangle = 10;
limuelbangle = 15;rimuelbangle = 15;lkinelbangle = 15;rkinelbangle = 15;
fs = 24;s=35;fontdiv = 1.3;limulocationdiv = 1.9/2.2;rimulocationdiv = 2.1/2.4;lkinlocationdiv = 1.75;rkinlocationdiv = 1.75;
ls = 0;rs = 1350;lw = 475;H = 1080;rw = 570;     %rectangle coordinates
fopen(ser);
while true
   tstart = tic;
   validData = k2.updateData;
   if validData
       depth = k2.getDepth;
       color = k2.getColor;
        depth8u = uint8(depth*(255/outOfRange));
        depth8uc3 = repmat(depth8u,[1 1 3]);
        color = imresize(color,COL_SCALE);
        c.im = imshow(color, 'Parent', c.ax);
        flag=1;
        tt=0;
        [bodies, fcp, timeStamp] = k2.getBodies('Quat');
        numBodies = size(bodies,2);
               if numBodies == 1
                   pos2Dxxx = bodies(1).Position;              % All 25 joints positions are stored to the variable pos2Dxxx.
                                                %Left Side Joints
                   leftShoulder = pos2Dxxx(:,5);
                   leftElbow = pos2Dxxx(:,6);
                   leftWrist = pos2Dxxx(:,7);
                                                %Right Side Joints
                   rightShoulder = pos2Dxxx(:,9); % Left arm: 4,5,6 ; RightArm: 8,9,10
                   rightElbow = pos2Dxxx(:,10);
                   rightWrist = pos2Dxxx(:,11);
                   rightHand = pos2Dxxx(:,12);
                   rightHandtip = pos2Dxxx(:,24);
                                                %Spine Joints
                   spineShoulder = pos2Dxxx(:,21);
                   spineCenter = pos2Dxxx(:,2);
                   spinebase = pos2Dxxx(:,1);
                   hipRight = pos2Dxxx(:,17);
                   hipLeft = pos2Dxxx(:,13);
                   %%%%%% ELBOW angle calculation
                   E1=rightElbow-rightShoulder;
                   E2=rightWrist-rightElbow;
                   rkinelbangle=acosd(dot(E1,E2)/(norm(E1)*norm(E2)));
                   F1=leftElbow-leftShoulder;
                   F2=leftWrist-leftElbow;
                   lkinelbangle=acosd(dot(F1,F2)/(norm(F1)*norm(F2)));
                   %%%%%% SHOULDER angle calculation
                   RH2=rightElbow([1:3])-rightShoulder([1:3]);
                   LH2=leftElbow([1:3])-leftShoulder([1:3]);
                   RSLS = leftShoulder-rightShoulder;
                   LSRS = rightShoulder-leftShoulder;
                   TrunkVector = spinebase-spineShoulder;
                   coronalnormalL = cross(LSRS,TrunkVector);
                   coronalnormalR = cross(RSLS,TrunkVector);
                   armaxisnormalL = cross(LSRS,LH2);
                   armaxisnormalR = cross(RSLS,RH2);
            %coronal plane calculation
                    if (leftElbow(1)<=(leftShoulder(1)-(0.25*norm(LH2))))
                        leftElbowprojection = LH2 - dot(LH2,coronalnormalL)*coronalnormalL;
                        lkinbdangle = atan2d(norm(cross(TrunkVector,LH2)),dot(TrunkVector,LH2));                      %Abduction-adduction angle left
                    else
                        lkinbdangle = 0;
                    end
                    if (rightElbow(1)>=(rightShoulder(1)+(0.25*norm(RH2))))
                        rightElbowprojection = RH2 - dot(RH2,coronalnormalR)*coronalnormalR;
                        rkinbdangle = atan2d(norm(cross(TrunkVector,RH2)),dot(TrunkVector,RH2));                     %Abduction-adduction angle right  
                    else
                        rkinbdangle = 0;
                    end
            %Sagittal plane calculation
                    sagittalnormalL = cross(coronalnormalL,TrunkVector);
                    sagittalnormalR = cross(coronalnormalR,TrunkVector);
            if (leftShoulder(3)>=(leftElbow(3)+(0.25*norm(LH2))))
                leftShoulderprojection = LH2 - (dot(LH2,sagittalnormalL)/norm(sagittalnormalL)^2)*sagittalnormalL;
                lkinefangle=atan2d(norm(cross(TrunkVector,leftShoulderprojection)),dot(TrunkVector,leftShoulderprojection));       %Extension-flexion left
            else
                lkinefangle = 0;
            end
            if (rightShoulder(3)>=(rightElbow(3)+(0.25*norm(RH2))))
                rightShoulderprojection = RH2 - (dot(RH2,sagittalnormalR)/norm(sagittalnormalR)^2)*sagittalnormalR;
                rkinefangle=atan2d(norm(cross(TrunkVector,rightShoulderprojection)),dot(TrunkVector,rightShoulderprojection));    %Extension-flexion right
            else
                rkinefangle = 0;
            end
            %arm-axis plane calculation
                    leftwristprojection = armaxisnormalL - (dot(LH2,armaxisnormalL)/norm(LH2)^2)*LH2;
                    rightwristprojection = armaxisnormalR - (dot(RH2,armaxisnormalR)/norm(RH2)^2)*RH2;
            if lkinelbangle>=60
                lkinieangle = acosd(dot(leftwristprojection,F2)/(norm(F2)*norm(leftwristprojection)));
            else
                lkinieangle = 0;
            end
            if rkinelbangle>=60
                rkinieangle = acosd(dot(-rightwristprojection,E2)/(norm(E2)*norm(-rightwristprojection)));
            else
                rkinieangle = 0;
            end
            rectangle('Position',[ls 0 lw H],'LineWidth',3,'FaceColor','k');  
            rectangle('Position',[rs 0 rw H],'LineWidth',3,'FaceColor','k');
                        %arduino section
    flushinput(ser);
    line = fscanf(ser);   % get data if there exists data in the next line
    data = strsplit(string(line),',');
    text(rs+rw/2,750,calib,'Color','white','FontSize',0.75*fs/fontdiv,'FontWeight','normal','HorizontalAlignment','center');
    if(length(data) == 5 || length(data) == 6)
    switch data(1)
        case 'cal'
          switch data(2)
                case 'b'
                    B_mag = str2double(data(3));B_acc = str2double(data(4));B_gyr = str2double(data(5));B_sys = str2double(data(6));
                    Cal_B = [B_mag B_acc B_gyr B_sys];
                case 'a'
                    A_mag = str2double(data(3));A_acc = str2double(data(4));A_gyr = str2double(data(5));A_sys = str2double(data(6));      
                    Cal_A = [A_mag A_acc A_gyr A_sys];
                case 'c'
                    C_mag = str2double(data(3));C_acc = str2double(data(4));C_gyr = str2double(data(5));C_sys = str2double(data(6));  
                    Cal_C = [C_mag C_acc C_gyr C_sys];
                case 'd'
                    D_mag = str2double(data(3));D_acc = str2double(data(4));D_gyr = str2double(data(5));D_sys = str2double(data(6));      
                    Cal_D = [D_mag D_acc D_gyr D_sys];
                case 'e'
                    E_mag = str2double(data(3));E_acc = str2double(data(4));E_gyr = str2double(data(5));E_sys = str2double(data(6));      
                    Cal_E = [E_mag E_acc E_gyr E_sys];
                end 
          
        case 'e'
            qE = qconvert(data);
            qE = quatnormalize(qE);
            qE = fix_E(qE);
%             R_sho = getShoulderRight(qE,qD);
           lshoangle = getlefthand(qE,qC,qA);
           limuieangle = lshoangle(3);limubdangle = lshoangle(2);limuefangle = lshoangle(1); 
           rshoangle = getrighthand(qE,qD,qB);
           rimuieangle = rshoangle(3);rimubdangle = rshoangle(2);rimuefangle = rshoangle(1);
        case 'a'
           qA = qconvert(data);
           qA = quatnormalize(qA);
           qA = fix_A(qA);
           lshoangle = getlefthand(qE,qC,qA);
           limuelbangle = lshoangle(4);
        case 'c'
           qC = qconvert(data);
           qC = quatnormalize(qC);
           qC = fix_C(qC);
           lshoangle = getlefthand(qE,qC,qA);
           limuieangle = lshoangle(3);limubdangle = lshoangle(2);limuefangle = lshoangle(1); 
           limuelbangle = lshoangle(4);
        case 'd'
           qD = qconvert(data);
           qD = quatnormalize(qD);
           qD = fix_D(qD);
           rshoangle = getrighthand(qE,qD,qB);
           rimuieangle = rshoangle(3);rimubdangle = rshoangle(2);rimuefangle = rshoangle(1);
           rimuelbangle = rshoangle(4);
        case 'b'
            qB = qconvert(data);
            qB = quatnormalize(qB);
            qB = fix_B(qB);
            rshoangle = getlefthand(qE,qD,qB);
            rimuelbangle = rshoangle(4);
    end 
    end
            text(rs+rw/2,850,strcat('Calib B: ',num2str(Cal_B)),'Color','white','FontSize',0.75*fs/fontdiv,'FontWeight','normal','HorizontalAlignment','center');
            text(rs+rw/2,800,strcat('Calib A: ',num2str(Cal_A)),'Color','white','FontSize',0.75*fs/fontdiv,'FontWeight','normal','HorizontalAlignment','center');
            text(rs+rw/2,900,strcat('Calib C: ',num2str(Cal_C)),'Color','white','FontSize',0.75*fs/fontdiv,'FontWeight','normal','HorizontalAlignment','center');
            text(rs+rw/2,950,strcat('Calib D: ',num2str(Cal_D)),'Color','white','FontSize',0.75*fs/fontdiv,'FontWeight','normal','HorizontalAlignment','center');
            text(rs+rw/2,1000,strcat('Calib E: ',num2str(Cal_E)),'Color','white','FontSize',0.75*fs/fontdiv,'FontWeight','normal','HorizontalAlignment','center');
            limuefstr = num2str(limuefangle,'%.1f');rimuefstr = num2str(rimuefangle,'%.1f');
            lkinefstr = num2str(lkinefangle,'%.1f');rkinefstr = num2str(rkinefangle,'%.1f');
            limubdstr = num2str(limubdangle,'%.1f');rimubdstr = num2str(rimubdangle,'%.1f');
            lkinbdstr = num2str(lkinbdangle,'%.1f');rkinbdstr = num2str(rkinbdangle,'%.1f');
            limuiestr = num2str(limuieangle,'%.1f');rimuiestr = num2str(rimuieangle,'%.1f');
            lkiniestr = num2str(lkinieangle,'%.1f');rkiniestr = num2str(rkinieangle,'%.1f');
            limuelbstr = num2str(limuelbangle,'%.1f');rimuelbstr = num2str(rimuelbangle,'%.1f');
            lkinelbstr = num2str(lkinelbangle,'%.1f');rkinelbstr = num2str(rkinelbangle,'%.1f');
                                                 %Text placement on the left side
            text(ls+lw/2,s,lftstr,'Color','white','FontSize',fs,'FontWeight','bold','HorizontalAlignment','center');
            text(rs+rw/2,s,rgtstr,'Color','white','FontSize',fs,'FontWeight','bold','HorizontalAlignment','center');
            text(ls+lw/5,4*s,stext,'Color','white','FontSize',fs/fontdiv,'FontWeight','bold','HorizontalAlignment','center');
            text(rs+rw/5,4*s,stext,'Color','white','FontSize',fs/fontdiv,'FontWeight','bold','HorizontalAlignment','center');
            text(ls+(lw/lkinlocationdiv),4*s,kntstr,'Color','white','FontSize',fs/fontdiv,'FontWeight','bold','HorizontalAlignment','center');
            text(rs+(rw/rkinlocationdiv),4*s,kntstr,'Color','white','FontSize',fs/fontdiv,'FontWeight','bold','HorizontalAlignment','center');
            text(ls+(limulocationdiv*lw),4*s,imustr,'Color','white','FontSize',fs/fontdiv,'FontWeight','bold','HorizontalAlignment','center');
            text(rs+(rimulocationdiv*rw),4*s,imustr,'Color','white','FontSize',fs/fontdiv,'FontWeight','bold','HorizontalAlignment','center');
            text(ls+lw/5,8*s,efstr,'Color','white','FontSize',fs/fontdiv,'FontWeight','bold','HorizontalAlignment','center');
            text(rs+rw/5,8*s,efstr,'Color','white','FontSize',fs/fontdiv,'FontWeight','bold','HorizontalAlignment','center');
            text(ls+(lw/lkinlocationdiv),8*s,lkinefstr,'Color','white','FontSize',fs/fontdiv,'FontWeight','normal','HorizontalAlignment','center');
            text(rs+(rw/rkinlocationdiv),8*s,rkinefstr,'Color','white','FontSize',fs/fontdiv,'FontWeight','normal','HorizontalAlignment','center');
            text(ls+(limulocationdiv*lw),8*s,limuefstr,'Color','white','FontSize',fs/fontdiv,'FontWeight','normal','HorizontalAlignment','center');
            text(rs+(rimulocationdiv*rw),8*s,rimuefstr,'Color','white','FontSize',fs/fontdiv,'FontWeight','normal','HorizontalAlignment','center');
            text(ls+lw/5,12*s,bdstr,'Color','white','FontSize',fs/fontdiv,'FontWeight','bold','HorizontalAlignment','center');
            text(rs+rw/5,12*s,bdstr,'Color','white','FontSize',fs/fontdiv,'FontWeight','bold','HorizontalAlignment','center');
            text(ls+(lw/lkinlocationdiv),12*s,lkinbdstr,'Color','white','FontSize',fs/fontdiv,'FontWeight','normal','HorizontalAlignment','center');
            text(rs+(rw/rkinlocationdiv),12*s,rkinbdstr,'Color','white','FontSize',fs/fontdiv,'FontWeight','normal','HorizontalAlignment','center');
            text(ls+(limulocationdiv*lw),12*s,limubdstr,'Color','white','FontSize',fs/fontdiv,'FontWeight','normal','HorizontalAlignment','center');
            text(rs+(rimulocationdiv*rw),12*s,rimubdstr,'Color','white','FontSize',fs/fontdiv,'FontWeight','normal','HorizontalAlignment','center');
            text(ls+lw/5,16*s,iestr,'Color','white','FontSize',fs/fontdiv,'FontWeight','bold','HorizontalAlignment','center');
            text(rs+rw/5,16*s,iestr,'Color','white','FontSize',fs/fontdiv,'FontWeight','bold','HorizontalAlignment','center');
            text(ls+(lw/lkinlocationdiv),16*s,lkiniestr,'Color','white','FontSize',fs/fontdiv,'FontWeight','normal','HorizontalAlignment','center');
            text(rs+(rw/rkinlocationdiv),16*s,rkiniestr,'Color','white','FontSize',fs/fontdiv,'FontWeight','normal','HorizontalAlignment','center');
            text(ls+(limulocationdiv*lw),16*s,limuiestr,'Color','white','FontSize',fs/fontdiv,'FontWeight','normal','HorizontalAlignment','center');
            text(rs+(rimulocationdiv*rw),16*s,rimuiestr,'Color','white','FontSize',fs/fontdiv,'FontWeight','normal','HorizontalAlignment','center');
            text(ls+lw/5,20*s,etext,'Color','white','FontSize',fs/fontdiv,'FontWeight','bold','HorizontalAlignment','center');
            text(rs+rw/5,20*s,etext,'Color','white','FontSize',fs/fontdiv,'FontWeight','bold','HorizontalAlignment','center');
            text(ls+(lw/lkinlocationdiv),20*s,lkinelbstr,'Color','white','FontSize',fs/fontdiv,'FontWeight','normal','HorizontalAlignment','center');
            text(rs+(rw/rkinlocationdiv),20*s,rkinelbstr,'Color','white','FontSize',fs/fontdiv,'FontWeight','normal','HorizontalAlignment','center');
            text(ls+(limulocationdiv*lw),20*s,limuelbstr,'Color','white','FontSize',fs/fontdiv,'FontWeight','normal','HorizontalAlignment','center');
            text(rs+(rimulocationdiv*rw),20*s,rimuelbstr,'Color','white','FontSize',fs/fontdiv,'FontWeight','normal','HorizontalAlignment','center');
            telapsed = telapsed+toc(tstart);
            text(ls+lw/3,1000,'Time (seconds)','Color','white','FontSize',fs/(fontdiv),'FontWeight','bold','HorizontalAlignment','center');
            text(ls+(limulocationdiv*lw),1000,num2str(telapsed,'%.2f'),'Color','white','FontSize',fs/fontdiv,'FontWeight','normal','HorizontalAlignment','center');
               end
       if numBodies == 0
           s1 = strcat('No persons in view');   
           text((1920/2) - 250,100,s1,'Color','red','FontSize',30,'FontWeight','bold');
           rectangle('Position',[0 0 475 1080],'LineWidth',3,'FaceColor','k');  
           rectangle('Position',[1350 0 620 1080],'LineWidth',3,'FaceColor','k');
       end      
       if numBodies > 1
           s1 = strcat('Too many people in view');
           text(1920/2,100,s1,'Color','red','FontSize',30,'FontWeight','bold');
       end      
       if ~isempty(k)
        if strcmp(k,'q'); 
            break; 
        end;
        end
        k2.drawBodies(c.ax,bodies,'color',3,2,1);
        flag = 0;         
   end
     pause(0.0001);
    clearvars pos2Dxxx depth color validData depth8u depth8uc3 leftShoulder leftElbow leftWrist rightShoulder rightElbow rightWrist rightHand rightHandtip spineShoulder spineCenter spinebase hipRight hipLeft E1 E2 F1 F2 RH2 LH2 LSRS RSLS coronalnormalL coronalnormalR TrunkVector sagittalnormalL sagittalnormalR line data
    clearvars limubdstr limuefstr limuelbstr lkinefstr lkinbdstr lkiniestr limuiestr lkinelbstr rimubdstr rimuefstr rimuelbstr rkinefstr rkinbdstr rkiniestr rimuiestr rkinelbstr
end
k2.delete;
clear all;
close all;
delete(instrfind({'Port'},{'COM15'}))

function resultmult = qconvert(a)
p = -1; %y = m x + p where y(-1 1) x(0 999) from rfduino z(-2^14 2^14)
m = 2/999;
resultmult(1) = str2double(a(2))*m+p;
resultmult(2) = str2double(a(3))*m+p;
resultmult(3) = str2double(a(4))*m+p;
resultmult(4) = str2double(a(5))*m+p;
end


function lefthand = getlefthand(back,arm,wrist)
lefthand = zeros(5,1);
Qi = [0,1,0,0]; Qj = [0,0,1,0]; Qk = [0,0,0,1];
Qx = quatmultiply(back,quatmultiply(Qi,quatconj(back)));
theta = -pi/2;
Qx1 = [cos(theta/2) Qx(2)*sin(theta/2) Qx(3)*sin(theta/2) Qx(4)*sin(theta/2)];
Qback = quatmultiply(Qx1,back);

Vzb = quatmultiply(Qback,quatmultiply(Qk,quatconj(Qback)));
Vxb = quatmultiply(Qback,quatmultiply(Qi,quatconj(Qback)));
Vyb = quatmultiply(Qback,quatmultiply(Qj,quatconj(Qback)));

Vxa = quatmultiply(arm,quatmultiply(-Qi,quatconj(arm)));

Vza = quatmultiply(arm,quatmultiply(Qk,quatconj(arm)));
Vya = quatmultiply(arm,quatmultiply(Qj,quatconj(arm)));
Vzw = quatmultiply(wrist,quatmultiply(Qk,quatconj(wrist)));
Vxw = quatmultiply(wrist,quatmultiply(-Qi,quatconj(wrist)));
Vyw = quatmultiply(wrist,quatmultiply(Qj,quatconj(wrist)));

%sagittal plane on back has Y axis as normal for extension and flexion

V = [dot(Vxa(2:4),Vxb(2:4)) , dot(Vxa(2:4),Vyb(2:4)) , dot(Vxa(2:4),Vzb(2:4))]

[azimuth,elevation,r] = cart2sph(V(1),V(2),V(3));

lefthand(1,1) = azimuth*180/pi;

%coronal plane on back has Z axis as normal for abduction and adduction
Vxacoronal = Vxa(2:4) - (dot(Vxa(2:4),Vzb(2:4))/norm(Vzb(2:4))^2)*Vzb(2:4);
cat = norm(Vxacoronal - Vxb(2:4))*sign(dot(Vxacoronal,Vxb(2:4)));
lefthand(2,1) = atan2d(cat,norm(Vxb(2:4)));
%elbow angle extension-flexion                    requires a normal plane
lefthand(4,1) = acosd(dot(Vxa(2:4),Vxw(2:4))/norm(Vxa(2:4))*norm(Vxw(2:4)));
%arm-axis plane
Vxwarmaxis = Vxw(2:4) - (dot(Vxw(2:4),Vxa(2:4))/norm(Vxa(2:4))^2)*Vxa(2:4);
cat = norm(Vxwarmaxis - Vya(2:4))*sign(dot(Vxwarmaxis,Vya(2:4)));
lefthand(3,1) = atan2d(cat,norm(Vya(2:4)));
%elbow pronation-supination                       requires a normal plane
lefthand(5,1) = acosd(dot(Vza(2:4),Vzw(2:4))/norm(Vza(2:4))*norm(Vzw(2:4)));
end

function righthand = getrighthand(back,arm,wrist)
righthand = zeros(5,1);
Qi = [0,1,0,0];Qj = [0,0,1,0];Qk = [0,0,0,1];
Vzb = quatmultiply(back,quatmultiply(Qk,quatconj(back)));
Vxb = quatmultiply(back,quatmultiply(Qi,quatconj(back)));
Vyb = quatmultiply(back,quatmultiply(Qj,quatconj(back)));
Vza = quatmultiply(arm,quatmultiply(Qk,quatconj(arm)));
Vxa = quatmultiply(arm,quatmultiply(Qi,quatconj(arm)));
Vxa_ = quatmultiply(arm,quatmultiply(-Qi,quatconj(arm)));
Vya = quatmultiply(arm,quatmultiply(Qj,quatconj(arm)));
Vzw = quatmultiply(wrist,quatmultiply(Qk,quatconj(wrist)));
Vxw = quatmultiply(wrist,quatmultiply(Qi,quatconj(wrist)));
Vyw = quatmultiply(wrist,quatmultiply(Qj,quatconj(wrist)));
%sagittal plane on back has Y axis as normal for extension and flexion
Vxasagittal = Vxa(2:4) - (dot(Vxa(2:4),Vyb(2:4))/norm(Vyb(2:4))^2)*Vyb(2:4);
righthand(1,1) = acosd(dot(Vxasagittal,Vxb(2:4))/norm(Vxasagittal)*norm(Vxb(2:4)));
%coronal plane on back has Z axis as normal for abduction and adduction
Vxacoronal = Vxa(2:4) - (dot(Vxa(2:4),Vzb(2:4))/norm(Vzb(2:4))^2)*Vzb(2:4);
righthand(2,1) = acosd(dot(Vxacoronal,Vxb(2:4))/(norm(Vxacoronal)*norm(Vxb(2:4))));
%arm-axis plane
Vxwarmaxis = Vxw(2:4) - (dot(Vxw(2:4),Vxa(2:4))/norm(Vxw(2:4))^2)*Vxw(2:4);
righthand(3,1) = acosd(dot(Vxwarmaxis,Vya(2:4))/(norm(Vxwarmaxis)*norm(Vya(2:4))));
%elbow angle extension-flexion
righthand(4,1) = acosd(dot(-Vxa(2:4),Vxw(2:4))/norm(-Vxa(2:4))*norm(Vxw(2:4)));
%elbow pronation-supination
righthand(5,1) = acosd(dot(Vza(2:4),Vzw(2:4))/norm(Vza(2:4))*norm(Vzw(2:4)));
end