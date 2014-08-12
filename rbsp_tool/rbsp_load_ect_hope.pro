;+++++++++++++++++++++++++++++++++++++++++++++++++++++
; PROCEDURE: 
;     RBSP_LOAD_ECT_HOPE 
; 
; PURPOSE: 
;     read Van Allen Probes ECT/HOPE L2 data files 
;
; EXAMPLES: 
;     rbsp_load_ect_hope, probes='a', /spin_avg
; 
; HISTORY: 
;     Created by Kunihiro Keika, August 2014
;
; AUTHOR: 
;     Kunihiro Keika, STEL/Nagoya Univ. (kkeika@stelab.nagoya-u.ac.jp) 
; 
;+++++++++++++++++++++++++++++++++++++++++++++++++++++
pro rbsp_load_ect_hope, probes=probes, spin_avg=spin_avg

if not keyword_set(probes) then probes=['a','b'] 
level = 'l2' 

thm_init
cdf_leap_second_init 

for i=0, n_elements(probes)-1 do begin 

  probe = probes[i] 

  source = file_retrieve(/struct) 
  ;;=====FILE_HTTP_COPY PROBLEM=====
  ;;source = file_retrieve(/struct, /no_update) 
  ;;================================
  ;source.local_data_dir = root_data_dir()+'rbsp/rbsp'+probe+'/ect/hope/' 
  ;source.local_data_dir = root_data_dir()+'rbsp/ect/hope/rbsp'+probe+'/'
  source.local_data_dir = root_data_dir()+'rbsp/ect/rbsp'+probe+'/hope/leve'+level+'/'
  source.remote_data_dir = 'http://www.rbsp-ect.lanl.gov/data_pub/rbsp'+probe+'/hope/leve'+level+'/' 

  pathformat = 'rbsp'+probe+'_rel02_ect-hope-sci-' $ 
                        + strupcase(level)+'_YYYYMMDD_v?.?.?.cdf' 
  if keyword_set(spin_avg) then $ 
                  pathformat= 'rbsp'+probe+'_rel02_ect-hope-sci-' $ 
                            + strupcase(level)+'SA_YYYYMMDD_v?.?.?.cdf' 

  relpathnames = file_dailynames(file_format=pathformat) 

  ;;=====FILE_HTTP_COPY PROBLEM=====
  files = file_retrieve(relpathnames, _extra=source, /last_version) 
;  files = file_retrieve(relpathnames, _extra=source, /last_version, /preserve_mtime) 
;  files = file_retrieve(relpathnames, _extra=source) 
;  files = file_retrieve(relpathnames, _extra=source, /no_download) 
;  files = file_retrieve(relpathnames, _extra=source, /no_update) 
;  files = file_retrieve(relpathnames, _extra=source, /no_clobber) 
  ;;================================

  prefix = 'rbsp'+probe+'_ect_hope_' ; Prefix for tplot variable name 
  ; Read CDF files 
  cdf2tplot, file=files, verbose=source.verbose, prefix=prefix, /get_support_data 


  options, prefix + ['FOSA','FPSA','FHESA','FESA'], 'ylog', 1
  options, prefix + ['FOSA','FPSA','FHESA','FESA'], 'zlog', 1
  options, prefix + ['FOSA','FPSA','FHESA','FESA'], 'yrange', [1,40000] 
  options, prefix + ['FOSA','FPSA','FHESA','FESA'], 'ystyle', 1
  options, prefix + ['FOSA','FPSA','FHESA','FESA'], 'ytitle', 'Energy [eV]'
  options, prefix + ['FOSA','FPSA','FHESA','FESA'], 'ysubtitle', ''
  options, prefix + ['FOSA','FPSA','FHESA','FESA'], 'ztitle', '[s!E-1!Ncm!E-2!Nster!E-1!NkeV!E-1!N]'

  tplot, prefix +['FESA', 'FPSA','FHESA','FOSA'], $ 
       title = 'RBSP'+strupcase(probe)+ '/ECT/HOPE Electron Proton Helium Oxygen'  

endfor 

end 
