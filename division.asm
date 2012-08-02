  LXI H,C050
  MOV C,M
  LXI H,C051
  MOV B,M
  LXI H,C052
  MOV E,M
  LXI H,C053
  MOV D,M
  MVI L,00
  MVI H,00
loop:
  MOV A,B
  CMP D
  JC EXIT
  JNC check
subt:
  MOV A,C
  SUB E
  MOV C,A
  MOV A,B
  SBB D
  MOV B,A
  INX H
  JMP loop
check:
  MOV A,C
  CMP E
  JC exit
  JMP subt
exit:
  SHLD C054
  HLT
