;+
; RBSP_LOAD_ECT_REPT2 
; 
; PURPOSE: 
;     read Van Allen Probes ECT/REPT data files 
; 
; EXAMPLES: 
;     rbsp_load_ect_rept2, probes='a', level='l3' 
; 
; HISTORY: 
;
;     prepared by Satoshi Kurita, 2015-09-15  
;
;-

pro rbsp_load_ect_rept2, probes=probes, level=level  

if not keyword_set(probes) then probes=['a','b']

cdf_leap_second_init

for i=0, n_elements(probes)-1 do begin

   probe = probes[i] 

   ;Set up the structure including the local/remote data directories.
   source = file_retrieve(/struct)

   ;source.local_data_dir = root_data_dir()+'rbsp/rbsp'+probe+'/ect/mageis/'
   ;source.local_data_dir = root_data_dir()+'rbsp/ect/mageis/rbsp'+probe+'/'
   source.local_data_dir = root_data_dir()+'rbsp/ect/rbsp'+probe+'/rept/leve'+level+'/'
   source.remote_data_dir = 'http://www.rbsp-ect.lanl.gov/data_pub/rbsp'+probe $ 
                          + '/rept/leve'+level+'/'

;   Relative path with wildcards for data files
   pathformat = 'rbsp'+probe+'_rel03_ect-rept-sci-' $
                + strupcase(level)+'_YYYYMMDD_v*.cdf'

   ;Expand the wildcards in the relative file paths for designated
   ;time range, which is set by "timespan"
   relpathnames = file_dailynames(file_format=pathformat)

   ;Check the time stamps and download data files if they are newer.   
   ; Use spd_download.pro instead of file_retrieve.pro
   ; spd_download.pro is available in the latest SPEDAS bleeding edge 

   files = spd_download(remote_file=relpathnames,remote_path=source.remote_data_dir,$
   local_path=source.local_data_dir,/last_version)

   prefix = 'rbsp'+probe+'_ect_rept_' ; Prefix for tplot variable name
   ; Read CDF files and deduce data as tplot variables
   cdf2tplot, file=files, verbose=source.verbose, prefix=prefix, /get_support_data

   if level eq 'l2' then begin

     tvar = prefix + ['FESA','FPSA'] 
     options, tvar, 'zlog', 1
     options, tvar, 'ylog', 1
     options, tvar, 'ytitle', 'Energy [MeV]' 
     options, tvar, 'ysubtitle', '' 
     options, prefix+'FESA', 'yrange', [2,20]
     options, prefix+'FESA', 'ystyle', 1
     options, prefix+'FESA', 'ztitle', 'Electron flux [cm!U-2!Ns!U-1!Nsr!U-1!NMeV!U-1!N]' 
     options, prefix+'FPSA', 'yrange', [20,200]
     options, prefix+'FPSA', 'ystyle', 1
     options, prefix+'FPSA', 'ztitle', 'Proton flux [cm!U-2!Ns!U-1!Nsr!U-1!NMeV!U-1!N]' 

   endif

endfor

end