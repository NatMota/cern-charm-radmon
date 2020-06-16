clc
clear
close all

tic
%% Load

%ONLY USE V5 DATA HERE

seu_f = '5s3s5';
pot_f = 'sec1cu3';

[seu,dtext] = xlsread(seu_f,1);
[seu2,dtext2]=xlsread(seu_f,2);
[ions,ptext] = xlsread(pot_f);

poT=ptext(3:end,1);
tseu=dtext(3:end,1);
tseu2=dtext2(3:end,1);

%% Set

cut=1500

rfact=rfactor('cu',13)

sigth3V=2.6e-6%lot 438
sigth5V=4.3e-8
sigHEH3V=9.33e-7 %lot 438
sigHEH5V=3.8e-7;


%% Fixgaps , trim to POT
sizes={length(ions),length(seu),length(seu2)};
a=min(cell2mat(sizes));
%a=length(ions);
ions(a+1:end)=[];
seu(a+1:end)=[];
seu2(a+1:end)=[];

poT(a+1:end)=[];
tseu(a+1:end)=[];
tseu2(a+1:end)=[];

seunew=fixgaps(seu);
seunew2=fixgaps(seu2);


%% Finding the time

for y=1:length(tseu(:,1));
    if length(tseu{y,1})<19;
        tseu{y,1}=strcat(tseu{y,1},' 00:00:00')
    end
end

for y=1:length(tseu2(:,1));
    if length(tseu2{y,1})<19;
        tseu2{y,1}=strcat(tseu2{y,1},' 00:00:00')
    end
end

for y=1:length(poT(:,1));
    if length(poT{y,1})<19;
        poT{y,1}=strcat(poT{y,1},' 00:00:00')
    end
end

parfor y=1:length(tseu(:,1)); 
    timeSEU(y,:)=datenum(tseu{y,1}, 'dd/mm/yyyy HH:MM:SS')
end

parfor y=1:length(tseu2(:,1)); 
    timeSEU2(y,:)=datenum(tseu2{y,1}, 'dd/mm/yyyy HH:MM:SS')
end

parfor y=1:length(poT(:,1));
	timePOT(y,:)=datenum(poT{y,1}, 'dd/mm/yyyy HH:MM:SS');
end

%% Interpolate
POT=(ions)*2.24e7;
csPOT=nancumsum(ions)*2.24e7;
endPOT=max(csPOT)

INTPS=interp1(timePOT,csPOT,timeSEU)
INTPS2=interp1(timePOT,csPOT,timeSEU2)

%% Calculating the R Factor
    deltaV5=seunew-seunew(1);
        xc=find(isnan(deltaV5));
    for r=1:length(xc)+1;
        if isempty(xc);
            wc=length(deltaV5);
        else
            wc=xc(1)-1;
        end
    end
    seuV5=deltaV5(wc)
    
    deltaV3=seunew2-seunew2(1)
            xt=find(isnan(deltaV3));
    for r=1:length(xt)+1;
        if isempty(xt);
            wt=length(deltaV3);
        else
            wt=xt(1)-1;
        end
    end
    seuV3=deltaV3(wt)


  rf2num=(sigHEH3V*seuV5)-(sigHEH5V*seuV3)
%------------------------------------------
  rf2denum=(sigth5V*seuV3)-(sigth3V*seuV5)

R_factor=rf2num/rf2denum


%% Caculating HEH - RADMON3 IS BIASED AT 5V

for y=length(seunew(1,:));
    HEH5V=(deltaV5/((R_factor*sigth5V)+sigHEH5V))
    kHEH5V=HEH5V(:,y)./INTPS(:,y)
    mkHEH5V=nanmean(kHEH5V(cut:end,y));
    stdHEH5V(y)=nanstd(kHEH5V(cut:end,y));
end

endHEH5V=HEH5V(end)


%% Calculating Thermals - RADMON5 IS BIASED AT 3V

for y=length(seunew2(1,:));
    TH3V = deltaV3/(sigth3V+(sigHEH3V/R_factor))
    kTH3V(:,y)= TH3V(:,y)./INTPS2(:,y);
    mkTH3V(y)= nanmean(kTH3V(cut:end,y));
    stdTH3V(y)=nanstd(kTH3V(cut:end,y));    
end

endTH3V=TH3V(end)


