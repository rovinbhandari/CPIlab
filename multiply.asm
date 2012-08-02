LXI H,C050
       MOV C,M        
       LXI H,C051
       MOV B,M        
       LXI H,C052
       MOV E,M        
       LXI H,C053
       MOV D,M        
       MVI L,00H
       MVI H,00H
loop:        MVI A,00H
       ORA B        
       JNZ decr
       ORA C        
       JZ exit
decr:        DAD D
       DCX B        
       JMP loop
exit:        SHLD C054
       RST 5
