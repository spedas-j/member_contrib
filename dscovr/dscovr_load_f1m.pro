pro dscovr_load_f1m, debug=debug, dat=dat, $
  no_download=no_download, download_only=download_only 
  
  ;Initialize 
  erg_init 
  
  ;Set keywords
  if undefined(debug) then debug = 0 
  if undefined(no_download) then no_download = 0 
  no_update = no_download 
  if undefined(download_only) then download_only = 0 
  
  ;https://www.ngdc.noaa.gov/dscovr/data/2017/09/oe_f1m_dscovr_s20170916000000_e20170916235959_p20170917023755_pub.nc.gz
  remotedir = 'https://www.ngdc.noaa.gov/dscovr/data/' 
  localdir = root_data_dir() + 'dscovr/data/' 
  relfpathfmt = 'YYYY/MM/oe_f1m_dscovr_sYYYYMMDD000000_e??????????????_p??????????????_pub.nc.gz'
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
    append_array, sample_count, dat.sample_count
    append_array, p_vx_gse, dat.proton_vx_gse 
    append_array, p_vy_gse, dat.proton_vy_gse 
    append_array, p_vz_gse, dat.proton_vz_gse 
    append_array, p_vx_gsm, dat.proton_vx_gsm 
    append_array, p_vy_gsm, dat.proton_vy_gsm 
    append_array, p_vz_gsm, dat.proton_vz_gsm 
    append_array, p_speed, dat.proton_speed 
    append_array, p_density, dat.proton_density 
    append_array, p_temp, dat.proton_temperature 
    append_array, calibration_mode_flag, dat.calibration_mode_flag 
    append_array, maneuver_flag, dat.maneuver_flag 
    append_array, low_proton_density_sample_count_flag, dat.low_proton_density_sample_count_flag 
    append_array, low_proton_velocity_sample_count_flag, dat.low_proton_velocity_sample_count_flag
    append_array, overall_quality, dat.overall_quality
    
  endfor
  if n_elements( time ) lt 2 then return
  
  ;Create tplot variables containing the data 
  prefix = 'dscovr_f1m_'
  store_data, prefix + 'proton_vgse', data={x:time, y:[[p_vx_gse],[p_vy_gse],[p_vz_gse]] }
  store_data, prefix + 'proton_vgsm', data={x:time, y:[[p_vx_gsm],[p_vy_gsm],[p_vz_gsm]] }
  store_data, prefix + 'proton_speed', data={x:time, y:p_speed} 
  store_data, prefix + 'proton_density', data={x:time, y:p_density} 
  store_data, prefix + 'proton_temp', data={x:time, y:p_temp} 
  store_data, prefix + 'maneuver_flag', data={x:time,y:maneuver_flag}
  store_data, prefix + 'low_proton_density_smpl_cnt_flag', data={x:time, y:low_proton_density_sample_count_flag}
  store_data, prefix + 'low_proton_velocity_smpl_cnt_flag', data={x:time, y:low_proton_velocity_sample_count_flag}
  store_data, prefix + 'overall_quality', data={x:time, y:overall_quality}
  
  ;Remove abnormal values 
  tclip, prefix + 'proton_*', -10000., 10000., /overwrite 
  
  ;Decorate the variables 
  options, prefix + 'proton_*',  $
    labflag=1, colors='bgr', constant=[0.]
  options, prefix + 'proton_vgse', ytitle='DSCOVR!CF.Cup 1min!CVel_H+', $
    labels=['Vx_gse','Vy_gse','Vz_gse'], ysubtitle='[km/s]' 
  options, prefix + 'proton_vgsm', ytitle='DSCOVR!CF.Cup 1min!CVel_H+', $
    labels=['Vx_gsm','Vy_gsm','Vz_gsm'], ysubtitle='[km/s]'
  options, prefix + 'proton_speed', ytitle='DSCOVR!CF.Cup 1min!C|Vel_H+|', $
    ysubtitle='[km/s]'
  options, prefix + 'proton_density', ytitle='DSCOVR!CF.Cup 1min!CN_H+', $
    ysubtitle='[/cc]'
  options, prefix + 'proton_temp', ytitle='DSCOVR!CF.Cup 1min!CTemp_H+', $
    ysubtitle='[eV?]'

  
  return
end
