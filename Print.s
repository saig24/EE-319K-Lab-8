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
NUM EQU		10000	
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
	MOV R12,R14
	MOV R1,#0
	PUSH {R1}
	MOV R3,#10
Loop	
	UDIV R1,R0,R3
	MUL R2,R1,R3
	SUB R2,R0,R2
	ADD R2,#0x30
	PUSH {R2}
	MOV R0,R1
	CMP R0,#0
	BNE Loop
	
Next  
	POP {R0}
	CMP R0,#0
	BEQ Done
	BL  ST7735_OutChar
	B   Next
	  
Done	
	MOV R14,R12

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
	LDR R1,=NUM
	CMP R0, R1
	BHS Large

	MOV R3, #10
	MOV R12, #4
NZero
    UDIV R1, R0, R3
	MUL R2, R1, R3
	SUB R2, R0, R2
	ADD R2, #0x30
	PUSH {R2}
	MOV R0, R1
	SUBS R12, #1
	BNE NZero  

	MOV R12,R14
	POP {R0}
	BL ST7735_OutChar
	LDR R0, =0x2E
	BL ST7735_OutChar
	POP {R0}
	BL ST7735_OutChar
	POP {R0}
	BL ST7735_OutChar
	POP {R0}
	BL ST7735_OutChar
	MOV R14,R12

	BX LR
Large
	LDR R0, =0x2A
	MOV R12,R14
	BL ST7735_OutChar
	LDR R0, =0x2E
	BL ST7735_OutChar
	LDR R0, =0x2A
	BL ST7735_OutChar
	LDR R0, =0x2A
	BL ST7735_OutChar
	LDR R0, =0x2A
	BL ST7735_OutChar
	MOV R14,R12
	
    BX   LR
 
    ALIGN
;* * * * * * * * End of LCD_OutFix * * * * * * * *

	ALIGN                           ; make sure the end of this section is aligned
    END                             ; end of file