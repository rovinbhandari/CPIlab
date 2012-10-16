cpu "8085.tbl"
hof "int8"

org 9000h




QUEUESTART: EQU 8200H
QUEUESIZE: EQU 8202H
QUEUEHEAD: EQU 8204H
QUEUETAIL: EQU 8206H
BOSSLOCATION: EQU 8601H

; initialize stack pointer
;LXI SP,7FFFH




;;;;;;;	BOSS FLOOR CONFIGURATIN ;;;;;;;;;;;;;;;;;;;
MVI A,00H
; store at the designated memory location
STOREBOSSLOCATION: STA BOSSLOCATION
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;




;;;;;;; CONFIGURE 8255   ;;;;;;;;;;;;;;;;;;;;;
MVI A, 8BH
OUT 43H
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;




;;;;;;;;  INITIAL CONFIGURATION OF THE LIFT  ;;;;;;;;;;;;;;;
; initial position of the lift
MVI H, 00H
MVI L, 01H
SHLD 8500H

; initial configuration of the floor bit vector
MVI A, 00H
STA 8600H
MVI A, 01H
OUT 40H
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;




;;;;;;;  INITIAL CONFIGURATION OF THE QUEUE  ;;;;;;;;;;;;;;
MVI H,80H
MVI L,00H

PUSH H
MVI H,00H
MVI L,10H
PUSH H
CALL QUEUEINIT 
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;




;;;;;; CONTINUOUSLY LOOP UNTIL THERE IS VALID VALUE IN THE QUEUE  ;;;;;;;;;;;;;;;;
WAITINPUT: NOP
MVI A, 00H
STA 890AH
CALL POLLING
;; TO INDICATE POLLING HAS ENDED
MVI A, 01H
STA 890AH

; check if the bit corresponding to boss floor is set
LDA BOSSLOCATION
MVI H, 00H
MOV L, A
; save reg values
PUSH H
;;;;;;;;;;;;;;;;;
PUSH H
CALL ISFLOORSET
POP D
;;;;;;;;;;;;;;;;
MOV A, E
CPI 01H

; retrieve saved reg values
POP H
JZ MOVELIFTSRCDEST
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;


CALL DEQUEUE ;returns the floor to move to by setting a bit in a byte.
POP H

SHLD 8800H ;dbg

MOV A, L
CPI 00H
JZ WAITINPUT

;;;;;;;;;;; check if the bit for this floor is set
; save reg values
PUSH H
;;;;;;;;;;;;;;;;
PUSH H
CALL ISFLOORSET
POP D
;;;;;;;;;;;;;;;
MOV A, E
CPI 01H

;retrieve saved reg values
POP H

JNZ WAITINPUT
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;





MOVELIFTSRCDEST: NOP
;;;;;;;  SET THE SOURCE AND DESTINATION FLOOR VALUES  ;;;;;;;;;;;;;;;;;
MVI B, H
MOV C, L
; so BC is the destination floor


LHLD 8500H
; so HL is the source floor

;; debug
SHLD 8902H

; move current destination floor to next source floor
MOV A, C
STA 8500H
MOV A, B
STA 8501H
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;




;; DEBUG
SHLD 8904H
MOV A, C
STA 8906H
MOV A, B
STA 8907H
;;;;;;;;;;




;;;;;;;;;;;;;;;;;;; STORE THE SIGN OF DESTINATION FLOOR - SOURCE FLOOR ;;;;;;;;;;;;;;;
; by default keep the sign bit as 1 ie lift source <= destination
MVI A, 01H
STA 8502H

MOV A, C
CMP L
JC HIGHTOLOW
JMP LOWTOHIGH
;;;;;;;;;;;;;;;;;;;;;;;;;;;

; change the sign bit to 0 if source < destination
HIGHTOLOW: NOP
LDA 8502H
SUI 01H
STA 8502H
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;






;;;;;;;;;;;;;;;;;;;;;;;;; ALGORITHM ;;;;;;;;;;;;;;;;;;;
; 1 - check if the current floor bit is set
; 2 - if the bit is set then RDLIFTBUTTON and reset the bit else skip RDLIFTBUTTON
; 3 - check if the destination floor has been reached
; 4 - if reached then jump to WAITINPUT else increment the floor number and glow the next LED
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;






;;;;;;;;;;;;;;;;;;;;;;   MAIN LOOP TO MOVE THE LIFT AND CHECK ALL CONDITIONS    ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
LOWTOHIGH: NOP
;RST 05H ; WORKING TILL HERE!
CHECKBOSSFLOOR: NOP
; check if the boss floor is set - CHECKFLOOR if it is not set
LDA BOSSLOCATION
PUSH H
PUSH B

