;;;=============================================
;;; PIC Trainer analog support
;;;  #include _after_ defining code origin!
;;;=============================================

;;;---------------------------------------------
;;; initialise ADC and DAC for PIC trainer board use
;;;---------------------------------------------
analog_init:
    clrf  TRISD         ; DAC data outputs
    movlw b'00001111'   ; RA5.. RA4 as output (DAC) RA3 .. RA0 as inputs (ADC)
    movwf TRISA
    movlw b'01000010'   ; left justify, FOSC/16, AN3 .. AN0 analog
    movwf ADCON1
    movlw b'01000001'   ; FOSC/16, AN0, on
    movwf ADCON0
    movlw b'00110000'   ; DAC inactive
    movwf LATA
    return

;;;---------------------------------------------
;;; Write WREG to analog output
;;; Multiple entry points for DAC A, DAC B
;;;---------------------------------------------

;;; write WREG to analog output A
DAC_A:  
    bcf LATA, 5                 ; 0 = channel A
    bra do_DAC

;;; write WREG to analog output B
DAC_B:  
    bsf LATA, 5                 ; 1 = channel B
    bra do_DAC

;;; common DAC helper
do_DAC: 
    movwf PORTD
    bcf LATA, 4
    bsf LATA, 4
    return

;;;---------------------------------------------
;;; Read analog input channel to WREG
;;; Multiple entry points for AN0, AN1, AN2
;;;---------------------------------------------

;;; read AN0 to WREG
ADC_0:  
    movlw b'01000001'           ; channel 0, FOSC/16
    movwf ADCON0
    goto do_ADC

;;; read AN1 to WREG
ADC_1:  
    movlw b'01001001'           ; channel 1, FOSC/16
    movwf ADCON0
    goto do_ADC

;;; read AN2 to WREG
ADC_2:
    movlw b'01010001'           ; channel 2, FOSC/16
    movwf ADCON0
    goto do_ADC

;;; common ADC helper
do_ADC: 
    movlw d'17'                 ; 20 usec at 10MHz clock
delay_ADC:                      ; acquisition
    decfsz WREG
    bra delay_ADC
    bsf ADCON0, 2               ; GO
wait_ADC:                       ; conversion
    btfsc ADCON0, 2             ; DONE?
    bra wait_ADC
    movf ADRESH, w
    return
