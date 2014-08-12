;++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
; RBSP_LOAD_ECT_MAGEIS 
; 
; PURPOSE: 
;     read Van Allen Probes ECT/MagEIS L2 data files 
; 
; EXAMPLES: 
;     rbsp_load_ect_mageis, probes='a'
;
; HISTORY: 
;     Last modified by Kunihiro Keika, August 2014 
; 
; AUTHOR: 
;     Kunihiro Keika, STEL/Nagoya Univ. (kkeika@stelab.nagoya-u.ac.jp) 
;
;++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++

pro rbsp_load_ect_mageis, probes=probes, level=level  

if not keyword_set(probes) then probes=['a','b']
if not keyword_set(level) then level = 'l2' 

thm_init
cdf_leap_second_init

for i=0, n_elements(probes)-1 do begin

   probe = probes[i] 

   source = file_retrieve(/struct)

;   source.local_data_dir = root_data_dir()+'rbsp/ect/mageis/rbsp'+probe+'/'
   source.local_data_dir = root_data_dir()+'rbsp/ect/rbsp'+probe+'/mageis/leve'+level+'/'
   source.remote_data_dir = 'http://www.rbsp-ect.lanl.gov/data_pub/rbsp'+probe $ 
                          + '/mageis/leve'+level+'/'

   pathformat = 'rbsp'+probe+'_rel02_ect-mageis-' $
                         + strupcase(level)+'_YYYYMMDD_v?.?.?.cdf'

   relpathnames = file_dailynames(file_format=pathformat)

   files = file_retrieve(relpathnames, _extra=source, /last_version)

   prefix = 'rbsp'+probe+'_ect_mageis_' ; Prefix for tplot variable name

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

   ;---TPLOT--- 
   tplot, prefix+['FESA','FPSA'], title='RBSP'+strupcase(probe)+'/ECT/MagEIS Electron & Proton' 
endfor



end 
