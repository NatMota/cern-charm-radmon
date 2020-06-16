clc
clear
close all

tic

%% Load

dose_f ='6t6';
pot_f = 'sec1al';

load('involt.mat')

cut=2500

% Simple name conventions, num contains data from radfet 1 (usually 400nm)
%num2 contains data from radfet 2 
%txt contains the times of the data
[num,txt] = xlsread(dose_f,1);
[num2,txt2] = xlsread(dose_f,2);
[ions,ptext] = xlsread(pot_f);
% reading the name of the sensor so it can be later compared to initial
% voltage nd indentified as v5 or v6
[status,sheets]=xlsfinfo(dose_f);

%% Time
 % TXT is 400 and TXT2 is 100
  
simpletxt400=txt(3:end,1);
simpletxt100=txt2(3:end,1);
timerPOT=ptext(3:end,1);

%% Trim data to POT
a=length(ions);

num(a+1:end)=[];
num2(a+1:end)=[];

simpletxt100(a+1:end)=[];
simpletxt400(a+1:end)=[];
timerPOT(a+1:end)=[];

%% Fill gaps

numnew=fixgaps(num);
numnew2=fixgaps(num2);

%% Timing

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

switch strncmpi(name400,'SIM',3);
       case 1;
       numnew=numnew*1000;
       numnew2=numnew2*1000;
end;

%% Dose 

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
    o1=dose100(1:end,y)-dose100(w1);
    k100=o1./INTP100(1:end);
    mk100=nanmean(k100(cut:end,y));
    stdk100=stdose100(:,y);
end

Vth400=numnew;
k400=[];
x4=[]
for y=1:length(Vth400(1,:));
    delta400(:,y)=Vth400(:,y)-init400{1};
    %Change vth to 100nm as appropriate;
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

