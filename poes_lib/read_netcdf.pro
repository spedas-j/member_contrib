;+
; FUNCTION READ_NETCDF
;
;  open and read a NetCDF file and return a structure
;  which contains variables in the file
;
; EXAMPLE:
;  d=read_netcdf(file)
; 
; HISTORY:
;  Created by Satoshi Kurita, April 2015
;
; AUTHOR:
;  Satoshi Kurita, STEL/Nagoya University (kurita@stelab.nagoya-u.ac.jp)
;-

function read_netcdf, fname

if not keyword_set(fname) then dprint,'filename must be set. Abort.'

if file_test(fname) then begin

	id=ncdf_open(fname)
	inq=ncdf_inquire(id)
	n=inq.nvars

	for i=0L, n-1 do begin

		varinq=ncdf_varinq(id,i)
;		if strlowcase(strmid(varinq.name,0,3)) ne 'ted' then $
		ncdf_varget, id, i, var
		if (i ne 0 ) then dat1=create_struct(dat,varinq.name,var) $
					 else dat1=create_struct(varinq.name,var)
		dat=dat1

	endfor

	ncdf_close, id
	dat=create_struct(dat1,'filename',fname)

	return, dat

endif else dprint,'File '+fname+' does not exist. Abort'

end