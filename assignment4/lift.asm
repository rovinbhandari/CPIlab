cpu "8085.tbl"
hof "int8"

org 9000h

; Program to simulate the behaviour of a lift (elevator) using 8255

MVI A,8BH  ; Configure 8255
OUT 43H	   
SEN: IN 41H; Read the input 
CMA
CPI 00H
JZ READKBD
MOV B, A
MVI H, 80H

LEDBLINKLOOP: nop
CALL DELAY
MOV A, H
RLC
OUT 40H
MOV H,A
MOV A,B
CMP H
JNZ LEDBLINKLOOP
READKBD: CALL 03BAH ; RDKBD	
CPI 1DH	; Compare with "EXEC"
JZ SEN	; If pressed goto SEN


RST 05H ; otherwise return to monitor



;;; Delay ;;;;
;;;;;;;;;;;;;;


DELAY: NOP
LXI D, 0CFFFH
DLOOP: NOP
DCX D
MOV A,D
ORA E
JNZ DLOOP
RET
