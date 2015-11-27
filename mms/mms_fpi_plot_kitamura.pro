;+
; PROCEDURE:
;         mms_fpi_plot_kitamura
;
; PURPOSE:
;         Plot ion and electron data obtained by MMS-FPI(fast_sitl)
;
; KEYWORDS:
;         trange:       time range of interest [starttime, endtime] with the format
;                       ['YYYY-MM-DD','YYYY-MM-DD'] or to specify more or less than a day
;                       ['YYYY-MM-DD/hh:mm:ss','YYYY-MM-DD/hh:mm:ss'].
;                       if the format is 'YYYY-MM-DD' or 'YYYY-MM-DD/hh:mm:ss' (one element)
;                       the time range is set as from 30 minutes before the beginning of the
;                       ROI just after the specified time to 30 minutes after the end of the ROI.
;         probe:        number of probe to plot dfg data (default value is '3')
;         no_plot:      set this flag to skip plotting
;         magplot:      set this flag to plot with dfg data
;         load_dfg:     set this flag to load dfg data
;         no_update_dfg:set this flag to preserve the original dfg data. if not set and
;                       newer data is found the existing data will be overwritten
;         load_fpi:     set this flag to load fpi data
;         no_update_fpi:set this flag to preserve the original fpi data. if not set and
;                       newer data is found the existing data will be overwritten         
;         no_avg:       set this flag to skip making 2.5 sec averaged dfg data
;         dfg_ql:       set this flag to use dfg ql data forcibly. if not set, l2pre data
;                       is used, if available
;         no_update_edp:set this flag to preserve the original edp data. if not set and
;                       newer data is found the existing data will be overwritten
;
; EXAMPLE:
;
;     To plot fast plasma investigation (FPI) fast_sitl data
;     MMS>  mms_dfg_plot_kitamura,trange=['2015-09-01/12:00:00','2015-09-01/15:00:00'],probe='1',/no_avg
;
; NOTES:
;     1) See the notes in mms_load_data for rules on the use of MMS data
;     2) DFG and FPI data should be loaded before running this procedure ()
;     3) Information of version of the first cdf files is shown in the plot,
;        if multiple cdf files are loaded for DFG or FPI
;-

pro mms_fpi_plot_kitamura,trange=trange,probe=probe,no_plot=no_plot,magplot=magplot,no_avg=no_avg,dfg_ql=dfg_ql,load_dfg=load_dfg,no_update_dfg=no_update_dfg,load_fpi=load_fpi,no_update_fpi=no_update_fpi,add_scpot=add_scpot,no_update_edp=no_update_edp

  loadct2,43
  time_stamp,/off
  if undefined(trange) then trange=timerange()
  if n_elements(trange) eq 1 then begin
    trange=mms_get_roi(trange,/next)
    trange[0]=trange[0]-60.d*30.d
    trange[1]=trange[1]+60.d*30.d
  endif
  trange=time_double(trange)
  if undefined(probe) then probe=['3']
  probe=string(probe,format='(i0)')
  
  dt=trange[1]-trange[0]
  timespan,trange[0],dt,/seconds

  if not undefined(load_fpi) then mms_load_fpi,trange=trange,probes=probe,level='sitl',data_rate='fast',no_update=no_update_fpi

  if not undefined(add_scpot) then begin
    mms_load_edp,trange=trange,data_rate='slow',probes=probe,datatype='scpot',level='l2',no_update=no_update_edp
    mms_load_edp,trange=trange,data_rate='fast',probes=probe,datatype='scpot',level='l2',no_update=no_update_edp
    avg_data,'mms'+probe+'_edp_slow_scpot',10.d,trange=[time_double(time_string(trange[0],format=0,precision=-3)),time_double(time_string(trange[1],format=0,precision=-3))+24.d*3600.d]
    avg_data,'mms'+probe+'_edp_fast_scpot',10.d,trange=[time_double(time_string(trange[0],format=0,precision=-3)),time_double(time_string(trange[1],format=0,precision=-3))+24.d*3600.d]
