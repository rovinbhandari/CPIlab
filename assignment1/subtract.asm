cpu "8085.tbl"
hof "int8"

org 9000h

LHLD 9050h ; Load from C050
XCHG      ; DE <- HL (rather, ED <- LH)
LHLD 9052h ; Load from C052  
MOV A,L   ; A <- L
SUB E     ; A = A - E
MOV L,A   ; L <- A
MOV A,H   ; A <- H
SBB D     ; Subtract with borrow.
MOV H,A   ; H <- A
SHLD 9054h ; Store result back to the memory
RST 05