; sample_script1.pro 
; A sample script to generate a polar plot for one time frame containing 
; THEMIS ASI images and footprints of THEMIS probes. The genrated 
; plot is saved as a png file in a directory set by output_dir (Line 15). 
; 
; To run this script, 
; IDL> del_data, 'th?_state_pos_ifoot*'  
; IDL> .r sample_script1.pro 

; Please run del_data command above to clear the pre-existing footprint data 
; so that the following command (sample_script1.pro) recalculates the footprint 
; positions. You need to do this when you change the solar wind-IMF input 
; values for the T96 model. 

  
  thm_init
  sd_init
  
  ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
  output_dir = 'mosaic'  ;Directory path where generated png files are saved. 
  
  ;For THEMIS ASI image
  asi_time ='2011-03-01/07:30:00'  ;date/time for which THEMIS/ASI data is drawn. 
  plot_site = 'snkq kuuj'  ;ASI stations that you want to plot
  center_glat = 57. ;[deg]  Geographical latitude of the center of the plot
  center_glon = -75. ;[deg] Geographical longitude of the center of the plot
  use_full_image = 0 ; 0: use thumbnail images,  1:use full resolution images
  
  ;For THEMIS footprint
  ts = '2011-03-01/05:00:00' ;Start date/time
  te = '2011-03-01/09:00:00' ;End date/time 
  thm_probes = 'e d'  ; Probes for which the footprints are drawn on the ASI images.
  colors = [1, 2, 3, 4, 6, 200 ]
  
  ;For field-line tracing with Tsyganenko 1996 model + IGRF 
  solarwind_dynamic_pressure = 1.0  ;[nPa]
  Dst = 0.0 ;[nT]
  imfby = 0.0 ;[nT]
  imfbz = 0.0 ;[nT] 
  
  autocalc_parmod = 0  ; Set 1 to automatically download the OMNI data and 
                                   ; generate the input parameters based on the time-varying 
                                   ; solar wind-IMF data for T96 model.  
  
  parmod = [solarwind_dynamic_pressure, Dst, imfby, imfbz ]
  
  
  ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
  
  file_mkdir, output_dir
  
  plotsites = strupcase( strsplit(plot_site, /ext) )
  thm_asi_stations,site,loc 
  idx = bytarr( n_elements(site) ) & idx[*] = byte(1) 
  for i=0, n_elements(plotsites)-1 do begin
    id = where( site eq plotsites[i], j ) 
    if id[0] ne -1 then idx[id[0]] = byte(0) 
  endfor
  ex_site = site[ where( idx ) ] 
  
  print, ex_site 
  
  
  sd_time, asi_time 
  
  thm_asi_create_mosaic,$
    asi_time,$
    thumb = ~use_full_image, $
    central_lat=center_glat,central_lon=center_glon, $
    scale = 20e+6, xsize = 800, ysize=600, $
    exclude = ex_site 
  loadct_sd, 43
  
  probes = strsplit( thm_probes, /ext ) 
  for i=0, n_elements(probes)-1 do begin
    probe = strlowcase(probes[i] )
    prefix = 'th'+probe+'_state_pos_ifoot_geo_'
    ;del_data, prefix+'*' 
    if strlen(tnames(prefix+'lat')) lt 6 then $
      themis_ifoot, probe=probe, parmod=parmod, auto=autocalc_parmod 
    if strlen(tnames(prefix+'lat')) gt 6 then begin
      print, 'overlay_map_sc_ifoot'
      overlay_map_sc_ifoot, prefix+'lat', prefix+'lon', [ts,te], $
        /geo_plot, trace_color=colors[i], $
        plottime = asi_time, $
        /draw_plottime_fp, fp_time=asi_time, fp_color=colors[i] 
    endif
    
  endfor
  
  
  png_fname = output_dir + '/' + time_string(asi_time, tfor='YYYYMMDD_hhmmss')
  makepng, png_fname 
  
end

