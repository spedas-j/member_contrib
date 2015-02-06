pro generate_cdf_file_sample

  ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
  ;Name of a data file in the CDF format
  cdf_fname = 'susanoo_swimf_earth_run000_yyyymmdd_v00.cdf'

  ;Dummy time label
  caldat, julday( 5, 2, 2014, 0, 0, 0 ) + dindgen(1440)/1440., $
    month, day, year, hour, minute, second  ; for 1 min values during 2014-5-2 00:00 to 23:59 UT

  ;Dummy solar wind speed data
  swvel = 400. + 50.*sin( findgen(1440) )  ; dummy solar wind speed data of dimension of [1440]

  ;Dummy IMF vector data
  imfbvec = [ [ 3.*sin(findgen(1440)) ], [ 4.*cos(findgen(1440)) ], [ 2.*sin(findgen(1440)) ] ]
  ; dummy IMF 3-D vector data of dimension of [1440, 3]
  ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

  ;Initialize the leap second table for the TT2000 epoch format
  cdf_leap_second_init

  ;First remove the data file just in case
  file_delete, cdf_fname, /allow_nonexist
  ;Create a CDF file
  cdfid = cdf_create( cdf_fname, $
    /clobber, /col_major, /network_encoding, /host_decoding )

  ;Uncomment the line below to internally compress the data file
  ;cdf_compression, cdfid,  set_compression=5, set_gzip_lev=2

  ;Create global attributes, a. k. a. metadata or header information for a data file
  gatt_name = 'Project'
  gatt_content = 'SUSANOO>Space-weather-forecast-Usable System Anchored by Numerical Operations and Observations'
  gattid = cdf_attcreate( cdfid, gatt_name, /global_scope )
  cdf_attput, cdfid, gattid, 0, gatt_content

  gatt_name = 'Http_link'
  gatt_content = 'http://st4a.stelab.nagoya-u.ac.jp/susanoo/'
  gattid = cdf_attcreate( cdfid, gatt_name, /global_scope )
  cdf_attput, cdfid, gattid, 0, gatt_content

  gatt_name = 'Rules_of_use'
  gatt_content = 'We require all data users to cheer and even worship the marriage of Dr. Shiota and his wife on using the SUSANOO data for their researches.'
  gattid = cdf_attcreate( cdfid, gatt_name, /global_scope )
  cdf_attput, cdfid, gattid, 0, gatt_content

  ;Create variable attributes, a. k. a. metadata for each data variable
  vattid1 = cdf_attcreate( cdfid, 'FIELDNAM', /variable_scope )
  vattid2 = cdf_attcreate( cdfid, 'VAR_TYPE', /variable_scope )
  vattid3 = cdf_attcreate( cdfid, 'DEPEND_0', /variable_scope )

  ;Create data variables for physical quantities stored in a CDF file.
  ;;; epoch
  vid = $
    cdf_varcreate( $
    cdfid, 'epoch', 0, /CDF_TIME_TT2000, $
    /rec_vary, /zvariable )
  ;Actually put the data in a data variable
  cdf_tt2000, epoch_tt2000, year, month, day, hour, minute, second, /compute_epoch
  cdf_varput, cdfid, vid, epoch_tt2000, /zvariable

  ;Set the variable attributes
  cdf_attput, cdfid, vattid1, vid, 'Epoch for data in TT2000 format', /zvariable
  cdf_attput, cdfid, vattid2, vid, 'support_data', /zvariable
  ;cdf_attput, cdfid, vattid3, vid, '', /zvariable

  ;;; swvel
  vid = $
    cdf_varcreate( $
    cdfid, 'swvel', 0, /CDF_FLOAT, $
    /rec_vary, /zvariable )
  ;Actually put the data in a data variable
  cdf_varput, cdfid, vid, swvel, /zvariable

  ;Set the variable attributes
  cdf_attput, cdfid, vattid1, vid, 'Solar wind speed', /zvariable
  cdf_attput, cdfid, vattid2, vid, 'data', /zvariable
  cdf_attput, cdfid, vattid3, vid, 'epoch', /zvariable

  vid = $
    cdf_varcreate( $
    cdfid, 'imfbvec', 1, /CDF_FLOAT, $
    dimensions=[3], /rec_vary, /zvariable )
  ;Actually put the data in a data variable. 
  ;Don't forget transposing if the raw data is a multi-dimensional array!
  cdf_varput, cdfid, vid, transpose(imfbvec), /zvariable

  ;Set the variable attributes
  cdf_attput, cdfid, vattid1, vid, '3-D IMF vector', /zvariable
  cdf_attput, cdfid, vattid2, vid, 'data', /zvariable
  cdf_attput, cdfid, vattid3, vid, 'epoch', /zvariable



  ;Close the CDF file to finalize
  cdf_close, cdfid




  return
end

