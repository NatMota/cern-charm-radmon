%function that create an array of dose given an array of Vth
% use Vth2Gy2 ( 'type' , Vtharray)
%type could be 100nm, 400nmW2, 400nmW5 , 1000nm
% max dose 1000nm = 20Gy
% max dose 100nm = 4224Gy
% max dose 400nm = 600Gy


function [dose_array , stddose]= Vth2Gy3 (replytype , Vtharray  )

load('calibrationcurve4.mat');


switch replytype
    case '100nm'

        dose_array = interp1(m_100smooth, dose_100_12, Vtharray);
  
        for i=1:length(Vtharray)
            [g  index] = min(abs(Vtharray(i) - m_100smooth));
            stdarray(i) = std_100(index);
        end
        stdarray = interp1(m_100smooth, dose_100_12, Vtharray+stdarray);
        stddose = stdarray - dose_array  
    case '400nmW2'
        
        dose_array = interp1(m_400W2smooth, dose_400_1_2, Vtharray);
       for i=1:length(Vtharray)
            [g  index] = min(abs(Vtharray(i) - m_400W2smooth));
            stdarray(i) = std_400W2(index);
       end
        stdarray = interp1(m_400W2smooth, dose_400_1_2, Vtharray+stdarray);
        stddose = stdarray - dose_array  
    case '400nmW5'
        
        dose_array = interp1(m_400W5smooth, dose_400_1_2, Vtharray);
        for i=1:length(Vtharray)
            [g  index] = min(abs(Vtharray(i) - m_400W5smooth));
            stdarray(i) = std_400W5(index);
        end
        
        stdarray = interp1(m_400W5smooth, dose_400_1_2, Vtharray+stdarray);
        stddose = stdarray - dose_array  
    case '400nmW8'
        
        dose_array = interp1(m_unique_400nmW8_2014, dose400nmW8_unique_2014, Vtharray);
        for i=1:length(Vtharray)
            [g  index] = min(abs(Vtharray(i) - m_400W8));
            stdarray(i) = std_400W8(index);
        end
        
        stdarray = interp1(m_400W8, dose400W8, Vtharray+stdarray);
        stddose = stdarray - dose_array         
        stddose = dose_array*0.1;
        
        
    case '1000nm'
        
        dose_array = interp1(m_1000smooth, dose_1000_1_2, Vtharray);
        for i=1:length(Vtharray)
            [g  index] = min(abs(Vtharray(i) - m_1000smooth));
            stdarray(i) = std_1000(index);
        end
        stdarray = interp1(m_1000smooth, dose_1000_1_2, Vtharray+stdarray);
        stddose = stdarray - dose_array  
    
    otherwise
        fprintf ( 'wrong radfet type, write "help Vth2Gy3" to have an help  ')
    end
end