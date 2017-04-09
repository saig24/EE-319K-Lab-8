; Print.s
; Student names: John Sigmon and Neel Kattumadam
; Last modification date: change this to the last modification date or look very silly
; Runs on LM4F120 or TM4C123
; EE319K lab 7 device driver for any LCD
;
; As part of Lab 7, students need to implement these LCD_OutDec and LCD_OutFix
; This driver assumes two low-level LCD functions
; ST7735_OutChar   outputs a single 8-bit ASCII character
; ST7735_OutString outputs a null-terminated string 

DATA EQU	0
	
    IMPORT   ST7735_OutChar
    IMPORT   ST7735_OutString
    EXPORT   LCD_OutDec
    EXPORT   LCD_OutFix

    AREA    |.text|, CODE, READONLY, ALIGN=2
	PRESERVE8
    THUMB

  

;-----------------------LCD_OutDec-----------------------
; Output a 32-bit number in unsigned decimal format
; Input: R0 (call by value) 32-bit unsigned number
; Output: none
; Invariables: This function must not permanently modify registers R4 to R11
LCD_OutDec

	PUSH {R4-R11,LR}			; save registers
	
	MOV R4, #0
	PUSH {R0,R4}				; Allocation - push input and zero onto stack
	MOV R11, SP					; R11 = frame pointer

	CMP R0, #0					; input == 0?
	BNE Stack_Use				; if not, continue to save digits in stack
	PUSH {R0}					; if yes, push onto stack and skip saving more
	B Print_1
	
Stack_Use						; use stack because no set amount of digits unlike next subroutine
	LDR R4, [R11,#DATA]
	CMP R4, #0					; check if done (data = 0)
	BEQ Print_1					; exit subroutine
	MOV R5, #10
	UDIV R5, R4, R5				; data = data/10
	STR R5, [R11,#DATA]

	MOV R6, #10
	MUL R5, R6
	
	SUB R4,R4,R5				; d = data%10
	PUSH {R4}					; push remainder on stack
	B	Stack_Use
	
Print_1
	POP {R0}					; pop remainders out backwards
	ADD R0, #0x30				; convert to ASCII
	BL ST7735_OutChar
	CMP SP, R11					; check if done popping (SP back at local variables)
	BNE Print_1
	ADD SP, #8					; DeAllocation
	
	POP {R4-R11,LR}			; restore registers
	
    BX  LR
	
	
;* * * * * * * * End of LCD_OutDec * * * * * * * *

; -----------------------LCD _OutFix----------------------
; Output characters to LCD display in fixed-point format
; unsigned decimal, resolution 0.001, range 0.000 to 9.999
; Inputs:  R0 is an unsigned 32-bit number
; Outputs: none
; E.g., R0=0,    then output "0.000 "
;       R0=3,    then output "0.003 "
;       R0=89,   then output "0.089 "
;       R0=123,  then output "0.123 "
;       R0=9999, then output "9.999 "
;       R0>9999, then output "*.*** "
; Invariables: This function must not permanently modify registers R4 to R11
LCD_OutFix

	PUSH {R4-R11, LR}			
	
	MOV R4, #0
	PUSH {R0,R4}				; push R0 and zero
	MOV R11, SP					; set r11 to frame pointer
	
	LDR R4, [R11, #DATA]
	MOV R5, #1000	; data/1000 --> start by calculating most sig digit
	UDIV R4,R5
	CMP R4, #9		; check for overflow
	BGT overflow
	
	ADD R4, #0x30		
	MOV R0, R4
	BL ST7735_OutChar	; display ones place value
	
	LDR R4, [R11, #DATA]
	MOV R6, #1000
	UDIV R5, R4, R6
	MUL R5, R6
	SUB R4,R4,R5			; calculate data%1000
	STR R4, [R11, #DATA]	; store remainder in "data"
	
	MOV R0, #0x2E			; print decimal point
	BL ST7735_OutChar
	
	LDR R4, [R11, #DATA]
	MOV R6, #100			; data/100
	UDIV R4,R6
	ADD R4, #0x30			
	MOV R0, R4
	BL ST7735_OutChar		; display tenths place value
	
	LDR R4, [R11, #DATA]
	MOV R6, #100
	UDIV R5, R4, R6
	MUL R5, R6
	SUB R4,R4,R5			; calculate data%100
	STR R4, [R11, #DATA]	; store remainder 
	
	LDR R4, [R11, #DATA]	;divides input by 10
	MOV R6, #10				;
	UDIV R4,R6		
	ADD R4, #0x30			
	MOV R0, R4
	BL ST7735_OutChar		; 
	
	LDR R4, [R11, #DATA]
	MOV R6, #10
	UDIV R5, R4, R6
	MUL R5, R6
	SUB R4,R4,R5			; calculate data%10
	STR R4, [R11, #DATA]	; store remainder in "data"

	LDR R4, [R11, #DATA]	; remaining information in "data" is last digit
	ADD R4, #0x30			; convert to ASCII
	MOV R0, R4
	BL ST7735_OutChar		; 
	
	B Break
	
overflow					; display "*.***" if input is greater than 9999
	MOV R0, #0x2A
	BL ST7735_OutChar		; *
	MOV R0, #0x2E
	BL ST7735_OutChar		; .
	MOV R0, #0x2A
	BL ST7735_OutChar		; *
	MOV R0, #0x2A
	BL ST7735_OutChar		; *
	MOV R0, #0x2A
	BL ST7735_OutChar		; *

Break
	ADD SP, #8				; de allocate space
	POP {R4-R11, LR}		; restore registers
    BX   LR
    BX   LR
 
    ALIGN
;* * * * * * * * End of LCD_OutFix * * * * * * * *

	ALIGN                           ; make sure the end of this section is aligned
    END                             ; end of file
