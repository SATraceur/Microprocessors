;;;---------------------------------------------
;;; Project Modulator: AM/FM signal modulator
;;;
;;; S3 = DAC, S4 = AN0, AN1 (for testing)
;;;---------------------------------------------

#include <p18f452.inc>

  config OSC = HS
  config BOR = OFF, WDT = OFF, LVP = OFF

  org 0x0000
    goto start

  org 0x0008
    goto ISR_high

  org 0x0018
    retfie FAST                 ; unused

  cblock 0x000 ; Variable declarations.
    increment
    offset
    time ; what sample to output
    signal    ;amplitude multiplier
    ADC_3_VAL ; temp test
    f100Hz_UM ; 100Hz unmodulated variable
    f100Hz ; 100Hz variable
    f200Hz ; 200 Hz variable
    f500Hz ; 500 Hz variable
    f1kHz ; 1kHz variable
    f2kHz ; 2kHz variable
    f5kHz ; 5kHz variable
    f10kHz ; 10kHz variable
  endc

#include "../include/analog.inc"
#include "../include/table.inc"
#include "../include/ops.inc"

start:
    call analog_init
    call init
again:
    
;===============================================================================
;            Bit Tests For Switches
;===============================================================================
    
    movf PORTB, WREG
    andlw b'00011100' ; mask off all bits we dont care about.
    
    cpfbeq f100Hz_UM, f100Hz_UM_function
    cpfbeq f100Hz, f100Hz_function
    cpfbeq f200Hz, f200Hz_function
    cpfbeq f500Hz, f500Hz_function
    cpfbeq f1kHz, f1kHz_function
    cpfbeq f2kHz, f2kHz_function
    cpfbeq f5kHz, f5kHz_function
    cpfbeq f10kHz, f10kHz_function

done:  
    btfss PORTB, 5 
    movlw h'ff'
    movwf signal   ; for AM Modulation
    negf WREG ; negates signal
    rrncf WREG ; divide by 2
    bcf WREG, 7 ; ignore carry
    movwf offset ; save value
    bra again

;===============================================================================
; Frequency output subroutines.
;===============================================================================

f100Hz_UM_function:
    movlw d'1' ; Display 100 samples from SINE table
    movwf increment    
    movlw d'249' ; Chosen to get a frequency of 100 Hz
    movwf PR2
    movlw h'ff' 
    bra done
f100Hz_function: ; 20% FM Modulation
    movlw d'1' ; Display 100 samples from SINE table
    movwf increment
    call ADC_3
    rrncf WREG
    rrncf WREG        ; Rotate right twice and
    andlw b'00111111' ; mask of bits 7 & 6 to retrive 25% of carrier wave
    negf WREG
    addlw d'249' ; Subtracts 25% of carrier wave from original period register that gave us 100Hz
    btfsc PORTB, 5 ;FM modulation is selected via RB5
    movlw d'249' ; Skips loading the default period register if FM Modulation is selected
    movwf PR2
    call ADC_3
    bra done    
f200Hz_function: ; 25% FM Modulation
    movlw d'1'
    movwf increment
    call ADC_3
    rrncf WREG
    rrncf WREG
    rrncf WREG        ; Rotate right three times and
    andlw b'00011111' ; mask of bits 7, 6 & 5 to retrive 12.5% of carrier wave
    negf WREG
    addlw d'124' ; Subtracts 12.5% of carrier wave from original period register 
    btfsc PORTB, 5 ; FM modulation is selected via RB5
    movlw d'124' ; Skips loading the default period register if FM Modulation is selected
    movwf PR2
    call ADC_3
    bra done
f500Hz_function: ; 20% FM Modulation
    movlw d'2'
    movwf increment
    call ADC_3
    rrncf WREG
    rrncf WREG
    rrncf WREG
    rrncf WREG ; Rotate right four times and
    andlw b'00001111' ; mask of bits 7, 6, 5 & 4 to retrive 6.25% of carrier wave
    negf WREG
    addlw d'99' ; Subtracts 6.25% of carrier wave from original period register 
    btfsc PORTB, 5 ; FM modulation is selected via RB5
    movlw d'99' ; Skips loading the default period register if FM Modulation is selected
    movwf PR2
    call ADC_3
    bra done
f1kHz_function: ; 25% FM Modulation 
    movlw d'5'
    movwf increment
    call ADC_3
    rrncf WREG
    rrncf WREG
    rrncf WREG ; Rotate right three times and
    andlw b'00011111' ; mask of bits 7, 6 & 5 to retrive 12.5% of carrier wave
    negf WREG
    addlw d'124' ; Subtracts 12.5% of carrier wave from original period register 
    btfsc PORTB, 5 ; FM modulation is selected via RB5
    movlw d'124' ; Skips loading the default period register if FM Modulation is selected
    movwf PR2
    call ADC_3
    bra done
