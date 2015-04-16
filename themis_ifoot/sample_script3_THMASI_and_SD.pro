; sample_script3.pro
; A sample script to generate a series of polar plots for a time interval
; set by asi_ts and asi_te (Line 20, 21) containing
; THEMIS ASI images, footprints of THEMIS probes, and SuperDARN LOSV data. 
; The generated plots are saved as png files in a directory set by output_dir (Line 19).
;
; To run this script,
; IDL> .r sample_script3.pro

; It is highly recommended to run sample_script1.pro in advance so that
; you can avoid doing the calculatoin of the footprint data over again.

thm_init
sd_init

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;Overall settings for plots

output_dir = 'mosaic'  ;Directory path where generated png files are saved.
asi_ts = '2011-03-01/08:02:00' ;start date/time for a series of mosaic plots
asi_te = '2011-03-01/08:12:00' ; end date/time for a series of mosaic plots
dt = 60. ;[sec]  time step between each plot. Set 3.0 to plot all mosaic plots for each 3 sec.
center_glat = 57. ;[deg] Geographical latitude of the center of the plot
center_glon = -75. ;[deg] Geographical longitude of the center of the plot
map_scale = 23e+6 ;The scale of drawn world map in IDL internal unit.
                                  ; 20e+6 : The nominal scale usually used for thm_asi_create_mosaic script
                                  ; Smaller values (e. g., 10e+6, 5e+6) give a map zoomed in to its center
                                  ; Larger values (e.g., 30e+6, 50e+6) give a map zoomed out to take a larger area in a plot.

;For THEMIS/GBO all-sky imager data
plot_site = 'snkq kuuj' ; THEMIS ASI stations you want plot images for.
use_full_image = 1 ; 0: use thumbnail images,  1:use full resolution images
                                  ; CAUTION!  It may take a while to download a full resolution data.

;THEMIS footprint
thmifoot_ts = '2011-03-01/05:00:00' ;Start date/time
thmifoot_te = '2011-03-01/09:00:00' ;End date/time
thm_probes = 'e d'  ;THEMIS probes you want to plot footprints for.
                                   ;Leave this as just a blank string to prevent you from plotting THEMIS footprints.
colors = [1, 2, 3, 4, 6, 200 ]

;For SuperDARN data
sd_radars = 'sas'  ;List of radars whose data are plotted. Set this like 'sas kap bks' for a multi radar plot.
losv_range = [-500,500] ;[m/s] SD plots are color-coded with this range in terms of line-of-sight Doppler vel.
sd_pixel_size = 0.7 ;Scale (0.0-1.0) of each drawn pixel relative to the real size of 1 range gate x 1 beam pixel.
                                   ; Drawing SD data with smaller pixels is useful to make image data behind radar data
                                   ; more visible to you.

;For field-line tracing with Tsyganenko 1996 model + IGRF
solarwind_dynamic_pressure = 1.0  ;[nPa]
Dst = 0.0 ;[nT]
imfby = 0.0 ;[nT]
imfbz = 0.0 ;[nT]

parmod = [solarwind_dynamic_pressure, Dst, imfby, imfbz ]


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

file_mkdir, output_dir

;Check THM/GBO ASI station names
plotsites = strupcase( strsplit(plot_site, /ext) )
thm_asi_stations,site,loc
idx = bytarr( n_elements(site) ) & idx[*] = byte(1)
for i=0, n_elements(plotsites)-1 do begin
  id = where( site eq plotsites[i], j )
  if id[0] ne -1 then idx[id[0]] = byte(0)
endfor
ex_site = site[ where( idx ) ]

print, ex_site

;Load SD data
ts = time_struct(asi_ts)
timespan, string(ts.year,ts.month, ts.date, '(i4.4,"-",i2.2,"-",i2.2)')
erg_load_sdfit, site=sd_radars, /get


;The for loop to generate a plot for each time frame.
for plottime = time_double(asi_ts), time_double(asi_te), dt do begin

  ;Set the time for which all data are plotted in the following part
  sd_time, plottime

  ;Generate a THEMIS/GBO ASI mosaic plot
  thm_asi_create_mosaic,$
    time_string(plottime),$
    thumb = ~use_full_image, $
    central_lat=center_glat,central_lon=center_glon, $
    scale = map_scale, xsize = 800, ysize=600, $
    exclude = ex_site

  ;Reset the color table to the nominal one.
  loadct_sd, 43

  ;Superpose footprint traces of THEMIS probes
  thm_probes_validated = thm_check_valid_name( $
    thm_probes,  ['a','b','c','d', 'e'], /ignore_case, /no_warning )
  probes = strsplit( thm_probes, /ext )
  for i=0, n_elements(probes)-1 do begin
    probe = strlowcase(probes[i] )
    if strlen(probe) eq 0 then continue
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

  ;Overlay the SD data
  radars = strsplit(sd_radars, /ext)
  if strlen(radars[0]) gt 0 then begin

    loadct_sd, 44 ;Change the color table to the CUTLASS type color table

    for i=0, n_elements(radars)-1 do begin
      rdr = radars[i]
      if strlen(rdr) eq 0 then continue
      varnames = tnames('sd_'+rdr+'_vlos_?')
      if strlen(varnames[0]) eq 0 then continue

      for j=0, n_elements(varnames)-1 do begin
        varn = varnames[j]
        zlim, varn, losv_range[0], losv_range[1]
        overlay_map_sdfit, varn, pixel_scale=sd_pixel_size, /notimelabel

      endfor


    endfor
  endif


  ;Save the generated plot as a png file in the desginated directory.
  png_fname = output_dir + '/' + time_string(plottime, tfor='YYYYMMDD_hhmmss')
  makepng, png_fname


endfor


end

