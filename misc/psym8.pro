pro psym8, nofill=nofill 
  
  a = findgen(25)/24*2*!pi 
  usersym, cos(a), sin(a), fill=~keyword_set(nofill)  
  
end
