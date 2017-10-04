pro dscovr_load_pos, debug=debug, dat=dat, $
  no_download=no_download, download_only=download_only 
  
  ;Initialize 
  erg_init 
  
  ;Set keywords
  if undefined(debug) then debug = 0 
  if undefined(no_download) then no_download = 0 
  no_update = no_download 
  if undefined(download_only) then download_only = 0 
  
  ;https://www.ngdc.noaa.gov/dscovr/data/2017/09/oe_pop_dscovr_s20170916000000_e20170916235959_p20170917023823_pub.nc.gz
  remotedir = 'https://www.ngdc.noaa.gov/dscovr/data/' 
  localdir = root_data_dir() + 'dscovr/data/' 
  relfpathfmt = 'YYYY/MM/oe_pop_dscovr_sYYYYMMDD000000_e??????????????_p??????????????_pub.nc.gz'
  if debug then begin
    dprint, 'remotedir = ', remotedir
    dprint, 'localdir  = ', localdir
  endif
  
  relfpath = file_dailynames( file_format=relfpathfmt, trange=trange ) 
  if debug then dprint, relfpath
  
  datfiles = $
    spd_download( $
      remote_path = remotedir, remote_file = relfpath $
      , local_path = localdir $
      , no_download=no_download, no_update=no_update, /unique $
      )
  if debug then dprint, datfiles 
  
  ;Stop here if download_only is set. 
  if download_only then return 
  
  idx = where( file_test( datfiles ), nfiles ) 
  if nfiles eq 0 then begin
    dprint, 'No data file exists for the designated time range.'
    return
  endif
  datfiles = datfiles[ idx ] 
  
  for i=0L, nfiles-1 do begin
    
    fpath_ncgz = datfiles[i] 
    fpath_nc = file_dirname(fpath_ncgz) + '/' + $
      strgsub( file_basename(fpath_ncgz), '.gz', '' )  
    
    ;This routine is available for IDL ver. 8.2.3 or newer 
    file_gunzip, fpath_ncgz 
    
    ;Open and read a NCDF file
    dat = '' ;Initialized
    dat = read_netcdf( fpath_nc ) 
    file_delete, fpath_nc, /allow_nonexist, /quiet 
    if ~is_struct(dat) then continue 
    
    ;Add data to arrays
    append_array, time, dat.time / 1000.D 
    append_array, pos_xgse, float(dat.sat_x_gse) 
    append_array, pos_ygse, float(dat.sat_y_gse) 
    append_array, pos_zgse, float(dat.sat_z_gse)  
    append_array, pos_xgsm, float(dat.sat_x_gsm)
    append_array, pos_ygsm, float(dat.sat_y_gsm)
    append_array, pos_zgsm, float(dat.sat_z_gsm)

    if debug then print, 'time = ', time_string(time)
    if debug then print, 'pos_xgse = ', dat.sat_x_gse
    
  endfor
  if n_elements( time ) lt 2 then return
  
  
  ;Create tplot variables containing the data 
  prefix = 'dscovr_'
  store_data, prefix + 'pos_gse', data={x:time, y:[[pos_xgse],[pos_ygse],[pos_zgse]] }
  store_data, prefix + 'pos_gsm', data={x:time, y:[[pos_xgsm],[pos_ygsm],[pos_zgsm]] }
  
  ;Remove abnormal values 
  tclip, prefix + 'pos_gs?', -2000000., 2000000., /overwrite 
  
  ;Decorate the variables 
  options, prefix + 'pos_gs?', ytitle='DSCOVR!CPOP', ysubtitle='[Re]', $
    labflag=1, colors='bgr', constant=[0.]
  options, prefix + 'pos_gse', labels=['Xgse','Ygse','Zgse'] 
  options, prefix + 'pos_gsm', labels=['Xgsm','Ygsm','Zgsm'] 
  
  
  
  return
end
