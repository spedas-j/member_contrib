;+
; PROCEDURE: RBSP_LOAD_EMFISIS_HFR
; A sample program to load the EMFISIS HFR data by downloading 
; data files from UIOWA. 
;
; You have to install the latest version of TDAS bleeding edge to 
; use this routine. 
; 
; CAUTION!!: This procedure is the very preliminary one, likely including 
; serious bugs/errors. Please let the author (T. Hori) know if you find 
; any bugs. 
;-

PRO rbsp_load_emfisis_hfr, probes=probes

  if ~keyword_set(probes) then probes = ['a','b'] 
  
  rbsp_emfisis_init 
  
  for i=0, n_elements(probes)-1 do begin 
  
  probe = probes[i] 
  
  ;Set up the structure including the local/remote data directories.
  source = file_retrieve( /struct )
  source.local_data_dir = root_data_dir()+'rbsp/rbsp'+probe+'/emfisis/hfr/'
  source.remote_data_dir = 'http://emfisis.physics.uiowa.edu/Flight/RBSP-'+strupcase(probe)+'/'
  
  ;Relative path with wildcards for data files
  pathformat = 'L2/YYYY/MM/DD/rbsp-'+probe+'_HFR-spectra_emfisis-L2_YYYYMMDD_v?.?.?.cdf'
  
  ;Expand the wildcards in the relative file paths for designated
  ;time range, which is set by "timespan".
  relpathnames = file_dailynames(file_format=pathformat)
  
  ;Check the time stamps and download data files if they are newer
  files = file_retrieve(relpathnames, _extra=source, /last_version)
  
  prefix = 'rbsp'+probe+'_' ;Prefix for tplot variable name
  ; Read CDF files and deduce data as tplot variables
  cdf2tplot,file=files,verbose=source.verbose,prefix=prefix
  
  varn = 'rbsp'+probe+'_HFR_Spectra'
  get_data, varn, data=d, dl=dl, lim=lim
  store_data, varn, data={x:d.x, y:d.y, v:reform(d.v[0,*]) }
  ylim, varn, 0,0, 1
  zlim, varn, 0,0, 1
  options, varn, 'ytitle', 'Freq [Hz]'
  options, varn, 'ysubtitle', ''
  options, varn, 'ztitle', dl.ysubtitle
  
  
  endfor
  
  return
end