;    store_data,'mms'+probe+'_edp_scpot_avg',data=['mms'+probe+'_edp_slow_scpot_avg','mms'+probe+'_edp_fast_scpot_avg']
;    options,'mms'+probe+'_edp'+['','_slow','_fast']+'_scpot_avg',ystyle=9,ylog=1,axis={yaxis:1,ytitle:'mms'+probe+'_edp!Cs/c pot!C[V]',yrange:[0.05d,300.d],ytickformat:'mms_exponent2'}
    options,'mms'+probe+'_edp'+['_slow','_fast']+'_scpot_avg',axis={yaxis:1,ytitle:'mms'+probe+'_edp!Cs/c pot!C[V]',ylog:1,ystyle:9,yrange:[0.05d,300.d],ytickformat:'mms_exponent2'}
  endif  

  get_data,'mms'+probe+'_fpi_eEnergySpectr_pX',dlim=dl
  
  if n_elements(dl.cdf.gatt.data_version) gt 0 then begin
    ;fpi_dv=dl.cdf.gatt.data_version
    fpi_dv=strmid(dl.cdf.gatt.logical_file_id,4,5,/reverse_offset)
    ;print,fpi_dv
    fpiver='v'+fpi_dv
    
    mms_load_fpi_calc_omni,probe
    store_data,'mms'+probe+'_fpi_eEnergySpectr_omni_avg',newname='mms'+probe+'_fpi_eEnergySpectr_omni'
    store_data,'mms'+probe+'_fpi_iEnergySpectr_omni_avg',newname='mms'+probe+'_fpi_iEnergySpectr_omni'
    
    options,['mms'+probe+'_fpi_?EnergySpectr_??','mms'+probe+'_fpi_D?SnumberDensity','mms'+probe+'_fpi_?BulkV_?_DSC','mms'+probe+'_fpi_D?StempP???','mms'+probe+'_fpi_bentPipeB_?_DSC'],datagap=10.5d
    
    options,'mms'+probe+'_fpi_eEnergySpectr_omni',spec=1.0,ytitle='mms'+probe+'_fpi!C'+fpiver+'!CElectron!CEnergySpectr!Comni',ysubtitle='[eV]',datagap=10.5d,ytickformat='mms_exponent2',ztickformat='mms_exponent2'
    ylim,'mms'+probe+'_fpi_eEnergySpectr_omni',10.d,30000.d,1
    zlim,'mms'+probe+'_fpi_eEnergySpectr_omni',0.1d,50000.d,1
    
    options,'mms'+probe+'_fpi_iEnergySpectr_omni',spec=1.0,ytitle='mms'+probe+'_fpi!C'+fpiver+'!CIon!CEnergySpectr!Comni',ysubtitle='[eV]',datagap=10.5d,ytickformat='mms_exponent2',ztickformat='mms_exponent2'
    ylim,'mms'+probe+'_fpi_iEnergySpectr_omni',10.d,30000.d,1
    zlim,'mms'+probe+'_fpi_iEnergySpectr_omni',0.1d,2000.d,1
    
;    store_data,'mms'+probe+'_fpi_numberDensity',data=['mms'+probe+'_fpi_DISnumberDensity','mms'+probe+'_fpi_DESnumberDensity']
;    options,'mms'+probe+'_fpi_numberDensity',ytitle='mms'+probe+'_fpi!CNumberDensity',ysubtitle='[cm!U-3!N]',ylog=1,colors=[0,6],labels=['Ni','Ne'],labflag=-1,datagap=10.5d,ytickformat='mms_exponent2'
    options,'mms'+probe+'_fpi_DISnumberDensity',ytitle='mms'+probe+'_fpi!CIon!CNumberDensity',ysubtitle='[cm!U-3!N]',colors=6,ylog=1,datagap=10.5d,ytickformat='mms_exponent2'
    ylim,'mms'+probe+'_fpi_DISnumberDensity',0.05d,300.d,1