error_final100=stdose100(end)/dose100(end);
error_final400=stdose400(end)/dose400(end);



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
picn=strcat('C:\Users\Natanael\Dropbox\Documents\CHARM\COMMISSIONING 2015\Data analysis Comissioning 2015\0. matlab\Fundamental Dose\al\',dose_f,'k100.png')
picfig=strcat('C:\Users\Natanael\Dropbox\Documents\CHARM\COMMISSIONING 2015\Data analysis Comissioning 2015\0. matlab\Fundamental Dose\al\',dose_f,'k100.fig')
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
picn2=strcat('C:\Users\Natanael\Dropbox\Documents\CHARM\COMMISSIONING 2015\Data analysis Comissioning 2015\0. matlab\Fundamental Dose\al\',dose_f,'k400.png')
picfig2=strcat('C:\Users\Natanael\Dropbox\Documents\CHARM\COMMISSIONING 2015\Data analysis Comissioning 2015\0. matlab\Fundamental Dose\al\',dose_f,'k400.fig')
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
picn3=strcat('C:\Users\Natanael\Dropbox\Documents\CHARM\COMMISSIONING 2015\Data analysis Comissioning 2015\0. matlab\Fundamental Dose\al\',dose_f,'dose100.png')
picfig3=strcat('C:\Users\Natanael\Dropbox\Documents\CHARM\COMMISSIONING 2015\Data analysis Comissioning 2015\0. matlab\Fundamental Dose\al\',dose_f,'dose100.fig')
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
picn4=strcat('C:\Users\Natanael\Dropbox\Documents\CHARM\COMMISSIONING 2015\Data analysis Comissioning 2015\0. matlab\Fundamental Dose\al\',dose_f,'dose400.png')
picfig4=strcat('C:\Users\Natanael\Dropbox\Documents\CHARM\COMMISSIONING 2015\Data analysis Comissioning 2015\0. matlab\Fundamental Dose\al\',dose_f,'dose400.fig')
saveas(gcf,picn4)
export_fig(picn4)
savefig(picfig4)

%% Times

time_file=datetime('now','TimeZone','local','Format','d-MMM-y HH:mm:ss Z')
time_script=datestr(time_file(1))

Begin=timerPOT(1)
End=timerPOT(end)


%% Saving files

name=strcat('C:\Users\Natanael\Dropbox\Documents\CHARM\COMMISSIONING 2015\Data analysis Comissioning 2015\0. matlab\Fundamental Dose\al\',dose_f,'variables.mat')
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
        
        
name2=strcat('C:\Users\Natanael\Dropbox\Documents\CHARM\COMMISSIONING 2015\Data analysis Comissioning 2015\0. matlab\Fundamental Dose\al\',dose_f,'variables.txt')
t=table(varmatrix)
writetable(t,name2)

toc


%% Recycling

%r=find(num(isnan(num)))



% 
% a=length(timerPOT)
% 
% x=isnan(ions)
% 
% z=find(x)
% 
% timerPOT(z)=[]
% 
% ions(z)=[]


% 
% for y=1:a
%     
%     if isnan(ions(y))>0
%         
%         timerPOT(y)=[]
%     end
% end
%        
%    Vth100 = num2;
% k100=[] ;
% for y=1:length(Vth100(1,:));
%     delta100(:,y)=Vth100(:,y)-2596; 
%     [dose100(:,y),stdose100(:,y)]=Vth2Gy3('100nm',delta100(:,y)');
%     dose100(isnan(dose100))=1
%     k100=(dose100(1:end,y)-dose100(1,y))./POTREP100(1:end,y);
%     mk100=nanmean(k100(cut:end,y));
%     stdk100=stdose100(:,y);
% end


%% Filter

% ding=num
% 
% dob=isnan(ding)
% 
% ding(dob)w
% 
% 
% 
% 
% filt4=sgolayfilt(num,3,11)
% filt1=sgolayfilt(num2,3,11)
% 
% filt100=medfilt1(num2,2)
% 
% cjeck=interp1(time100,num2,timePOT)

% check=interp1(timePOT,POT,time400)
% check2=interp1(time400,num,timePOT)
% 
% test=check2./check


% hold on
% plot(k400)

%aa=max(csPOT)

% figure (3)
% plot(time100,k100);
% hold on
% plot(time400,k400,'g');
% hold on
% plot(timepin,kpin,'r');
% datetickzoom('x','dd/mmm HH:MM','keepticks','keeplimits');
% legend('K factor RF2', 'K factor RF1','K factor pin');

% figure(4)
% plot(time100,dose100)
% datetickzoom('x','dd/mmm HH:MM','keepticks','keeplimits');
% hold on
% plot(time100,mk100*POTREP100, 'r')
% hold on 
% plot(time100,(mk100-stdk100)*POTREP100, 'g')
% hold on 
% plot(time100,(mk100+stdk100)*POTREP100, 'g')
% legend('Dose100nm','k*POT interpolated','Standard Deviation')
% 
% figure(5)
% plot(time400,dose400)
% datetickzoom('x','dd/mmm HH:MM','keepticks','keeplimits');
% hold on
% plot(time400,mk400*POTREP400, 'r')
% hold on 
% plot(time400,(mk400-stdk400)*POTREP400, 'g')
% hold on 
% plot(time400,(mk400+stdk400)*POTREP400, 'g')
% legend('Dose100nm','k*POT interpolated','Standard Deviation')

% hold on 
% plot(time400,(mk400-stdk400)*POTREP400, 'g')
% hold on 
% plot(time400,(mk400+stdk400)*POTREP400, 'g')#hold on 

% hold on 
% plot(time100,(mk100-stdk100)*POTREP100, 'g')
% hold on 
% plot(time100,(mk100+stdk100)*POTREP100, 'g')

% picn2=strcat('C:\Users\Natanael\Dropbox\Documents\CHARM\COMMISSIONING 2015\Data analysis Comissioning 2015\0. matlab\Fundamental Dose\albin\',dose_f,'k100')
% saveas(gcf,(sprintf('%s',picn)))
% export_fig(sprintf('%s',picn2),'-png')
% export_fig('C:\Users\Natanael\Dropbox\Documents\CHARM\COMMISSIONING 2015\Data analysis Comissioning 2015\0. matlab\Fundamental Dose\albin\3v5rk100')
