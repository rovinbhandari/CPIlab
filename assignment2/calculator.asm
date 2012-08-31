cpu "8085.tbl"
hof "int8"

org 8000h

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

LHLD 9050h ; Load first argument from 9050h
PUSH H

; now read the operator
LDA 9049h

ADDLABEL: SUI 01h
JNZ SUBLABEL

LHLD 9052h
PUSH H

CALL ADDITION

;get result
POP H
;store result in mem
SHLD 8400H
JMP EXITPROG


SUBLABEL: SUI 01h
JNZ MULLABEL

LHLD 9052h
PUSH H

CALL SUBTRACTION

;get result
POP H
;store result in mem
SHLD 8400H
JMP EXITPROG

MULLABEL: SUI 01h
JNZ DIVLABEL

LHLD 9052h
PUSH H

CALL MULTIPLICATION

;get result
POP H
;store result in mem
SHLD 8400H
JMP EXITPROG

DIVLABEL: SUI 01h
JNZ GCDLABEL

LHLD 9052h
PUSH H

CALL DIVISION

;get result
POP H
;store result in mem
SHLD 8400H
JMP EXITPROG

GCDLABEL: SUI 01h
JNZ MODLABEL

; Load values into registers from memory
LHLD 9052h   ; Load second number from memory location C092H to HL pair.
PUSH H       ; Push second number on the stack

CALL GCD

; Get the result into Register HL
POP H

; Store the result into memory
SHLD 8400h

MODLABEL: SUI 01h
JNZ EXITPROG

LHLD 9052h
PUSH H

CALL REMAINDER

;get result
POP H
;store result in mem
SHLD 8400H
JMP EXITPROG

;restore state
EXITPROG: POP H
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
JNC STORERESULTADD
INR C
STORERESULTADD: MOV A,C
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


MULTIPLICATION: nop

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

POP D       ; Pop dividend from stack to HL
POP H       ; Pop divisor from stack to DE
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



;;;GCD;;;;;
;;;;;;;;;;;

; 16-bit GCD.
; number on the top of the stack (smaller number) goes to DE pair; the lower number (bigger number) goes to BC pair.
; returns the answer on the stack.
GCD: MVI H,00H
; Get the return address and store in memory
POP H
SHLD 8300H
POP H
XCHG
POP H
MOV C,L
MOV B,H
MVI H,00H
MVI L,00H
GCDLOOP: MOV A,D
ORA E
JZ STORERESULT
PUSH PSW
PUSH H
PUSH D
PUSH B
PUSH D
CALL REMAINDER
POP D
POP B
POP H
POP PSW
JMP GCDLOOP
STORERESULT: PUSH B
LHLD 8300H
PUSH H
RET

;;;MOD;;;;;
;;;;;;;;;;;

; 16-bit modulo
REMAINDER: MVI H,00H
; Get the return address and store in memory
POP H
SHLD 8302H
POP D       ; Pop divisor from stack to DE
POP H       ; Pop dividend from stack to HL
LXI B,0000H ; Set BC to 0
REMAINDERLOOP: MVI A,00H
MOV A,L     ; A <- L [copy the lower 8 bits ]
SUB E       ; A = A - E [subtract the lower 8 bits ]
MOV L,A     ; L <- A
MOV A,H     ; A <- H [copy the higher 8 bits]
SBB D       ; Subtract the higher 8 bits with borrow.
MOV H,A     ; H <- A
INX B       ; Increment B 
JNC REMAINDERLOOP    ; If not carry (which occurs if the subtraction yielded a negative number) Jump to loop
DCX B       ; Since we over-counted B, decrement B
DAD D       ; Add DE to HL (makes it positive)
PUSH H		; Push remainder on stack
LHLD 8302H  ; Read return address from memory
PUSH H      ; Push return address on memory
RET         ; Return