;    options,'mms'+probe+'_fpi_DESnumberDensity',ytitle='mms'+probe+'_fpi!CElectron!CNumberDensity',ysubtitle='[cm!U-3!N]',colors=6,ylog=1,datagap=10.5d,ytickformat='mms_exponent2'
;    ylim,'mms'+probe+'_fpi_DESnumberDensity',0.05d,300.d,1
    if undefined(add_scpot) and strlen(tnames('mms'+probe+'_edp_fast_scpot_avg')) gt 0 then begin
      copy_data,'mms'+probe+'_fpi_DISnumberDensity','mms'+probe+'_fpi_numberDensity'
    endif else begin
      options,'mms'+probe+'_fpi_DISnumberDensity',ystyle=9
      store_data,'mms'+probe+'_fpi_numberDensity',data=['mms'+probe+'_edp_slow_scpot_avg','mms'+probe+'_edp_fast_scpot_avg','mms'+probe+'_fpi_DISnumberDensity']
      options,'mms'+probe+'_fpi_numberDensity',ytickformat='mms_exponent2'
    endelse
    ylim,'mms'+probe+'_fpi_numberDensity',0.05d,300.d,1


    
    store_data,'mms'+probe+'_fpi_iBulkV_DSC',data=['mms'+probe+'_fpi_iBulkV_X_DSC','mms'+probe+'_fpi_iBulkV_Y_DSC','mms'+probe+'_fpi_iBulkV_Z_DSC']
    options,'mms'+probe+'_fpi_iBulkV_DSC',constant=0.0,ytitle='mms'+probe+'_fpi!CiBulkV_DSC',ysubtitle='[km/s]',colors=[2,4,6],labels=['V!DX_DSC!N','V!DY_DSC!N','V!DZ_DSC!N'],labflag=-1,datagap=10.5d
    
    ;store_data,'mms'+probe+'_fpi_eBulkV_DSC',data=['mms'+probe+'_fpi_eBulkV_X_DSC','mms'+probe+'_fpi_eBulkV_Y_DSC','mms'+probe+'_fpi_eBulkV_Z_DSC']
    ;options,'mms'+probe+'_fpi_eBulkV_DSC',constant=0.0,ytitle='mms'+probe+'_fpi!CeBulkV_DSC',ysubtitle='[km/s]',colors=[2,4,6],labels=['V!DX_DSC!N','V!DY_DSC!N','V!DZ_DSC!N'],labflag=-1,datagap=10.5d
    
    store_data,'mms'+probe+'_fpi_DEStemp',data=['mms'+probe+'_fpi_DEStempPerp','mms'+probe+'_fpi_DEStempPara']
    options,'mms'+probe+'_fpi_DEStemp',ylog=1,ytitle='mms'+probe+'_fpi!CeTemp',ysubtitle='[eV]',colors=[6,0],labels=['Perp','Para'],labflag=-1,datagap=10.5d,ytickformat='mms_exponent2'
    store_data,'mms'+probe+'_fpi_DIStemp',data=['mms'+probe+'_fpi_DIStempPerp','mms'+probe+'_fpi_DIStempPara']
    options,'mms'+probe+'_fpi_DIStemp',ylog=1,ytitle='mms'+probe+'_fpi!CiTemp',ysubtitle='[eV]',colors=[6,0],labels=['Perp','Para'],labflag=-1,datagap=10.5d,ytickformat='mms_exponent2'
    store_data,'mms'+probe+'_fpi_temp',data=['mms'+probe+'_fpi_DIStempPerp','mms'+probe+'_fpi_DIStempPara','mms'+probe+'_fpi_DEStempPerp','mms'+probe+'_fpi_DEStempPara']
    ylim,'mms'+probe+'_fpi_temp',5.d,50000.d,1
    options,'mms'+probe+'_fpi_temp',ylog=1,ytitle='mms'+probe+'_fpi!CTemp',ysubtitle='[eV]',colors=[2,4,6,0],labels=['Ti_Perp','Ti_Para','Te_Perp','Te_Para'],labflag=-1,datagap=10.5d,ytickformat='mms_exponent2'
    
    store_data,'mms'+probe+'_fpi_bentPipeB_DSC',data=['mms'+probe+'_fpi_bentPipeB_X_DSC','mms'+probe+'_fpi_bentPipeB_Y_DSC','mms'+probe+'_fpi_bentPipeB_Z_DSC']
    options,'mms'+probe+'_fpi_bentPipeB_DSC',ytitle='mms'+probe+'_fpi!CbentPipeB!CDSC',constant=0.0,colors=[2,4,6],labels=['B!DX!N_DSC','B!DY!N_DSC','B!DZ!N_DSC'],labflag=-1,datagap=10.5d
    ylim,'mms'+probe+'_fpi_bentPipeB_DSC',-1.0,1.0,0
    
    if not undefined(magplot) then begin
      mms_dfg_plot_kitamura,trange=trange,probe=probe,no_avg=no_avg,dfg_ql=dfg_ql,load_dfg=load_dfg,no_update=no_update_dfg,/no_plot
      tplot_options,'xmargin',[20,12]
      if strlen(tnames('mms'+probe+'_dfg_srvy_l2pre_gse')) eq 0 then begin
  ;      tplot,['mms'+probe+'_fpi_eEnergySpectr_omni','mms'+probe+'_fpi_iEnergySpectr_omni','mms'+probe+'_fpi_numberDensity','mms'+probe+'_fpi_temp','mms'+probe+'_fpi_eBulkV_DSC','mms'+probe+'_fpi_iBulkV_DSC','mms'+probe+'_dfg_srvy_dmpa_xyz_avg','mms'+probe+'_dfg_srvy_dmpa_btot']
        tplot,['mms'+probe+'_fpi_eEnergySpectr_omni','mms'+probe+'_fpi_iEnergySpectr_omni','mms'+probe+'_fpi_numberDensity','mms'+probe+'_fpi_temp','mms'+probe+'_fpi_iBulkV_DSC','mms'+probe+'_dfg_srvy_dmpa_bvec_avg','mms'+probe+'_dfg_srvy_dmpa_btot']
      endif else begin
  ;      tplot,['mms'+probe+'_fpi_eEnergySpectr_omni','mms'+probe+'_fpi_iEnergySpectr_omni','mms'+probe+'_fpi_numberDensity','mms'+probe+'_fpi_temp','mms'+probe+'_fpi_eBulkV_DSC','mms'+probe+'_fpi_iBulkV_DSC','mms'+probe+'_dfg_srvy_l2pre_gse_xyz_avg','mms'+probe+'_dfg_srvy_l2pre_gse_m']
        tplot,['mms'+probe+'_fpi_eEnergySpectr_omni','mms'+probe+'_fpi_iEnergySpectr_omni','mms'+probe+'_fpi_numberDensity','mms'+probe+'_fpi_temp','mms'+probe+'_fpi_iBulkV_DSC','mms'+probe+'_dfg_srvy_l2pre_gse_bvec_avg','mms'+probe+'_dfg_srvy_l2pre_gse_btot']
      endelse
    endif else begin
      if undefined(no_plot) then begin
        tplot_options,'xmargin',[20,12]
  ;      tplot,['mms'+probe+'_fpi_eEnergySpectr_omni','mms'+probe+'_fpi_iEnergySpectr_omni','mms'+probe+'_fpi_numberDensity','mms'+probe+'_fpi_temp','mms'+probe+'_fpi_eBulkV_DSC','mms'+probe+'_fpi_iBulkV_DSC','mms'+probe+'_fpi_bentPipeB_DSC']
        tplot,['mms'+probe+'_fpi_eEnergySpectr_omni','mms'+probe+'_fpi_iEnergySpectr_omni','mms'+probe+'_fpi_numberDensity','mms'+probe+'_fpi_temp','mms'+probe+'_fpi_iBulkV_DSC','mms'+probe+'_fpi_bentPipeB_DSC']
      endif
    endelse
  endif else begin
    print,'FPI data files are not found in this interval.'
  endelse

end
