;EXAMPLE:
;MMS>  mms_load_plot_hpca_kitamura,'2015-09-01/08:00:00',probe='1',/delete
;MMS>  mms_load_plot_hpca_kitamura,['2015-09-01/12:00:00','2015-09-01/13:00:00'],probe='1',/no_update_dfg,/no_update_fpi,/no_update_hpca,/delete,/no_bss
;MMS>  mms_load_plot_hpca_kitamura,'2015-09-01/08:00:00',probe='1',/brst,/delete
;MMS>  mms_load_plot_hpca_kitamura,['2015-09-01/08:00:00','2015-09-02/00:00:00'],probe='1',/brst,/no_update_dfg,/no_update_fpi,/no_update_hpca,/delete,/no_bss

pro mms_load_plot_hpca_kitamura,trange,probe=probe,brst=brst,no_load_dfg=no_load_dfg,dfg_ql=dfg_ql,no_update_fgm=no_update_fgm,$
                                no_load_fpi=no_load_fpi,no_update_fpi=no_update_fpi,no_update_mec=no_update_mec,$
                                no_update_hpca=no_update_hpca,delete=delete,plot_wave=plot_wave,no_bss=no_bss,gsm=gsm

  if not undefined(delete) then store_data,'*',/delete

  if n_elements(trange) eq 1 then begin
    roi=mms_get_roi(trange,/next)
    trange=dblarr(2)
    trange[0]=roi[0]-60.d*210.d
    trange[1]=roi[1]+60.d*210.d
  endif else begin
    trange=time_double(trange)
    roi=trange
  endelse
  if undefined(probe) then probe=['3']
  probe=strcompress(string(probe),/rem)

  dt=trange[1]-trange[0]
  timespan,trange[0],dt,/seconds
  
  prefix='mms'+probe
  if keyword_set(brst) then data_rate='brst' else data_rate='srvy'
  
  if undefined(gsm) then coord='gse' else coord='gsm'
  
  mms_init
  loadct2,43
  time_stamp,/off
  if undefined(no_load_fgm) then mms_fgm_plot_kitamura,trange=trange,probe=probe,dfg_ql=dfg_ql,no_update=no_update_fgm,/no_avg,/load_fgm,/no_plot
  if strlen(tnames('mms'+probe+'_fgm_b_'+coord+'_srvy_l2')) gt 0 and undefined(dfg_ql) then begin
    fgm_name='mms'+probe+'_fgm_b_'+coord+'_srvy_l2'
  endif else begin
    if strlen(tnames('mms'+probe+'_dfg_b_'+coord+'_srvy_l2pre')) gt 0 and undefined(dfg_ql) then begin
      ql=''
      fgm_name='mms'+probe+'_dfg_b_'+coord+'_srvy_l2pre'
    endif else begin
      ql='_ql'
      fgm_name='mms'+probe+'_dfg_srvy_dmpa'
    endelse
  endelse


  if undefined(no_load_fpi) then mms_fpi_plot_kitamura,trange=trange,probe=probe,no_update_fpi=no_update_fpi,/no_plot,/load_fpi
  
  mms_load_hpca,probes=probe,trange=trange,datatype='moments',level='l1b',data_rate=data_rate,no_update=no_update_hpca
  mms_load_hpca,probes=probe,trange=trange,datatype='rf_corr',level='l1b',data_rate=data_rate,no_update=no_update_hpca
  mms_hpca_calc_anodes,fov=[0,360],probe=probe

  ion_sp=[['hplus','heplusplus','heplus','oplusplus','oplus'],['H!U+!N','He!U++!N','He!U+!N','O!U++!N','O!U+!N']]
  if undefined(brst) then begin
    for s=0,n_elements(ion_sp[*,0])-1 do options,[prefix+'_hpca_'+ion_sp[s,0]+'_RF_corrected_elev_0-360'],spec=1,datagap=600.d,ytitle='HPCA!C'+ion_sp[s,1]+' fast!CELEV 0-360',ysubtitle='[eV]',ytickformat='mms_exponent2',ztitle=ion_sp[s,1]+'!CRF_corrected',ztickformat='mms_exponent2'
    zlim,[prefix+'_hpca_*plus_RF_corrected_elev_0-360'],0.1d,1000.d,1
    options,prefix+'_hpca_*plus_number_density',datagap=600.d
  endif else begin
    for s=0,n_elements(ion_sp[*,0])-1 do options,[prefix+'_hpca_'+ion_sp[s,0]+'_RF_corrected_elev_0-360'],spec=1,datagap=0.75d,ytitle='HPCA!C'+ion_sp[s,1]+' burst!CELEV 0-360',ysubtitle='[eV]',ytickformat='mms_exponent2',ztitle=ion_sp[s,1]+'!CRF_corrected',ztickformat='mms_exponent2'
    zlim,[prefix+'_hpca_*plus_RF_corrected_elev_0-360'],1.d,1000.d,1
    options,prefix+'_hpca_*plus_number_density',datagap=25.d
  endelse
  
  store_data,prefix+'_fpi_hpca_numberDensity',data=[prefix+'_fpi_DISnumberDensity',prefix+'_hpca_hplus_number_density',prefix+'_hpca_heplusplus_number_density',prefix+'_hpca_heplus_number_density',prefix+'_hpca_oplusplus_number_density',prefix+'_hpca_oplus_number_density']
  options,prefix+'_fpi_hpca_numberDensity',colors=[0,6,3,2,5,4],labels=['DIS','H+','He++','He+','O++','O+'],labflag=-1,constant=[0.01,0.1,1.0,10.0],ytickformat='mms_exponent2'
  ylim,prefix+'_fpi_hpca_numberDensity',0.001d,100.0d,1
  
  mms_cotrans,'mms'+probe+'_hpca_hplus_ion_bulk_velocity',in_coord='dmpa',out_coord=coord,out_suffix='_'+coord,/ignore_dlimit
  options,'mms'+probe+'_hpca_hplus_ion_bulk_velocity_'+coord,constant=0.0
  ylim,'mms'+probe+'_hpca_hplus_ion_bulk_velocity_'+coord,-300.0,300.0,0
  
  if undefined(no_bss) then begin
    time_stamp,/on
    spd_mms_load_bss,datatype=['fast','status']
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

  if strlen(tnames('mms'+probe+'_mec_r_'+coord)) eq 0 then mms_load_mec,trange=trange,probes=probe,no_update=no_update_mec,varformat=['mms'+probe+'_mec_r_eci','mms'+probe+'_mec_r_gse','mms'+probe+'_mec_r_gsm','mms'+probe+'_mec_L_vec']
  if strlen(tnames('mms'+probe+'_mec_r_'+coord)) gt 0 then begin
    tkm2re,'mms'+probe+'_mec_r_'+coord
    split_vec,'mms'+probe+'_mec_r_'+coord+'_re'
    options,'mms'+probe+'_mec_r_'+coord+'_re_x',ytitle=strupcase(coord)+'X [R!DE!N]',format='(f8.4)'
    options,'mms'+probe+'_mec_r_'+coord+'_re_y',ytitle=strupcase(coord)+'Y [R!DE!N]',format='(f8.4)'
    options,'mms'+probe+'_mec_r_'+coord+'_re_z',ytitle=strupcase(coord)+'Z [R!DE!N]',format='(f8.4)'
    tplot_options,var_label=['mms'+probe+'_mec_r_'+coord+'_re_z','mms'+probe+'_mec_r_'+coord+'_re_y','mms'+probe+'_mec_r_'+coord+'_re_x']
  endif else begin
    tkm2re,'mms'+probe+ql+'_pos_gsm'
    split_vec,'mms'+probe+ql+'_pos_'+coord+'_re'
    options,'mms'+probe+ql+'_pos_'+coord+'_re_0',ytitle='MMS'+probe+' '+strupcase(coord)+'X [R!DE!N]',format='(f7.3)'
    options,'mms'+probe+ql+'_pos_'+coord+'_re_1',ytitle='MMS'+probe+' '+strupcase(coord)+'Y [R!DE!N]',format='(f7.3)'
    options,'mms'+probe+ql+'_pos_'+coord+'_re_2',ytitle='MMS'+probe+' '+strupcase(coord)+'Z [R!DE!N]',format='(f7.3)'
    options,'mms'+probe+ql+'_pos_'+coord+'_re_3',ytitle='MMS'+probe+' R [R!DE!N]',format='(f7.3)'
    tplot_options, var_label=['mms'+probe+ql+'_pos_'+coord+'_re_3','mms'+probe+ql+'_pos_'+coord+'_re_2','mms'+probe+ql+'_pos_'+coord+'_re_1','mms'+probe+ql+'_pos_'+coord+'_re_0']
  endelse
  
  tplot_options,'xmargin',[15,10]              ; Set left/right margins to 10 characters
  
  if undefined(wave_plot) then begin
    tplot,['mms_bss',fgm_name+'_mod','mms'+probe+'_fpi_eEnergySpectr_omni','mms'+probe+'_fpi_iEnergySpectr_omni','mms'+probe+'_hpca_hplus_RF_corrected_elev_0-360','mms'+probe+'_hpca_heplusplus_RF_corrected_elev_0-360','mms'+probe+'_hpca_heplus_RF_corrected_elev_0-360','mms'+probe+'_hpca_oplusplus_RF_corrected_elev_0-360','mms'+probe+'_hpca_oplus_RF_corrected_elev_0-360','mms'+probe+'_fpi_hpca_numberDensity','mms'+probe+'_hpca_hplus_ion_bulk_velocity_'+coord]
  endif else begin
    tplot,['mms_bss',fgm_name+'_bvec','mms'+probe+'_fgm_srvy_fac_hpfilt','mms'+probe+'_fgm_srvy_fac_xy_dpwrspc_gyro','mms'+probe+'_edp_slow_fast_dce_fac_xy_dpwrspc_gyro','mms'+probe+'_fpi_eEnergySpectr_omni','mms'+probe+'_fpi_iEnergySpectr_omni','mms'+probe+'_hpca_hplus_RF_corrected_elev_0-360','mms'+probe+'_hpca_heplus_RF_corrected_elev_0-360','mms'+probe+'_hpca_oplus_RF_corrected_elev_0-360','mms'+probe+'_fpi_hpca_numberDensity']
  endelse

end
