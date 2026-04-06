  .syntax unified
  .cpu cortex-m3
  .fpu softvfp
  .thumb
  
  .global  fp_exp
  .global  fp_frac
  .global  fp_enc
  .global  fp_add

@ fp_exp subroutine
@ Obtain the exponent of an IEEE-754 (half-precision) number as a signed
@   integer (2's complement)
@
@ Parameters:
@   R0: IEEE-754 half-precision number (occupying bits 15 to 0)
@
@ Return:
@   R0: exponent (signed integer using 2's complement)
fp_exp:
  PUSH    {LR}                      @ add any registers R4...R12 that you use

  AND   R0, R0, #0x00007C00             @ get exponent
  LSR   R0, R0, #10                 @ shift over to the right spot
  SUB   R0, R0, #15                 @ subtract bias                   

  POP     {PC}                      @ add any registers R4...R12 that you use



@ fp_frac subroutine
@ Obtain the fraction of an IEEE-754 (half-precision) number.
@
@ The returned fraction will include the 'hidden' bit to the left
@   of the radix point (at bit 10). The radix point should be considered to be
@   between bits 9 and 10.
@
@ The returned fraction will be in 2's complement form, reflecting the sign
@   (sign bit) of the original IEEE-754 number.
@
@ Parameters:
@   R0: IEEE-754 half-precision number (occupying bits 15 to 0)
@
@ Return:
@   R0: fraction (signed fraction, including the 'hidden' bit, in 2's
@         complement form)
fp_frac:
  PUSH    {R4,R5,LR}                      @ add any registers R4...R12 that you use
  MOV   R5, #0x03FF
  MOV   R4, R0
  AND   R4, R4, #0x8000                @ isolate signed bit

  AND   R0, R0, R5                @ get fraction
  ORR   R0, R0, #0x0400                @ add hidden bit

  CMP   R4, #0
  BEQ   fp_frac_done
  RSB   R0, R0, #0                     @convert to negative 2s complement
fp_frac_done:

  POP     {R4,R5,PC}                      @ add any registers R4...R12 that you use



@ fp_enc subroutine
@ Encode an IEEE-754 (half-precision) floating point number given the
@   fraction (in 2's complement form) and the exponent (also in 2's
@   complement form).
@
@ Fractions that are not normalised will be normalised by the subroutine,
@   with a corresponding adjustment made to the exponent.
@
@ Parameters:
@   R0: fraction (in 2's complement form)
@   R1: exponent (in 2's complement form)
@
@ Return:
@   R0: IEEE-754 half-precision floating point number (occupying bits 15 to 0)
fp_enc:
  PUSH    {R4-R7,LR}                      @ add any registers R4...R12 that you use

  MOV     R4, R0                          @ fraction
  MOV     R5, R1                          @ exponent
  MOV     R6, #0                          @ sign

  @ check for 0 special case
  CMP     R4, #0
  BEQ     fp_enc_zero

  @ get sign and absolute magnitude
  CMP     R4, #0
  BGE     fp_enc_abs_done
  MOV     R6, #0x8000              @ sign bit
  RSB     R4, R4, #0               @ abs(fraction)

fp_enc_abs_done:
  @ normalize so magnitude is in range 0x400 .. 0x7FF

fp_enc_shift_right:
  CMP     R4, #0x0800               @ while magnitude >= 0x800
  BLT     fp_enc_shift_left
  LSR     R4, R4, #1
  ADD     R5, R5, #1
  B       fp_enc_shift_right

fp_enc_shift_left:
  CMP     R4, #0x0400               @ while magnitude < 0x400
  BGE     fp_enc_pack
  LSL     R4, R4, #1
  SUB     R5, R5, #1
  B       fp_enc_shift_left

fp_enc_pack:
  @ remove hidden bit
  MOV     R7, #0x03FF
  AND     R4, R4, R7

  @ bias exponent
  ADD     R5, R5, #15
  LSL     R5, R5, #10

  @ pack result
  ORR     R5, R5, R6
  ORR     R5, R5, R4
  MOV     R0, R5
  B       fp_enc_done

fp_enc_zero:
  MOV     R0, #0

fp_enc_done:
  POP     {R4-R7,PC}                      @ add any registers R4...R12 that you use


@ fp_add subroutine
@ Add two IEEE-754 half-precision floating point numbers
@
@ Paramaters:
@   R0: a - first number (occupying bits 15 to 0)
@   R1: b - second number  (occupying bits 15 to 0)
@
@ Return:
@   R0: result - a+b (occupying bits 15 to 0)
fp_add:
  PUSH    {LR}                      @ add any registers R4...R12 that you use

  

  POP     {PC}                      @ add any registers R4...R12 that you use



  .end