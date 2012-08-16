; Store current state
PUSH PSW
PUSH B
PUSH D
PUSH H

; Load values into registers from memory
LHLD C090H   ; Load first number from memory location C090H to HL pair.
PUSH H       ; Push first number on the stack
LHLD C092H   ; Load second number from memory location C092H to HL pair.
PUSH H       ; Push second number on the stack

CALL GCD

; Get the result into Register HL
POP H

; Store the result into memory
SHLD C094H

; Restore last state
POP H
POP D
POP B
POP PSW

HLT

; 16-bit GCD.
; number on the top of the stack (smaller number) goes to DE pair; the lower number (bigger number) goes to BC pair.
; returns the answer on the stack.
GCD: NOP

; Get the return address and store in memory
POP H
SHLD C0A0H

POP H
XCHG
POP H
MOV C,L
MOV B,H
MVI H,00H
MVI L,00H
LOOP: MOV A, B
ORA C
JZ DECREMENT
JZ STORERESULT
DECREMENT: DAD D
DCX B
JMP LOOP
; Store current state
PUSH PSW
PUSH B
PUSH D
PUSH H

; Load values into registers from memory
LHLD 9050H   ; Load divisor from memory location C050 to HL pair.
PUSH H       ; Push divisor on the stack
LHLD 9052H   ; Load dividend from memory location C052 to HL pair.
PUSH H       ; Push dividend on the stack

CALL DIVISION

; Get the quotient into Register HL
POP H

; Store the quotient into memory
SHLD 9054H

; Get the remainder into Register HL
POP H

; Store the remainder into memory
SHLD 9056H

; Restore last state
POP H
POP D
POP B
POP PSW


STORERESULT: PUSH H
LHLD C0A0H
PUSH H
RET
