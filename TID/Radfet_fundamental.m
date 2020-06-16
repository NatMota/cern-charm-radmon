clc
clear
close all
%This script processes raw mV data from the RadMON
%to retreive the total inonising dose (Gy),which
%quantifies the amount of energy deposited by 
%inonising particles in the RadFET.
%This script works for both V5 and V6 raw RadFET data.

tic

%% Load

dose_f ='6t8';
pot_f  ='sec1al';

in_dir = './al/'
out_dir= './al/'

load('involt.mat')

cut=2500 %used later to find normalisation factor

% Simple name conventions, num contains data from radfet 1 (usually 400nm)
%num2 contains data from radfet 2 
%txt contains the times of the data
[num,txt] = xlsread(strcat(in_dir,dose_f),1);
[num2,txt2] = xlsread(strcat(in_dir,dose_f),2);
[ions,ptext] = xlsread(strcat(in_dir,pot_f));
% reading the name of the sensor so it can be later compared to initial
% voltage nd indentified as v5 or v6
[status,sheets]=xlsfinfo(strcat(in_dir,dose_f));

%% Time
 % TXT is 400 and TXT2 is 100
  
simpletxt400=txt(3:end,1);
simpletxt100=txt2(3:end,1);
timerPOT=ptext(3:end,1);

%% Trim data to smallest

sizes={length(ions),length(num),length(num2)};
a=min(cell2mat(sizes));

ions(a+1:end)=[];
num(a+1:end)=[];
num2(a+1:end)=[];

simpletxt100(a+1:end)=[];
simpletxt400(a+1:end)=[];
timerPOT(a+1:end)=[];


%% Fill gaps

numnew=fixgaps(num);
numnew2=fixgaps(num2);

%% Timing
%Matlab incorrecly stores the '00:00:00' for midnight at the end of the day
%so this needs to be added or datenum won't work

for y=1:length(simpletxt400(:,1));
    if length(simpletxt400{y,1})<19;
        simpletxt400{y,1}=strcat(simpletxt400{y,1},' 00:00:00');
    end
end

for y=1:length(simpletxt100(:,1));
    if length(simpletxt100{y,1})<19;
        simpletxt100{y,1}=strcat(simpletxt100{y,1},' 00:00:00');
    end
end

for y=1:length(timerPOT(:,1));
    if length(timerPOT{y,1})<19;
        timerPOT{y,1}=strcat(timerPOT{y,1},' 00:00:00');
    end
end

parfor y=1:length(simpletxt100(:,1)); 
time100(y,:)=datenum(simpletxt100{y,1}, 'dd/mm/yyyy HH:MM:SS');
end

parfor y=1:length(timerPOT(:,1));
timePOT(y,:)=datenum(timerPOT{y,1}, 'dd/mm/yyyy HH:MM:SS');
end

parfor y=1:length(simpletxt400(:,1));
time400(y,:)=datenum(simpletxt400{y,1}, 'dd/mm/yyyy HH:MM:SS');
end

%% Interpolation

POT=(ions)*2.24e7;
csPOT=nancumsum(ions)*2.24e7;

INTP100=interp1(timePOT, csPOT, time100);
INTP400=interp1(timePOT, csPOT, time400);


%% Finding init values

%initial values in mV are stored in the initvoltages variable to 
%make this process automatic. They are CHARACTERISTIC of each
%RadFET. This is updated as of 01.07.2015


stri=sheets';
for g=1:length(initvoltages);
        if strcmp(initvoltages(g,1),stri(1,1));
        init400=initvoltages(g,2);
        name400=initvoltages(g,1);
    elseif strcmp(initvoltages(g,1),stri(2,1));
        init100=initvoltages(g,2);
        name100=initvoltages(g,1);
    end
end

%% V5 vs V6 mv to V
%v5 logs in mV whilst v6 logs in V (Vth2Gy3 only works in mV)

switch strncmpi(name400,'SIM',3);
       case 1;
       numnew=numnew*1000;
       numnew2=numnew2*1000;
end;

