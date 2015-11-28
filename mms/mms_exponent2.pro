; - Written by Stein Vidar Hagfors Haugan
; - Copied from https://www.idlcoyote.com/tips/exponents.html
; - Added prefix "mms_" to avoid conflict 
;
; - Slightly modified by Naritoshi Kitamura to remove mantissa
;

FUNCTION mms_exponent2, axis, index, number

  ; A special case.
  IF number EQ 0 THEN RETURN, '0'

  ; Assuming multiples of 10 with format.
  ex = String(number, Format='(e8.0)')
  pt = StrPos(ex, '.')

  first = StrMid(ex, 0, pt)
  sign = StrMid(ex, pt+2, 1)
  thisExponent = StrMid(ex, pt+3)

  ; Shave off leading zero in exponent
  WHILE StrMid(thisExponent, 0, 1) EQ '0' DO thisExponent = StrMid(thisExponent, 1)

  ; Fix for sign and missing zero problem.
  IF (Long(thisExponent) EQ 0) THEN BEGIN
    sign = ''
    thisExponent = '0'
  ENDIF

  ; Make the exponent a superscript.
  IF sign EQ '-' THEN BEGIN
;    RETURN, first + 'x10!U' + sign + thisExponent + '!N'
    RETURN, '10!U' + sign + thisExponent + '!N'
  ENDIF ELSE BEGIN
;    RETURN, first + 'x10!U' + thisExponent + '!N'
    RETURN, '10!U' + thisExponent + '!N'
  ENDELSE

END
