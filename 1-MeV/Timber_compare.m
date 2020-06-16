%Comparison with timber

timb = 'TIMBER_DATA_INT3';
[neb,inttext] = xlsread(timb);
nebpin=neb(:,1)
ti=inttext(3:end,1)

for y=1:length(ti(:,1));
    if length(ti{y,1})<19; % testing if there are bad timing data insertions from matlab, where HH:MM:SS are missing for changes over midnight
        ti{y,1}=strcat(ti{y,1},' 00:00:00');
    end
end

parfor y=1:length(ti(:,1)); %pararell for loop is much faster here
    timeint(y,:)=datenum(ti{y,1}, 'dd/mm/yyyy HH:MM:SS')
end

figure(393)
plot(nebpin)


figure(58)
plot(timepin,neq-neq(1))
title('Comparison of 1-MeV Neutron Fluence with 1 pin kfactor*POT for run 3')
datetickzoom('x','dd/mmm HH:MM','keepticks','keeplimits');
ylabel('Fluence[neq/cm2]'); 
xlabel('Time [day/month hh:mm]')
hold on
plot(timepin,mpin*POTintPIN, 'r')
hold on 
plot(timeint,nebpin-(5.5454e12),'g')
% plot(timepin,mpin3*POTOSintPIN, 'g')
% hold on
hold on
plot(timepin,(neq-neq(1))+stdpin)
hold on
plot(timepin,(neq-neq(1))-stdpin)
legend('Fluence[neq/cm2]','k factor*POT','Timber fluence')

figure(59)
plot(timepin,neq)
title('Comparison of 1-MeV Neutron Fluence with 1 pin kfactor*POT for run 3')
datetickzoom('x','dd/mmm HH:MM','keepticks','keeplimits');
ylabel('Fluence[neq/cm2]'); 
xlabel('Time [day/month hh:mm]')
hold on
plot(timepin,mpin2*POTintPIN, 'r')
hold on 
plot(timeint,nebpin-(0),'g')
% plot(timepin,mpin3*POTOSintPIN, 'g')
% hold on
hold on
plot(timepin,(neq)+stdpin)
hold on
plot(timepin,(neq)-stdpin)
legend('Fluence[neq/cm2]','k factor*POT','Timber fluence')
