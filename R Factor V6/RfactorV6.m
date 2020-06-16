clc
clear
close all

tic
%% Load

% ONLY USE V6 DATA HERE

seu_f = '6s8';
pot_f = 'sec1cush';

in_dir  ='./cush/'
out_dir ='./cush/'

[seu,dtext]  = xlsread(strcat(in_dir,seu_f),1);
[seu2,dtext2]= xlsread(strcat(in_dir,seu_f),2);
[ions,ptext] = xlsread(strcat(in_dir,pot_f));

poT=ptext(3:end,1);
tseu=dtext(3:end,1);
tseu2=dtext2(3:end,1);

%% Set

cut=1500

rfact=rfactor('cu',13);

sigth3V=2.6e-6;%lot 438;
sigth5V=4.3e-8;
sigHEH3V=9.33e-7; %lot 438
sigHEH5V=3.8e-7;

sigHEHCyp4mem =1.87e-13;
sigTHCyp4mem  =3.84e-16*4;

n_memories

mbitcyp=2^23;

hehcyp=sigHEHCyp4mem*mbitcyp;
thcyp=sigTHCyp4mem*mbitcyp;

%sigheh Cypress on another script

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
        tseu{y,1}=strcat(tseu{y,1},' 00:00:00');
    end
end
for y=1:length(tseu2(:,1));
    if length(tseu2{y,1})<19;
        tseu2{y,1}=strcat(tseu2{y,1},' 00:00:00');
    end
end

for y=1:length(poT(:,1));
    if length(poT{y,1})<19;
        poT{y,1}=strcat(poT{y,1},' 00:00:00');
    end
end

parfor y=1:length(tseu(:,1)); 
    timeSEU(y,:)=datenum(tseu{y,1}, 'dd/mm/yyyy HH:MM:SS');
end

parfor y=1:length(tseu2(:,1)); 
    timeSEU2(y,:)=datenum(tseu2{y,1}, 'dd/mm/yyyy HH:MM:SS');
end

parfor y=1:length(poT(:,1));
	timePOT(y,:)=datenum(poT{y,1}, 'dd/mm/yyyy HH:MM:SS');
end

%% Interpolate
POT=(ions)*2.24e7;
csPOT=nancumsum(ions)*2.24e7;
endPOT=max(csPOT);

INTPS=interp1(timePOT,csPOT,timeSEU);
INTPS2=interp1(timePOT,csPOT,timeSEU2);

%% Calculating the R Factor
    deltacyp=seunew-seunew(1);
    xc=find(isnan(deltacyp));
    for r=1:length(xc)+1;
        if isempty(xc);
            wc=length(deltacyp);
        else
            wc=xc(1)-1;
        end
    end
    seucyp=deltacyp(wc)
    
    deltatosh=seunew2-seunew2(1)
        xt=find(isnan(deltatosh));
    for r=1:length(xt)+1;
        if isempty(xt);
            wt=length(deltatosh);
        else
            wt=xt(1)-1;
        end
    end
    seutosh=deltatosh(wt)

 rf2num=(sigHEH3V*seucyp)-(hehcyp*seutosh)
%------------------------------------------
 rf2denum=(thcyp*seutosh)-(sigth3V*seucyp)

R_factor=rf2num/rf2denum


%% Caculating HEH Cypress

for y=length(seunew(1,:));
    HEHCyp=deltacyp/((R_factor*thcyp)+hehcyp)
    kHEHCyp=HEHCyp(:,y)./INTPS(:,y)
    kHEHCyp2=HEHCyp(:,y)./csPOT(:,y)
    mkHEHcyp=nanmean(kHEHCyp(cut:end,y));
    std_HEHCyp(y)=std(kHEHCyp(cut:end,y));
end

endHEHcyp=HEHCyp(end)

%% Thermals Toshiba

%THIS IS RADMON#5 AT 3V !!

for y=length(seunew2(1,:));
    THto3V = deltatosh/(sigth3V+(sigHEH3V/R_factor))
    kTHto3V(:,y)= THto3V(:,y)./INTPS2(:,y);
    mkTHto3V(y)= nanmean(kTHto3V(cut:end,y));
    stdTHto3V(y)=std(kTHto3V(cut:end,y));  
end

endTHtosh=THto3V(end)

R_factor3=THto3V./HEHCyp %thermal neutron fluence over high energy hadrons

R_factor2=mkTHto3V/mkHEHcyp


%le_error=100*(sqrt(max(d2u))/max(d2u))

