; A generic program to draw footprint positions of spacecraft on the
; polar plot.
;
; Typically used keyword settings are shown below:
; overlay_map_sc_ifoot, 'erg_orb_l2_pos_ifoot_geo_lat', 'erg_orb_l2_pos_ifoot_geo_lon', $
; plottime=!map2d.time, draw_plot=!map2d.time, scname='ERG', changle=70, fp_symsize=3.5, $
; force_symsize=3.5,force_linethick=2, force_symthick=2

pro overlay_map_sc_ifoot, vn_glat, vn_glon, trange, $
  plottime = plottime, $
  force_chscale = force_chscale, changle = changle, $
  force_charthick = force_charthick, $
  choffset = choffset, $
  scname = scname, $
  geo_plot = geo_plot, $
  spellout = spellout, $
  notimelabel = notimelabel, $
  notick = notick, $
  trace_color = trace_color, $
  force_symsize = force_symsize, $
  force_linethick = force_linethick, $
  force_symthick = force_symthick, $
  draw_plottime_fp = draw_plottime_fp, fp_time = fp_time, $
  fp_psym = fp_psym, fp_symsize = fp_symsize, fp_symthick = fp_symthick, $
  fp_color = fp_color, $
  mintick = mintick, $
  typical_set = typical_set, $
  help = help
  compile_opt idl2

  ; Usage
  npar = n_params()
  if keyword_set(help) or (npar ne 2 and npar ne 3) then begin
    print, "Usage:"
    print, " overlay_map_sc_ifoot, 'thm_state_pos_ifoot_geo_lat', 'thm_state_pos_ifoot_geo_lon',['2011-03-01/04:00','2011-03-01/12:00'], /geo_plot"
    print, ''
    print, " overlay_map_sc_ifoot, 'erg_orb_l2_pos_ifoot_geo_lat', 'erg_orb_l2_pos_ifoot_geo_lon', changle=70, fp_symsize=3.5, force_symsize=3.5, force_linethick=2, force_symthick=2, plottime=!map2d.time, draw_plot=!map2d.time, scname='ERG'"
    RETURN
  endif

  ; Check the arguments

  npar = n_params()
  if npar ne 2 and npar ne 3 then return
  if npar eq 2 then begin
    get_timespan, tr
    trange = tr
  endif

  if strlen(tnames(vn_glat)) eq 0 then return
  if strlen(tnames(vn_glon)) eq 0 then return
  vn_glat = tnames(vn_glat)
  vn_glon = tnames(vn_glon)
  trange = time_double(trange)
  if keyword_set(plottime) then tp = time_double(plottime) $
  else tp = 0
  if undefined(choffset) then choffset = 0.

  if undefined(scname) then scname = (strsplit(vn_glat, '_', /ext))[0]

  ; Note that setting "typical_set" overwrites some keywords below.
  if keyword_set(typical_set) then begin
    fp_symsize = 3.5
    force_symsize = 3.5
    force_linethick = 2
    force_symthick = 2
  endif

  ; Case when typical_set is given (for testing)
  if keyword_set(typical_set) then begin

  end

  ; Set the paramters

  ts = trange[0]
  te = trange[1]

  ; Set the plot interval
  get_timespan, tr_orig
  timespan, [ts, te]

  ; Clip the data for the plot interval
  get_data, vn_glat, data = ttglat
  get_data, vn_glon, data = ttglon
  tsidx = nn(ttglat.x, ts)
  teidx = nn(ttglat.x, te)
  tglat = {x: ttglat.x[tsidx : teidx], y: ttglat.y[tsidx : teidx]}
  tglon = {x: ttglon.x[tsidx : teidx], y: ttglon.y[tsidx : teidx]}

  if keyword_set(geo_plot) or !map2d.coord eq 0 then begin
    tlat = tglat
    tlon = tglon
    tmlt = {x: tglon.x, y: tglon.y / 360. * 24.}
    ; a dummy variable to get through the following process
  endif else begin
    tstr = time_struct(ts)
    aacgmloadcoef, tstr.year
    h = replicate(100., n_elements(tglat.x))
    aacgmconvcoord, tglat.y, tglon.y, h, mlat, mlon, err, /to_aacgm
    tlat = {x: tglat.x, y: mlat}
    if tp le 0 then begin
      tstr = time_struct(tglat.x)
      yr = tstr.year
      yrsec = long((tstr.doy - 1) * 86400l + tstr.sod)
    endif else begin
      tstr = time_struct(tp)
      yr = replicate(tstr.year, n_elements(tglat.x))
      yrsec = replicate(long((tstr.doy - 1) * 86400l + tstr.sod), n_elements(tglat.x))
    endelse
    t = aacgmmlt(yr, yrsec, (mlon + 360.) mod 360.)
    tmlt = {x: tglat.x, y: t}
  endelse

  idx = where(tlat.x ge ts and tlat.x le te, cnt)
  if cnt lt 1 then begin
    print, 'No data in the time range'
    print, time_string([ts, te])
    RETURN
  endif
  tdbl_clip = tlat.x[idx]
  lat_clip = tlat.y[idx]
  mlt_clip = tmlt.y[idx]

  ; Convert (lat,mlt) to the plot coordinates
  phi_clip = mlt_clip / 24. * 360. ; [deg]

  x = phi_clip
  y = lat_clip

  ; ;;; Plot start

  ; Trajectory
  if keyword_set(force_linethick) then thick = force_linethick else thick = 1
  if ~keyword_set(trace_color) then trace_color = !p.color ; foreground color
  oplot, x, y, linestyle = 0, thick = thick, color = trace_color

  ; hourly ticks on trajectory
  tdbl = ts + 3600 * dindgen(round(te - ts) / 3600 + 1)
  if keyword_set(mintick) then tdbl = ts + 60 * dindgen(round(te - ts) / 60 + 1)
  lat = interpol(tlat.y, tlat.x, tdbl, /spline)
  mlt = interpol(tmlt.y, tmlt.x, tdbl, /spline)
  phi = mlt / 24. * 360.

  x = phi
  y = lat

  if !d.window eq 1 then chscale = 1.0 else chscale = 1.0
  if keyword_set(force_chscale) then chscale = force_chscale
  if keyword_set(force_charthick) then charthick = force_charthick else charthick = 1.
  if keyword_set(force_symsize) then symsz = force_symsize else symsz = 1.0
  if keyword_set(force_symthick) then symthk = force_symthick else symthk = 1.0
  if ~keyword_set(notick) then $
    oplot, x, y, linestyle = 0, psym = 1, color = trace_color, thick = symthk, symsize = symsz

  ; Draw the labels by the trajectory
  if ~keyword_set(notimelabel) then begin
    if ~keyword_set(changle) then changle = 0.
    dr = 1.
    chunit = 10. ; apart by dr*chunit*chsz
    chsz = !p.charsize * chscale
    xch0 = x[0]
    ych0 = y[0]
    devc = convert_coord(xch0, ych0, /data, /to_device) + choffset * [!d.x_size, !d.y_size]
    xyzch = convert_coord(devc[0] + dr * chsz * chunit * cos(changle * !dtor), $
      devc[1] + dr * chsz * chunit * sin(changle * !dtor), $
      /device, /to_data)
    xyouts, xyzch[0], xyzch[1], $
      time_string(tdbl[0], tformat = 'hh:mm') + '!C' + scname, $
      size = !p.charsize * chscale, orientation = changle, color = trace_color, $
      charthick = charthick

    xch0 = x[n_elements(tdbl) - 1]
    ych0 = y[n_elements(tdbl) - 1]
    devc = convert_coord(xch0, ych0, /data, /to_device) + choffset * [!d.x_size, !d.y_size]
    xyzch = convert_coord(devc[0] + dr * chsz * chunit * cos(changle * !dtor), $
      devc[1] + dr * chsz * chunit * sin(changle * !dtor), $
      /device, /to_data)
    xyouts, xyzch[0], xyzch[1], $
      time_string(tdbl[n_elements(tdbl) - 1], tformat = 'hh:mm'), $
      size = !p.charsize * chscale, orientation = changle, color = trace_color, $
      charthick = charthick
  endif

  ; Draw the footprint at the time given by plottime keyword
  if tp gt 0 and keyword_set(draw_plottime_fp) then begin
    if ~keyword_set(fp_time) then fp_time = tp
    if keyword_set(fp_psym) then fppsym = fp_psym else fppsym = 5
    if keyword_set(fp_symsize) then fpsymsz = fp_symsize else fpsymsz = 2
    if keyword_set(fp_symthick) then fpsymthick = fp_symthick else fpsymthick = 2
    if keyword_set(fp_color) then fpcol = fp_color else fpcol = !p.color

    px = [-1.0, -0.2, -0.2, 0.2, 0.2, 1.0, 1.0, 0.2, 0.2, -0.2, -0.2, -1.0]
    py = [0.7, 0.7, 1.0, 1.0, 0.7, 0.7, -0.7, -0.7, -1.0, -1.0, -0.7, -0.7]
    usersym, px, py, /fill

    idx = nn(tdbl_clip, fp_time)
    print, 'tp = ', time_string(fp_time)
    print, 'tdbl_clip[idx]= ', time_string(tdbl_clip[idx])
    plots, phi_clip[idx], lat_clip[idx], $
      psym = fppsym, $
      symsize = fpsymsz, $
      thick = fpsymthick, color = fpcol
  endif

  ; ;;; Plot end

  timespan, tr_orig ; Restore the original time range

  return
end
