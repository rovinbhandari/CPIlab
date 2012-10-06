cpu "8085.tbl"
hof "int8"

org 9000h

; Program to simulate the behaviour of a lift (elevator) using 8255

MVI A,8BH  ; Configure 8255
OUT 43H

;TODO: add an interrupt service routine to let boss' secretary enter the
; boss' current floor. //PG

;WAITINPUT and POLLING are coupled subroutines.

WAITINPUT: NOP ;while there is no input, keep calling POLLING (inside DELAY).
CALL DELAY
CALL DEQUEUE ;returns the floor to move to by setting a bit in a byte.
POP A ;TODO: check if it will work. //RB, RK
JZ WAITINPUT

; WHEN THE LIFT STARTS FOR THE FIRST TIME
; =======================================

; 1. initialize the current floor to 00h
MVI A, 00H
STA 8500H

; 2. read the input directly from 8255 input port
; RDIN: IN 41H; 
; CMA
; JMP VALIDATEINPUT


; WHEN THE LIFT IS IN THE MIDDLE OF OPERATION
; ===========================================

RDQUE: CALL DEQUEUE
POP H
MOV A, L

; ASSUMPTION ABOUT THE QUEUE
; ==========================

; It is assumed that the queue function skips those floor numbers which have already been served out of order; that is skip if the corresponding bit is not set
; The queue should push a new floor number only if the corresponding bit is not set
; The queue should return 0 in case it is empty
; The queue should not push when no button is pressed
; The queue should store the bit configuration of a floor and not the floor number

; CHECK THE FLOOR NUMBER FOR SPECIAL VALUES
; =========================================

; jump to reading the queue if the floor number is 0; 0 indicates the queue is empty
;ADI 01H
JZ RDIN

; jump to the end of lift operation if floor number is 0; 0 indicates end of lift operation; effective when beginning lift operation
; CPI 00H
; JZ READKBD


; ALGORITHM:
; ==========

; When the lift stops at a floor, there are following priorities:
; 1. The next floor number in the request queue
; 2. The floor numbers to which the people inside the lift want to go currently:
;     a. the lift might have stopped at other floors previously and the then requests of people inside the lift may not yet have been served
;     b. all the people who enter the lift at a floor all may have different requests
;
; But this will become extremely complicated.

; SOLUTION 1:
; 1. take a simple path where the buttons pressed inside the lift are also pushed into the same request queue
; 2. at every floor in the way, stop if the corresponding bit is set

; ?? whether to stop the lift at intermediate floors which might not be the next in the queue ??
; this has a little bug which needs to be resolved:
; suppose at a certain point in time, the request queue is: 1 5 3 6   ; where 1 is the earliest request. then moving from 1 to 5, the lift reaches floor 3 and checks the 
; Corresponding bit and finds it set. So it stops at 3 and unsets it, but the number 3 is not removed from the queue. Then the lift moves from 3 to 5 and during then a request 
; for 3 is received again and since the corresponding bit is not set, 3 is pushed in the queue and the corresponding bit is set. So the queue becomes: 3 6 3. After the lift 
; reaches 5, it again pops 3 from the queue and since the corresponding is set (because of the second 3), 3 becomes the next destination. But the corresponding request for 3 
; that ;has been popped has already been served. The corresponding bit was set at this point because of the second 3 in the queue. So, we see that the second 3, though later 
; than 6 in the queue, gets to be served first without any reason (as the lift which was moving from 1 to 5 should have now moved to 6, but will now move down towards 3 first).


; at this point, A contains the value of the next floor number
MOV B, A

; read current floor number from the memory location 8500h
LDA 8500H
MOV H, A

; save the next floor number as the current floor number at the memory location 8500h
MOV A, B
STA 8500H


; now move the lift from floor in H to floor in B
CPM B

JNC HIGHTOLOW

LOWTOHIGH: NOP

; read from buttons inside the lift if the next floor has been reached; buttons inside lift have been simulated using keyboard on MPS kit
MOV A, H
CMP B
JZ RDLIFTBUTTON

; move the lift one floor up; i.e. blink the next LED
MOV A, H
RLC
MOV H, A
OUT 40H

; check if the corresponding bit is set for the current floor stored in h
; save values of H and B
MOV A, H
STA 8501H
MOV A, B
STA 8502H

; call function to check if the floor bit is set
MOV L, H
MVI H, 00H
PUSH H
CALL ISFLOORSET

; read back the saved values of H and B, as they will be required in the next iteration
LDA 8501H
MOV H, A
LDA 8502H
MOV B, A

; read from buttons inside the lift if the corresponding floor bit is set
JNZ RDLIFTBUTTON

; at this point, we are sure that the lift is not to be opened and thus we don't need to read buttons from inside the lift; so give some delay
PUSH B ;because DELAY (and its nested subroutines) might change B.
PUSH H ;because DELAY (and its nested subroutines) might change H.
CALL DELAY
POP H
POP B

; read from buttons inside the lift
RDLIFTBUTTON: NOP
CALL 03BAH ; RDKBD

; push the value read from buttons inside the lift into the request queue
MOV L, A
MVI H, 00H
PUSH H
CALL ENQUEUE

; check if the next floor has been reached; read the values of H and B again and compare them
LDA 8501H
MOV H, A
LDA 8502H
CMP H
JZ RDQUE
JMP LOWTOHIGH

HIGHTOLOW: NOP

JMP RDIN ; read the queue once again

READKBD: CALL 03BAH ; RDKBD	
CPI 1DH	; Compare with "EXEC"
JZ RDIN ; If pressed goto SEN


RST 05H ; otherwise return to monitor


;;; Delay ;;;;
;; Polling ;;;

DELAY: NOP
CALL POLLING
LXI D, 0CFFFH
DLOOP: NOP
DCX D
MOV A,D
ORA E
JNZ DLOOP

POLLING: NOP
IN 41H ;Read the input 
CMA
CPI 00H
RZ
PUSH A
CALL ENQUEUE
RET

