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

  cblock 0x000 ; VAriable declarations.
    increment
    offset
    temp
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
    f100Hz_UM_AM ; 100Hz unmodulated variable
    f100Hz_AM ; 100Hz variable
    f200Hz_AM ; 200 Hz variable
    f500Hz_AM ; 500 Hz variable
    f1kHz_AM ; 1kHz variable
    f2kHz_AM ; 2kHz variable
    f5kHz_AM ; 5kHz variable
    f10kHz_AM ; 10kHz variable
  endc

#include "../include/analog.inc"
#include "../include/table.inc"
#include "../include/ops.inc"

start:
    call analog_init
    call init
again:

;===============================================================================
;            Bit Tests For Buttons
;===============================================================================
    movf PORTB, WREG
    andlw b'00111100' ; mask off all bits we dont care about.
    cpfbeq f100Hz_UM, f100Hz_UM_function
    cpfbeq f100Hz, f100Hz_function
    cpfbeq f200Hz, f200Hz_function
    cpfbeq f500Hz, f500Hz_function
    cpfbeq f1kHz, f1kHz_function
    cpfbeq f2kHz, f2kHz_function
    cpfbeq f5kHz, f5kHz_function
    cpfbeq f10kHz, f10kHz_function
    cpfbeq f100Hz_UM_AM, f100Hz_UM_function
    cpfbeq f100Hz_AM, f100Hz_function
    cpfbeq f200Hz_AM, f200Hz_function
    cpfbeq f500Hz_AM, f500Hz_function
    cpfbeq f1kHz_AM, f1kHz_function
    cpfbeq f2kHz_AM, f2kHz_function
    cpfbeq f5kHz_AM, f5kHz_function
    cpfbeq f10kHz_AM, f10kHz_function

done:
    
    btfss PORTB, 5
    movlw h'ff'
    movwf signal   ; for AM
    sublw h'FF'   ; subtracts ADC_3 from 5
    mullw d'128'  ; divides by 2
    movf PRODH, WREG ; Moves high byte into offset for use in ISR.
    movwf offset

    bra again

;===============================================================================
; Frequency output subroutines.
;===============================================================================

f100Hz_UM_function:
    movlw d'96'
    movwf PR2
    movlw h'ff'
    bra done
f100Hz_function:
    movlw d'96'
    movwf PR2
    btfsc PORTB, 5
    call ADC_3
    bra done
f200Hz_function:
    movlw d'1'
    movwf increment
    movlw d'48'
    movwf PR2
    btfsc PORTB, 5
    call ADC_3
    bra done
f500Hz_function:
    movlw d'3'
    movwf increment
    movlw d'58'
    movwf PR2
    btfsc PORTB, 5
    call ADC_3
    bra done
f1kHz_function:
    movlw d'6'
    movwf increment
    movlw d'55'
    movwf PR2
    btfsc PORTB, 5
    call ADC_3
    bra done
f2kHz_function:
    movlw d'10'
    movwf increment
    movlw d'35'
    movwf PR2
    btfsc PORTB, 5
    call ADC_3
    bra done
f5kHz_function:
    movlw d'30'
    movwf increment
    movlw d'58'
    movwf PR2
    btfsc PORTB, 5
    call ADC_3
    bra done
f10kHz_function:
    movlw d'64'
    movwf increment
    movlw d'61'
    movwf PR2
    btfsc PORTB, 5
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
    movwf f100Hz_UM_AM ; 100Hz unmodulated variable
    movlw b'00110000' ; bit 4 on
    movwf f100Hz_AM ; 100Hz variable
    movlw b'00101000'  ; bit 3 on
    movwf f200Hz_AM ; 200 Hz variable
    movlw b'00111000' ; bits 3 & 4 on
    movwf f500Hz_AM ; 500 Hz variable
    movlw b'00100100' ; bit 2 on
    movwf f1kHz_AM ; 1kHz variable
    movlw b'00110100'  ; bits 2 & 4 on
    movwf f2kHz_AM ; 2kHz variable
    movlw b'00101100' ; bits 2 & 3 on
    movwf f5kHz_AM ; 5kHz variable
    movlw b'00111100' ; bits 2 & 3 & 4 on
    movwf f10kHz_AM ; 10kHz variable
    return

;===============================================================================
; Service high-priority interrupt.
;===============================================================================
ISR_high:
    btfsc PIR1, 1               ; skip if not timer 2 flag
    call timer2_handler
    retfie FAST

;;; output one value
timer2_handler:
    bcf PIR1, 1                 ; clear timer 2 flag
    movf time, w
    lookup SINE
    mulwf signal
    movff PRODH, WREG
    addwf offset, w ; Adds offset
  ; movf offset, w
    call DAC_A
    incf time
    return

;;; lookup tables

