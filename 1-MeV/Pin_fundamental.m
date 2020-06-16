clc
clear
close all

tic

%% Load

pin_f = '6p5';
pot_f = 'sec1cu3';

in_dir = './cu3/'
out_dir= './cu3/'

load('involtpin.mat')

cut=2500

[num,txt] = xlsread(strcat(in_dir,pin_f));
[ions,ptext] = xlsread(strcat(in_dir,pot_f));

[status,sheets]=xlsfinfo(strcat(in_dir,pin_f));


%% Time

tp=txt(3:end,1);
tpo=ptext(3:end,1);


%% Trim data to POT, fill gaps

sizes={length(ions),length(num)};
a=min(cell2mat(sizes));

ions(a+1:end)=[]
num(a+1:end)=[];

tp(a+1:end)=[];
tpo(a+1:end)=[];

numnew=fixgaps(num)

%% Timing

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

%% Interpolation

POT=(ions)*2.24e7;
csPOT=nancumsum(ions)*2.24e7;

INTPpin=interp1(timePOT, csPOT, timepin);

%% Finding init values

stri=sheets';
for g=1:length(initvoltages);
    if strcmp(initvoltages(g,1),stri(1,1));
    initpin=initvoltages{g,2};
    namepin=initvoltages{g,1};
    end
end

%% V5 vs V6 mv to V

switch strncmpi(namepin,'SIM',3);
       case 1;
       numnew=numnew*1000;
end;

%% Fluence
mvpin=numnew
kpin=[]
x1=[]
for y=1:length(mvpin(1,:));
    deltapin(:,y)=mvpin(:,y)-initpin; %
    [neq(:,y),stdneq(:,y)]=PinVth2Fluence(deltapin(1:end,y)','');
    x1=find(isnan(neq));
    for r=1:length(x1)+1;
    if isempty(x1);
        w1=1;
    else
        w1=x1(end)+1;
    end
    end
        for k=1:length(w1)
        if w1>length(neq)
            w1=1
        end
    end
    o1=neq(1:end,y)-neq(w1);
    kpin=o1./INTPpin;
    mkpin=nanmean(kpin(cut:end,y));
    stdpin=stdneq(:,y); 
end

endFluence=nanmax(o1)-nanmin(o1)
endStd=nanmax(stdpin)-nanmin(stdpin)
errorPin=endStd/endFluence
endpot=max(csPOT);

figure(1)
plot(timepin, kpin)
title(strcat('Normalisation of 1-MeV NEQ fluence by POT for PIN ',namepin))
legend('Normalisation of 1-MeV NEQ by POT')
ylabel('Dose divided by POT [Gy]')
xlabel('Time units')
datetick('x','dd/mmm HH:MM','keepticks','keeplimits');
set(gcf, 'Position', [300, 0, 1080, 720])
picn=strcat(out_dir,pin_f,'kpin.png')
picfig=strcat(out_dir,pin_f,'kpin.fig')
saveas(gcf,picn)
export_fig(picn)
savefig(picfig)

figure(2)
plot(timepin,neq-neq(w1))
title(strcat('1-MeV Neutron Equivalent Fluence evolution through time for ',namepin))
datetickzoom('x','dd/mmm HH:MM','keepticks','keeplimits');
ylabel('Fluence[neq/cm2]'); 
xlabel('Time [day/month hh:mm]')
hold on
plot(timepin,mkpin*INTPpin, 'r')
hold on 
plot(timepin,(neq-neq(w1))+stdpin)
hold on
plot(timepin,(neq-neq(w1))-stdpin)
legend('Fluence[neq/cm2]','k factor*POT','Standard Deviation')
set(gcf, 'Position', [300, 0, 1080, 720])
picn2=strcat(out_dir,pin_f,'fluence.png')
picfig2=strcat(out_dir,pin_f,'fluence.fig')
saveas(gcf,picn2)
export_fig(picn2)
savefig(picfig2)


%% Times

time_file=datetime('now','TimeZone','local','Format','d-MMM-y HH:mm:ss Z')
time_script=datestr(time_file(1))

Begin=datestr(timePOT(1))
End=datestr(timePOT(end))

toc

%% Saving files

name=strcat(out_dir,pin_f,'variables.mat')
save(name,'time_file','Begin','End','endFluence','endStd','errorPin','mkpin','endpot','cut')


varmatrix ={'Time_of_data',time_script;
            'Start_of_run',Begin;
            'End_of_run',End;
            'endFluence',endFluence;
            'endStd',endStd;
            'mkpin',mkpin;
            'errorPin',errorPin;
            'endpot',endpot;
            'cut',cut}           
        
        
name2=strcat(out_dir,pin_f,'variables.txt')
t=table(varmatrix)
writetable(t,name2)

toc



%% Trash

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




% figure (7968)
% plot(kpin2)
% title('K factor for run 2');
% datetickzoom('x','dd/mmm HH:MM','keepticks','keeplimits');
% ylabel('Fluence[neq/cm2]/POT(counts)'); 
% xlabel('Time [day/month hh:mm]');

% figure (7968)
% plot(kpin2)
% title('K factor for run 2');
% datetickzoom('x','dd/mmm HH:MM','keepticks','keeplimits');
% ylabel('Fluence[neq/cm2]/POT(counts)'); 
% %xlabel('Time [day/month hh:mm]');

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
