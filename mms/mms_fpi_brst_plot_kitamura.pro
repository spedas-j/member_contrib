;+
; PROCEDURE:
;         mms_fpi_brst_plot_kitamura
;
; PURPOSE:
;         Plot magnetic field (DFG) and FPI data obtained by MMS
;
; KEYWORDS:
;         trange:       time range of interest [starttime, endtime] with the format
;                       ['YYYY-MM-DD','YYYY-MM-DD'] or to specify more or less than a day
;                       ['YYYY-MM-DD/hh:mm:ss','YYYY-MM-DD/hh:mm:ss']
;         probe:        a probe - value for MMS SC # (default value is '3')
;         no_plot:      set this flag to skip plotting
;         magplot:      set this flag to plot with dfg data
;         no_load:      set this flag to skip loading data
;         dfg_ql:       set this flag to use dfg ql data forcibly. if not set, l2pre data
;                       is used, if available (use with magplot flag)
;         no_update:    set this flag to preserve the original fpi data. if not set and
;                       newer data is found the existing data will be overwritten
;
; EXAMPLE:
;
;     To plot fast plasma investigation (FPI) burst moments with fast_sitl data
;     MMS>  mms_fpi_brst_plot_kitamura,trange=['2015-09-01/12:00:00','2015-09-01/13:00:00'],probe='3',/magplot
;     MMS>  mms_fpi_brst_plot_kitamura,trange=['2015-09-01/12:00:00','2015-09-01/13:00:00'],probe='3',/magplot,/no_update,/no_bss
;
; NOTES:
;     1) See the notes in mms_load_data for rules on the use of MMS data
;     2) DFG data should be loaded before running this procedure if magplot flag is set
;-


pro mms_fpi_brst_plot_kitamura,trange=trange,probe=probe,no_plot=no_plot,magplot=magplot,no_load=no_load,no_update=no_update,no_bss=no_bss

  loadct2,43
  time_stamp,/off
  trange=time_double(trange)
  
  if undefined(no_load) then mms_load_fpi,trange=trange,probes=probe,level='l1b',data_rate='brst',datatype=['des-moms','dis-moms'],no_update=no_update
  if undefined(probe) then probe=['3']
  probe=string(probe,format='(i0)')
  if undefined(trange) then trange=timerange()
  timespan,trange[0],trange[1]-trange[0],/seconds
  
  store_data,'mms'+probe+'_fpi_dis_numberDensity',data=['mms'+probe+'_fpi_DISnumberDensity','mms'+probe+'_dis_numberDensity']
  
  if strlen(tnames('mms'+probe+'_des_bulkX_fast_ql')) gt 0 then begin
    store_data,'mms'+probe+'_fpi_des_numberDensity',data=['mms'+probe+'_fpi_DESnumberDensity','mms'+probe+'_des_numberDensity']
    store_data,'mms'+probe+'_fpi_dis_des_numberDensity',data=['mms'+probe+'_fpi_DISnumberDensity','mms'+probe+'_dis_numberDensity','mms'+probe+'_fpi_DESnumberDensity','mms'+probe+'_des_numberDensity']
    options,'mms'+probe+'_fpi_dis_des_numberDensity',ytitle='mms'+probe+'_fpi!CNumber!CDensity',ysubtitle='[cm!U-3!N]',ylog=1,colors=[3,2,0,6],labels=['Ni','Ni_brst','Ne','Ne_brst'],labflag=-1
  endif else begin
    store_data,'mms'+probe+'_fpi_dis_des_numberDensity',data=['mms'+probe+'_fpi_DISnumberDensity','mms'+probe+'_dis_numberDensity','mms'+probe+'_des_numberDensity']
    options,'mms'+probe+'_fpi_dis_des_numberDensity',ytitle='mms'+probe+'_fpi!CNumber!CDensity',ysubtitle='[cm!U-3!N]',ylog=1,colors=[3,2,6],labels=['Ni','Ni_brst','Ne_brst'],labflag=-1
  endelse
  ylim,'mms'+probe+'_fpi_dis_des_numberDensity',0.03d,300.d,1
  
  options,'mms'+probe+'_dis_numberDensity',ytitle='mms'+probe+'_fpi!CDIS!CNumber!CDensity',ysubtitle='[cm!U-3!N]',ylog=1,datagap=0.16d
  options,'mms'+probe+'_des_numberDensity',ytitle='mms'+probe+'_fpi!CDES!CNumber!CDensity',ysubtitle='[cm!U-3!N]',ylog=1,datagap=0.032d
  
  store_data,'mms'+probe+'_dis_bulkV',data=['mms'+probe+'_dis_bulkX','mms'+probe+'_dis_bulkY','mms'+probe+'_dis_bulkZ']
  options,'mms'+probe+'_dis_bulkV',constant=0.0,ytitle='mms'+probe+'_dis!CBulkV',ysubtitle='[km/s]',colors=[2,4,6],labels=['Vx','Vy','Vz'],labflag=-1,datagap=0.16d
  
  store_data,'mms'+probe+'_des_bulkV',data=['mms'+probe+'_des_bulkX','mms'+probe+'_des_bulkY','mms'+probe+'_des_bulkZ']
  options,'mms'+probe+'_des_bulkV',constant=0.0,ytitle='mms'+probe+'_des!CBulkV',ysubtitle='[km/s]',colors=[2,4,6],labels=['Vx','Vy','Vz'],labflag=-1,datagap=0.032d

  if undefined(no_bss) then begin
    mms_load_bss
    split_vec,'mms_bss_status'
    calc,'"mms_bss_complete"="mms_bss_status_0"-0.1d'
    calc,'"mms_bss_incomplete"="mms_bss_status_1"-0.2d'
    calc,'"mms_bss_pending"="mms_bss_status_3"-0.3d'
    del_data,'mms_bss_status_?'
    store_data,'mms_bss',data=['mms_bss_fast','mms_bss_complete','mms_bss_incomplete','mms_bss_pending']
    options,'mms_bss',colors=[6,2,3,4],panel_size=0.55,thick=10.0,xstyle=4,ystyle=4,ticklen=0,yrange=[-0.325d,0.025d],ylabel='',labels=['ROI','Complete','Incomplete','Pending'],labflag=-1    
  endif

  if not undefined(magplot) then begin
    mms_dfg_plot_kitamura,trange=trange,probe=probe,dfg_ql=dfg_ql,/no_avg,/no_plot
    tplot_options,'xmargin',[20,10]
    if strlen(tnames('mms'+probe+'_dfg_srvy_l2pre_gse')) gt 0 then begin
      ql_name=''
      level_name='srvy_l2pre_gse'
    endif else begin
      ql_name='_ql'
      level_name='srvy_dmpa'
    endelse
    
    tkm2re,'mms'+probe+ql_name+'_pos_gse'
    split_vec,'mms'+probe+ql_name+'_pos_gse_re'
    options,'mms'+probe+ql_name+'_pos_gse_re_0',ytitle='GSEX [R!DE!N]',format='(f8.4)'
    options,'mms'+probe+ql_name+'_pos_gse_re_1',ytitle='GSEY [R!DE!N]',format='(f8.4)'
    options,'mms'+probe+ql_name+'_pos_gse_re_2',ytitle='GSEZ [R!DE!N]',format='(f8.4)'
    options,'mms'+probe+ql_name+'_pos_gse_re_3',ytitle='R [R!DE!N]',format='(f8.4)'
    tplot_options, var_label=['mms'+probe+ql_name+'_pos_gse_re_3','mms'+probe+ql_name+'_pos_gse_re_2','mms'+probe+ql_name+'_pos_gse_re_1','mms'+probe+ql_name+'_pos_gse_re_0']