SINE:
    db d'255', d'255', d'255', d'255', d'254', d'254', d'254', d'253'
    db d'253', d'252', d'251', d'250', d'249', d'249', d'248', d'246'
    db d'245', d'244', d'243', d'241', d'240', d'238', d'237', d'235'
    db d'233', d'232', d'230', d'228', d'226', d'224', d'222', d'220'
    db d'218', d'215', d'213', d'211', d'208', d'206', d'203', d'201'
    db d'198', d'195', d'193', d'190', d'187', d'185', d'182', d'179'
    db d'176', d'173', d'170', d'167', d'164', d'161', d'158', d'155'
    db d'152', d'149', d'146', d'143', d'140', d'136', d'133', d'130'
    db d'127', d'124', d'121', d'118', d'114', d'111', d'108', d'105'
    db d'102', d'99', d'96', d'93', d'90', d'87', d'84', d'81'
    db d'78', d'75', d'72', d'69', d'67', d'64', d'61', d'59'
    db d'56', d'53', d'51', d'48', d'46', d'43', d'41', d'39'
    db d'36', d'34', d'32', d'30', d'28', d'26', d'24', d'22'
    db d'21', d'19', d'17', d'16', d'14', d'13', d'11', d'10'
    db d'9', d'8', d'6', d'5', d'5', d'4', d'3', d'2'
    db d'1', d'1', d'0', d'0', d'0', d'0', d'0', d'0'
    db d'0', d'0', d'0', d'0', d'0', d'0', d'0', d'1'
    db d'1', d'2', d'3', d'4', d'5', d'5', d'6', d'8'
    db d'9', d'10', d'11', d'13', d'14', d'16', d'17', d'19'
    db d'21', d'22', d'24', d'26', d'28', d'30', d'32', d'34'
    db d'36', d'39', d'41', d'43', d'46', d'48', d'51', d'53'
    db d'56', d'59', d'61', d'64', d'67', d'69', d'72', d'75'
    db d'78', d'81', d'84', d'87', d'90', d'93', d'96', d'99'
    db d'102', d'105', d'108', d'111', d'114', d'118', d'121', d'124'
    db d'127', d'130', d'133', d'136', d'140', d'143', d'146', d'149'
    db d'152', d'155', d'158', d'161', d'164', d'167', d'170', d'173'
    db d'176', d'179', d'182', d'185', d'187', d'190', d'193', d'195'
    db d'198', d'201', d'203', d'206', d'208', d'211', d'213', d'215'
    db d'218', d'220', d'222', d'224', d'226', d'228', d'230', d'232'
    db d'233', d'235', d'237', d'238', d'240', d'241', d'243', d'244'
    db d'245', d'246', d'248', d'249', d'249', d'250', d'251', d'252'
    db d'253', d'253', d'254', d'254', d'254', d'255', d'255', d'255'
    db d'127', d'130', d'133', d'136', d'140', d'143', d'146', d'149'
    db d'152', d'155', d'158', d'161', d'164', d'167', d'170', d'173'
    db d'176', d'179', d'182', d'185', d'187', d'190', d'193', d'195'
    db d'198', d'201', d'203', d'206', d'208', d'211', d'213', d'215'
    db d'218', d'220', d'222', d'224', d'226', d'228', d'230', d'232'
    db d'233', d'235', d'237', d'238', d'240', d'241', d'243', d'244'
    db d'245', d'246', d'248', d'249', d'249', d'250', d'251', d'252'
    db d'253', d'253', d'254', d'254', d'254', d'255', d'255', d'255'
    db d'255', d'255', d'255', d'255', d'254', d'254', d'254', d'253'
    db d'253', d'252', d'251', d'250', d'249', d'249', d'248', d'246'
    db d'245', d'244', d'243', d'241', d'240', d'238', d'237', d'235'
    db d'233', d'232', d'230', d'228', d'226', d'224', d'222', d'220'
    db d'218', d'215', d'213', d'211', d'208', d'206', d'203', d'201'
    db d'198', d'195', d'193', d'190', d'187', d'185', d'182', d'179'
    db d'176', d'173', d'170', d'167', d'164', d'161', d'158', d'155'
    db d'152', d'149', d'146', d'143', d'140', d'136', d'133', d'130'
    db d'127', d'124', d'121', d'118', d'114', d'111', d'108', d'105'
    db d'102', d'99', d'96', d'93', d'90', d'87', d'84', d'81'
    db d'78', d'75', d'72', d'69', d'67', d'64', d'61', d'59'
    db d'56', d'53', d'51', d'48', d'46', d'43', d'41', d'39'
    db d'36', d'34', d'32', d'30', d'28', d'26', d'24', d'22'
    db d'21', d'19', d'17', d'16', d'14', d'13', d'11', d'10'
    db d'9', d'8', d'6', d'5', d'5', d'4', d'3', d'2'
    db d'1', d'1', d'0', d'0', d'0', d'0', d'0', d'0'
    db d'0', d'0', d'0', d'0', d'0', d'0', d'0', d'1'
    db d'1', d'2', d'3', d'4', d'5', d'5', d'6', d'8'
    db d'9', d'10', d'11', d'13', d'14', d'16', d'17', d'19'
    db d'21', d'22', d'24', d'26', d'28', d'30', d'32', d'34'
    db d'36', d'39', d'41', d'43', d'46', d'48', d'51', d'53'
    db d'56', d'59', d'61', d'64', d'67', d'69', d'72', d'75'
    db d'78', d'81', d'84', d'87', d'90', d'93', d'96', d'99'
    db d'102', d'105', d'108', d'111', d'114', d'118', d'121', d'124'

  end