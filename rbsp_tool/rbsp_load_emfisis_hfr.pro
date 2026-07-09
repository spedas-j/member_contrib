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
;    2. Updated by Y. Obana, July 2026
;       - Changed the EMFISIS HFR remote data directory from
;         http://emfisis.physics.uiowa.edu/Flight/...
;         to
;         https://space.physics.uiowa.edu/emfisis/Flight/...
;         following the migration of the Iowa EMFISIS data server.
;       - Added a fallback curl download when file_retrieve fails to
;         resolve the v?.?.?.cdf version wildcard on the new HTTPS server.
;       - Added deletion of old HFR tplot variables before loading new data
;         to avoid using stale spectra from a previous timespan.
;       - Added a check for successful creation of the HFR_Spectra tplot
;         variable before applying plotting options.
;       - Reformatted the HFR frequency axis for tplot/specplot compatibility.
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
    ;source.remote_data_dir = 'http://emfisis.physics.uiowa.edu/Flight/RBSP-'+strupcase(probe)+'/'
    source.remote_data_dir = 'https://space.physics.uiowa.edu/emfisis/Flight/RBSP-'+strupcase(probe)+'/'

    pathformat = strupcase(level)+'/YYYY/MM/DD/rbsp-'+probe $ 
               + '_HFR-'+datatype+'_emfisis-'+strupcase(level) $ 
               + '_YYYYMMDD_v?.?.?.cdf'
  
    relpathnames = file_dailynames(file_format=pathformat)
    if keyword_set(continuous) then $ 
        relpathnames = file_dailynames(file_format=pathformat,/hour_res)
  
    files = file_retrieve(relpathnames, _extra=source, /last_version)
    
    ; If file_retrieve fails to resolve v?.?.?.cdf on the new Iowa HTTPS server,
    ; try downloading the known HFR spectra file via curl.
    if n_elements(files) eq 1 then begin
      if strpos(files[0], '?') ge 0 then begin

        tr = timerange()
        ymd = time_string(tr[0], tformat='YYYYMMDD')
        yyyy = strmid(ymd, 0, 4)
        mm   = strmid(ymd, 4, 2)
        dd   = strmid(ymd, 6, 2)

        local_dir = source.local_data_dir + strupcase(level) + '\' + yyyy + '\' + mm + '\' + dd + '\'
        spawn, 'cmd /c if not exist "' + local_dir + '" mkdir "' + local_dir + '"'

        ; Most 2017 HFR spectra L2 files use v1.6.5. If this fails, the file will remain missing.
        fname = 'rbsp-' + probe + '_HFR-' + datatype + '_emfisis-' + strupcase(level) + '_' + ymd + '_v1.6.5.cdf'
        url = source.remote_data_dir + strupcase(level) + '/' + yyyy + '/' + mm + '/' + dd + '/' + fname
        local_file = local_dir + fname

        print, 'Trying curl download: ', url
        spawn, 'curl -L -o "' + local_file + '" "' + url + '"'

        if file_test(local_file) then files = [local_file]
      endif
    endif
    
    prefix = 'rbsp'+probe+'_emfisis_' ;Prefix for tplot variable name
    
    ; remove old HFR variables to avoid using stale data
    del_data, prefix + 'HFR_Spectra'
    del_data, prefix + 'HFR_Spectra_gyro'
    
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
       
       if size(data, /type) ne 8 then begin
         dprint, dlevel=0, 'No tplot variable found: '+prefix+'HFR_Spectra'
         continue
       endif

       freq = reform(data.v[0,*])
       spec = data.y

       store_data, prefix + 'HFR_Spectra', data={x:data.x, y:spec, v:freq}
       
       ;store_data, 'HFR_Spectra', data={x:data.x,y:data.y,v:reform(data.v)}
       ;store_data, prefix + 'HFR_Spectra', data={x:data.x,y:data.y,v:reform(data.v[0,*])}
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

