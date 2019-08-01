;*************************************
;Copyright(c) 2015 Joseph L'ingenieur
;All right reserved.
;*************************************

	
	list p=16F870
	#include "p16F870.inc"


; Registers needed to operate this task
	Xl		EQU		0X20	
	Xh		EQU		0X21
	Yl		EQU		0X22
	Yh		EQU		0X23
	Zl		EQU		0X24
	TempYl	EQU		0X26
	TempYh	EQU		0X27
	Shifts	EQU		0X28	



;******* Example test : 30000 / 5000 **********
;
;d 30000 = b01110101_00110000 = 0X75_30
;
;			0X75	112 * 2^8 = 29952
;			0X30			  =____48 +
;							  = 30000
;
;d 5000	= b00010011_10001000 = 0X13_88
;
;			0X13	19  * 2^8 = 4864
;			0X88			  =__136 +
;							  = 5000

	MOVLW	0XEA	
	MOVWF	Xh

	MOVLW	0X60
	MOVWF	Xl

	MOVLW	0X27
	MOVWF	Yh

	MOVLW	0X10 
	MOVWF	Yl


;********** Start*********

;16 bits numerator will go in: Xl, Xh
;16 bits denominator will go in: Yl, Yh
;We store the answer in: Zl, W_register
;We store remainder number in: Xl. 
;if remainder is 16bit : Xl, Xh
;if divided by 0 output will be : 0


											
	MOVF 	Yl, 0
	MOVWF	TempYl
	MOVF 	Yh, 0
	MOVWF	TempYh					

	CLRF	Zl						
	MOVLW 	0X01					
	MOVWF	Shifts					

	MOVF	Yl, 1
	BTFSS	STATUS, Z
	GOTO	XminYtest					

	MOVF	Yh, 1
	BTFSS	STATUS, Z
	GOTO	XminYtest				
	
	MOVLW	0x00
	GOTO	Eind					


	XminYtest:
		MOVF	TempYl, 0
		BSF 	STATUS, C
		SUBWF	Xl, 0				;Xl - Yl

		MOVF	TempYh, 0
		BTFSS	STATUS, C
		INCF	TempYh, 0			;Yh + 1 bij, Xl < Yl 
		
		BSF 	STATUS, C
		SUBWF	Xh, 0				;Xh - Yh
		
		BTFSC	STATUS, C						
		GOTO	Ymul2				;Y*2 bij, X >= Y		
		GOTO	Ydiv2				;Y:2 bij, X < Y							

	Ymul2:		
		BCF		STATUS, C			;clear carry to avoid undesired bits
		RLF		TempYl, 1			
		RLF		TempYh, 1 			
		BTFSC	STATUS, C
		GOTO	OverFlow
		BCF		STATUS, C			
		RLF		Shifts, 1			
		GOTO 	XminYtest			
		
	Ydiv2:		
		DECF	Shifts, 1			
		BTFSC	STATUS, Z
		GOTO	Eind				

		INCF	Shifts, 1			
		BCF		STATUS, C			
		RRF 	Shifts, 1			;Shifts / 2 because y is bigger than x (y>X) 
		BCF		STATUS, C			
		RRF		TempYh, 1			
		RRF		TempYl, 1			;Yh / 2 (if Yh has a carry: Yl + 128)	
		GOTO	XminY				
		
	OverFlow:	
		RRF		TempYh, 1
		RRF		TempYl, 1  
		
	XminY:
		MOVF	TempYl, 0
		BSF 	STATUS, C
		SUBWF	Xl, 1				

		BTFSS	STATUS, C
		INCF 	TempYh, 1
					 
		MOVF	TempYh, 0
		BSF 	STATUS, C		
		SUBWF	Xh, 1

		MOVF	Yl, 0
		MOVWF	TempYl
		MOVF	Yh, 0
		MOVWF	TempYh
		
		MOVF	Shifts, 0				
		ADDWF	Zl, 1
		MOVLW	0X01				
		MOVWF	Shifts  			;Reset Shifts to 1		
		
		GOTO	XminYtest			
			
	Eind:

		MOVF	Zl, 0

		Return	

	End																