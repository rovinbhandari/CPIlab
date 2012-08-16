cpu "8085.tbl"
hof "int8"

org 8000h

; Store current state
PUSH PSW
PUSH B
PUSH D
PUSH H

; Load values into registers from memory
LHLD 9000H   ; Load first number from memory location C090H to HL pair.
PUSH H       ; Push first number on the stack
LHLD 9002H   ; Load second number from memory location C092H to HL pair.
PUSH H       ; Push second number on the stack

CALL GCD

; Get the result into Register HL
POP H

; Store the result into memory
SHLD 9004H

; Restore last state
POP H
POP D
POP B
POP PSW

RST 05

; 16-bit GCD.
; number on the top of the stack (smaller number) goes to DE pair; the lower number (bigger number) goes to BC pair.
; returns the answer on the stack.
GCD: MVI H,00H
; Get the return address and store in memory
POP H
SHLD 9050H
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
PUSH D
PUSH B
CALL REMAINDER
POP D
POP B
POP H
POP PSW
JMP GCDLOOP
STORERESULT: PUSH B
LHLD 9050H
PUSH H
RET

REMAINDER: MVI H,00H
; Get the return address and store in memory
POP H
SHLD 9060H
POP H       ; Pop dividend from stack to HL
POP D       ; Pop divisor from stack to DE
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
LHLD 9060H  ; Read return address from memory
PUSH H      ; Push return address on memory
RET         ; Return
