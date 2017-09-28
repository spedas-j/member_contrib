pro dscovr_load_m1m, debug=debug, dat=dat, $
  no_download=no_download, download_only=download_only 
  
  ;Initialize 
  erg_init 
  
  ;Set keywords
  if undefined(debug) then debug = 0 
  if undefined(no_download) then no_download = 0 
  no_update = no_download 
  if undefined(download_only) then download_only = 0 
  
  ;https://www.ngdc.noaa.gov/dscovr/data/2017/09/oe_m1m_dscovr_s20170916000000_e20170916235959_p20170917023317_pub.nc.gz
  remotedir = 'https://www.ngdc.noaa.gov/dscovr/data/' 
  localdir = root_data_dir() + 'dscovr/data/' 
  relfpathfmt = 'YYYY/MM/oe_m1m_dscovr_sYYYYMMDD000000_e??????????????_p??????????????_pub.nc.gz'
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
    append_array, measurement_mode, dat.measurement_mode
    append_array, bt, dat.bt 
    append_array, bx_gse, dat.bx_gse 
    append_array, by_gse, dat.by_gse 
    append_array, bz_gse, dat.bz_gse  
    append_array, bx_gsm, dat.bx_gsm 
    append_array, by_gsm, dat.by_gsm 
    append_array, bz_gsm, dat.bz_gsm 
    append_array, backfill_flag, dat.backfill_flag 
    append_array, fill_flag, dat.fill_flag 
    append_array, calibration_mode_flag, dat.calibration_mode_flag 
    append_array, maneuver_flag, dat.maneuver_flag 
    append_array, low_sample_count_flag, dat.low_sample_count_flag 
    append_array, overall_quality, dat.overall_quality
    
  endfor
  if n_elements( time ) lt 2 then return
  
  
  ;Create tplot variables containing the data 
  prefix = 'dscovr_m1m_'
  store_data, prefix + 'bgse', data={x:time, y:[[bx_gse],[by_gse],[bz_gse]] }
  store_data, prefix + 'bgsm', data={x:time, y:[[bx_gsm],[by_gsm],[bz_gsm]] }
  store_data, prefix + 'overall_quality', data={x:time, y:overall_quality } 
  
  ;Remove abnormal values 
  tclip, prefix + 'bgs?', -1000., 1000., /overwrite 
  
  ;Decorate the variables 
  options, prefix + 'bgs?', ytitle='DSCOVR!CMag 1min', ysubtitle='[nT]', $
    labflag=1, colors='bgr', constant=[0.]
  options, prefix + 'bgse', labels=['Bx_gse','By_gse','Bz_gse'] 
  options, prefix + 'bgsm', labels=['Bx_gsm','By_gsm','Bz_gsm'] 
  
  ylim, prefix + 'overall_quality', -0.5, 1.5 
  
  
  return
end
