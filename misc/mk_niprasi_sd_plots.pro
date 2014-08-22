;+
; Execute this script by typing on the IDL prompt:
; IDL> .run mk_niprasi_sd_plots.pro
;

;;;;;;;;;;;;;;;;;;;; Settings ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

; Start & End times between which the combined 2D map plots are made.
st = time_double('2012-03-27/23:05:00')
et = time_double('2012-03-27/23:15:00')
dt = 10. ;[sec]

sd_list = 'pyk han' ; SD radars to be plotted. Multiple radars are acceptable as, for example, 'pyk han'
sd_losv_range = [-600,600]  ; the color bar range in [m/s] used for plotting SD LOS-V data

asi_list = 'hus'; NIPR ASIs to be plotted
asi_count_range = [20,140] ; the color bar range in [count/sample] used for plotting NIPR ASI data

glatc=70   ; geographic latitude and longitude of the center of the plot
glonc=346 ;
scale=20e+6  ;  the scale of the map drawn on the plot canvas. A larger value gives a larger area of the map.

outdir = './png/' ;the directory to which the generated plots are saved.

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;


thm_init & map2d_init

timespan, st, 60, /min & get_timespan, tr
erg_load_sdfit, site=sd_list, /get
zlim, 'sd_???_vlos_?', sd_losv_range[0], sd_losv_range[1]
iug_load_asi_nipr, site=asi_list

tt = st

window, 0, xs=800, ys=600
erase

while ( tt le et ) do begin

  ;Read data for a subsequent time range if the plotting time passed the previous data interval
  if tt lt tr[0] or tt gt tr[1] then begin
    timespan, tt, 60, /min & get_timespan, tr
    erg_load_sdfit, site=sd_list, /get
    zlim, 'sd_???_vlos_?', sd_losv_range[0], sd_losv_range[1]
    iug_load_asi_nipr, site=asi_list
  endif
  
  ;Prepare the 2D map plotting
  map2d_time, tt
  map2d_coord, 'geo'
  map2d_set, /erase, scale=scale, glatc=glatc, glonc=glonc
  
  ;Plot the NIPR ASI data
  asi_stns = strsplit( asi_list, /ext )
  loadct, 0
  overlay_map_asi_nipr, 'nipr_asi_'+asi_stns+'_0000', colorr=asi_count_range, $
    colorscalepos=[0.05,0.1,0.07,0.45], tlcharsize=2.0
  
  ;Plot the SD data
  sd_stns = strsplit( sd_list, /ext )
  loadct_sd, 44
  overlay_map_sdfit, 'sd_'+sd_stns+'_vlos_?', pixel=0.5, /notimelabel
  overlay_map_coast, col=40
  
  ;Dump the plot window to a png file
  if ~file_test(outdir) then file_mkdir, outdir
  
  fn = outdir+$
    'niprasi_sd_'+time_string(tt,tfor='YYYYMMDD_hhmmss')
  makepng, fn
  
  tt += dt 
  
endwhile

end




