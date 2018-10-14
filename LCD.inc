;;;=============================================
;;; PIC Trainer LCD support
;;;  #include _after_ defining code origin!
;;;=============================================

;;;---------------------------------------------
;;; wait for LCD to be ready
;;;---------------------------------------------
LCD_wait macro
  local _wait_again
    setf TRISD                  ; Port D as inputs
    bsf PORTE, 0                ; read mode
    bcf PORTE, 1                ; command register
    bsf PORTE, 2                ; take E high ...
_wait_again:
    btfsc PORTD, 7              ; skip if not busy
    bra _wait_again
    bcf PORTE, 2                ; ... then low
  endm

;;;---------------------------------------------
;;; send WREG to LCD
;;;---------------------------------------------
LCD_send macro
    clrf TRISD                  ; Port D as outputs
    movwf PORTD                 ; send command or data
    bcf PORTE, 0                ; write mode
    bsf PORTE, 2                ; pulse E high ...
    bcf PORTE, 2                ; ... then low
  endm

;;;---------------------------------------------
;;; Initialize Altronic Z7000A LCD module
;;; for PIC trainer board use
;;;---------------------------------------------
LCD_init:
    movlw b'00000010'           ; Port E as digital (shared with analog port)
    movwf ADCON1
    clrf TRISE                  ; Port E as outputs (LCD control inputs)
    movlw b'00111000'	        ; 001 DL N F xx	(8-bit, 2 lines, 5x7 font)
    call LCD_command
    movlw b'00001111'	        ; 00001 D C B 	(display ON, cursor OFF, blinking ON)
    call LCD_command
    movlw b'00000001'           ; clear display
    call LCD_command
    return

;;;---------------------------------------------
;;; Clear LCD and home cursor
;;;---------------------------------------------
LCD_clear:
    movlw b'00000001'           ; clear display
    call LCD_command
    return

;;;---------------------------------------------
;;; Home cursor without clearing display
;;;---------------------------------------------
LCD_home:
    movlw b'00000010'           ; return home
    call LCD_command
    return

;;;---------------------------------------------
;;; Move cursor to beginning of line 2
;;;---------------------------------------------
LCD_home2:
    movlw h'40'                 ; start of line 2
    call LCD_cursor
    return

;;;---------------------------------------------
;;; Move LCD cursor to position specified by WREG
;;; Useful values: 0 = start of line 1; h'40' = start of line 2
;;;---------------------------------------------
LCD_cursor:
    addlw b'10000000'           ; move command
    call LCD_command
    return

;;;---------------------------------------------
;;; Write WREG to LCD as command
;;;---------------------------------------------
LCD_command:
    LCD_wait
    bcf PORTE, 1                ; clear for command
    LCD_send
    return

;;;---------------------------------------------
;;; Write WREG to LCD as data
;;;---------------------------------------------
LCD_data:
    LCD_wait
    bsf PORTE, 1                ; set for data
    LCD_send
    return