;    tplot,['mms_bss','mms'+probe+'_fpi_eEnergySpectr_omni','mms'+probe+'_fpi_iEnergySpectr_omni','mms'+probe+'_fpi_dis_des_numberDensity','mms'+probe+'_fpi_temp','mms'+probe+'_fpi_eBulkV_DSC','mms'+probe+'_des_bulkV','mms'+probe+'_fpi_iBulkV_DSC','mms'+probe+'_dis_bulkV','mms'+probe+'_dfg_'+level_name+'_bvec','mms'+probe+'_dfg_'+level_name+'_btot']
    tplot,['mms_bss','mms'+probe+'_fpi_eEnergySpectr_omni','mms'+probe+'_fpi_iEnergySpectr_omni','mms'+probe+'_fpi_dis_des_numberDensity','mms'+probe+'_fpi_temp','mms'+probe+'_des_bulkV','mms'+probe+'_dis_bulkV','mms'+probe+'_fpi_iBulkV_DSC','mms'+probe+'_dfg_'+level_name+'_bvec','mms'+probe+'_dfg_'+level_name+'_btot']
  
  endif else begin
    if not undefined(no_plot) then begin
      tplot_options,'xmargin',[20,10]
;      tplot,['mms_bss','mms'+probe+'_fpi_eEnergySpectr_omni','mms'+probe+'_fpi_iEnergySpectr_omni','mms'+probe+'_fpi_dis_des_numberDensity','mms'+probe+'_fpi_temp','mms'+probe+'_fpi_eBulkV_DSC','mms'+probe+'_des_bulkV','mms'+probe+'_fpi_iBulkV_DSC','mms'+probe+'_dis_bulkV','mms'+probe+'_fpi_bentPipeB_DSC']
      tplot,['mms_bss','mms'+probe+'_fpi_eEnergySpectr_omni','mms'+probe+'_fpi_iEnergySpectr_omni','mms'+probe+'_fpi_dis_des_numberDensity','mms'+probe+'_fpi_temp','mms'+probe+'_des_bulkV','mms'+probe+'_dis_bulkV','mms'+probe+'_fpi_iBulkV_DSC','mms'+probe+'_fpi_bentPipeB_DSC']
    endif
  endelse

end
