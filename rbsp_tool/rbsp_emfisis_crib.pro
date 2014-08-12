;
; PURPOSE: 
;   Load Van Allen Probes EMFISIS 64-Hz fluxgate magnetometer data and 
;   perform wave analysis, using routines prepared in TDAS. 
;
; USAGE: 
;   IDL> .r sample_emfisis.pro 
;    & 
;   Type .c to continue. 
; 
; HISTORY: 
;   Modified by Kunihiro Keika, STEL, on July 31, 2014 
;   Modified by Kunihiro Keika, STEL, on June 13, 2014 
;   Prepared by Kunihiro Keika, STEL, on June 3, 2014 
;
; AUTHOR: 
;   Kunihiro Keika, STEL/Nagoya Univ. (kkeika@stelab.nagoya-u.ac.jp) 
; 
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

; Set date and time range. 
date='2013-06-29'
w_date=date+'/'+['11:00:00','12:00:00']
timespan, date, 1
stop

; GET 64Hz magnetic field data from EMFISIS fluxgate magnetometer. 
rbsp_load_emfisis, level='l3', cadence='hires', coord='gsm', probe='a' 
tname = 'rbspa_emfisis_l3_hires_gsm_Mag
options, tname, 'colors', [2,4,6]
options, tname, 'labels', ['Bx','By','Bz']
stop 

; TIME CLIP 
time_clip, 'rbspa_emfisis_l3_hires_gsm_Mag', w_date[0], w_date[1], $
         newname = 'rbspa_emfisis_l3_hires_gsm_Mag_tclip'
stop 

; = = = WAVE ANALYSIS = = = 
; POWER SPECTRUM (USING TDPWRSPC) 
tdpwrspc, 'rbspa_emfisis_l3_hires_gsm_Mag_tclip', $ 
          newname='rbspa_emfisis_l3_hires_gsm_Mag_tclip_spec', $
          nboxpoints = 64.*20., nshiftpoints = 1280./2.
tplot,['rbspa_emfisis_l3_hires_gsm_Mag_tclip_x_dpwrspc',$ 
       'rbspa_emfisis_l3_hires_gsm_Mag_tclip_y_dpwrspc', $
       'rbspa_emfisis_l3_hires_gsm_Mag_tclip_z_dpwrspc'], $
       title = 'Van Allen Probes A / EMFISIS' 
stop 

; POWER SPECTRUM & WAVE PROPERTIES (USING TWAVPOL) 
twavpol, 'rbspa_emfisis_l3_hires_gsm_Mag_tclip', freqline=f1, timeline=t1, nopfft=64.*20.
options,'rbspa_emfisis_l3_hires_gsm_Mag_tclip_powspec','zlog', 1
tplot,['rbspa_emfisis_l3_hires_gsm_Mag_tclip_powspec', $    
       'rbspa_emfisis_l3_hires_gsm_Mag_tclip_degpol', $     
       'rbspa_emfisis_l3_hires_gsm_Mag_tclip_waveangle', $  
       'rbspa_emfisis_l3_hires_gsm_Mag_tclip_elliptict', $  
       'rbspa_emfisis_l3_hires_gsm_Mag_tclip_helict'], $     
       title = 'Van Allen Probes A / EMFISIS' 
tvar_mag = 'rbspa_emfisis_l3_hires_gsm_Mag_tclip'
tplot, tvar_mag + ['_powspec','_degpol', '_waveangle', '_elliptict', '_helict'] 
stop 

; SMOOTH HIGH-RES DATA TO DEFINE MAGNETIC FIELD COORDINATES 
; 20-sec smoothing 
tsmooth2,'rbspa_emfisis_l3_hires_gsm_Mag_tclip', 1280., $ 
         newname = 'rbspa_emfisis_l3_hires_gsm_Mag_tclip_smt'
stop

; ROTATION TO MAGNETIC FIELD COORDINATES 
; CREATE MATRIX
thm_fac_matrix_make, 'rbspa_emfisis_l3_hires_gsm_Mag_tclip_smt', $ 
                     other_dim='Xgse', $ 
                     newname='rbspa_emfisis_l3_hires_gsm_Mag_tclip_smt_mat'
stop 

; ROTATE USING THE MATRIX 
tvector_rotate, 'rbspa_emfisis_l3_hires_gsm_Mag_tclip_smt_mat', $ 
                'rbspa_emfisis_l3_hires_gsm_Mag_tclip', $ 
                newname = 'rbspa_emfisis_l3_hires_gsm_Mag_tclip_smt_mat_rot'
stop 

; CHANGE OPTIONS 
options, 'rbspa_emfisis_l3_hires_gsm_Mag_tclip_smt_mat_rot', 'colors', [2,4,6]
options, 'rbspa_emfisis_l3_hires_gsm_Mag_tclip_smt_mat_rot', 'labels', $ 
         ['perp1','perp2','para']
