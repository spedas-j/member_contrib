pro modify_cdf_file_for_cdf2tplot, fpaths, debug=debug  
  
  npar = n_params() 
  if npar ne 1 then return 
  if ~keyword_set(debug) then debug = 0 
  
  for i=0L, n_elements(fpaths)-1 do begin
    fpath = fpaths[i] 
    if ~file_test(fpath) then continue 
    if debug then print, 'Searching '+fpath
    
    ;Open a CDF file and get the info structure
    id = cdf_open( fpath ) 
    info = cdf_inquire( id ) 
    
    ;To rename any attribute with a name containing "(" or ")". 
    for j=0, info.natts-1 do begin
      cdf_attinq, id, j, name, scope, maxent 
      
      if strpos( name, '(' ) ne -1 or strpos( name, ')' ) ne -1 then begin
        
        if debug then print, 'Detected! -->   ', j, ' ', scope, '   ', name
        
        ;Rename any attribute with an invalid name to a valid name by removing ( or ).  
        name_tmp = strjoin(strsplit(name,"(",/extract,/preserve_null ) ,'')
        newname = strjoin(strsplit(name_tmp,")",/extract,/preserve_null ) ,'')
        cdf_attrename, id, name, newname  
        
        if debug then begin
          print, 'Renamed -->   ', newname 
          cdf_attinq, id, j, name2, scope, maxent 
          print, 'Check -->   ', j, ' ', scope, '   ', name2
        endif
         
      endif
      
    endfor
    
    
    
    ;Close the CDF file
    cdf_close, id 
  endfor
  
  return
end
