; Store current state
PUSH PSW
PUSH B
PUSH D
PUSH H

; Load values into registers from memory
LHLD 9050H   ; Load multiplier from memory location C050 to HL pair.
PUSH H       ; Push multiplier on the stack
LHLD 9052H   ; Load multiplicand from memory location C052 to HL pair.
PUSH H       ; Push multiplicand on the stack

CALL MULTIPLY

; Get the result into Register HL
POP H

; Store the result into memory
SHLD 9054H

; Restore last state
POP H
POP D
POP B
POP PSW

RST 05        ; Restore to monitor

LHLD C050H
MOV C,L
MOV B,H
LHLD C052H
XCHG
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
STORERESULT: SHLD C054H
RST 5
