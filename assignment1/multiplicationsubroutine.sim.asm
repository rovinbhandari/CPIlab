; Store current state
PUSH PSW
PUSH B
PUSH D
PUSH H

; Load values into registers from memory
LHLD C090H   ; Load multiplier from memory location C090H to HL pair.
PUSH H       ; Push multiplier on the stack
LHLD C092H   ; Load multiplicand from memory location C092H to HL pair.
PUSH H       ; Push multiplicand on the stack

CALL MULTIPLY

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

; 16-bit division.
; number on the top of the stack goes to DE pair; the lower number goes to BC pair.
; returns the answer on the stack.
; TODO: add functionality to accomodate the overflowed bits (> 16 bits) in answer.
MULTIPLY: NOP

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
LOOP: MVI A,00H
ORA B
JNZ DECREMENT
ORA C
JZ STORERESULT
DECREMENT: DAD D
DCX B
JMP LOOP
STORERESULT: PUSH H
LHLD C0A0H
PUSH H
RET
