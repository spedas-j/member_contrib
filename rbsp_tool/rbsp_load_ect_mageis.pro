;+++++++++++++++++++++++++++++++++++++++++++++++++++++
; RBSP_LOAD_ECT_MAGEIS 
; 
; PURPOSE: 
;     read Van Allen Probes ECT/MagEIS L2 data files 
; 
; EXAMPLES: 
;     rbsp_load_ect_mageis, probes='a', level='l3' 
; 
; HISTORY: 
;     modified for automatic downloading by Kunihiro Keika, January 2014 
;     prepared by Kunihiro Keika, August 2013
; 
;+++++++++++++++++++++++++++++++++++++++++++++++++++++

pro rbsp_load_ect_mageis, probes=probes, level=level  

if not keyword_set(probes) then probes=['a','b']

cdf_leap_second_init
; rbsp_ect_init

for i=0, n_elements(probes)-1 do begin

   probe = probes[i] 

   ;Set up the structure including the local/remote data directories.
   source = file_retrieve(/struct)

   ;source.local_data_dir = root_data_dir()+'rbsp/rbsp'+probe+'/ect/mageis/'
   ;source.local_data_dir = root_data_dir()+'rbsp/ect/mageis/rbsp'+probe+'/'
   source.local_data_dir = root_data_dir()+'rbsp/ect/rbsp'+probe+'/mageis/leve'+level+'/'
   source.remote_data_dir = 'http://www.rbsp-ect.lanl.gov/data_pub/rbsp'+probe $ 
                          + '/mageis/leve'+level+'/'

  ;Relative path with wildcards for data files
   case level of
     'l2': begin
              ;pathformat = 'rbsp'+probe+'_rel02_ect-mageis-' $
              pathformat = 'rbsp'+probe+'_rel03_ect-mageis-' $
                         + strupcase(level)+'_YYYYMMDD_v?.?.?.cdf'
           endcase
     'l3': pathformat = 'rbsp'+probe+'_rel02_ect-mageis-' $
              + strupcase(level)+'_YYYYMMDD_v?.?.?.cdf'
   endcase


   ;Expand the wildcards in the relative file paths for designated
   ;time range, which is set by "timespan"
   relpathnames = file_dailynames(file_format=pathformat)

   ;Check the time stamps and download data files if they are newer.
   files = file_retrieve(relpathnames, _extra=source, /last_version)
print, 'FILES:', files 

   prefix = 'rbsp'+probe+'_ect_mageis_' ; Prefix for tplot variable name
   ; Read CDF files and deduce data as tplot variables
   cdf2tplot, file=files, verbose=source.verbose, prefix=prefix, /get_support_data


   tvar = prefix + ['FESA','FPSA'] 
   options, tvar, 'zlog', 1
   options, tvar, 'ylog', 1
   options, tvar, 'ytitle', 'Energy [keV]' 
   options, tvar, 'ysubtitle', '' 
   options, prefix+'FESA', 'yrange', [30,5000]
   options, prefix+'FESA', 'ystyle', 1
   options, prefix+'FESA', 'ztitle', 'Electron flux [cm!U-2!Ns!U-1!Nsr!U-1!NkeV!U-1!N]' 
   options, prefix+'FPSA', 'yrange', [40,2000]
   options, prefix+'FPSA', 'ystyle', 1
   options, prefix+'FPSA', 'ztitle', 'Proton flux [cm!U-2!Ns!U-1!Nsr!U-1!NkeV!U-1!N]' 

   ; FOR LEVEL-3 DATA
;   if level eq 'l3' then begin
;      get_data, prefix + 'FEDU', data=data, dlim=dlim
;      for pa = 0, n_elements(data.v1)-1 do begin
;         data_tmp = reform(data.y[*,*,pa])
;         tvar_tmp = prefix + 'FEDU' + '_pa'+string(format='(i3.3)',data.v1[pa])
;         store_data, tvar_tmp, data={x:data.x,y:data_tmp,v:data.v2}, dlim=dlim
;         options, tvar_tmp, 'ylog', 1
;         options, tvar_tmp, 'zlog', 1
;         options, tvar_tmp, 'spec', 1
;         options, tvar_tmp, 'ystyle', 1
;         options, tvar_tmp, 'yrange', [1,10]
;      endfor
;      for en = 0, n_elements(data.v2)-1 do begin
;         data_tmp = reform(data.y[*,en,*])
;         tvar_tmp = prefix + 'FEDU' + '_en'+string(format='(i3.3)',data.v2[en]*10)
;         store_data, tvar_tmp, data={x:data.x,y:data_tmp,v:data.v1}, dlim=dlim
;         options, tvar_tmp, 'zlog', 1
;         options, tvar_tmp, 'spec', 1
;         options, tvar_tmp, 'yrange', [0,180]
;         options, tvar_tmp, 'ystyle', 1
;      endfor
;   endif


endfor

;;---INDICES---
;;if keyword_set(dst) then kyoto_load_dst 
;if keyword_set(ae) then kyoto_load_ae 

;---TPLOT--- 
tplot, '*FESA *FPSA'


end 