;;;;;;;;;;;;;;;;
MOV L,A
PUSH H
CALL ISFLOORSET
POP H
;;;;;;;;;;;;;;;;

MOV A, L
CPI 01H

; retrieved saved reg values
POP B
POP H

JNZ CHECKFLOOR

;; check if the boss floor has been reached ;;;;;;
LDA BOSSLOCATION
CMP L
JZ MAKEBOSSFLOORZERO
; otherwise straighaway jump to MAKEDELAY
JMP MAKEDELAY
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
MAKEBOSSFLOORZERO: NOP
MVI A, 00H
STA BOSSLOCATION
JMP RDLIFTBUTTON


CHECKFLOOR: NOP
;; CHECK IF THE BIT IS SET FOR THIS FLOOR - IF IT IS SET THEN STOP THE LIFT HERE THAT IS RDLIFTBUTTON
; save register values
PUSH H
PUSH B

; argument; floor to be checked
PUSH H
CALL ISFLOORSET
; pop the result
POP H
;;;;;;;;;;;;;;

MOV A, L
CPI 01H

; retrieve saved reg values
POP B
POP H

; don't RDLIFTBUTTON if the floor bit is not set
JNZ CHECKDESTINATION





;; READ THE BUTTONS INSIDE THE LIFT IF THE LIFT HAS BEEN STOPPED ON THIS FLOOR
RDLIFTBUTTON: NOP

;; RESET THE BIT FOR THE CORRESPONDING FLOOR
; save reg values
PUSH H
PUSH B
;;;;;;;;;;;;;;;;;;
PUSH H
CALL RESETFLOORBIT
;;;;;;;;;;;;;;;;;;
; retrieve saved reg values
POP B
POP H

;; READ THE BUTTON INSIDE THE LIFT
;;CALL 03BAH ; RDKBD

;; DONT NECESSARILY READ BUTTON FROM INSIDE THE LIFT AS PEOPLE HERE MAY ONLY GET DOWN AND NOBODY MAY ENTER
;; SO EVEN IF THE BUTTON IS NOT PRESSED FROM INSIDE THE LIFT ON THIS FLOOR, THE LIFT SHOULD CONTINUE TO SERVER OTHER REQUESTS
;; BUT A SMALL DELAY SHOULD BE GIVEN IF SOMEONE WANTS TO GET INSIDE THE LIFT AND PRESS A BUTTON
PUSH H
PUSH B
CALL DELAY
CALL DELAY
POP B
POP H

;; CONVERT THE KEYBOARD INPUT TO BIT CONFIGURATION
;MOV E, A
;DCR E
;MVI A, 01H
;CONVERTLOOP: NOP
;MOV D, A
;MOV A, E
;CPI 00H
;MOV A, D
;JZ AFTERCONVERTLOOP
;DCR E
;RLC
;JMP CONVERTLOOP
;;;;;;;;;;;;;;;;;;;;;;;;;;

;AFTERCONVERTLOOP: NOP
;; debug
;STA 8909H ; BIT CONFIGURATION OF THE BUTTON PRESSED INSIDE THE LIFT

; save the floor value of the preseed button in DE
;MVI D, 00H
;MOV E, A

; check if the floor corresponding to pressed button is already set
;PUSH H
;PUSH B
;PUSH D

;;;;;;;;;;;;;;;
;PUSH D
;CALL ISFLOORSET
;POP H
;;;;;;;;;;;;;;;

;MOV A, L
;CPI 01H

;POP D
;POP B
;POP H

;; don't enqueue if the floor bit is already set
;JZ CHECKDESTINATION

;; ENQUEUE THE FLOOR NUMBER if its bit was not set
;PUSH H
;PUSH B
;PUSH D
;PUSH D

;;;;;;;;;;;;;
;PUSH D
;CALL ENQUEUE
;POP H
;;;;;;;;;;;;;

;; SET THE FLOOR BIT AS IT HAS BEEN ENQUEUED
;CALL SETFLOORBIT
;RST 05H
;POP H

;POP D
;POP B
;POP H
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;





;; CHECK IF THIS IS THE DESTINATION FLOOR AND JUMP TO WAITINPUT IF IT IS
CHECKDESTINATION: NOP
MOV A, L
CMP C
JZ WAITINPUT
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;





;; INTRODUCE DELAY - MOVE ONE STEP FORWARD - INCREMENT THE NEXT LED

