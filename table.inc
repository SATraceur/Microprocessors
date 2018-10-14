;;;============================================
;;; MPASM PIC18 table lookup macros
;;;============================================

;;;---------------------------------------------
;;; Return contents of (table + WREG)
;;;---------------------------------------------
lookup macro table
    addlw low(table)
    movwf TBLPTRL
    movlw high(table)
    movwf TBLPTRH
    clrf WREG
    addwfc TBLPTRH  ; carry
    movlw upper(table)
    movwf TBLPTRU
    clrf WREG
    addwfc TBLPTRU  ; carry
    tblrd*
    movf TABLAT, w
  endm

;;;--------------------------------------------
;;; Process each element in lookup table
;;;   table: table of values (zero marks end)
;;;   process: subroutine to call for each
;;;--------------------------------------------
foreach macro table, process
  local loop, done
    movlw low(table)
    movwf TBLPTRL
    movlw high(table)
    movwf TBLPTRH
    movlw upper(table)
    movwf TBLPTRU
loop:
    tblrd*+
    movf TABLAT, w
    bz done
    call process
    bra loop
done:
  endm

