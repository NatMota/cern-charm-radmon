%provides rfactor into script
%copper=cu
%aluminium=al
%aluminium holes=alh
%coppershieldingfull=cuciic
%use old positions for now

function y=rfactor(target,position)

switch target

    case 'cu'
    
        switch position
            
            case 1
                y=3.228
            case 2
                y=2.919  
            case 3
                y=2.251 
            case 4
                y=2.078
            case 5
                y=1.996
            case 6
                y=1.893 
            case 7
                y=1.896 
            case 8
                y=2.201
            case 9
                y=2.048
            case 10
                y=2.185
            case 11
                y=2.291
            case 12
                y=2.423
            case 13
                y=1.972
               
            otherwise
              fprintf ( 'Error: position data not available')
        end
            
        case 'al'
    
        switch position
            
            case 1
                y=2.244
            case 2
                y=2.004 
            case 3
                y=1.613
            case 4
                y=1.468
            case 5
                y=1.383
            case 6
                y=1.313 
            case 7
                y=1.305 
            case 8
                y=1.427
            case 9
                y=1.318
            case 10
                y=1.356
            case 11
                y=1.382
            case 12
                y=1.391
            case 13
                y=1.112
               
            otherwise
              fprintf ( 'Error: position data not available')
        end
            
        case 'cuciic'
    
        switch position
            
            case 1
                y=25.608
            case 2
                y=19.902 
            case 3
                y=14.764
            case 4
                y=13.877
            case 5
                y=13.116
            case 6
                y=13.395
            case 7
                y=13.772 
            case 8
                y=14.321
            case 9
                y=14.766
            case 10
                y=14.61
            case 11
                y=13.965
            case 12
                y=13.965
            case 13
                y=9.492
               
            otherwise
              fprintf ( 'Error: position data not available')
            end
    otherwise
        fprintf ( 'Error: target data not available')
    end