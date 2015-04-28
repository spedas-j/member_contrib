; sample_script2.pro
; A sample script to generate a series of polar plots for a time interval 
; set by asi_ts and asi_te (Line 18, 19) containing
; THEMIS ASI images and footprints of THEMIS probes. The genrated
; plots are saved as png files in a directory set by output_dir (Line 16).
; 
; To run this script, 
; IDL> .r sample_script2.pro 

; It is highly recommended to run sample_script1.pro in advance so that 
; you can avoid doing the calculatoin of the footprint data over again.  
  
  thm_init
  sd_init
  
  ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
  output_dir = 'mosaic'  ;Directory path where generated png files are saved. 
  
  asi_ts = '2011-03-01/05:30:00' ;start date/time for a series of mosaic plots
  asi_te = '2011-03-01/08:30:00' ; end date/time for a series of mosaic plots
  dt = 60. ;[sec]  time step between each plot. Set 3.0 to plot all mosaic plots for each 3 sec. 
  plot_site = 'snkq kuuj' ; THEMIS ASI stations you want plot images for. 
  center_glat = 57. ;[deg] Geographical latitude of the center of the plot
  center_glon = -75. ;[deg] Geographical longitude of the center of the plot 
  use_full_image = 0 ; 0: use thumbnail images,  1:use full resolution images
                               ; CAUTION!  It may take a while to download a full resolution data. 
  
  ;THEMIS footprint
  thmifoot_ts = '2011-03-01/05:00:00' ;Start date/time
  thmifoot_te = '2011-03-01/09:00:00' ;End date/time 
  thm_probes = 'e d'  ;THEMIS probes you want to plot footprints for
  colors = [1, 2, 3, 4, 6, 200 ]
  
  ;For field-line tracing with Tsyganenko 1996 model + IGRF 
  solarwind_dynamic_pressure = 1.0  ;[nPa]
  Dst = 0.0 ;[nT]
  imfby = 0.0 ;[nT]
  imfbz = 0.0 ;[nT] 
  
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
  
  
  for plottime = time_double(asi_ts), time_double(asi_te), dt do begin
  
  sd_time, plottime 
  
  thm_asi_create_mosaic,$
    time_string(plottime),$
    thumb = ~use_full_image, $
    central_lat=center_glat,central_lon=center_glon, $
    scale = 20e+6, xsize = 800, ysize=600, $
    exclude = ex_site 
  loadct_sd, 43
  
  probes = strsplit( thm_probes, /ext ) 
  for i=0, n_elements(probes)-1 do begin
    probe = strlowcase(probes[i] )
    prefix = 'th'+probe+'_state_pos_ifoot_geo_'
    if strlen(tnames(prefix+'lat')) lt 6 then $
      themis_ifoot, probe=probe, parmod=parmod 
    if strlen(tnames(prefix+'lat')) gt 6 then begin
      print, 'overlay_map_sc_ifoot'
      overlay_map_sc_ifoot, prefix+'lat', prefix+'lon', [thmifoot_ts,thmifoot_te], $
        /geo_plot, trace_color=colors[i], $
        plottime = plottime, $
        /draw_plottime_fp, fp_time=plottime, fp_color=colors[i] 
    endif
    
  endfor
  
  
  png_fname = output_dir + '/' + time_string(plottime, tfor='YYYYMMDD_hhmmss')
  makepng, png_fname 
  
  
  endfor
  
  
end

