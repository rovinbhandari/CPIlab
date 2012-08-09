cpu "8085.tbl"
hof "int8"

org 9000h

LXI H,9050h
MOV C,M
LXI H,9051h
MOV B,M
LXI H,9052h
MOV E,M
LXI H,9053h
MOV D,M
MVI L,00H
MVI H,00H
loop: MVI A,00H
ORA B 
JNZ decr
ORA C
JZ exit
decr: DAD D
DCX B
JMP loop
exit: SHLD 9054h
RST 5