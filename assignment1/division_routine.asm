cpu "8085.tbl"
hof "int8"

org 9000h

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

RST 05        ; Restore to monitor

; 16-bit division. Number on the top of the stack is the dividend, followed by 
; divisor.
; Returns the remainder and quotient on the stack.
DIVISION: NOP

; Get the return address and store in memory
POP H
SHLD 8300H

POP H       ; Pop dividend from stack to HL
POP D       ; Pop divisor from stack to DE
LXI B,0000H ; Set BC to 0

loop: NOP
MOV A,L     ; A <- L [copy the lower 8 bits ]
SUB E       ; A = A - E [subtract the lower 8 bits ]
MOV L,A     ; L <- A
MOV A,H     ; A <- H [copy the higher 8 bits]
SBB D       ; Subtract the higher 8 bits with borrow.
MOV H,A     ; H <- A
INX B       ; Increment B 
JNC loop    ; If not carry (which occurs if the subtraction yielded a negative number) Jump to loop

DCX B       ; Since we over-counted B, decrement B
DAD D       ; Add DE to HL (makes it positive)
PUSH H		; Push remainder on stack
PUSH B      ; Push quotient on stack

LHLD 8300H  ; Read return address from memory
PUSH H      ; Push return address on memory
RET         ; Return
