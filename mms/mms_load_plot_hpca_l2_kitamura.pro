;EXAMPLE:
;MMS>  mms_load_plot_hpca_l2_kitamura,'2015-09-01/08:00:00',probe='1',/delete
;MMS>  mms_load_plot_hpca_l2_kitamura,['2015-09-01/12:00:00','2015-09-01/13:00:00'],probe='1',/no_update_dfg,/no_update_fpi,/no_update_hpca,/delete,/no_bss
;MMS>  mms_load_plot_hpca_l2_kitamura,'2015-09-01/08:00:00',probe='1',/brst,/delete
;MMS>  mms_load_plot_hpca_l2_kitamura,['2015-09-01/08:00:00','2015-09-02/00:00:00'],probe='1',/brst,/no_update_dfg,/no_update_fpi,/no_update_hpca,/delete,/no_bss

pro mms_load_plot_hpca_l2_kitamura,trange,probe=probe,brst=brst,no_load_fgm=no_load_fgm,dfg_ql=dfg_ql,no_update_fgm=no_update_fgm,no_load_fpi=no_load_fpi,$
                                   no_update_fpi=no_update_fpi,no_update_hpca=no_update_hpca,no_update_mec=no_update_mec,delete=delete,$
                                   plot_wave=plot_wave,no_bss=no_bss,gsm=gsm

  if not undefined(delete) then store_data,'*',/delete

  status=mms_login_lasp(login_info=login_info,username=username)
  if username eq '' or username eq 'public' then public=1 else public=0

  trange=time_double(trange)
  if n_elements(trange) eq 1 then begin
    if public eq 0 then begin
      roi=mms_get_roi(trange,/next)
      trange=dblarr(2)
      trange[0]=roi[0]-60.d*180.d
      trange[1]=roi[1]+60.d*180.d
    endif else begin
      print
      print,'Please input start and end time to use public data'
      print
      return
    endelse
  endif else begin
    roi=trange
  endelse
  if undefined(probe) then probe='1'
  probe=strcompress(string(probe),/rem)

  dt=trange[1]-trange[0]
  timespan,trange[0],dt,/seconds
  
  prefix='mms'+probe
  if keyword_set(brst) then data_rate='brst' else data_rate='srvy'
  
  mms_init
  loadct2,43
  time_stamp,/off
  if undefined(no_load_fgm) then mms_fgm_plot_kitamura,trange=trange,probe=probe,dfg_ql=dfg_ql,no_update=no_update_fgm,/no_avg,/load_fgm,/no_plot
  if undefined(no_load_fpi) then mms_fpi_plot_kitamura,trange=trange,probe=probe,no_update_fpi=no_update_fpi,/no_plot,/load_fpi
  
  mms_load_hpca,probes=probe,trange=trange,datatype='moments',level='l2',data_rate=data_rate,no_update=no_update_hpca,/time_clip
  mms_load_hpca,probes=probe,trange=trange,datatype='ion',level='l2',data_rate=data_rate,no_update=no_update_hpca,/time_clip
  mms_hpca_calc_anodes,fov=[0,360],probe=probe

  ion_sp=[['hplus','heplusplus','heplus','oplus'],['H!U+!N','He!U++!N','He!U+!N','O!U+!N']]
  if undefined(brst) then begin
    for s=0,n_elements(ion_sp[*,0])-1 do options,[prefix+'_hpca_'+ion_sp[s,0]+'_flux_elev_0-360'],spec=1,datagap=600.d,ytitle='HPCA!C'+ion_sp[s,1]+' fast!CELEV 0-360',ysubtitle='[eV]',ytickformat='mms_exponent2',ztitle=ion_sp[s,1]+'!Cflux',ztickformat='mms_exponent2'
    zlim,[prefix+'_hpca_*plus_flux_elev_0-360'],0.3d,3e6,1
    options,prefix+'_hpca_*plus_number_density',datagap=600.d
  endif else begin
    for s=0,n_elements(ion_sp[*,0])-1 do options,[prefix+'_hpca_'+ion_sp[s,0]+'_flux_elev_0-360'],spec=1,datagap=0.75d,ytitle='HPCA!C'+ion_sp[s,1]+' burst!CELEV 0-360',ysubtitle='[eV]',ytickformat='mms_exponent2',ztitle=ion_sp[s,1]+'!Cflux',ztickformat='mms_exponent2'
    zlim,[prefix+'_hpca_*plus_flux_elev_0-360'],1.d,1000.d,1
    options,prefix+'_hpca_*plus_number_density',datagap=25.d
  endelse
  
  store_data,prefix+'_fpi_hpca_numberDensity',data=[prefix+'_fpi_DISnumberDensity',prefix+'_hpca_hplus_number_density',prefix+'_hpca_heplusplus_number_density',prefix+'_hpca_heplus_number_density',prefix+'_hpca_oplus_number_density']
  options,prefix+'_fpi_hpca_numberDensity',colors=[0,6,3,2,4],labels=['DIS','H+','He++','He+','O+'],labflag=-1,constant=[0.01,0.1,1.0,10.0],ytickformat='mms_exponent2'
  ylim,prefix+'_fpi_hpca_numberDensity',0.001d,100.0d,1
  
  if undefined(no_bss) and public eq 0 then begin
    time_stamp,/on
    spd_mms_load_bss
    split_vec,'mms_bss_status'
    calc,'"mms_bss_complete"="mms_bss_status_0"-0.1d'
    calc,'"mms_bss_incomplete"="mms_bss_status_1"-0.2d'
    calc,'"mms_bss_pending"="mms_bss_status_3"-0.3d'
    del_data,'mms_bss_status_?'
    store_data,'mms_bss',data=['mms_bss_fast','mms_bss_complete','mms_bss_incomplete','mms_bss_pending']
    options,'mms_bss',colors=[6,2,3,4],panel_size=0.5,thick=10.0,xstyle=4,ystyle=4,ticklen=0,yrange=[-0.325d,0.025d],ylabel='',labels=['ROI','Complete','Incomplete','Pending'],labflag=-1
  endif else begin
    time_stamp,/off
  endelse

  if undefined(gsm) then coord='gse' else coord='gsm'
  if strlen(tnames('mms'+probe+'_mec_r_'+coord)) eq 0 then mms_load_mec,trange=trange,probes=probe,no_update=no_update_mec
  tkm2re,'mms'+probe+'_mec_r_'+coord
  split_vec,'mms'+probe+'_mec_r_'+coord+'_re'
  options,'mms'+probe+'_mec_r_'+coord+'_re_x',ytitle=strupcase(coord)+'X [R!DE!N]',format='(f8.4)'
  options,'mms'+probe+'_mec_r_'+coord+'_re_y',ytitle=strupcase(coord)+'Y [R!DE!N]',format='(f8.4)'
  options,'mms'+probe+'_mec_r_'+coord+'_re_z',ytitle=strupcase(coord)+'Z [R!DE!N]',format='(f8.4)'
  tplot_options,var_label=['mms'+probe+'_mec_r_'+coord+'_re_z','mms'+probe+'_mec_r_'+coord+'_re_y','mms'+probe+'_mec_r_'+coord+'_re_x']
  tplot_options,'xmargin',[17,10]
  
  if undefined(wave_plot) then begin
    tplot,['mms_bss','mms'+probe+'_fgm_b_'+coord+'_srvy_l2_btot','mms'+probe+'_fgm_b_'+coord+'_srvy_l2_bvec','mms'+probe+'_fpi_eEnergySpectr_omni','mms'+probe+'_fpi_iEnergySpectr_omni','mms'+probe+'_hpca_hplus_flux_elev_0-360','mms'+probe+'_hpca_heplusplus_flux_elev_0-360','mms'+probe+'_hpca_heplus_flux_elev_0-360','mms'+probe+'_hpca_oplus_flux_elev_0-360','mms'+probe+'_fpi_hpca_numberDensity']
  endif else begin
    tplot,['mms_bss','mms'+probe+'_fgm_b_'+coord+'_srvy_l2_bvec','mms'+probe+'_fgm_srvy_fac_hpfilt','mms'+probe+'_fgm_srvy_fac_xy_dpwrspc_gyro','mms'+probe+'_edp_slow_fast_dce_fac_xy_dpwrspc_gyro','mms'+probe+'_fpi_eEnergySpectr_omni','mms'+probe+'_fpi_iEnergySpectr_omni','mms'+probe+'_hpca_hplus_flux_elev_0-360','mms'+probe+'_hpca_heplus_flux_elev_0-360','mms'+probe+'_hpca_oplus_flux_elev_0-360','mms'+probe+'_fpi_hpca_numberDensity']
  endelse

end
