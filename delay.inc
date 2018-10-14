;;;===========================================
;;; MPASM PIC18 delay macros for PIC Trainer
;;;===========================================

  constant clock_frequency = d'10'        ; 10 MHz
  constant clocks_per_cycle = d'4'        ; HS mode

  constant u = d'1'
  constant k = d'1000'
  constant M = d'1000000'

  constant usec = d'1'
  constant msec = d'1000'
  constant sec = d'1000000'


;;;-------------------------------------------
;;; delay WREG * t * unit (~50 usec - 67 sec)
;;;
;;;   WREG: multiplier
;;;   t, unit: time for one cycle
;;;   counter: space for counting (assumed large enough)
;;;-------------------------------------------
delay_w macro _t, _unit, _counter
  local _again, _done
    movwf _counter
    movf _counter                              ; to set Z bit
_again
    bz _done
    delay_t _t, _unit, _counter + 1
    decf _counter
    bra _again
_done
  endm
    
;;;-------------------------------------------
;;; delay by t * unit (~50 usec ... ~67 sec)
;;;
;;;   t, unit: time to delay
;;;   counter: space for counting (assumed large enough)
;;;-------------------------------------------
delay_t macro _t, _unit, _counter
    work_n 0, 0, _t * _unit * clock_frequency / clocks_per_cycle, _counter
  endm

;;;-------------------------------------------
;;; call worker subroutine for t * unit (~50 usec ... ~67 sec)
;;;
;;;   worker: subroutine to call
;;;   work: cycles consumed per call and return (0 to skip call)
;;;   t, unit: time to work
;;;   counter: space for counting (assumed large enough)
;;;-------------------------------------------
work_t macro _worker, _work, _t, _unit, _counter
    work_n _worker, _work, _t * _unit * clock_frequency / clocks_per_cycle, _counter
  endm

;;;-------------------------------------------
;;; call worker subroutine for n machine cycles (~20 - ~160M)
;;;
;;;   worker: subroutine to call
;;;   work: cycles consumed per worker call and return (0 to skip call)
;;;   n: machine cycles to work for
;;;   counter: space for counting (assumed large enough)
;;;-------------------------------------------
work_n macro _worker, _work, _n, _counter
  variable _count
_count = (_n - d'2')/(_work + d'6')     ; try 1-byte counter
  if (_count > h'FF')
_count = (_n - d'4')/(_work + d'8')     ; try 2-byte counter
  endif
  if (_count > h'FFFF')
_count = (_n - d'6')/(_work + d'10')    ; try 3-byte counter
  endif
  if (_count > h'FFFFFF')
_count = h'FFFFFF'                      ; too many!
  endif
    do_k _worker, _work, _count, _counter
  endm

;;;--------------------------------------------
;;; call worker subroutine k times (1 - ~16M)
;;;
;;;   worker: subroutine to call
;;;   work: cycles consumed per call and return (0 to skip call)
;;;   k: call count
;;;   counter: space for counting (assumed large enough)
;;;--------------------------------------------
do_k macro _worker, _work, _k, _counter
  local _again
    movlw low(_k)
    movwf _counter + 0
  if (_k > h'FF')
    movlw high(_k)
    movwf _counter + 1
  endif
  if (_k > h'FFFF')
    movlw upper(_k)
    movwf _counter + 2
  endif
_again
    movf _counter, w
  if (_work)
    call _worker
  endif
    clrf WREG
    decf _counter + 0
  if (_k > h'FF')
    subwfb _counter + 1
  endif
  if (_k > h'FFFF')
    subwfb _counter + 2
  endif
    iorwf _counter + 0, w
  if (_k > h'FF')
    iorwf _counter + 1, w
  endif
  if (_k > h'FFFF')
    iorwf _counter + 2, w
  endif
    bnz _again
  endm
