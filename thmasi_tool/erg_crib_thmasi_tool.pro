PRO erg_crib_thmasi_tool
  
  thm_init
  sd_init
  
  timespan, '2007-04-09/07:00:00', 1, /hour
  thm_load_asi, site='fsim' 
  thm_load_asi_cal, 'fsim', cal_fsim
  
  sd_time, 0706 
  sd_map_set, /erase, force_scale=1.5e+7,center_glat=60,center_glon=240, /geo
  overlay_map_thmasi, 'thg_asf_fsim', cal=cal_fsim, /geo 
  overlay_map_coast, /geo
  
  
  
  return
end
