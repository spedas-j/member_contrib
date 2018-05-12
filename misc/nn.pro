;+
; FUNCTION nn
;   A much faster version of the nn() bundled in SPEDAS
;
; IDL> a = [ 0, 1,2,3,4,5,6,7,8,9 ]
; IDL> b = [ 1.2, 4.3, 8.8 ]
; IDL> nn2( a, b )
;           1           4           9
;
;!!!CAUTION!!!
;This routine accepts a simple numerical array as arguments, and does
;not work directly with a tplot variable, SPEDAS data structure {x:??,
;y:??}, or a time string, which can be given to the original nn() in
;SPEDAS. If you want to give time values, they should be converted to
;decimal UNIX times with time_double() beforehand. 
;-
Function nn,  time1, time2

  w = value_locate( time1, time2 )
  w1 = (w > 0) < (n_elements(time1)-1)
  w2 = ((w1+1) > 0) < (n_elements(time1)-1)
  dt1 = abs(time2 - time1[w1])
  dt2 = abs(time2 - time1[w2])
  w =  [ [w1], [w2] ]
  dt = [ [dt1], [dt2] ]
  mndt = min( dt, dim=2, imin )
  if n_elements(w[imin]) eq 1 then return, (w[imin])[0] else return, w[imin]

end

