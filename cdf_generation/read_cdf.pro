function read_cdf, fname, debug=debug
  ;; contact to T.T
  ;; USAGE: IDL> a=read_cdf('test.cdf')
  if not keyword_set(fname) then return, ''
  
  if ~file_test(fname) then return, ''
  
  ;Open a CDF file
  id = CDF_OPEN(fname)
  
  ;Obtain glocal and variable attributes from the CDF file and 
  ;print them on terminal. Both the attribute name and content are 
  ;displayed for a global attribute while only the name is shown 
  ;for a variable attribute. 
  cdf_control, id, get_numattr=natt  ;Obtain the number of attributes stored in a CDF file.
  for i=0, total(natt)-1 do begin
    cdf_attinq, id, i, name, scope, maxentry, maxzentry
    if strmid(scope, 0,1) eq 'G' then begin ;For a global attribute
      cdf_control, id, attribute=name, get_attr_info=att_info
      attval = ''
      for j=0, att_info.maxgentry do begin
        cdf_attget, id, name, j, attval1
        if j eq 0 then attval = attval1 else attval = [ attval, attval1 ]
      endfor
      print, name+'  ('+scope+'):     '+attval
    endif else begin ;For a variable attribute 
      print, name+'  ('+scope+')'
    endelse
  endfor
  
  ;Now draw data variables from a CDF file. 
  ;First inquire the number of variables contained in a CDF file. 
  inq=cdf_inquire(id)
  if inq.nvars ne 0 then begin ;finite number of rVariables exist
    n=inq.nvars
    if inq.nzvars ne 0 and inq.nzvars gt inq.nvars then begin ;For cases with both rVariables and zVariables
      n=inq.nzvars & zvariable=1
    endif
  endif else if inq.nzvars ne 0 then begin ;No rVariables, then check zVariables
    zvariable=1
    n=inq.nzvars
  endif
  
  ;Get the variable name by cdf_varinq(), and inquire the record 
  ;amount of a data variable by cdf_control, and draw the data variable itself 
  ;by cdf_varget. put them in a structure. 
  for i=0L, n-1 do begin ; the loop for drawing all data variables sequencially. 
    varinq=cdf_varinq(id,i,zvariable=zvariable)
    if keyword_set(debug) then print, varinq.name, varinq.datatype, format='(2a15)'
    cdf_control, id, get_var_info=info, variable=i,zvariable=zvariable
    cdf_varget, id, i, var, zvariable=zvariable, rec_count=info.maxrecs+1
    if (i ne 0 ) then dat1=create_struct(dat,varinq.name,var) else dat1=create_struct(varinq.name,var)
    dat=dat1
  endfor
  
  ;Close the CDF file. 
  cdf_close, id
  
  ;Finally, the file name of a CDF file is put in the structure. 
  dat=create_struct(dat1,'filename',fname)
  if keyword_set(debug) then help, dat,/st
  
  return, dat ;Return the resultant structure and finish!
end