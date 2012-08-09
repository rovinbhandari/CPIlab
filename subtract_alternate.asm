;LHLD C050
;XCHG 
;LHLD C052 
;MOV A,E 
;SUB L 
;MOV L,A 
;MOV A,D 
;SBB H 
;MOV H,A 
;SHLD C054 
;HLT 

; Not tested/verified yet.

  LHLD C050 ; Load from C050
  XCHG      ; DE <- HL (rather, ED <- LH)
  LHLD C052 ; Load from C052  
  MOV A,L   ; A <- L
  SUB E     ; A = A - E
  MOV L,A   ; L <- A
  MOV A,H   ; A <- H
  SBB D     ; Subtract with borrow.
  MOV H,A   ; H <- A
  SHLD C054 ; Store result back to the memory
