FUNCTION tsy_params, model

;Error check
argc= N_PARAMS()
IF argc NE 1 THEN model='t96'

list=['t89','t96','t01','t04s']
idx=WHERE( list EQ STRLOWCASE(model), cnt)
IF cnt LT 1 THEN BEGIN
	PRINT,'tsy_params.pro: Invalid model name!'
	RETURN,''
ENDIF ELSE IF cnt GT 1 THEN BEGIN
	PRINT,'tsy_params.pro: Multiple model names are specified!'
	PRINT,'T96 is used now'
	model='t96'
ENDIF


;kyoto_dst_load
omni_hro_load

;tdegap,'kyoto_dst',/overwrite
;tdeflag,'kyoto_dst','linear',/overwrite

tdegap, 'OMNI_HRO_1min_SYM_H', /overwrite
tdeflag, 'OMNI_HRO_1min_SYM_H', 'linear', /overwrite

tdegap,'OMNI_HRO_1min_BY_GSM',/overwrite
tdeflag,'OMNI_HRO_1min_BY_GSM','linear',/overwrite

tdegap,'OMNI_HRO_1min_BZ_GSM',/overwrite
tdeflag,'OMNI_HRO_1min_BZ_GSM','linear',/overwrite

tdegap,'OMNI_HRO_1min_proton_density',/overwrite
tdeflag,'OMNI_HRO_1min_proton_density','linear',/overwrite

tdegap,'OMNI_HRO_1min_flow_speed',/overwrite
tdeflag,'OMNI_HRO_1min_flow_speed','linear',/overwrite

store_data,'omni_imf',data=['OMNI_HRO_1min_BY_GSM','OMNI_HRO_1min_BZ_GSM']

;get_tsy_params generates parameters for t96,t01, & t04s models
get_tsy_params,'OMNI_HRO_1min_SYM_H','omni_imf',$
  'OMNI_HRO_1min_proton_density','OMNI_HRO_1min_flow_speed',model,/speed,/imf_yz

par = model + '_par'

RETURN, par

END

