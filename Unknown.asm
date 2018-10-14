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
	digit_right
	digit_left
    endc


start:
     call init         ; 2 for call
     clrf count        ; 1 cycle
     clrf digit_right  ; 1 cycle
     clrf digit_left   ; 1 cycle

again:

    movf count, w       ; 1 cycle
    call get_hex_7seg   ; 2 for call, 
    movwf digit_right   ; 1 cycle
   
   
    swapf count, w      ; 1 cycle
    call get_hex_7seg   ; 2 for call,
    movwf digit_left    ; 1 cycle
    
    call delay_and_display
      
    
     btfsc PORTD, 6     ; 1 cycle
     movlw h'99'        ; 1 cycle 
     btfss PORTD, 6     ; 1 cycle
     movlw b'01'        ; 1 cycle
     btfsc PORTD, 7     ; 1 cycle
     movlw b'00'        ; 1 cycle
     
     addwf count, w     ; 1 cycle
     daw                ; 1 cycle
     movwf count        ; 1 cycle 

    bra again           ; 2 cycles
     
init: ; INIT - TOTAL 9 
    clrf TRISC   ; 1 cycle
    clrf PORTC   ; 1 cycle
    clrf TRISB   ; 1 cycle
    clrf PORTB   ; 1 cycle
    setf TRISD   ; 1 cycle
    setf PORTD   ; 1 cycle
    bcf PORTC, 1 ; 1 cycle
    return       ; 2 cycles

get_hex_7seg:
    andlw b'1111' ; 1 cycle
    lookup HEX_7SEG_CODES ; ? cycles

HEX_7SEG_CODES:
    db b'11111100', b'01100000', b'11011010', b'11110010' ;0123
    db b'01100110', b'10110110', b'10111110', b'11100000' ;4567
    db b'11111110', b'11110110', b'11101110', b'00111110' ;89Ab
    db b'10011100', b'01111010', b'10011110', b'10001110' ;CdEF

idle:
    bra idle

 constant LOOP_COUNT = d'10000'
delay_and_display:              ; DELAY & DISPLAY - TOTAL: 37
     movlw low(LOOP_COUNT)      ; 1 cycle
     movwf delay_counter + 0    ; 1 cycle
     movlw high(LOOP_COUNT)     ; 1 cycle
     movwf delay_counter + 1    ; 1 cycle
delay_again:                    ; DELAY_AGAIN - TOTAL: 24
     movf delay_counter, w      ; 1 cycle
     call display_worker        ; 2 for call, 14 in function, TOTAL: 16
     
     clrf WREG                  ; 1 cycle
     decf delay_counter + 0     ; 1 cycle
     subwfb delay_counter + 1   ; 1 cycle
     iorwf delay_counter + 0, w ; 1 cycle
     iorwf delay_counter + 1, w ; 1 cycle
     bnz delay_again            ; 2 cycles
     return                     ; 2 cycles, dont include
     
display_worker:                 ; DISPLAY_WORKER - TOTAL: 14
    btfsc WREG, 0               ; 1 cycle
    call turn_on_right_dig      ; 2 for call, 6 in function, TOTAL: 8
    btfss WREG, 0               ; 1 cycle
    call turn_on_left_dig       ; 2 for call, 6 in function, 2 for skip, TOTAL: 10
    return                      ; 2 cycles
    
turn_on_right_dig:              ; TOTAL - 6
    bcf PORTC, 4                ; 1 cycle
    bsf PORTC, 5                ; 1 cycle
    movff digit_right, PORTB    ; 2 cycles
    return                      ; 2 cycles
    
turn_on_left_dig:               ; TOTAL - 6
    bcf PORTC, 5                ; 1 cycle
    bsf PORTC, 4                ; 1 cycle
    movff digit_left, PORTB     ; 2 cycles
    return                      ; 2 cycles
    
    end


