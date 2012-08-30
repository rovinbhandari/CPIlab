cpu "8085.tbl"
hof "int8"

org 9000h

;manually store HHMMSS in 8410 to 8415
;it cannot be 000000.

CALL CLOCK

RST 05

CLOCK: NOP
POP H
SHLD 8300H

; Hold the clock until some key input is received
CALL 03BAH; RDKBD

;initialize 6 memory locations to hold display values of H1H2, M1M2, S1S2
MVI A,00H
STA 8400H
STA 8401H
STA 8402H
STA 8403H
STA 8404H
STA 8405H

;initialize 3 memory locations to hold values of H,M,S
STA 8200H
STA 8201H
STA 8202H

;loop with delay to update the memory locations
CLOCKLOOP: NOP
INCSEC: NOP
LDA 8202h
INR A
CPI 3Ch
JNZ STORESEC
MVI A,00h
STORESEC: NOP
STA 8202h
CPI 00h
JNZ DISPLAYPROC

INCMIN: NOP
LDA 8201h
INR A
CPI 3Ch
JNZ STOREMIN
MVI A,00h

STOREMIN: NOP
STA 8201h
CPI 00h
JNZ DISPLAYPROC

INCHOUR: NOP
LDA 8200h
INR A
CPI 18h
JNZ STOREHOUR
MVI A,00h

STOREHOUR: NOP
STA 8200h
CPI 00h
JNZ DISPLAYPROC

DISPLAYPROC: NOP
; display the seconds
; determine the individual digits
; ten's place
MVI L, 0Ah
MVI H, 00h
PUSH H
LDA 8202h
MOV L,A
PUSH H
CALL DIVISION
POP H ; quotient
MOV A,L
STA 8404h
POP H ; remainder
MOV A,L
STA 8405h
MVI B,00H
MVI A,01H
LXI H,8404h
CALL 0389h ; OUTPUT

; display the minutes and hours
; minutes
MVI L, 0Ah
MVI H, 00h
PUSH H
LDA 8201h
MOV L,A
PUSH H
CALL DIVISION
; ten's place
POP H ; quotient
MOV A,L
STA 8402h
; one's place
POP H ; remainder
MOV A,L
STA 8403h
; hours
MVI L, 0Ah
MVI H, 00h
PUSH H
LDA 8200h
MOV L,A
PUSH H
CALL DIVISION
; ten's place
POP H ; quotient
MOV A,L
STA 8400h
; one's place
POP H ; remainder
MOV A,L
STA 8401h
MVI B,00H
MVI A,00H
LXI H,8400h
CALL 0389h ; OUTPUT
CALL DELAY
CALL DELAY
;before proceeding with the next clock iteration, check if
;the current time matches the alarm time set.
LDA 8405H
CMP 8415H
JNZ CLOCKLOOP
LDA 8404H
CMP 8414H
JNZ CLOCKLOOP
LDA 8403H
CMP 8413H
JNZ CLOCKLOOP
LDA 8402H
CMP 8412H
JNZ CLOCKLOOP
LDA 8401H
CMP 8411H
JNZ CLOCKLOOP
LDA 8400H
CMP 8410H
JNZ CLOCKLOOP
JMP ALARMDISPLAY
LHLD 8300H
PUSH H
RET

ALARMDISPLAY: NOP
MVI A,0AH
STA 8420H
MVI A,16H
STA 8421H
MVI A,0AH
STA 8422H
MVI A,1CH
STA 8423H
MVI A,17H
STA 8424H
MVI A,00H
MVI B,00H
LXI H,8420H
CALL 0389H ;OUTPUT
MVI A,01H
MVI B,00H
LXI H,8424H
CALL 0389H ;OUTPUT
JMP ALARMDISPLAY



;;; Delay ;;;;
;;;;;;;;;;;;;;


DELAY: NOP
LXI D, 000FH	;0FFFDH
DLOOP: NOP
DCX D
MOV A,D
ORA E
JNZ DLOOP
RET



;;; Division ;;;;
;;;;;;;;;;;;;;;;;


; 16-bit division. Number on the top of the stack is the dividend, followed by
; divisor.
; Returns the remainder and quotient on the stack.
DIVISION: NOP

; Get the return address and store in memory
POP H
SHLD 8302H

POP H ; Pop dividend from stack to HL
POP D ; Pop divisor from stack to DE
LXI B,0000H ; Set BC to 0

DIVloop: NOP
MOV A,L ; A <- L [copy the lower 8 bits ]
SUB E ; A = A - E [subtract the lower 8 bits ]
MOV L,A ; L <- A
MOV A,H ; A <- H [copy the higher 8 bits]
SBB D ; Subtract the higher 8 bits with borrow.
MOV H,A ; H <- A
INX B ; Increment B
JNC DIVloop ; If not carry (which occurs if the subtraction yielded a negative number) Jump to loop

DCX B ; Since we over-counted B, decrement B
DAD D ; Add DE to HL (makes it positive)
PUSH H	; Push remainder on stack
PUSH B ; Push quotient on stack

LHLD 8302H ; Read return address from memory
PUSH H ; Push return address on memory
RET ; Return

