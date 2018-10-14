;;;---------------------------------------------
;;; ENGR2721 Microprocessors
;;; Prac 1: P2_Counter
;;; << Joshua Francis >>
;;;
;;; s3, s4, s5 = off
;;;---------------------------------------------

#include <p18f452.inc>
#include "../include/delay.inc"
#include "../include/table.inc"

  config OSC = HS
  config BOR = OFF, WDT = OFF, LVP = OFF

  org 0x0000
    goto start

    cblock 0x00
        delay_counter : 3
        count 
    endc


start:
     call init

     movlw b'11111100' ; segments to display '0'
     movwf PORTB
     bsf PORTC, 5

     movlw 0x00
     movwf count


again:


     movf count, w ; move count to WREG
     bcf PORTC, 4
     bsf PORTC, 5
     call get_hex_7seg ; call function to get 7seg code and display low nibble on right side
     movwf PORTB
     delay_t d'500', msec, delay_counter

     
     bcf PORTC, 5
     bsf PORTC, 4
     swapf WREG,w
     call get_hex_7seg ; call function to get 7seg code and display high nibble on left side
     movwf PORTB
     delay_t d'500', msec, delay_counter
     incf count ; increment count


     bra again
     

    ;;;-----------------------------------------------------
    ;;; initialise PIC trainer to use MUX board
    ;;;-----------------------------------------------------
init:
     ;;< initialisation code >
    clrf TRISC  ; put PORTC in output mode
    clrf PORTC
    clrf TRISB  ; put PORTB in output mode
    clrf PORTB
    setf TRISD
    setf PORTD  ; put PORTD into input mode
    return

;;;-----------------------------------------------------
;;; return 7-segment code for low nibble of WREG
;;;-----------------------------------------------------

get_hex_7seg:
    andlw h'0f' ; mask off high nibble
    lookup HEX_7SEG_CODES ; do the table lookup
    return

HEX_7SEG_CODES:
    db b'11111100', b'01100000', b'11011010', b'11110010' ;0123
    db b'01100110', b'10110110', b'10111110', b'11100000' ;4567
    db b'11111110', b'11110110', b'11101110', b'00111110' ;89Ab
    db b'10011100', b'01111010', b'10011110', b'10001110' ;CdEF

    end