f2kHz_function: ; 25% FM Modulation
    movlw d'10'
    movwf increment
    call ADC_3
    rrncf WREG
    rrncf WREG
    rrncf WREG ; Rotate right three times and
    andlw b'00011111' ; mask of bits 7, 6 & 5 to retrive 12.5% of carrier wave
    negf WREG
    addlw d'124' ; Subtracts 12.5% of carrier wave from original period register 
    btfsc PORTB, 5 ; FM modulation is selected via RB5
    movlw d'124'
    movwf PR2
    call ADC_3
    bra done
f5kHz_function: ; 20% FM Modulation 
    movlw d'10'
    movwf increment
    call ADC_3
    rrncf WREG
    rrncf WREG
    rrncf WREG ; Rotate right three times and
    andlw b'00011111' ; mask of bits 7, 6 & 5 to retrive 12.5% of carrier wave
    negf WREG
    addlw d'49' ; Subtracts 12.5% of carrier wave from original period register 
    btfsc PORTB, 5 ; FM modulation is selected via RB5
    movlw d'49'
    movwf PR2
    call ADC_3
    bra done
f10kHz_function:
    movlw d'25'
    movwf increment
    movlw d'60'
    movwf PR2
    call ADC_3
    bra done

;===============================================================================
; Configure interrupts & timers.
;===============================================================================
init:
    bcf RCON, 7                 ; disable priority interrupts
    bsf INTCON, 7               ; enable global interrupts
    bsf INTCON, 6               ; enable peripheral interrupts
    bcf PIR1, 1                 ; clear timer 2 flag
    bsf PIE1, 1                 ; enable timer 2 interrupts

    ;; timer 2
    movlw b'00000100'           ; on, postscale 1, prescale 1
    movwf T2CON
    
    ;; Switch bit pattern deffinitions
    movlw b'00000000' ; all bits off
    movwf f100Hz_UM ; 100Hz unmodulated variable
    movlw b'00010000' ; bit 4 on
    movwf f100Hz ; 100Hz variable
    movlw b'00001000'  ; bit 3 on
    movwf f200Hz ; 200 Hz variable
    movlw b'00011000' ; bits 3 & 4 on
    movwf f500Hz ; 500 Hz variable
    movlw b'00000100' ; bit 2 on
    movwf f1kHz ; 1kHz variable
    movlw b'00010100'  ; bits 2 & 4 on
    movwf f2kHz ; 2kHz variable
    movlw b'00001100' ; bits 2 & 3 on
    movwf f5kHz ; 5kHz variable
    movlw b'00011100' ; bits 2 & 3 & 4 on
    movwf f10kHz ; 10kHz variable
    movlw b'00100000' ; all bits off
    return

;===============================================================================
; Service high-priority interrupt.
;===============================================================================
ISR_high:
    bcf PIR1, 1                 ; clear timer 2 flag
    movf time, w
    lookup SINE
    mulwf signal
    movff PRODH, WREG
    addwf offset, w ; Adds offset
    call DAC_A
    movf increment, WREG
    addwf time, WREG
    movwf time
    ; Stops time from exceeding SINE table limits
    movlw d'100'
    cpfsne time
    clrf time
    retfie FAST


SINE: ; (100 values)
    db d'127', d'135', d'143', d'151', d'159', d'167', d'174', d'181'
    db d'189', d'196', d'202', d'209', d'215', d'220', d'226', d'231'
    db d'235', d'239', d'243', d'246', d'249', d'251', d'253', d'254'
    db d'255', d'255', d'255', d'254', d'253', d'251', d'249', d'246'
    db d'243', d'239', d'235', d'231', d'226', d'220', d'215', d'209'
    db d'202', d'196', d'189', d'182', d'174', d'167', d'159', d'151'
    db d'143', d'135', d'127', d'119', d'111', d'103', d'95', d'87'
    db d'80', d'73', d'65', d'58', d'52', d'45', d'39', d'34'
    db d'28', d'23', d'19', d'15', d'11', d'8', d'5', d'3'
    db d'1', d'0', d'0', d'0', d'0', d'0', d'1', d'3'
    db d'5', d'8', d'11', d'15', d'19', d'23', d'28', d'34'
    db d'39', d'45', d'52', d'58', d'65', d'72', d'80', d'87'
    db d'95', d'103', d'111', d'119'

  end