;;;;;;;;;; introduce delay
MAKEDELAY: NOP
;RST 05H

; save reg values
PUSH B 
PUSH H

CALL DELAY

; retrieve saved reg values
POP H
POP B
;;;;;;;;;;;;;;;;;;;;;;;;

;;;;;;;;;;;;;;;;;;; STORE THE SIGN OF DESTINATION FLOOR - SOURCE FLOOR ;;;;;;;;;;;;;;;
; by default keep the sign bit as 1 ie lift source <= destination
MVI A, 01H
STA 8502H

LDA BOSSLOCATION
CPI 00H
JNZ SETSIGNBIT

MOV A, C

SETSIGNBIT: NOP
CMP L
JC BLINKLEDHIGHTOLOW
JMP ROTATE
;;;;;;;;;;;;;;;;;;;;;;;;;;;

; change the sign bit to 0 if source < destination
BLINKLEDHIGHTOLOW: NOP
LDA 8502H
SUI 01H
STA 8502H
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;


;;;;;;;;; move one step forward
ROTATE: NOP
LDA 8502H
CPI 00H
MOV A, L
JZ ROTATERIGHT

ROTATELEFT:
RLC
JMP BLINKLED

ROTATERIGHT:
RRC
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

;;;;;;  blink the next LED
BLINKLED: NOP
;;;  save the value of next floor into L
MOV L, A
OUT 40H
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;


;; CONTINUE IN THE LOOP
JMP LOWTOHIGH

;; TERMINATE THE PROGRAM
RST 05H 









;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;              FUNCTIONS                ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;



ISFLOORSET: NOP

POP H
SHLD 8700H

POP H
LDA 8600H
ANA L
JZ RETZERO

RETONE: NOP
MVI L, 01H
MVI	H, 00H
PUSH H
JMP RETISFLOORSET

RETZERO: NOP
MVI L, 00H
MVI	H, 00H
PUSH H

RETISFLOORSET: NOP
LHLD 8700H
PUSH H
RET




SETFLOORBIT: NOP
; save return address
POP H
SHLD 8700H

POP H ;SFB's input
LDA 8600H
ORA L
STA 8600H

; retrieve return address
LHLD 8700H
PUSH H
RET





RESETFLOORBIT: NOP
; save the return address
POP H
SHLD 8700H

POP H

LDA 8600H
XRA L
STA 8600H

; retrieve the return address
LHLD 8700H
PUSH H
RET





DELAY: NOP
LXI D, 01FFFH
DLOOP: NOP
PUSH D
;; TO INDICATE POLLING HAS STARTED
MVI A, 00H
STA 890AH
CALL POLLING
;; TO INDICATE POLLING HAS ENDED
MVI A, 01H
STA 890AH
POP D
DCX D
MOV A,D
ORA E
JNZ DLOOP
RET




POLLING: NOP
IN 41H 
CMA
;;dbg;;
MVI H, 00H
MOV L, A
SHLD 8806H
;;
CPI 00H
RZ

;; DEBUG
MVI A, 00H
STA 890EH
; check if the input is from the boss that is if the 8th bit in the input is set
MOV A, L
MVI C, 80H
ANA C
JZ NONBOSSINPUT

BOSSINPUT: NOP
; unset the 8th bit in the input
MVI A, 80H
CMA
ANA L
MOV L, A

; set boss location equivalent to this input
STA BOSSLOCATION
MVI A, 01H
STA 890EH

;JMP ENQUEUEINPUT
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;


NONBOSSINPUT: NOP
PUSH H ;has input

;PUSH B
;PUSH PSW

;; Call ISFLOORSET
PUSH H
CALL ISFLOORSET
POP D
;;  
;POP PSW
;POP B
POP H ;has input

SHLD 880AH ;dbg

MOV A, E
CPI 01H
RZ

ENQUEUEINPUT: NOP
SHLD 890CH
PUSH H
; Call enqueue
PUSH H
CALL ENQUEUE
POP H ;queue's exit flag ignored
;;
CALL SETFLOORBIT
RET





QUEUEINIT: nop
POP H
XCHG


POP H	   
SHLD QUEUESIZE 


POP H	
SHLD QUEUESTART 

MVI H,00H
MVI L,00H
SHLD QUEUEHEAD 
SHLD QUEUETAIL 

PUSH D
RET







ENQUEUE: nop

POP H 
SHLD 8300H

CALL QUEUEISFULL
POP H           
MOV A,L         
CPI 00H         
JZ NOTFULLLABEL

