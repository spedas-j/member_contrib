;+
;PROCCEDURE: RBSP_ECT_REPT_PAD_MAP2EQ
;
; PURPOSE: 
;     Convert local pitch angles to equatorial pitch angles and generate
;     pitch angle-time plots for REPT data. The t04s magnetic field model
;     is used to estimate local and equatorial magnetic field intensities.
;
;     'rbsp*_ect_rept_FEDU_mapped' consists of two different tplot variables,
;     and is useful to show fluxes in equatorial pitch angle v.s. time domain.
;
;     'rbsp*_ect_rept_FEDU_mapped2' consists of one tplot variables, and is
;     useful to show fluxes v.s. equatorial pitch angles after get_data.
;
; KEYWORDS:
;     probe: spacecraft name e.g., probe='a'
;
;     avg: time window to take averages, in seconds
;
;	  echan: energy channel of the  REPT instrument, defalut is 1 (2.1 MeV)
; 
; EXAMPLES: 
;     rbsp_ect_rept_pad_map2eq,probe='a',avg=60.0,echan=3
;
; HISTORY: 
;     First created by Satoshi Kurita, April 2015 
; 
; AUTHOR: 
;     Satoshi Kurita, STEL/Nagoya University (kurita@stelab.nagoya-u.ac.jp) 
;-
pro rbsp_ect_rept_pad_map2eq,probe=sc,avg=avg,echan=echan,plot=plot

;Load REPT L3 data and obtaine pitch angle data
rbsp_load_ect_rept,probe=sc,level='l3'
get_data,'rbsp'+sc+'_ect_rept_FEDU',data=flux

if size(flux,/type) eq 8 then begin

;take averages
	if keyword_set(avg) then begin
		avg_data,'rbsp'+sc+'_ect_rept_FEDU',avg
		get_data,'rbsp'+sc+'_ect_rept_FEDU_avg',data=flux
	endif

	if not keyword_set(echan) then echan=1

;Calcurate magnetic field intensity at s/c location and equator
	prefix='OMNI_HRO_5min_'
	omni_hro_load,/res5min,$
		varformat='BY_GSM BZ_GSM flow_speed proton_density SYM_H'
	store_data,'omni_imf',$
		data=['OMNI_HRO_5min_BY_GSM','OMNI_HRO_5min_BZ_GSM']
	get_tsy_params,prefix+'SYM_H','omni_imf',prefix+'proton_density',$
		prefix+'flow_speed','t04s',/imf_yz,/speed

	cotrans,'rbsp'+sc+'_ect_rept_Position','rbsp'+sc+'_ect_rept_Position_tmp',/geo2gei
	cotrans,'rbsp'+sc+'_ect_rept_Position_tmp','rbsp'+sc+'_ect_rept_Position_tmp',/gei2gse
	cotrans,'rbsp'+sc+'_ect_rept_Position_tmp','rbsp'+sc+'_ect_rept_Position_gsm',/gse2gsm
	del_data,'rbsp'+sc+'_ect_rept_Position_tmp'

	ttrace2equator,'rbsp'+sc+'_ect_rept_Position_gsm',par='t04s_par',/km
	tt04s,'rbsp'+sc+'_ect_rept_Position_gsm',par='t04s_par'
	tt04s,'rbsp'+sc+'_ect_rept_Position_gsm_foot',par='t04s_par'

	get_data,'rbsp'+sc+'_ect_rept_Position_gsm_bt04s',data=bvec_l
	get_data,'rbsp'+sc+'_ect_rept_Position_gsm_foot_bt04s',data=bvec_eq

	bl={x:bvec_l.x,y:sqrt(total(bvec_l.y^2,2))}
	beq={x:bvec_eq.x,y:sqrt(total(bvec_eq.y^2,2))}

	idx=nn(bl,flux.x)

;Make arrays for equatorial pitch angle-time plot
	pa=dblarr(18)
	pa_eq=dblarr(n_elements(flux.x),18)
	flux2=dblarr(n_elements(flux.x),18)

	pa[0:8]=flux.v1[0:8]
	pa[9:17]=flux.v1[8:16]
	flux2[*,0:8]=flux.y[*,echan,0:8]
	flux2[*,9:17]=flux.y[*,echan,8:16]
	
;Convert local pitch angles to equatorial pitch angles
	fact=sqrt(beq.y[idx]/bl.y[idx])
	for ii=0.,n_elements(pa)-1 do pa_eq[*,ii]=asin(fact*sin(pa[ii]*!dtor))/!dtor
	pa_eq[*,9:17]=180.0-pa_eq[*,9:17]

;Make tplot variables
	yt='REPT-'+strupcase(sc)+'  '+strcompress(string(flux.v2[echan],$
				format='(f4.1)'),/remove_all)+' MeV!C!CPitch angle [deg.]'
	zt='!Ccm!e-2!n s!e-1!n str!e-1!n MeV!e-1!n'

	store_data,'rbsp'+sc+'_ect_rept_FEDU_mapped_0_90deg',data={x:flux.x,y:flux2[*,0:8],v:pa_eq[*,0:8]},$
			dlim={spec:1,yrange:[0,180],zlog:1,ytitle:yt,ztitle:zt}
	store_data,'rbsp'+sc+'_ect_rept_FEDU_mapped_90_180deg',data={x:flux.x,y:flux2[*,9:17],v:pa_eq[*,9:17]},$
			dlim={spec:1,yrange:[0,180],zlog:1,ytitle:yt,ztitle:zt}
	store_data,'rbsp'+sc+'_ect_rept_FEDU_mapped',$
		data=['rbsp'+sc+'_ect_rept_FEDU_mapped_0_90deg','rbsp'+sc+'_ect_rept_FEDU_mapped_90_180deg'],$
			dlim={spec:1,yrange:[0,180],zlog:1,ytitle:yt,ztitle:zt}
	store_data,'rbsp'+sc+'_ect_rept_FEDU_mapped2',data={x:flux.x,y:flux2,v:pa_eq},$
			dlim={spec:1,yrange:[0,180],zlog:1,ytitle:yt,ztitle:zt}

	if keyword_set(plot) then begin

		options,'rbspa_ect_rept_MLAT',constant=0.,$
			ytitle='RBSP-'+strupcase(sc)+' MLAT [deg.]',ysubtitle=''
		tplot,['rbsp'+sc+'_ect_rept_MLAT','rbsp'+sc+'_ect_rept_FEDU_mapped']

	endif

endif else dprint,'NO data are available during the specified time interval. Abort.'

end