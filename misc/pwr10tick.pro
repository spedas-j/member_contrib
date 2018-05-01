FUNCTION PWR10TICK, axis, index, value

   expval=FIX(round(ALOG10(value)))


   RETURN, STRJOIN('10!U'+STRTRIM(STRING(expval),2)+'!N')
END
