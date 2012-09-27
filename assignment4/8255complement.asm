cpu "8085.tbl"
hof "int8"

org 9000h

; Program to complement the input at B (on 8255) and display it at A
; at the press of "EXEC"

MVI A,8BH  ; Configure 8255
OUT 43H	   
SEN: IN 41H; Read the input 
CMA		   ; Complement the read value	
OUT 40H	   ; Output to Port A of 8255	
IN 50H	   ; Read DIP switch 	
CALL 03BAH ; RDKBD	
CPI 1DH	; Compare with "EXEC"
JZ SEN	; If pressed goto SEN
RST 05H ; otherwise return to monitor

