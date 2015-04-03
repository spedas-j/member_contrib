; Set time range 
timespan, '2013-07-25', 1, /day  

;goto, lab1

; Load solar wind OMNI, SYM-H, and AE index data 
omni_hro_load 

; Load THEMIS E Spin-fit magnetic field data 
thm_load_fgm, probe='e', coord='gsm', datatype='fgs', level='l2'  
cotrans, 'the_fgs_gsm', 'the_fgs_sm', /GSM2SM 

; Load THEMIS E ESA data 
thm_load_esa, level='l2', probe='e'

; Load THEMIS E SST data 
thm_load_sst, probe='e', level='l2'

; Load Van Allen Probes A EMFISIS magnetometer data 
rbsp_load_emfisis, probe='a', coord='sm', cadence='4sec' 

; Load Van Allen Probes B EMFISIS magnetometer data 
rbsp_load_emfisis, probe='b', coord='sm', cadence='4sec' 

;(OPTIONS) Load Van Allen Probes A MAGEIS electron and proton data 
rbsp_load_ect_mageis, probes='a', level='l2'


lab1: 

;- - - PLOT 1: Overview - - - 
tvar = [$ 
    'OMNI_HRO_1min_BX_GSE', $ 
    'OMNI_HRO_1min_BY_GSM', $ 
    'OMNI_HRO_1min_BZ_GSM', $ 
    'OMNI_HRO_1min_flow_speed', $ 
    'OMNI_HRO_1min_Pressure', $ 
    'OMNI_HRO_1min_SYM_H', $ 
    'OMNI_HRO_1min_AE_INDEX', $ 
    ''] 


;- - - PLOT 2: THEMIS and Van Allen Probes 
tvar =[$ 
      'the_fgs', $ 
      'the_psef_en_eflux', $ 
      'the_peer_en_eflux', $ 
;      'the_peer_density', $ 
;      'the_peer_velocity_gsm', $ 
      'the_psif_en_eflux', $ 
      'the_peir_en_eflux', $ 
;      'the_peir_density', $ 
;      'the_peef_velocity_gsm', $ 
      'rbspa_emfisis_l3_4sec_sm_Mag', $ 
      'rbspb_emfisis_l3_4sec_sm_Mag', $ 
;      'rbspa_ect_rept_FEDU_pa090', $ 
      'rbspa_ect_mageis_FESA', $ 
      'rbspa_ect_mageis_FPSA', $ 
      ''] 

tplot, tvar 

end 

