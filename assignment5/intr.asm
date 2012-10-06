cpu "8085.tbl"
hof "int8"

org 8000H

; Program to capture RDKBD interrupt

PUSH PSW

INTR: NOP
CALL 03BAh; RDKBD

POP PSW
EI
RET
