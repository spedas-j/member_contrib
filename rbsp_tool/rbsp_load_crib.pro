timespan, '2013-03-17', 2 

;LOAD EMFISIS LEVEL-3 DATA 
rbsp_load_emfisis, level='l3', cadence='4sec', coord='sm', probe='b' 

;LOAD EMFISIS LEVEL-2 HFR DATA 
rbsp_load_emfisis_hfr, datatype='spectra', probes='b' 

;LOAD EMFISIS LEVEL-2 WFR DATA 
rbsp_load_emfisis_wfr, datatype='spectra', probes='b' 

;LOAD ECT/HOPE LEVEL-2 DATA 
rbsp_load_ect_hope, probes='b', /spin_avg

;LOAD ECT/MagEIS LEVEL-2 DATA 
rbsp_load_ect_mageis, probes='b'

;LOAD OMNI DATA 
omni_hro_load 

;PLOT EMFISIS LEVEL-3 DATA 
!p.charsize=1.5
tname = ['OMNI_HRO_1min_SYM_H','rbspb_emfisis_l3_4sec_sm_Mag'] 
tkm2re, 'rbspb_emfisis_l3_4sec_sm_coordinates' 
split_vec, 'rbspb_emfisis_l3_4sec_sm_coordinates_re' 
options, 'rbspb_emfisis_l3_4sec_sm_coordinates_re_x', 'ytitle', 'X!DSM!N[RE]'  
options, 'rbspb_emfisis_l3_4sec_sm_coordinates_re_y', 'ytitle', 'Y!DSM!N[RE]'  
options, 'rbspb_emfisis_l3_4sec_sm_coordinates_re_z', 'ytitle', 'Z!DSM!N[RE]'  
tplot, tname, title='RBSPB/EMFISIS B-field', $ 
      var_label = ['rbspb_emfisis_l3_4sec_sm_coordinates_re_z', $ 
                   'rbspb_emfisis_l3_4sec_sm_coordinates_re_y', $ 
                   'rbspb_emfisis_l3_4sec_sm_coordinates_re_x'] 
stop 

;PLOT EMFISIS LEVEL-2 HFR DATA 
tname = ['OMNI_HRO_1min_SYM_H','rbspb_emfisis_HFR_Spectra'] 
tname = ['OMNI_HRO_1min_SYM_H','rbspb_emfisis_HFR_Spectra_gyro'] 
tplot, tname, title = 'RBSPB/EMFISIS HFR'
stop 

;PLOT EMFISIS LEVEL-2 WFR DATA 
tname = ['OMNI_HRO_1min_SYM_H','rbspb_emfisis_WFR_?u?u'] 
tname = ['OMNI_HRO_1min_SYM_H','rbspb_emfisis_WFR_?u?u_gyro'] 
tplot, tname, title = 'RBSPB/EMFISIS WFR' 
stop

;PLOT ECT/HOPE LEVEL-2 DATA 
tname = ['OMNI_HRO_1min_SYM_H','rbspa_ect_hope_F*SA'] 
tplot, tname 
tname = ['OMNI_HRO_1min_SYM_H','rbspb_ect_hope_F*SA'] 
tplot, tname, title = 'RBSPB/ECT/HOPE' 
stop 

;PLOT ECT/MagEIS LEVEL-2 DATA 
tname = ['OMNI_HRO_1min_SYM_H','rbspb_ect_mageis*F*SA'] 
tplot, tname, title = 'RBSPB/ECT/MagEIS' 
stop 

;PLOT SOLAR WIND AND GEOMANTEIC INDEX DATA 
tname = ['OMNI_HRO_1min_BZ_GSM','OMNI_HRO_1min_flow_speed',$ 
         'OMNI_HRO_1min_proton_density','OMNI_HRO_1min_Pressure', $ 
         'OMNI_HRO_1min_Mach_num','OMNI_HRO_1min_SYM_H']
tplot, tname, title = 'Solar wind & Geomagnetic indices' 

end 
