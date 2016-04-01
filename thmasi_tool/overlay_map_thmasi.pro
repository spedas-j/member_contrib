pro overlay_map_thmasi, asi_vns, cal=cal, imgscale=imgscale, geo_plot=geo_plot, $
  debug=debug, $
  charscale=charscale, $
  notimelabel=notimelabel, timelabelpos=timelabelpos
  
  
  ;Need at least one variable to be plotted
  npar = n_params()
  if npar lt 1 then return
  vns = tnames(asi_vns)
  if strlen(vns[0]) lt 2 then return
  
  ;Default scale
  default_cntscale = [0.01e+3, 2.0e+3]
  if ~keyword_set(imgscale) then imgscale = default_cntscale
    
  ;Initialize
  sd_init
  
  ;Obtain the plot time
  plot_time = !map2d.time
  
  ;Initialize the combined arrays
  cmb_img = '' & cmb_cin = ''
  cmb_ele = '' & cmb_corner_lats = '' & cmb_corner_lons = ''
  cmb_www = ''
  
  ; Loop for loading data for each station 
  for i=0L, n_elements(vns)-1 do begin
    
    vn = vns[i]
    prefix = strmid( vn, 0, 8 )
    dtype = strmid( prefix, 4,3 ) ; ast or asf
    stn = strmid( vn, 8,4 ) ;3-letter station code
    if strpos(dtype,'ast') eq 0 then is_thumb=1 else is_thumb=0
    
    ;Obtain image data for the designated time
    get_data, vn, data=d
    tidx = nn( d.x, plot_time )
    img = reform( d.y[ tidx, *, * ] )  ; [256,256] or [32,32]
    if is_thumb then begin  ;array rotation mimicing Line 173 in thm_mosaic_array.pro
      img = rotate( img, 8 )
    endif else begin
      bkgd = mean( img[0:10,0:10] )  ;Define the background count by averaging counts near the bottom-left corner
      img_sbtrctd = img - bkgd  ;Subtraction of background count
      img = img_sbtrctd
    endelse
    
    ;Check if data for the designated time is obtained or not.
    dt = abs( plot_time - d.x[tidx] )
    if dt lt 2. then note = '  (ok)' else note = ' !!! NOT within 2 sec !!! ... skip plotting'
    print, '========== '+strupcase(stn)+' =========='
    print, 'Designated time: '+time_string(plot_time)
    print, '  ASI data time: '+time_string(d.x[tidx]), tidx, note
    d = 0L ;Initialize the variable to save the memory
    if dt ge 2. then continue  ;Skip plotting and move to the next stations
    
    ;For debugging
    if keyword_set(debug) then print, 'min/max count:', minmax(img) 
    if keyword_set(debug)and not is_thumb then print, 'bgd_cnt:',bkgd
    
    ;Set the scale for image data
    nscale = (size(imgscale))[0]
    case (nscale) of
      1: begin  ;given as a 1-D array, used for all data
        scl = imgscale
      end
      2: begin  ;given as a 2-D array, used each for each data
        narr = n_elements( imgscale[0,*] )
        scl = reform( imgscale[ 0:1, i < (narr-1) ] )
      end
      else: begin
        print, 'WARNING: invalid array is given for scale: Use default!'
        scl = default_cntscale
      end
    endcase

    ;Set color level for contour
    clmax = !d.table_size-1
    clmin = 8L
    cnum = clmax-clmin
    ;Calculate the color index for image data
    cscl = (img-scl[0]) / (scl[1]-scl[0]) * ( cnum ) + clmin  
    cin = long( ( cscl > clmin ) < clmax )
    ;;if keyword_set(debug) then print, minmax(cin)
    
    ;Load the cal file
    if keyword_set(cal) then calstr = cal[i] else $
      thm_load_asi_cal, stn, calstr
    
    ;Obtain the elevation array
    idx = where( strpos( calstr.vars[*].name, vn+'_elev' ) eq 0 )
    if idx[0] ne -1 then elevs = *(calstr.vars[idx[0]].dataptr)
    
    ;Generate the lat,lon arrays
    ele = elevs[*] ; converting to a 1-D array
    npxl = n_elements(ele) ; # of pixels: 1024 for ast, 65536 for asf
    n1 = n_elements( elevs[*,0] )  ; 32 for ast, 256 for asf 
    corner_lats = fltarr( npxl, 4 ) 
    corner_lons = fltarr( npxl, 4 ) 
    www = intarr(npxl) -1 
    
    if NOT is_thumb then begin  ;For asf
      idx = where( strpos( calstr.vars[*].name, vn+'_glat' ) eq 0 )
      if idx[0] ne -1 then glats = reform( (*(calstr.vars[idx[0]].dataptr))[1, *, *] ) ;[257, 257] 
      idx = where( strpos( calstr.vars[*].name, vn+'_glon' ) eq 0 )
      if idx[0] ne -1 then glons = reform( (*(calstr.vars[idx[0]].dataptr))[1, *, *] ) ;[257, 257] 
      
      k1=0L
      for j1=0L,n1-1 do for i1=0L,n1-1 do begin
        corner_lats[k1,0:3] = transpose( glats[ [i1,i1,i1+1,i1+1],[j1,j1+1,j1+1,j1] ] )
        corner_lons[k1,0:3] = transpose( glons[ [i1,i1,i1+1,i1+1],[j1,j1+1,j1+1,j1] ] )
        if total( finite( corner_lats[k1,0:3] ) ) eq 4 then www[k1]=1
        k1 = k1 + 1L
      endfor
      
    endif else begin  ;For ast
      idx = where( strpos( calstr.vars[*].name, vn+'_glat' ) eq 0 )
      if idx[0] ne -1 then glats = *(calstr.vars[idx[0]].dataptr) ;[4, 1024] 
      idx = where( strpos( calstr.vars[*].name, vn+'_glon' ) eq 0 )
      if idx[0] ne -1 then glons = *(calstr.vars[idx[0]].dataptr) ;[4, 1024] 
      
      wt = total( finite(glats), 1 ) ;[1024]
      idx = where( wt eq 4 )
      if idx[0] ne -1 then www[idx] = 1
      corner_lats = transpose(glats)  ;[1024, 4]
      corner_lons = transpose(glons)
      
    endelse
    
    ;Merge data for each station to the combined arrays
    append_array, cmb_ele, ele
    append_array, cmb_img, img[*]
    append_array, cmb_cin, cin[*]
    append_array, cmb_corner_lats, corner_lats
    append_array, cmb_corner_lons, corner_lons
    append_array, cmb_www, www
    
  endfor

  ;Sort by increasing elevation angle
  a = sort(cmb_ele)
  cmb_ele = cmb_ele[a]
  cmb_img = cmb_img[a] & cmb_cin = cmb_cin[a]
  cmb_corner_lats = cmb_corner_lats[a,*] & cmb_corner_lons = cmb_corner_lons[a,*]
  cmb_www = cmb_www[a]
  
  ;AACGM conversion
  
  if ~keyword_set(geo_plot) then begin
    
    if keyword_set(debug) then print, 'converting to AACGM  (', n_elements(cmb_ele), '  pixels)'
    
    ts = time_struct(plot_time)
    glat = cmb_corner_lats
    glon = cmb_corner_lons
    alt = glat & alt[*] = 110. ; Assuming 110 [km]
    aacgmconvcoord, glat,glon,alt, mlat,mlon,err, /to_aacgm
    yrs = fix(mlat) & yrs[*] = ts.year
    yrsec = long(mlat) & yrsec[*] = long( (ts.doy-1)*86400. + ts.sod )
    mlt = aacgmmlt( yrs, yrsec, mlon ) 
    mlt = ( ( mlt + 24. ) mod 24. ) / 24.*360. ; [deg]
    
    cmb_corner_lats = mlat
    cmb_corner_lons = mlt
  endif
  
  ;Paint each pixel 
  if keyword_set(debug) then print, 'Now drawing...'
  for n=0L, n_elements(cmb_ele)-1 do begin
      
      if cmb_ele[n] ge 8 and finite( cmb_img[n] ) and cmb_www[n] eq 1 then begin
        
        polyfill, reform(cmb_corner_lons[n,*]), reform(cmb_corner_lats[n,*]), $
            color=cmb_cin[n] 
          
      endif
      
  endfor
    
  
  ;Post processing ;;;;;;;;;;;;;;;;;;;;

  ;Size of characters
  if ~keyword_set(charscale) then charscale=1.0
  charsz = !sdarn.sd_polar.charsize * charscale
  
  ;Time label
  if ~keyword_set(notimelabel) then begin
    t = plot_time
    if keyword_set(timelabelpos) then begin ;Customizable by user
      x = !x.window[0] + (!x.window[1]-!x.window[0])*timelabelpos[0] 
      y = !y.window[0] + (!y.window[1]-!y.window[0])*timelabelpos[1]
    endif else begin  ;Default position
      x = !x.window[0]+0.02 & y = !y.window[0]+0.02
    endelse
    
    tstr = time_string(t, tfor='hh:mm:ss')+' UT'
    XYOUTS, x, y, tstr, /normal, $
      font=1, charsize=charsz*2.5, color=!p.color    
  endif
  
  
  
  
  return
end

