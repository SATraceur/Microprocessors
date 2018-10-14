;;;=============================================
;;;  opcode-like macros
;;;==============================================

;;; unconditional skip
skip macro
    cpfseq WREG
  endm

;;; compare f with WREG, skip on greater or equal
cpfsge macro f
    cpfsgt f
    skip
  endm

;;; compare f with WREG, skip on less or equal    
cpfsle macro f
    cpfslt f
    skip
  endm

;;; compare f with WREG, skip on not equal    
cpfsne macro f
    cpfseq f
    skip
  endm

;;; compare f with WREG, branch on not equal
cpfbne macro f, target
    cpfseq f
    bra target
  endm

;;; compare f with WREG, branch on equal
cpfbeq macro f, target
    cpfseq f
    skip
    bra target
  endm

;;; compare f with WREG, call on not equal
cpfcne macro f, target
    cpfseq f
    call target
  endm

;;; compare f with WREG, call on equal
cpfceq macro f, target
    cpfseq f
    skip
    call target
  endm
