;+
; RBSP_LOAD_ECT_MAGEIS2
; 
; PURPOSE: 
;     read Van Allen Probes ECT/MagEIS data files 
; 
; EXAMPLES: 
;     rbsp_load_ect_mageis, probes='a', level='l3' 
; 
; HISTORY: 
;
;     prepared by Kunihiro Keika, August 2013
;     
;     modified for automatic downloading by Kunihiro Keika, January 2014 
;     
;     modified and renamed by Satoshi Kurita, 2015-09-15  
;-

pro rbsp_load_ect_mageis2, probes=probes, level=level  

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

;   Relative path with wildcards for data files

;========= OLD CODE ===========
;   case level of
;     'l2': begin
;               pathformat = 'rbsp'+probe+'_rel02_ect-mageis-' $
;              pathformat = 'rbsp'+probe+'_rel03_ect-mageis-' $
;                         + strupcase(level)+'_YYYYMMDD_v?.?.?.cdf'
;           endcase
;     'l3': pathformat = 'rbsp'+probe+'_rel02_ect-mageis-' $
;              + strupcase(level)+'_YYYYMMDD_v?.?.?.cdf'
;   endcase
;========= OLD CODE ===========


   pathformat = 'rbsp'+probe+'_rel03_ect-mageis-' $
                + strupcase(level)+'_YYYYMMDD_v*.cdf'


   ;Expand the wildcards in the relative file paths for designated
   ;time range, which is set by "timespan"
   relpathnames = file_dailynames(file_format=pathformat)

   ;Check the time stamps and download data files if they are newer.

   ;By SK on 2015-09-15
   ;Use spd_download.pro instead of file_retrieve.pro
   ;spd_download.pro is available in the latest SPEDAS bleeding edge 

   files = spd_download(remote_file=relpathnames,remote_path=source.remote_data_dir,$
   local_path=source.local_data_dir,/last_version)
   
   prefix = 'rbsp'+probe+'_ect_mageis_' ; Prefix for tplot variable name
   ; Read CDF files and deduce data as tplot variables
   cdf2tplot, file=files, verbose=source.verbose, prefix=prefix;, /get_support_data

   if level eq 'l2' then begin

     tvar = prefix + ['FESA','FESA_CORR','FESA_ERROR','FESA_CORR_ERROR','FPSA'] 
     options, tvar, 'zlog', 1
     options, tvar, 'ylog', 1
     options, tvar, 'ytitle', 'Energy [keV]' 
     options, tvar, 'ysubtitle', '' 
     options, tvar[0:3], 'yrange', [30,5000]
     options, tvar[0:3], 'ystyle', 1
     options, tvar[0:1], 'ztitle', 'Electron flux [cm!U-2!Ns!U-1!Nsr!U-1!NkeV!U-1!N]' 
     options, tvar[2:3], 'ztitle', 'd(flux)/flux [%]' 
     options, tvar[4], 'yrange', [40,2000]
     options, tvar[4], 'ystyle', 1
     options, tvar[4], 'ztitle', 'Proton flux [cm!U-2!Ns!U-1!Nsr!U-1!NkeV!U-1!N]' 

   endif

;   FOR LEVEL-3 DATA
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

end 
