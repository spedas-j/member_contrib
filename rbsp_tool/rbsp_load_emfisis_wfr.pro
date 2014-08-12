;
; PURPOSE: Read RBSP/EMFISIS WFR Lev-2 wave data.
;
; Datatype: 
;    spectra: wave power spectra 
;      FOR rbsp-a_WFR-spectral-matrix-diagonal_emfisis-L2_YYYYMMDD_v?.?.?.cdf
;    spectra-merged: wave power spectra + wave burst 
;      FOR rbsp-a_WFR-spectral-matrix-diagonal-merged_emfisis-L2_YYYYMMDD_v?.?.?.cdf
; 
; Examples: 
;    rbsp_load_emfisis_wfr, datatype='spectra', probes='a'
; 
; History:
;    Prepared by Kunihiro Keika, July 31, 2014. 
;
; Author: 
;    Kunihiro Keika, STEL/Nagoya Univ. (kkeika@stelab.nagoya-u.ac.jp) 
;
;
;---------------------------------------------------
function GyroFreq, b, emu, charge
b1=b*10^(-9.);T 
mass=emu*1.67D*10^(-27.);kg
if emu eq -1 then mass=9.1093D*10^(-31.);kg
q=charge*1.6*10^(-19.)

omega=q*b1/mass

return, omega/2./!pi; Hz

end

;---------------------------------------------------
pro options_wfr_spectra, tvar, prefix=prefix 
   get_data, prefix+tvar, data=data, dlim=dlim
   store_data, prefix+'WFR_'+tvar, data={x:data.x,y:data.y,v:reform(data.v[0,*])}
   options, prefix+'WFR_'+tvar+'*', 'spec', 1
   options, prefix+'WFR_'+tvar+'*', 'ylog', 1
   options, prefix+'WFR_'+tvar+'*', 'zlog', 1
   options, prefix+'WFR_'+tvar+'*', 'ytitle', tvar
   options, prefix+'WFR_'+tvar+'*', 'ysubtitle', 'Freq [Hz]' 
   options, prefix+'WFR_'+tvar+'*', 'ztitle', dlim.ysubtitle 
   options, prefix+'WFR_'+tvar+'*', 'yrange', 10^[0.,4.] 
   store_data, prefix+'WFR_'+tvar+'_gyro', $ 
           data=[prefix+'WFR_'+tvar, $ 
                 prefix+'l3_4sec_sm_Magnitude_gyro_e', $ 
                 prefix+'l3_4sec_sm_Magnitude_gyro_e_half', $ 
                 prefix+'l3_4sec_sm_Magnitude_gyro_e_tenth', $ 
                 prefix+'l3_4sec_sm_Magnitude_gyro_h', $ 
                 prefix+'l3_4sec_sm_Magnitude_gyro_he', $ 
                 prefix+'l3_4sec_sm_Magnitude_gyro_o'] 
   options, prefix+'WFR_'+tvar+'*', 'yrange', 10^[0.,4.] 
end 

;---------------------------------------------------
pro rbsp_load_emfisis_wfr, datatype=datatype, probes=probes, level=level

if not keyword_set(level) then level='l2' 

rbsp_emfisis_init 

for i=0, n_elements(probes)-1 do begin 
    probe = probes[i] 
    source = file_retrieve(/struct) 
    ;source.local_data_dir = root_data_dir()+'rbsp/rbsp'+probe+'/emfisis/fr/'  
    ;source.local_data_dir = root_data_dir()+'rbsp/emfisis/Flight/rbsp'+probe+'/'  
    source.local_data_dir = root_data_dir()+'rbsp/emfisis/Flight/RBSP-'+strupcase(probe)+'/'  
    source.remote_data_dir = 'http://emfisis.physics.uiowa.edu/Flight/RBSP-'+strupcase(probe)+'/'

    if datatype eq 'spectra' then $ 
               pathformat = strupcase(level)+'/YYYY/MM/DD/rbsp-'+probe $ 
               + '_WFR-'+datatype+'l-matrix-diagonal_emfisis-' $ 
               + strupcase(level) + '_YYYYMMDD_v?.?.?.cdf' $ 
    else if datatype eq 'spectra-merged' then $ 
               pathformat = strupcase(level)+'/YYYY/MM/DD/rbsp-'+probe $ 
               + '_WFR-spectral-matrix-diagonal-merged_emfisis-' $ 
               + strupcase(level) + '_YYYYMMDD_v?.?.?.cdf'  
  
    relpathnames = file_dailynames(file_format=pathformat)
    if keyword_set(continuous) then $ 
        relpathnames = file_dailynames(file_format=pathformat,/hour_res)
  
    ; Download CDF files if they are updated. 
    files = file_retrieve(relpathnames, _extra=source, /last_version)

    ; Read CDF files 
    prefix = 'rbsp'+probe+'_emfisis_' ;Prefix for tplot variable name
    cdf2tplot,file=files,verbose=source.verbose,prefix=prefix

    ;---GYROFREQ---(USE 4-SEC FLUXGATE MAGNETOMETER DATA)---
    rbsp_load_emfisis, level='l3', cadence='4sec', coord='sm', probe=probe
    tvar_gyro = 'rbsp'+probe+'_emfisis_l3_4sec_sm_Magnitude' 
    get_data, tvar_gyro, data=data 
    gyrofreq_h=gyrofreq(data.y,1,1)
    gyrofreq_he=gyrofreq(data.y,4,1)
    gyrofreq_o=gyrofreq(data.y,16,1)
    gyrofreq_e=gyrofreq(data.y,-1,1)
    gyrofreq_e_half=gyrofreq(data.y,-1,1)/2. 
    gyrofreq_e_tenth=gyrofreq(data.y,-1,1)/10. 
    store_data, tvar_gyro+'_gyro_h', data={x:data.x,y:gyrofreq_h}, dlim={colors:0}  
    store_data, tvar_gyro+'_gyro_he', data={x:data.x,y:gyrofreq_he}, dlim={colors:0}  
    store_data, tvar_gyro+'_gyro_o', data={x:data.x,y:gyrofreq_o}, dlim={colors:0}  
    store_data, tvar_gyro+'_gyro_e', data={x:data.x,y:gyrofreq_e}, dlim={colors:5}  
    store_data, tvar_gyro+'_gyro_e_half', data={x:data.x,y:gyrofreq_e_half}, dlim={colors:5}  
    store_data, tvar_gyro+'_gyro_e_tenth', data={x:data.x,y:gyrofreq_e_tenth}, dlim={colors:5}  
    ;---OPTIONS---
       options_wfr_spectra, 'BuBu', prefix=prefix 
       options_wfr_spectra, 'BvBv', prefix=prefix 
       options_wfr_spectra, 'BwBw', prefix=prefix 
       options_wfr_spectra, 'EuEu', prefix=prefix 
       options_wfr_spectra, 'EvEv', prefix=prefix 
       options_wfr_spectra, 'EwEw', prefix=prefix 
       ;---TPLOT---
       tplot_names
       window, 0, xsize=800., ysize=1000. 
       tplot, prefix + ['*_B?B?','*_E?E?'] + '_gyro'  

endfor 
end 

