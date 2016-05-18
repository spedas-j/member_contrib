;+
; PROCEDURE:
;         mms_fpi_brst_plot_kitamura
;
; PURPOSE:
;         Plot magnetic field (FGM (or DFG)) and FPI data obtained by MMS
;
; KEYWORDS:
;         trange:       time range of interest [starttime, endtime] with the format
;                       ['YYYY-MM-DD','YYYY-MM-DD'] or to specify more or less than a day
;                       ['YYYY-MM-DD/hh:mm:ss','YYYY-MM-DD/hh:mm:ss']
;         probe:        a probe - value for MMS SC # (default value is '3')
;         no_plot:      set this flag to skip plotting
;         magplot:      set this flag to plot with fgm(dfg) data
;         no_load:      set this flag to skip loading data
;         dfg_ql:       set this flag to use dfg ql data forcibly. if not set, l2pre data
;                       is used, if available (use with magplot flag)
;         no_update:    set this flag to preserve the original fpi data. if not set and
;                       newer data is found the existing data will be overwritten
;         no_load_mec:  set this flag to skip loading mec data
;         gsm:          set this flag to plot data in the GSM (or DMPA_GSM) coordinate
;         time_clip:    set this flag to time clip the fpi data
;
; EXAMPLE:
;
;     To plot fast plasma investigation (FPI) burst moments with fast survey (or SITL) data
;     MMS>  mms_fpi_brst_plot_kitamura,trange=['2015-09-01/12:00:00','2015-09-01/13:00:00'],probe='3',/magplot
;     MMS>  mms_fpi_brst_plot_kitamura,trange=['2015-09-01/12:00:00','2015-09-01/13:00:00'],probe='3',/magplot,/no_update,/no_bss
;
; NOTES:
;     1) See the notes in mms_load_data for rules on the use of MMS data
;     2) FGM(DFG) data should be loaded before running this procedure if magplot flag is set
;-


