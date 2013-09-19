pro sample_script
  
  st = time_double('2010-04-08/07:15:00')
  et = time_double('2010-04-08/07:38:00')
  dt = 6. ;[sec]
  
  ;thm_init & sd_init
  ;timespan, st, 1, /hour
  ;thm_load_asi, site=['fsim','fsmi','fykn']
  
  tt = st
  
  while ( tt lt et ) do begin
    
    sd_time, tt
    sd_map_set, /erase, force_scale=1.1e+7,center_glat=63,center_glon=230, /geo
    overlay_map_thmasi, ['thg_asf_fs??'], charsc=1.7,imgsca=[10.,4e+3],/geo  & overlay_map_coast,/geo
    
    fn = 'asi_'+time_string(tt,tfor='hhmmss')
    makepng, fn
    
    tt += dt
    
  endwhile
  
  return
end
