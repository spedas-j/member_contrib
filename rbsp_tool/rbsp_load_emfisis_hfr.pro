;
; PURPOSE: Read RBSP/EMFISIS L-2 wave data.
;
; Datatype: 
;    spectra: wave power spectra (survey) 
;      FOR rbsp-a_HFR-spectra_emfisis-L2_YYYYMMDD_v?.?.?.cdf
;    spectra-merged: wave power spectra (survey + burst) 
;      FOR rbsp-a_HFR-spectra-merged_emfisis-L2_YYYYMMDD_v?.?.?.cdf
; 
; Examples: 
;    rbsp_load_emfisis_hfr, datatype='spectra', probes='a'
;    rbsp_load_emfisis_hfr, datatype='spectra-merged', probes='a'
; 
; History:
;    1. Prepared by Kunihiro Keika, August 2014
;
;
;--------------------------------------------------------------------
function GyroFreq, b, emu, charge
b1=b*10^(-9.);T
mass=emu*1.67D*10^(-27.);kg
if emu eq -1 then mass=9.1093D*10^(-31.);kg
q=charge*1.6*10^(-19.)

omega=q*b1/mass

return, omega/2./!pi; Hz

end

;---------------------------------------------------
pro rbsp_load_emfisis_hfr, datatype=datatype, probes=probes, level=level

if not keyword_set(level) then level='l2' 

rbsp_emfisis_init 

for i=0, n_elements(probes)-1 do begin 
    probe = probes[i] 
    source = file_retrieve(/struct) 
    ;source.local_data_dir = root_data_dir()+'rbsp/rbsp'+probe+'/emfisis/fr/'  
    ;source.local_data_dir = root_data_dir()+'rbsp/emfisis/Flight/rbsp'+probe+'/'  
    source.local_data_dir = root_data_dir()+'rbsp/emfisis/Flight/RBSP-'+strupcase(probe)+'/'  
    source.remote_data_dir = 'http://emfisis.physics.uiowa.edu/Flight/RBSP-'+strupcase(probe)+'/'

    pathformat = strupcase(level)+'/YYYY/MM/DD/rbsp-'+probe $ 
               + '_HFR-'+datatype+'_emfisis-'+strupcase(level) $ 
               + '_YYYYMMDD_v?.?.?.cdf'
  
    relpathnames = file_dailynames(file_format=pathformat)
    if keyword_set(continuous) then $ 
        relpathnames = file_dailynames(file_format=pathformat,/hour_res)
  
    files = file_retrieve(relpathnames, _extra=source, /last_version)

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
       get_data, prefix + 'HFR_Spectra', data=data, dlim=dlim
       ;store_data, 'HFR_Spectra', data={x:data.x,y:data.y,v:reform(data.v)}
       store_data, prefix + 'HFR_Spectra', data={x:data.x,y:data.y,v:reform(data.v[0,*])}
       options, prefix + 'HFR_Spectra', 'ylog', 1
       options, prefix + 'HFR_Spectra', 'zlog', 1
       options, prefix + 'HFR_Spectra', 'ytitle', 'Freq [Hz]' 
       options, prefix + 'HFR_Spectra', 'ysubtitle', '' 
       options, prefix + 'HFR_Spectra', 'ztitle', dlim.ysubtitle
       store_data, prefix + 'HFR_Spectra_gyro', $ 
              data=[prefix + 'HFR_Spectra',prefix+'l3_4sec_sm_Magnitude_gyro_e'] 
       options, prefix + 'HFR_Spectra_gyro', 'yrange', [10^4.,5.*10^5.]
       options, prefix + 'HFR_Spectra_gyro', 'ystyle', 1 
       ;---TPLOT---
       tplot_names
    ;   tplot, prefix + 'HFR_Spectra_gyro', title='Van Allen Probes A: HFR Spectra'  

endfor 
end 