pro mms_fpi_brst_plot_kitamura,trange=trange,probe=probe,no_plot=no_plot,magplot=magplot,no_load=no_load,no_update=no_update,$
                               no_bss=no_bss,gsm=gsm,no_load_mec=no_load_mec,l1b=l1b,time_clip=time_clip

  loadct2,43
  time_stamp,/off
  trange=time_double(trange)

  status=mms_login_lasp(login_info=login_info,username=username)
  if username eq '' or username eq 'public' then public=1 else public=0
  
  if undefined(no_load) then begin
    if undefined(l1b) then begin
      mms_load_fpi,trange=trange,probes=probe,level='l2',data_rate='brst',datatype=['des-moms','dis-moms'],no_update=no_update,/center_measurement,time_clip=time_clip
      join_vec,'mms'+probe+'_des_bulk'+['x','y','z']+'_dbcs_brst','mms'+probe+'_des_bulkV_DSC'
      copy_data,'mms'+probe+'_des_numberdensity_dbcs_brst','mms'+probe+'_des_numberDensity'
      join_vec,'mms'+probe+'_dis_bulk'+['x','y','z']+'_dbcs_brst','mms'+probe+'_dis_bulkV_DSC'
      copy_data,'mms'+probe+'_dis_numberdensity_dbcs_brst','mms'+probe+'_dis_numberDensity'
    endif
    if strlen(tnames('mms'+probe+'_dis_numberdensity_dbcs_brst')) eq 0 or strlen(tnames('mms'+probe+'_des_numberdensity_dbcs_brst')) eq 0 then begin
      mms_load_fpi,trange=trange,probes=probe,level='l1b',data_rate='brst',datatype=['des-moms','dis-moms'],no_update=no_update,time_clip=time_clip
      join_vec,'mms'+probe+'_dis_bulk'+['X','Y','Z'],'mms'+probe+'_dis_bulkV_DSC'
      join_vec,'mms'+probe+'_des_bulk'+['X','Y','Z'],'mms'+probe+'_des_bulkV_DSC'
    endif else begin
      
    endelse
  endif
  if undefined(probe) then probe=['3']
  probe=strcompress(string(probe),/remove_all)
  if undefined(trange) then trange=timerange()
  timespan,trange[0],trange[1]-trange[0],/seconds
  
  if strlen(tnames('mms'+probe+'_dis_energyspectr_omni_avg')) gt 0 and strlen(tnames('mms'+probe+'_fpi_iEnergySpectr_omni')) gt 0 then begin
    store_data,'mms'+probe+'_fpi_iEnergySpectr_omni_mix',data=['mms'+probe+'_fpi_iEnergySpectr_omni','mms'+probe+'_dis_energyspectr_omni_avg']
    options,'mms'+probe+'_fpi_iEnergySpectr_omni_mix',spec=1,ytitle='MMS'+probe+'_FPI!CIon!CL2_MIX!Comni',ysubtitle='[eV]',ytickformat='mms_exponent2',ztickformat='mms_exponent2'
    options,'mms'+probe+'_dis_energyspectr_omni_avg',datagap=0.16d
    ylim,'mms'+probe+'_fpi_iEnergySpectr_omni_mix',10.d,30000.d,1
    zlim,'mms'+probe+'_fpi_iEnergySpectr_omni_mix',3e4,3e8,1
    ispec_name='mms'+probe+'_fpi_iEnergySpectr_omni_mix'
  endif else begin
    ispec_name='mms'+probe+'_fpi_iEnergySpectr_omni'
  endelse
  if strlen(tnames('mms'+probe+'_des_energyspectr_omni_avg')) gt 0 and strlen(tnames('mms'+probe+'_fpi_eEnergySpectr_omni')) gt 0 then begin
    store_data,'mms'+probe+'_fpi_eEnergySpectr_omni_mix',data=['mms'+probe+'_fpi_eEnergySpectr_omni','mms'+probe+'_des_energyspectr_omni_avg']
    options,'mms'+probe+'_fpi_eEnergySpectr_omni_mix',spec=1,ytitle='MMS'+probe+'_FPI!CElectron!CL2_MIX!Comni',ysubtitle='[eV]',ytickformat='mms_exponent2',ztickformat='mms_exponent2'
    options,'mms'+probe+'_des_energyspectr_omni_avg',datagap=0.04d
    ylim,'mms'+probe+'_fpi_eEnergySpectr_omni_mix',10.d,30000.d,1
    zlim,'mms'+probe+'_fpi_eEnergySpectr_omni_mix',3e5,3e9,1
    espec_name='mms'+probe+'_fpi_eEnergySpectr_omni_mix'
  endif else begin
    espec_name='mms'+probe+'_fpi_eEnergySpectr_omni'
  endelse
  
  store_data,'mms'+probe+'_fpi_dis_numberDensity',data=['mms'+probe+'_fpi_DISnumberDensity','mms'+probe+'_dis_numberDensity']
  
  if strlen(tnames('mms'+probe+'_des_bulkX_fast_ql')) gt 0 or strlen(tnames('mms'+probe+'_des_bulkX_fast_l1b')) gt 0 or strlen(tnames('mms'+probe+'_des_bulkx_dbcs_fast')) gt 0 then begin
    store_data,'mms'+probe+'_fpi_des_numberDensity',data=['mms'+probe+'_fpi_DESnumberDensity','mms'+probe+'_des_numberDensity']
    store_data,'mms'+probe+'_fpi_dis_des_numberDensity',data=['mms'+probe+'_fpi_DISnumberDensity','mms'+probe+'_dis_numberDensity','mms'+probe+'_fpi_DESnumberDensity','mms'+probe+'_des_numberDensity']
    options,'mms'+probe+'_fpi_dis_des_numberDensity',ytitle='MMS'+probe+'_fpi!CNumber!CDensity',ysubtitle='[cm!U-3!N]',ylog=1,colors=[3,2,0,6],labels=['Ni','Ni_brst','Ne','Ne_brst'],labflag=-1
  endif else begin
    store_data,'mms'+probe+'_fpi_dis_des_numberDensity',data=['mms'+probe+'_fpi_DISnumberDensity','mms'+probe+'_dis_numberDensity','mms'+probe+'_des_numberDensity']
    options,'mms'+probe+'_fpi_dis_des_numberDensity',ytitle='MMS'+probe+'_fpi!CNumber!CDensity',ysubtitle='[cm!U-3!N]',ylog=1,colors=[3,2,6],labels=['Ni','Ni_brst','Ne_brst'],labflag=-1
  endelse
  ylim,'mms'+probe+'_fpi_dis_des_numberDensity',0.03d,300.d,1
  
  options,'mms'+probe+'_dis_numberDensity',ytitle='MMS'+probe+'_fpi!CDIS!CNumber!CDensity',ysubtitle='[cm!U-3!N]',ylog=1,datagap=0.16d
  options,'mms'+probe+'_des_numberDensity',ytitle='MMS'+probe+'_fpi!CDES!CNumber!CDensity',ysubtitle='[cm!U-3!N]',ylog=1,datagap=0.032d
  
  options,'mms'+probe+'_dis_bulkV_DSC',constant=0.0,ytitle='MMS'+probe+'_DIS!CBulkV!CDBCS',ysubtitle='[km/s]',colors=[2,4,1],labels=['V!DX!N','V!DY!N','V!DZ!N'],labflag=-1,datagap=0.16d
  
  if undefined(no_load_mec) then mms_load_mec,trange=trange,probes=probe,no_update=no_update

  if strlen(tnames('mms'+probe+'_defatt_spinras')) eq 0 or strlen(tnames('mms'+probe+'_defatt_spindec')) eq 0 then skip_cotrans=1
  if undefined(skip_cotrans) then begin
    ;This part should be improved in future.
    get_data,'mms'+probe+'_dis_bulkV_DSC',data=d,lim=l,dlim=dl
    dl.data_att.coord_sys='DMPA'
    store_data,'mms'+probe+'_dis_bulkV_DSC',data=d,lim=l,dlim=dl
    mms_cotrans,'mms'+probe+'_dis_bulkV',in_coord='dmpa',in_suffix='_DSC',out_coord='gse',out_suffix='_gse',/ignore_dlimits
    options,'mms'+probe+'_dis_bulkV_gse',constant=0.0,ytitle='MMS'+probe+'_DIS!CBulkV!CGSE',ysubtitle='[km/s]',colors=[2,4,6],labels=['V!DX!N','V!DY!N','V!DZ!N'],labflag=-1,datagap=0.16d
    mms_cotrans,'mms'+probe+'_dis_bulkV',in_coord='gse',in_suffix='_gse',out_coord='gsm',out_suffix='_gsm',/ignore_dlimits
    options,'mms'+probe+'_dis_bulkV_gsm',constant=0.0,ytitle='MMS'+probe+'_DIS!CBulkV!CGSM',ysubtitle='[km/s]',colors=[2,4,6],labels=['V!DX!N','V!DY!N','V!DZ!N'],labflag=-1,datagap=0.16d
  endif
  
  options,'mms'+probe+'_des_bulkV_DSC',constant=0.0,ytitle='MMS'+probe+'_DES!CBulkV!CDBCS',ysubtitle='[km/s]',colors=[2,4,1],labels=['V!DX!N','V!DY!N','V!DZ!N'],labflag=-1,datagap=0.032d

  if undefined(skip_cotrans) then begin
    ;This part should be improved in future.
    get_data,'mms'+probe+'_des_bulkV_DSC',data=d,lim=l,dlim=dl
    dl.data_att.coord_sys='DMPA'
    store_data,'mms'+probe+'_des_bulkV_DSC',data=d,lim=l,dlim=dl
    mms_cotrans,'mms'+probe+'_des_bulkV',in_coord='dmpa',in_suffix='_DSC',out_coord='gse',out_suffix='_gse',/ignore_dlimits
    options,'mms'+probe+'_des_bulkV_gse',constant=0.0,ytitle='MMS'+probe+'_DES!CBulkV!CGSE',ysubtitle='[km/s]',colors=[2,4,6],labels=['V!DX!N','V!DY!N','V!DZ!N'],labflag=-1,datagap=0.032d
    mms_cotrans,'mms'+probe+'_des_bulkV',in_coord='gse',in_suffix='_gse',out_coord='gsm',out_suffix='_gsm',/ignore_dlimits
    options,'mms'+probe+'_des_bulkV_gsm',constant=0.0,ytitle='MMS'+probe+'_DES!CBulkV!CGSM',ysubtitle='[km/s]',colors=[2,4,6],labels=['V!DX!N','V!DY!N','V!DZ!N'],labflag=-1,datagap=0.032d
  endif

  if undefined(no_bss) and public eq 0 then begin
    spd_mms_load_bss,datatype=['fast','status']
    split_vec,'mms_bss_status'
    calc,'"mms_bss_complete"="mms_bss_status_0"-0.1d'
    calc,'"mms_bss_incomplete"="mms_bss_status_1"-0.2d'
    calc,'"mms_bss_pending"="mms_bss_status_3"-0.3d'
    del_data,'mms_bss_status_?'
    store_data,'mms_bss',data=['mms_bss_fast','mms_bss_complete','mms_bss_incomplete','mms_bss_pending']
    options,'mms_bss',colors=[6,2,3,4],panel_size=0.55,thick=10.0,xstyle=4,ystyle=4,ticklen=0,yrange=[-0.325d,0.025d],ylabel='',labels=['ROI','Complete','Incomplete','Pending'],labflag=-1    
  endif

  if not undefined(magplot) then begin
    mms_fgm_plot_kitamura,trange=trange,probe=probe,dfg_ql=dfg_ql,/no_avg,/no_plot
    tplot_options,'xmargin',[20,10]

    if undefined(gsm) then ncoord='GSE' else ncoord='GSM'
    
    if strlen(tnames('mms'+probe+'_fgm_b_'+strlowcase(ncoord)+'_srvy_l2_bvec')) gt 0 then begin
      fgm_name='mms'+probe+'_fgm_b_'+strlowcase(ncoord)+'_srvy_l2'
    endif else begin
      if strlen(tnames('mms'+probe+'_dfg_srvy_l2pre_'+strlowcase(ncoord))) gt 0 then begin
        fgm_name='mms'+probe+'_dfg_srvy_l2pre_'+strlowcase(ncoord)
      endif else begin
        if undefined(gsm) then fgm_name='mms'+probe+'_dfg_srvy_dmpa' else fgm_name='mms'+probe+'_dfg_srvy_gsm_dmpa'
      endelse
    endelse

    if strlen(tnames('mms'+probe+'_mec_r_'+strlowcase(ncoord))) gt 0 then begin
      tkm2re,'mms'+probe+'_mec_r_'+strlowcase(ncoord)
      split_vec,'mms'+probe+'_mec_r_'+strlowcase(ncoord)+'_re'
      options,'mms'+probe+'_mec_r_'+strlowcase(ncoord)+'_re_x',ytitle=ncoord+'X [R!DE!N]',format='(f8.4)'
      options,'mms'+probe+'_mec_r_'+strlowcase(ncoord)+'_re_y',ytitle=ncoord+'Y [R!DE!N]',format='(f8.4)'
      options,'mms'+probe+'_mec_r_'+strlowcase(ncoord)+'_re_z',ytitle=ncoord+'Z [R!DE!N]',format='(f8.4)'
      tplot_options,var_label=['mms'+probe+'_mec_r_'+strlowcase(ncoord)+'_re_z','mms'+probe+'_mec_r_'+strlowcase(ncoord)+'_re_y','mms'+probe+'_mec_r_'+strlowcase(ncoord)+'_re_x']
    endif else begin
      tkm2re,'mms'+probe+'_ql_pos_'+strlowcase(ncoord)
      split_vec,'mms'+probe+'_ql_pos_'+strlowcase(ncoord)+'_re'
      options,'mms'+probe+'_ql_pos_'+strlowcase(ncoord)+'_re_0',ytitle=ncoord+'X [R!DE!N]',format='(f8.4)'
      options,'mms'+probe+'_ql_pos_'+strlowcase(ncoord)+'_re_1',ytitle=ncoord+'Y [R!DE!N]',format='(f8.4)'
      options,'mms'+probe+'_ql_pos_'+strlowcase(ncoord)+'_re_2',ytitle=ncoord+'Z [R!DE!N]',format='(f8.4)'
      options,'mms'+probe+'_ql_pos_'+strlowcase(ncoord)+'_re_3',ytitle='R [R!DE!N]',format='(f8.4)'
      tplot_options, var_label=['mms'+probe+'_ql_pos_'+strlowcase(ncoord)+'_re_3','mms'+probe+'_ql_pos_'+strlowcase(ncoord)+'_re_2','mms'+probe+'_ql_pos_'+strlowcase(ncoord)+'_re_1','mms'+probe+'_ql_pos_'+strlowcase(ncoord)+'_re_0']
      ;    tplot_options, var_label=['mms'+probe+'_ql_pos_'+strlowcase(ncoord)+'_re_2','mms'+probe+'_ql_pos_'+strlowcase(ncoord)+'_re_1','mms'+probe+'_ql_pos_'+strlowcase(ncoord)+'_re_0']
    endelse

    if strlen(tnames('mms'+probe+'_fpi_iBulkV_'+strlowcase(ncoord))) eq 0 then ncoord='DSC' else ncoord=strlowcase(ncoord)
    tplot,['mms_bss',espec_name,ispec_name,'mms'+probe+'_fpi_dis_des_numberDensity','mms'+probe+'_fpi_temp','mms'+probe+'_des_bulkV_'+ncoord,'mms'+probe+'_dis_bulkV_'+ncoord,'mms'+probe+'_fpi_iBulkV_'+ncoord,fgm_name+'_bvec',fgm_name+'_btot']
  
  endif else begin
    if not undefined(no_plot) then begin
      if undefined(gsm) then ncoord='gse' else ncoord='gsm'
      if strlen(tnames('mms'+probe+'_fpi_iBulkV_'+ncoord)) eq 0 then ncoord='DSC'
      tplot_options,'xmargin',[20,10]
;      tplot,['mms_bss',espec_name,ispec_name,'mms'+probe+'_fpi_dis_des_numberDensity','mms'+probe+'_fpi_temp','mms'+probe+'_fpi_eBulkV_DSC','mms'+probe+'_des_bulkV','mms'+probe+'_fpi_iBulkV_DSC','mms'+probe+'_dis_bulkV','mms'+probe+'_fpi_bentPipeB_DSC']
      tplot,['mms_bss',espec_name,ispec_name,'mms'+probe+'_fpi_dis_des_numberDensity','mms'+probe+'_fpi_temp','mms'+probe+'_des_bulkV_'+ncoord,'mms'+probe+'_dis_bulkV_'+ncoord,'mms'+probe+'_fpi_iBulkV_'+ncoord,'mms'+probe+'_fpi_bentPipeB_DSC']
    endif
  endelse

end
