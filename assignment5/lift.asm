cpu "8085.tbl"
hof "int8"

org 9000h

; Program to simulate the behaviour of a lift (elevator) using 8255

MVI A,8BH  ; Configure 8255
OUT 43H	   

;TODO: add an interrupt service routine to let boss' secretary enter the
; boss' current floor. //PG

;WAITINPUT and POLLING are coupled subroutines.

WAITINPUT: NOP ;while there is no input, keep calling POLLING (inside DELAY).
CALL DELAY
CALL DEQUEUE ;returns the floor to move to by setting a bit in a byte.
POP A ;TODO: check if it will work. //RB, RK
JZ WAITINPUT

MOV B, A
MVI H, 80H

LEDBLINKLOOP: NOP
PUSH B ;because DELAY (and its nested subroutines) might change B.
PUSH H ;because DELAY (and its nested subroutines) might change H.
CALL DELAY
POP H
POP B
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
CALL POLLING
LXI D, 0CFFFH
DLOOP: NOP
DCX D
MOV A,D
ORA E
JNZ DLOOP
RET

POLLING: NOP
IN 41H ;Read the input 
CMA
CPI 00H
RZ
PUSH A
CALL ENQUEUE
RET