%% Graphing
figure(1)
plot(timeSEU,kHEH5V);
title(strcat('Normalised High Energy Hadrons For 5V Toshiba on RadMONV5#3',seu_f));
legend('Normalisation of HEHs by POT')
ylabel('HEH divided by POT (cm^(-2))');
xlabel('Time (dd/mm hh:mm)')
datetickzoom('x','dd/mmm HH:MM','keepticks','keeplimits');
set(gcf, 'Position', [300, 0, 1080, 720])
picn=strcat('C:\Users\Natanael\Dropbox\Documents\CHARM\COMMISSIONING 2015\Data analysis Comissioning 2015\0. matlab\Fundamental R Factor\cu3\',seu_f,'kHEH3V5.png')
picfig=strcat('C:\Users\Natanael\Dropbox\Documents\CHARM\COMMISSIONING 2015\Data analysis Comissioning 2015\0. matlab\Fundamental R Factor\cu3\',seu_f,'kHEH3V5.fig')
saveas(gcf,picn)
export_fig(picn)
savefig(picfig)

figure(2)
plot(timeSEU,kTH3V);
title(strcat('Ratio of Thermal Neutrons For 3V Toshiba on RadMONV5#5',seu_f));
legend('Normalisation of Thermal Neutrons by POT')
ylabel('HEH divided by POT (cm^(-2))');
xlabel('Time (dd/mm hh:mm)')
datetickzoom('x','dd/mmm HH:MM','keepticks','keeplimits');
set(gcf, 'Position', [300, 0, 1080, 720])
picn2=strcat('C:\Users\Natanael\Dropbox\Documents\CHARM\COMMISSIONING 2015\Data analysis Comissioning 2015\0. matlab\Fundamental R Factor\cu3\',seu_f,'kTH5V5.png')
picfig2=strcat('C:\Users\Natanael\Dropbox\Documents\CHARM\COMMISSIONING 2015\Data analysis Comissioning 2015\0. matlab\Fundamental R Factor\cu3\',seu_f,'kTH5V5.fig')
saveas(gcf,picn2)
export_fig(picn2)
savefig(picfig2)

%% Time

time_file=datetime('now','TimeZone','local','Format','d-MMM-y HH:mm:ss Z')
time_script=datestr(time_file(1))

Begin=datestr(timePOT(1))
End=datestr(timePOT(end))

%% Saving variables

name=strcat('C:\Users\Natanael\Dropbox\Documents\CHARM\COMMISSIONING 2015\Data analysis Comissioning 2015\0. matlab\Fundamental R Factor\cu3\',seu_f,'variables.mat')
save(name,'time_file','Begin','End','R_factor','endHEH5V','endTH3V','mkHEH5V','mkTH3V','seuV5','seuV3','endPOT','cut')

varmatrix ={'Time_of_data',time_script;
            'Start_of_run',Begin;
            'End_of_run',End;
            'Risk factor',R_factor;
            'endHEH5V',endHEH5V;
            'endTH3V',endTH3V;
            'endpot',endPOT;
            'mkHEH5V',mkHEH5V;
            'mkTH3V',mkTH3V;
            'seuV5',seuV5;
            'seuV3',seuV3;
            'cut',cut}           
        
        
name2=strcat('C:\Users\Natanael\Dropbox\Documents\CHARM\COMMISSIONING 2015\Data analysis Comissioning 2015\0. matlab\Fundamental R Factor\cu3\',seu_f,'variables.txt')
t=table(varmatrix)
writetable(t,name2)


toc

%% Trash


% for y=2:length(oob(1,:));
%     if d2u(y,1)-d2u(y-1,1)>300
%         d2u(y,1)=((d2u(y-1))+1)
%     end
% end
% 
% 
% 
% for y=2:length(oob(1,:));
%     if weeb(y,1) > 20
%         d2u(weeb-1,1)=d2u(weeb-2,1)
%     end
% end
% for y=length(deltaseu(1,:));
% d2u(webcor(y),1)=d2u(webcor(y)-1,1)
% end

% % weeb2=find(weeb > 50)
% diFF=dif+1

% io=find(ions<13000);
% ions(io)=ions(io-1);
% 
% iu=find(ions>20000);
% ions(iu)=ions(iu-1);
% sigth3V = 2.79e-6;
% sigth5V = 5.26e-8;
% 
% sigHEH3V = 1.18e-6;
% sigHEH5V = 5e-7;


% %% Removing JDI Jumps, much proud of this code
% 
% deltaseu=zeros(length(counts),1);
% for y=length(counts(1,:));
%     deltaseu(:,y)=counts(:,y) - counts(1,y);
% end
% 
% d2u=deltaseu;
% 
% Dif=diff(d2u)
% diFF=(find(Dif>50))+1
% 
% for y=1:length(diFF)
% d2u(diFF(y):end)=(d2u(diFF(y):end))-(Dif(diFF(y)-1))
% end%% Variables
% 
% counts=seu(:,1);
% POT=(ions)*2.24e7;
% csPOT=cumsum(ions)*2.24e7;
% cut=1500
% 
% 
% % 
% % stdevHEH5V=2.89e-15*1024*1024*16
% % 
% % stdevHEH3V=4.86e-15*1024*1024*16

% carefullHEH=mk_HEH5V*muchoPOT
% 
% carefullTHER=mk_TH5V*muchoPOT

%le_error=100*(sqrt(max(d2u))/max(d2u))