%% Graphing
figure(1)
plot(timeSEU,kHEHCyp);
title(strcat('Normalised High Energy Hadrons for Cypress Memory for RadMON-',seu_f));
legend('Normalisation of HEHs by POT')
ylabel('HEH divided by POT (cm^(-2))');
xlabel('Time (dd/mm hh:mm)')
datetickzoom('x','dd/mmm HH:MM','keepticks','keeplimits');
set(gcf, 'Position', [300, 0, 1080, 720])
picn=strcat(out_dir,seu_f,'kHEHcyp.png')
picfig=strcat(out_dir,seu_f,'kHEHcyp.fig')
saveas(gcf,picn)
export_fig(picn)
savefig(picfig)

figure(2)
plot(timeSEU2,kTHto3V);
title(strcat('Normalised Thermal Neutrons POT For 3V Toshiba on RadMON',seu_f));
legend('Normalisation of Thermal Neutrons by POT'),
ylabel('HEH divided by POT (cm^(-2))');
xlabel('Time (dd/mm hh:mm)')
datetickzoom('x','dd/mmm HH:MM','keepticks','keeplimits');
set(gcf, 'Position', [300, 0, 1080, 720])
picn2=strcat(out_dir,seu_f,'kTHtosh.png')
picfig2=strcat(out_dir,seu_f,'kTHtosh.fig')
saveas(gcf,picn2)
export_fig(picn2)
savefig(picfig2)

%% Time 

time_file=datetime('now','TimeZone','local','Format','d-MMM-y HH:mm:ss Z')
time_script=datestr(time_file(1))

Begin=datestr(timePOT(1))
End=datestr(timePOT(end))

%% Saving variables

name=strcat(out_dir,seu_f,'variables.mat')
save(name,'time_file','Begin','End','R_factor','endHEHcyp','endTHtosh','mkHEHcyp','mkTHto3V','seucyp','seutosh','endPOT','cut')

varmatrix ={'Time_of_data',time_script;
            'Start_of_run',Begin;
            'End_of_run',End;
            'Risk factor',R_factor;
            'endHEHcyp',endHEHcyp;
            'endTHtosh',endTHtosh;
            'endpot',endPOT;
            'mkHEHcyp',mkHEHcyp;
            'mkTHto3V',mkTHto3V;
            'seucyp',seucyp;
            'seutosh',seutosh;
            'cut',cut}           
        
        
name2=strcat(out_dir,seu_f,'variables.txt')
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
%% Variables



 
% stdevHEH5V=2.89e-15*1024*1024*16
% 
% stdevHEH3V=4.86e-15*1024*1024*16



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
% end

% for y=length(seu(1,:));
%     HEH5V(:,y) = deltatosh/((rfact*sigth5V)+ sigHEH5V))
%     kHEH5V(:,y)= HEH5V(:,y)./POTintSEU(:,y);
%     maxHEH5V(y)= max(kHEH5V)
%     mk_HEH5V(y)= mean(kHEH5V(cut:end,y));
%     std_HEH5V(y)=std(kHEH5V(cut:end,y));
% end

% carefullHEH=mk_HEH5V*endPOT
% 
% carefullTHER=mk_TH5V*endPOT

%     kHEHCyp=HEHCyp(:,y)./INTPS(:,y)
%     kHEHCyp2=HEHCyp(:,y)./csPOT(:,y)
%     mk_HEHCyp(y)= mean(kHEHCyp(cut:end,y));
%     mk_HEHCyp2(y)= mean(kHEHCyp2(cut:end,y));
%     std_HEHCyp(y)=std(HEHCyp(cut:end,y));


       %(sigHEHCyp*mbitcyp)
       
       
       % aaTHto3V = deltatosh(end)/(sigth5V+(sigHEH3V/rfact))
% 
% newkTHto3V=THto3V(end)/endPOT

%aakHEHCype=HEHCyp(end)/endPOT
%set(gca, 'xtick',[timeNUM(1) timeNUM(o1) timeNUM(q1) timeNUM(o3) timeNUM(middle) timeNUM(o5) timeNUM(q3) timeNUM(o7) timeNUM(end)])

% XYrotalabel(45,0);
% XYrotalabel(45,0);

%set(gca, 'xtick',[timeNUM(1) timeNUM(o1) timeNUM(q1) timeNUM(o3) timeNUM(middle) timeNUM(o5) timeNUM(q3) timeNUM(o7) timeNUM(end)])

% 
% SaveFig(1,'HEH5V');
% SaveFig(2,'TH5V');
% 
% figure(3)
% plot(timeSEU,d2u)
% datetick('x','dd/mmm HH:MM','keepticks','keeplimits');
% 
% figure(4)
% plot(timePOT,csPOT)
% datetick('x','dd/mmm HH:MM','keepticks','keeplimits');

 %  maxTHto3V(y)= max(kTHto3V)