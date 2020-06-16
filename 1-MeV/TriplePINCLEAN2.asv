clc
clear
close all

tic

%% Load

pin_f = '6p7';
pot_f = 'sec1cu3';

load('involtpin.mat')

[num,txt] = xlsread(pin_f);
[ions,ptext] = xlsread(pot_f);

cut=2500

[num,txt] = xlsread(dose_f,1);
[num2,txt2] = xlsread(dose_f,2);
[ions,ptext] = xlsread(pot_f);

[status,sheets]=xlsfinfo(dose_f);


%% Time

tp=txt(3:end,1);
tpo=ptext(3:end,1);


%% Trim data to POT

a=length(ions);

num(length(ions)+1:end)=[];
num2(length(ions)+1:end)=[];



simpletxt100(length(ions)+1:end)=[];
simpletxt400(length(ions)+1:end)=[];
timerPOT(length(ions)+1:end)=[];








mvpin=mv(:,1);
POT=(ions)*1.99e7;
csPOT=cumsum(ions)*1.99e7;


cut=100

%% Time

for y=1:length(tp(:,1));
    if length(tp{y,1})<19; % testing if there are bad timing data insertions from matlab, where HH:MM:SS are missing for changes over midnight
        tp{y,1}=strcat(tp{y,1},' 00:00:00');
    end
end

for y=1:length(tpo(:,1));
    if length(tpo{y,1})<19; % testing if there are bad timing data insertions from matlab, where HH:MM:SS are missing for changes over midnight
        tpo{y,1}=strcat(tpo{y,1},' 00:00:00')
    end
end

parfor y=1:length(tp(:,1)); %pararell for loop is much faster here
    timepin(y,:)=datenum(tp{y,1}, 'dd/mm/yyyy HH:MM:SS')
end

parfor y=1:length(tpo(:,1));
    timePOT(y,:)=datenum(tpo{y,1}, 'dd/mm/yyyy HH:MM:SS')
end

POTintPIN=interp1(timePOT,csPOT,timepin)

%% FLuence

% HJ = 1:100:length(mvpin)
kpin=[]
for y=1:length(mvpin(1,:));
    deltapin(:,y)=mvpin(:,y)-1894; %1930 for run 1 or 1848 for run 2
    [neq(:,y),stdneq(:,y)]=PinVth2Fluence(deltapin(1:end,y)');
    kpin=(neq(:,y)-neq(1))./POTintPIN;
    kpin2=neq(:,y)./POTintPIN;
    %kpin2=neq(144:end,y)./POTintPIN(144:end,y);
    mpin=nanmean(kpin(cut:end,y));
    mpin2=nanmean(kpin2(cut:end,y));
    stdpin=stdneq(:,y); %nanstd(kpin)
%   kpin2=neq(HJ,y)./POTintPIN(HJ) ;
end

a=max(csPOT)
% 
%     kpin3=neq(cut:end,y)./POTOSintPIN(cut:end,y)
%     mpin3=nanmean(kpin3(1000:end,y))

 %oob=neq(:,y)-neq(1)
% eeb=neq
% m2pin=nanmean(kpin2)
[nuq,stdsing]=PinVth2Fluence(max(deltapin));

repfluence=mpin*max(csPOT)

% figure(892)
% 
% plot(mvpin)
% hold on
% plot(deltapin)

figure (7968)
plot(kpin2)
title('K factor for run 2');
datetickzoom('x','dd/mmm HH:MM','keepticks','keeplimits');
ylabel('Fluence[neq/cm2]/POT(counts)'); 
xlabel('Time [day/month hh:mm]');

% figure (7968)
% plot(kpin2)
% title('K factor for run 2');
% datetickzoom('x','dd/mmm HH:MM','keepticks','keeplimits');
% ylabel('Fluence[neq/cm2]/POT(counts)'); 
% %xlabel('Time [day/month hh:mm]');

figure(9)
plot(kpin)

figure(56)
plot(timepin,neq-neq(1))
title('Comparison of 1-MeV Neutron Fluence with 1 pin kfactor*POT for run 2')
datetickzoom('x','dd/mmm HH:MM','keepticks','keeplimits');
ylabel('Fluence[neq/cm2]'); 
xlabel('Time [day/month hh:mm]')
hold on
plot(timepin,mpin*POTintPIN, 'r')
hold on 
% plot(timepin,mpin3*POTOSintPIN, 'g')
% hold on
plot(timepin,(neq-neq(1))+stdpin)
hold on
plot(timepin,(neq-neq(1))-stdpin)
legend('Fluence[neq/cm2]','k factor*POT','Standard Deviation')

% figure(57)
% plot(timepin,neq)
% title('Comparison of 1-MeV Neutron Fluence with 1 pin kfactor*POT for run 2')
% datetickzoom('x','dd/mmm HH:MM','keepticks','keeplimits');
% ylabel('Fluence[neq/cm2]'); 
% xlabel('Time [day/month hh:mm]')
% hold on
% plot(timepin,mpin2*POTintPIN, 'r')
% hold on 
% % plot(timepin,mpin3*POTOSintPIN, 'g')
% % hold on
% plot(timepin,(neq)+stdpin)
% hold on
% plot(timepin,(neq)-stdpin)
% legend('Fluence[neq/cm2]','k factor*POT','Standard Deviation')




% figure(57)
% plot(timepin,neq)
% title('Comparison of 1-MeV Neutron Fluence with 1 pin kfactor*POT from 28 to 30 November ')
% datetickzoom('x','dd/mmm HH:MM','keepticks','keeplimits');
% ylabel('Fluence[neq/cm2]'); 
% xlabel('Time [day/month hh:mm]')
% hold on
% plot(timepin,mpin*POTOSintPIN, 'r')
% hold on 
% % plot(timepin,mpin3*POTOSintPIN, 'g')
% % hold on
% plot(timepin,(neq)+stdpin)
% hold on
% plot(timepin,(neq)-stdpin)
% legend('Fluence[neq/cm2]','k factor*POT','Standard Deviation')


toc


% 
% snoise=2000
% 
% figure(9)
% plot(timepin(snoise:end,y),kpin(snoise:end,y)/10e9)
% datetickzoom('x','dd/mmm HH:MM','keepticks','keeplimits');
% ylabel('K factor ( PIN is scaled down by 10e9 for ease of comparison)')
% xlabel('Time [day/month hh:mm]')
% title('K factor stability over time for run 1.1')
% legend('PIN k factor','400nm k factor','100nm k factor')
% hold on
% plot(time100(1600:end,y),k100(1600:end,y),'r')
% hold on
% plot(time400(snoise:end,y),k400(snoise:end,y),'g')
% 
% 
% rat=kpin(1000:end,y)./POTOSintPIN(1000:end,y)
% 
% figure(10)
% plot(rat/10e9)
% hold on
% plot(k100(1000:end,y)./POTREP100(1000:end,y),'r')
% hold on
% plot(k400(1000:end,y)./POTREP400(1000:end,y),'g')
% ylabel('K factor / POT ( PIN is scaled down by 10e9 for ease of comparison)')
% title('K factors / POT')
% set(gca,'YTick',[])
% 
% 
% % hold on
% % plot((kpin./POTOSintPIN))
% %for after second oscilaltion
% mpin=1.70e-3



% plot(timepin,(mpin-stdpin')*POTOSintPIN, 'g')
% hold on 
% plot(timepin,(mpin+stdpin')*POTOSintPIN, 'g')