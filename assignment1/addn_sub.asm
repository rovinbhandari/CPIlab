cpu "8085.tbl"
hof "int8"

org 9000h

;<Program title>

JMP START

;data


;code
START: NOP


;store current state
PUSH PSW
PUSH B
PUSH D
PUSH H

;push args for addition arg1 + arg2
;arg2
MVI H , 02H
MVI L , 00H
PUSH H
;arg1
MVI H , 04H
MVI L , 00H
PUSH H

CALL DIVISION

;get result
POP H
;store result in mem
SHLD 8200H

;restore state
POP H
POP D
POP B
POP PSW


RST 5




;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;  SUBROUTINES ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;


;;; Addition ;;;;
;;;;;;;;;;;;;;;;;

ADDITION: nop

;pop the return address
POP H
SHLD 8300H

;get arguments (numbers)
POP D
POP H

MVI C,00h
DAD D
JNC STORERESULT
INR C
STORERESULT: MOV A,C
STA 9056h

;put answer on stack
     PUSH H
;push the return address back
     LHLD 8300H
     PUSH H
RET


;;; Subtraction ;;;;
;;;;;;;;;;;;;;;;;;;;


SUBTRACTION: nop

;pop the return address
POP H
SHLD 8300H

;get arguments (numbers)
POP D
POP H

MOV A,L   ; A <- L
SUB E     ; A = A - E
MOV L,A   ; L <- A
MOV A,H   ; A <- H
SBB D     ; Subtract with borrow.
MOV H,A   ; H <- A

PUSH H
LHLD 8300H
PUSH H
RET


;;; Multiplication ;;;;
;;;;;;;;;;;;;;;;;;;;;;;


MULTI: nop

;pop the return address
POP H
SHLD 8300H

;get arguments (numbers)
POP B
POP D

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
exit: PUSH H
LHLD 8300H
PUSH H
RET


;;; Division ;;;;
;;;;;;;;;;;;;;;;;


DIVISION: NOP

; Get the return address and store in memory
POP H
SHLD 8300H

POP H       ; Pop dividend from stack to HL
POP D       ; Pop divisor from stack to DE
LXI B,0000H ; Set BC to 0

loopD: NOP
MOV A,L     ; A <- L [copy the lower 8 bits ]
SUB E       ; A = A - E [subtract the lower 8 bits ]
MOV L,A     ; L <- A
MOV A,H     ; A <- H [copy the higher 8 bits]
SBB D       ; Subtract the higher 8 bits with borrow.
MOV H,A     ; H <- A
INX B       ; Increment B 
JNC loopD    ; If not carry (which occurs if the subtraction yielded a negative number) Jump to loop

DCX B       ; Since we over-counted B, decrement B
DAD D       ; Add DE to HL (makes it positive)
PUSH B      ; Push quotient on stack

LHLD 8300H  ; Read return address from memory
PUSH H      ; Push return address on memory
RET         ; Return