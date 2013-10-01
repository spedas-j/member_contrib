;+
; PRO comp_vap_b_t04s
;
; :Description:
;    VAPのEMFISISのDC磁場データと、OMNIデータを使って計算した
;    VAPの軌道に沿ったTsyganenko 2004 model磁場を求める。
;    実行するためには最新のTDAS bleeding edge が必要。
;
;    emfisis_l3_4sec_gsm_coordinates_bt04s_? がT04モデル磁場が入ったtplot変数。
;    VAP_and_T04S_B? はモデル磁場と実際に観測された磁場とのmulti tplot変数になっている。
;    
; :Examples:
;   comp_vap_b_t04s, /smooth, /noplot
;    
; :Keywords:
;    smooth: Set to smooth out the T04S B-field values by taking its 600-sec running average
;    noplot: Set to prevent from displaying the resultant comparison plot
;    
; :Author: horit
;-
pro comp_vap_b_t04s, smooth=smooth, noplot=noplot

  prob='a'
  prefix = 'rbsp'+prob+'_'
  
  rbsp_emfisis_init
  rbsp_load_emfisis, prob=prob, coord='gsm', cad='4sec'
  
  ;; A temporary workaround for the ongoing problem of EMFISIS CDF files (2013-09-28~)
  emfisis_array_flag = 0
  get_data, prefix+'emfisis_l3_4sec_gsm_coordinates', data=d, dl=dl, lim=lim
  if n_elements(d.x) ne n_elements(d.y[*,0]) then begin
    store_data, prefix+'emfisis_l3_4sec_gsm_coordinates', $
      data={ x:d.x[0:(n_elements(d.y[*,0])-1)], y:d.y }, dl=dl, lim=lim
    emfisis_array_flag = 1
  endif
  
  get_timespan, tr
  timespan, [ tr[0]-86400./4, tr[1]+86400./4]
  rslt = tsy_params('t04s')
  
  timespan, tr
  tt04s, prefix+'emfisis_l3_4sec_gsm_coordinates',parmod='t04s_par'
  if keyword_set(smooth) then begin
    tsmooth_in_time, prefix+'emfisis_l3_4sec_gsm_coordinates_bt04s', 600., $
      new=prefix+'emfisis_l3_4sec_gsm_coordinates_bt04s'
  endif
  
  tkm2re, prefix+'emfisis_l3_4sec_gsm_coordinates', /rep
  xyz_to_polar, prefix+'emfisis_l3_4sec_gsm_coordinates',/ph_0_360
  calc, '"'+prefix+'emfisis_l3_4sec_gsm_coordinates_lt"='$
    +'((("'+prefix+'emfisis_l3_4sec_gsm_coordinates_phi"+180.) + 360. ) mod 360.)/360.*24.'
  options, prefix+'emfisis_l3_4sec_gsm_coordinates_mag','ytitle',prefix+'R'
  options, prefix+'emfisis_l3_4sec_gsm_coordinates_mag','ysubtitle','[Re]'
  
  ;Options
  options, prefix+'emfisis_l3_4sec_gsm_Mag','colors','rbg'
  options, prefix+'emfisis_l3_4sec_gsm_Mag','labels',['Bx_gsm','By_gsm','Bz_gsm']
  options, prefix+'emfisis_l3_4sec_gsm_Mag','labflag',1
  options, prefix+'emfisis_l3_4sec_gsm_Mag','thick',2.2
  
  options, prefix+'emfisis_l3_4sec_gsm_coordinates_bt04s','colors','kkk'
  options, prefix+'emfisis_l3_4sec_gsm_coordinates_bt04s','labels',['!C  Bx_t04s','!C  By_t04s','!C  Bz_t04s']
  options, prefix+'emfisis_l3_4sec_gsm_coordinates_bt04s','labflag',-1
  
  split_vec, prefix+'emfisis_l3_4sec_gsm_Mag'
  split_vec, prefix+'emfisis_l3_4sec_gsm_coordinates_bt04s'
  tplot_names, prefix+'emfisis_l3_4sec_gsm_coordinates_bt04s_x'
  
  if keyword_set(smooth) then begin
    tsmooth_in_time, prefix+'emfisis_l3_4sec_gsm_coordinates_bt04s_x', 600., $
      new=prefix+'emfisis_l3_4sec_gsm_coordinates_bt04s_x'
    tplot_names, prefix+'emfisis_l3_4sec_gsm_coordinates_bt04s_x'
    tsmooth_in_time, prefix+'emfisis_l3_4sec_gsm_coordinates_bt04s_y', 600., $
      new=prefix+'emfisis_l3_4sec_gsm_coordinates_bt04s_y'
    tsmooth_in_time, prefix+'emfisis_l3_4sec_gsm_coordinates_bt04s_z', 600., $
      new=prefix+'emfisis_l3_4sec_gsm_coordinates_bt04s_z'
  endif
  
  store_data, 'VAP_and_T04S_Bx', $
    data=[prefix+'emfisis_l3_4sec_gsm_Mag',prefix+'emfisis_l3_4sec_gsm_coordinates_bt04s']+'_x'
  store_data, 'VAP_and_T04S_By', $
    data=[prefix+'emfisis_l3_4sec_gsm_Mag',prefix+'emfisis_l3_4sec_gsm_coordinates_bt04s']+'_y'
  store_data, 'VAP_and_T04S_Bz', $
    data=[prefix+'emfisis_l3_4sec_gsm_Mag',prefix+'emfisis_l3_4sec_gsm_coordinates_bt04s']+'_z'
    
  if ~emfisis_array_flag then begin
    dif_data, prefix+'emfisis_l3_4sec_gsm_Mag_x', $
      prefix+'emfisis_l3_4sec_gsm_coordinates_bt04s_x', $
      new='VAP_and_T04S_dBx'
    dif_data, prefix+'emfisis_l3_4sec_gsm_Mag_y', $
      prefix+'emfisis_l3_4sec_gsm_coordinates_bt04s_y', $
      new='VAP_and_T04S_dBy'
    dif_data, prefix+'emfisis_l3_4sec_gsm_Mag_z', $
      prefix+'emfisis_l3_4sec_gsm_coordinates_bt04s_z', $
      new='VAP_and_T04S_dBz'
  endif
  
  if ~keyword_set(noplot) then $
    tplot, ['OMNI_HRO_1min_SYM_H','VAP_and_T04S_B?','rbsp?_emfisis_l3_4sec_gsm_coordinates_'+['mag','lt']]
  
  return
  
end