%% Dose 
%initialise variables
Vth100 = numnew2;
k100=[] ;
x1=[]
for y=1:length(Vth100(1,:));
   delta100(:,y)=Vth100(:,y)-init100{1};
   [dose100(:,y),stdose100(:,y)]=Vth2Gy3('100nm',delta100(:,y)');  
    x1=find(isnan(dose100));
    for r=1:length(x1)+1; % To calculate initial value in case its nan in the begining of the matrix without changing matrix size
    if isempty(x1);
        w1=1;
    else
        w1=x1(end)+1;
    end
    end
    for k=1:length(w1)
        if w1>length(dose100)
            w1=1
        end
    end
    o1=dose100(1:end,y)-dose100(w1); % using a non-nan initial value
    k100=o1./INTP100(1:end);
    mk100=nanmean(k100(cut:end,y));
    %mk100=nanmean(k100(2500:5500)); for broken radmons
    stdk100=stdose100(:,y);
end

Vth400=numnew;
k400=[];
x4=[]
for y=1:length(Vth400(1,:));
    delta400(:,y)=Vth400(:,y)-init400{1};
    %Change vth to 100nm as appropriate if two 100nm are used;
    [dose400(:,y),stdose400(:,y)]=Vth2Gy3('400nmW8',delta400(:,y)');
    x4=find(isnan(dose400));
    for r=1:length(x4)+1;
        if isempty(x4);
            w4=1;
        else
            w4=x4(end)+1;
        end
    end
        for k=1:length(w4)
        if w4>length(dose400)
            w4=1
        end
    end
    o4=dose400(1:end,y)-dose400(w4);
    k400=o4./INTP400(1:end,y);
    mk400=nanmean(k400(cut:end,y));
    stdk400=stdose400(:,y)
end

endpot=max(csPOT);
% doseend100=nanmax(o1)-nanmin(o1);
% doseend400=nanmax(o4)-nanmin(o4);
doseend100=mk100*endpot
doseend400=mk400*endpot


std100end=nanmax(stdose100)-nanmin(stdose100);
std400end=nanmax(stdose400)-nanmin(stdose400);

error_final100=std100end/nanmax(dose100);
error_final400=std100end/nanmax(dose400);



% 
% test=stdose100(end)-nanmin(stdose100)
% 

%% Making Plots and saving them

figure(1)
plot(time100,k100)
title(strcat('Normalisation of Measured Dose by POT for 100nm ',name100))
legend('Normalisation of Dose by POT')
ylabel('Dose divided by POT [Gy]')
xlabel('Time units')
datetickzoom('x','dd/mmm HH:MM','keepticks','keeplimits');
set(gcf, 'Position', [300, 0, 1080, 720])
%These filename directories need to be changed according to the run being
%analysed
picn=strcat(out_dir,dose_f,'k100.png')
picfig=strcat(out_dir,dose_f,'k100.fig')
saveas(gcf,picn)
export_fig(picn)
savefig(picfig)


figure(2)
plot(time400,k400)
title(strcat('Normalisation of Measured Dose by POT for 400nm',name400))
legend('Normalisation of Dose by POT')
ylabel('Dose divided by POT [Gy]')
xlabel('Time units')
datetickzoom('x','dd/mmm HH:MM','keepticks','keeplimits');
set(gcf, 'Position', [300, 0, 1080, 720]);
  picn2=strcat(out_dir,dose_f,'k400.png')
  picfig2=strcat(out_dir,dose_f,'k400.fig')
saveas(gcf,picn2)
export_fig(picn2)
savefig(picfig2)


figure(3)
plot(time100,dose100-dose100(w1))
title(strcat('Dose evolution through time for ',name100))
datetickzoom('x','dd/mmm HH:MM','keepticks','keeplimits');
hold on
plot(time100,mk100*INTP100, 'r')
hold on 
plot(time100,(dose100-dose100(w1))+stdk100)
hold on
plot(time100,(dose100-dose100(w1))-stdk100)
legend('Dose100nm','k*POT interpolated','Standard Deviation')
ylabel('Dose in Gy')
xlabel('Time in dd/MM hh:mm')
set(gcf, 'Position', [300, 0, 1080, 720])
picn3=strcat(out_dir,dose_f,'dose100.png')
picfig3=strcat(out_dir,dose_f,'dose100.fig')
saveas(gcf,picn3)
export_fig(picn3)
savefig(picfig3)

figure(4)
plot(time400,dose400-dose400(w4))
title(strcat('Dose evolution through time for ',name400))
datetickzoom('x','dd/mmm HH:MM','keepticks','keeplimits');
hold on
plot(time400,mk400*INTP400, 'r')
hold on
plot(time400,(dose400-dose400(w4))+stdk400)
hold on
plot(time400,(dose400-dose400(w4))-stdk400)
legend('Dose400nm','k*POT interpolated','Standard Deviation')
set(gcf, 'Position', [300, 0, 1080, 720])
picn4=strcat(out_dir,dose_f,'dose400.png')
picfig4=strcat(out_dir,dose_f,'dose400.fig')
saveas(gcf,picn4)
export_fig(picn4)
savefig(picfig4)

%% Times

time_file=datetime('now','TimeZone','local','Format','d-MMM-y HH:mm:ss Z')
time_script=datestr(time_file(1))

Begin=timerPOT(1)
End=timerPOT(end)


%% Saving files

name=strcat(out_dir,dose_f,'variables.mat')
save(name,'time_file','Begin','End','doseend100','error_final100','mk100','doseend400','error_final400','endpot','mk400','cut')


varmatrix ={'Time_of_data',time_script;
            'Start_of_run',Begin{1};
            'End_of_run',End{1};
            'doseend100',doseend100;
            'error_final100',error_final100;
            'doseend400',doseend400;
            'error_final400',error_final400;
            'endpot',endpot;
            'mk100',mk100;
            'mk400',mk400;
            'cut',cut}           
        
        
name2=strcat(out_dir,dose_f,'variables.txt')
t=table(varmatrix)
writetable(t,name2)

toc