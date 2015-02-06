function read_cdf, fname, debug=debug
;; contact to T.T
;; USAGE: IDL> a=read_cdf('test.cdf')
if not keyword_set(fname) then return, ''

if ~file_test(fname) then return, ''

id = CDF_OPEN(fname)

cdf_control, id, get_numattr=natt
for i=0, total(natt)-1 do begin
  cdf_attinq, id, i, name, scope, maxentry, maxzentry
  if strmid(scope, 0,1) eq 'G' then begin
    cdf_control, id, attribute=name, get_attr_info=att_info
    attval = ''
    for j=0, att_info.maxgentry do begin 
    cdf_attget, id, name, j, attval1
    if j eq 0 then attval = attval1 else attval = [ attval, attval1 ]
    endfor
    print, name+'  ('+scope+'):     '+attval
  endif else begin
    print, name+'  ('+scope+')'
  endelse
endfor

;info=cdf_info(id);help,info.vars[12],/st
inq=cdf_inquire(id)
if inq.nvars ne 0 then begin
   n=inq.nvars
   if inq.nzvars ne 0 and inq.nzvars gt inq.nvars then begin
   n=inq.nzvars & zvariable=1
   endif
endif else if inq.nzvars ne 0 then begin
   zvariable=1
   n=inq.nzvars
endif

for i=0L, n-1 do begin
   varinq=cdf_varinq(id,i,zvariable=zvariable)
   if keyword_set(debug) then print, varinq.name, varinq.datatype, format='(2a15)'
   cdf_control, id, get_var_info=info, variable=i,zvariable=zvariable
   cdf_varget, id, i, var, zvariable=zvariable, rec_count=info.maxrecs+1
   if (i ne 0 ) then dat1=create_struct(dat,varinq.name,var) else dat1=create_struct(varinq.name,var)
   dat=dat1
endfor
cdf_close, id
dat=create_struct(dat1,'filename',fname)
if keyword_set(debug) then help, dat,/st
return, dat
end