options, 'rbspa_emfisis_l3_hires_gsm_Mag_tclip_smt_mat_rot', 'labflag', 1
stop 

; = = = WAVE ANALYSIS IN MAGNETIC FIELD COORDINATES = = = 
; SPECTRUM (USING TDPWRSPC) 
tdpwrspc, 'rbspa_emfisis_l3_hires_gsm_Mag_tclip_smt_mat_rot', $ 
          newname='rbspa_emfisis_l3_hires_gsm_Mag_tclip_smt_mat_rot_spec', $
          nboxpoints = 64.*20., nshiftpoints = 1280./2.
tplot,['rbspa_emfisis_l3_hires_gsm_Mag_tclip_smt_mat_rot_x_dpwrspc',$ 
       'rbspa_emfisis_l3_hires_gsm_Mag_tclip_smt_mat_rot_y_dpwrspc', $
       'rbspa_emfisis_l3_hires_gsm_Mag_tclip_smt_mat_rot_z_dpwrspc'], $
       title = 'Van Allen Probes A / EMFISIS : PERP & PARA'
stop 

; SPECTRUM & WAVE PROPERTIES (USING TWAVPOL)
twavpol, 'rbspa_emfisis_l3_hires_gsm_Mag_tclip_smt_mat_rot', $ 
         freqline=f1, timeline=t1, nopfft=64.*20.
options,'rbspa_emfisis_l3_hires_gsm_Mag_tclip_smt_mat_rot_powspec','zlog', 1
tplot,['rbspa_emfisis_l3_hires_gsm_Mag_tclip_smt_mat_rot_powspec', $
       'rbspa_emfisis_l3_hires_gsm_Mag_tclip_smt_mat_rot_degpol', $
       'rbspa_emfisis_l3_hires_gsm_Mag_tclip_smt_mat_rot_waveangle', $
       'rbspa_emfisis_l3_hires_gsm_Mag_tclip_smt_mat_rot_elliptict', $
       'rbspa_emfisis_l3_hires_gsm_Mag_tclip_smt_mat_rot_helict'], $
       title = 'Van Allen Probes A / EMFISIS : PERP & PARA'
; ADD THE FOLLOWING LINES TO WAVPOL.PRO FOR POWER SPECTRA OF 
; PERPENDICULAR AND PARALLEL COMPONENTS (right after the wavpol, d.x, ... line). 
;  store_data, prefix+'_powspec', data = {x:timeline, y:powspec, v:freqline}, dlimits = {spec:1B}
;  store_data, prefix+'_powspec_p', data = {x:timeline, y:powspec_p, v:freqline}, dlimits = {spec:1B}
;  store_data, prefix+'_powspec_x', data = {x:timeline, y:powspec_x, v:freqline}, dlimits = {spec:1B}
;  store_data, prefix+'_powspec_y', data = {x:timeline, y:powspec_y, v:freqline}, dlimits = {spec:1B}
;  store_data, prefix+'_powspec_z', data = {x:timeline, y:powspec_z, v:freqline}, dlimits = {spec:1B}
;  options, prefix+'_powspe*', 'zlog', 1
;  options, prefix+'_powspe*', 'zrange', [min(powspec),max(powspec)]
stop 

; ADD LOCAL GYROFREQUENCIES 
; - - - GYROFREQUENCY - - -
; NOTE: gyrofreq.pro used below is my personal function. 
;       Please replace it with your own. 
tvar_smt = 'rbspa_emfisis_l3_hires_gsm_Mag_tclip_smt'
get_data, tvar_smt, data=mag_smt
totalb=sqrt(mag_smt.y(*,0)^2.+mag_smt.y(*,1)^2.+mag_smt.y(*,2)^2.)
   gyrofreq1=gyrofreq(totalb,1,1)
   store_data, 'gyrofreq_h', data={x:mag_smt.x,y:gyrofreq1}, $
                                   dlim={colors:5}
   gyrofreq1=gyrofreq(totalb,4,1)
   store_data, 'gyrofreq_he', data={x:mag_smt.x,y:gyrofreq1}, $
                                   dlim={colors:5}
   gyrofreq1=gyrofreq(totalb,16,1)
   store_data, 'gyrofreq_o', data={x:mag_smt.x,y:gyrofreq1}, $
                                   dlim={colors:5}
stop 

; - - - COMBINE SPECTRUM DATA & GYRO FREQ DATA - - - 
tvar_spc_gyro = ['rbspa_emfisis_l3_hires_gsm_Mag_tclip_smt_mat_rot_x_dpwrspc',$ 
                 'gyrofreq_h','gyrofreq_he','gyrofreq_o'] 
store_data, tvar_spc_gyro[0]+'_gyro', data=tvar_spc_gyro, $ 
            dlim={yrange:[0.1,32],ylog:1,ystyle:1} 

print, '=== END OF THIS CRIB SHEET ===' 
stop 


end 

