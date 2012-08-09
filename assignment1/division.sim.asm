  LHLD C050   ; Load divisor from memory location C050 to HL pair.
  XCHG        ; Transfer divisor from HL pair to DE pair
  LHLD C052   ; Load dividend from memory location C052 to HL pair.
  LXI B,0000H ; Set BC to 0
loop:
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
  SHLD C054   ; Puts remainder at C054  
  MOV A,C     ; A <- C
  STA C056    ; Store lower 8 bits to memory location
  MOV A,B     ; A <- B
  STA C057    ; Store higher 8 bits to memory location
  HLT
