%function that create an array of Fluence given an array of PIN Vth
% use PINVth2Fluence ( Vtharray , type)
% type field emtpy means 3BPW in series
% type == 'singlePIN' means 1BPW 

function [Fluence_array , stdFluence] = PinVth2Fluence (Vtharray,type) 
    load 'PINCalibration2Compensated.mat'
    
    if strcmp(type,'')
    Fluence_array = interp1(PINVth_mean, Fluence, Vtharray);
    for i=1:length(Vtharray)
            [g  index] = min(abs(Vtharray(i) - PINVth_mean));
            stdarray(i) =  PINVth_std(index);
        end
     stdarray = interp1(PINVth_mean, Fluence, Vtharray+stdarray);
     stdFluence = stdarray - Fluence_array 
    else
    Fluence_array = interp1(PINVth_single, FluenceSingle,Vtharray );
    stdFluence = zeros(1,length(Fluence_array))
    end
        
end 