MVI H,00H
MVI L,01H
PUSH H
JMP ENQUEUERETLABEL

NOTFULLLABEL: nop

; Times enqueue has been called when it is not full
LHLD 8208H
INX H
SHLD 8208H

LHLD QUEUESTART
XCHG


LHLD QUEUETAIL


MVI B,00H
MVI C,02H

PUSH PSW
PUSH D
PUSH H

PUSH B
PUSH H
CALL MULTIPLICATION   

POP H       

POP B       
POP D 
POP PSW


DAD D     
PUSH H



INX B
LHLD QUEUESIZE  
;INX H       

PUSH PSW    
PUSH D
PUSH H

PUSH B
PUSH H
CALL REMAINDER


POP B       

POP H
POP D
POP PSW

MOV H,B     
MOV L,C     
SHLD QUEUETAIL

POP B	






POP D       





MOV A,E     



STAX B      
INX B       
MOV A,D     



STAX B     













MVI H,00H
MVI L,00H
PUSH H
ENQUEUERETLABEL: nop
LHLD 8300H
PUSH H
RET





DEQUEUE: nop
POP H
SHLD 8300H


CALL QUEUEISEMPTY
POP H       
MOV A,L     
CPI 00H   
JZ QUEUENOTEMPTYLABEL 
MVI H,00H   
MVI L,00H   
PUSH H      
JMP DEQUEUERETLABEL 

QUEUENOTEMPTYLABEL: nop

; Times dequeue has been called when it is not empty
LHLD 820AH
INX H
SHLD 820AH

LHLD QUEUEHEAD    
XCHG          


LHLD QUEUESTART    


PUSH H        
PUSH D        
PUSH PSW

MVI H,00
MVI L,02H
PUSH H
PUSH D
CALL MULTIPLICATION
POP B       

POP PSW     
POP D
POP H

DAD B



MOV B,H   
MOV C,L
LDAX B      
MOV L,A     
INX B       
LDAX B      
MOV H,A     
PUSH H      


INX D       
LHLD QUEUESIZE  
;INX H       


PUSH PSW
PUSH H
PUSH B

PUSH D
PUSH H
CALL REMAINDER

POP D

POP B
POP H
POP PSW

XCHG         
SHLD QUEUEHEAD   

DEQUEUERETLABEL: nop

LHLD 8300H   
PUSH H      
RET





QUEUEISEMPTY: nop
POP H
SHLD 8302H

LHLD QUEUEHEAD  
XCHG        
LHLD QUEUETAIL  

MOV A,H
CMP D
JNZ QUEUENOTEMPTY
MOV A,L
CMP E
JNZ QUEUENOTEMPTY


MVI H, 00H
MVI L, 01H
PUSH H
JMP QUEUEISEMPTYRETURNLABEL


QUEUENOTEMPTY: nop
MVI H,00H
MVI L,00H
PUSH H

QUEUEISEMPTYRETURNLABEL: nop
LHLD 8302H
PUSH H
RET








QUEUEISFULL: nop

POP H
SHLD 8304H  

LHLD QUEUETAIL  
INX H       
XCHG        
LHLD QUEUESIZE  
;INX H       
            

PUSH PSW
PUSH B
PUSH H

PUSH D      
PUSH H      
CALL REMAINDER

POP D       

POP H
POP B
POP PSW

LHLD QUEUEHEAD  

MOV A,H
CMP D
JNZ NOTSAMELABEL
MOV A,L
CMP E
JNZ NOTSAMELABEL


MVI H,00H
MVI L,01H
PUSH H
JMP QUEUEISFULLRETURNLABEL

NOTSAMELABEL: nop
MVI H,00H
MVI L,00H
PUSH H

QUEUEISFULLRETURNLABEL: nop
LHLD 8304H
PUSH H
RET






REMAINDER: MVI H,00H

POP H
SHLD 8302H
POP D       
POP H       
LXI B,0000H 
REMAINDERLOOP: MVI A,00H
MOV A,L     
SUB E       
MOV L,A     
MOV A,H     
SBB D       
MOV H,A     
INX B       
JNC REMAINDERLOOP    
DCX B       
DAD D       
PUSH H		
LHLD 8302H  
PUSH H      
RET         





MULTIPLICATION: nop


POP H
SHLD 8304H


POP B
POP D

MVI L,00H
MVI H,00H
loop: MVI A,00H
ORA B 
JNZ decr
ORA C
JZ exit
decr: DAD D
DCX B
JMP loop
exit: PUSH H
LHLD 8304H
PUSH H
RET
