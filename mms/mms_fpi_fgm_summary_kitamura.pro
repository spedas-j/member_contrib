;+
; PROCEDURE:
;         mms_fpi_fgm_summary_kitamura
;
; PURPOSE:
;         Plot magnetic field (FGM (or DFG)) and FPI data obtained by MMS
;
; KEYWORDS:
;         trange:       time range of interest [starttime, endtime] with the format
;                       ['YYYY-MM-DD','YYYY-MM-DD'] or to specify more or less than a day
;                       ['YYYY-MM-DD/hh:mm:ss','YYYY-MM-DD/hh:mm:ss']
;                       if the format is 'YYYY-MM-DD' or 'YYYY-MM-DD/hh:mm:ss' (one element)
;                       the time range is set as from 30 minutes before the beginning of the
;                       ROI just after the specified time to 30 minutes after the end of the ROI.
;         probe:        a probe - value for MMS SC #
;         delete:       set this flag to delete all tplot variables at the beginning
;         no_short:     set this flag to skip short plots (2 hours)
;         no_update_fpi:set this flag to preserve the original fpi data. if not set and
;                       newer data is found the existing data will be overwritten 
;         no_update_fgm:set this flag to preserve the original fgm data. if not set and
;                       newer data is found the existing data will be overwritten
;         add_scpot:    set this flag to additionally plot scpot data with number densities
;         no_bss:       set this flag to skip loading bss data
;         full_bss:     set this flag to load detailed bss data (team member only)
;         no_load:      set this flag to skip loading data
;         dfg_ql:       set this flag to use dfg ql data forcibly. if not set, l2pre data
;                       are used, if available (team member only)
;         no_output:    set this flag to skip making png and ps files
;         fpi_sitl:     set this flag to use fpi fast sitl data forcibly. if not set, fast ql data
;                       are used, if available (team member only)
;         plotdir:      set this flag to assine a directory for plots
;         plotcdir:     set this flag to assine a directory for plots with currents in the LMN coordinate
;
; EXAMPLE:
;
;     To make summary plots of fluxgate magnetometers (FGM (or DFG)) and fast plasma investigation (FPI) data
;     team members
;     MMS>  mms_fpi_fgm_summary_kitamura,'2015-09-01/08:00:00','3',/delete,/add_scpot,/no_output
;     public users
;     MMS>  mms_fpi_fgm_summary_kitamura,['2015-09-01/08:00:00','2015-09-02/00:00:00'],'3',/delete,/no_output,/add_scpot
;
; NOTES:
;     1) See the notes in mms_load_data for rules on the use of MMS data
;     2) Set plotdir before use if you output plots
;     3) Information of version of the first cdf files is shown in the plot,
;        if multiple cdf files are loaded for FGM(DFG) or FPI
;-

pro mms_fpi_fgm_summary_kitamura,trange,probe,delete=delete,no_short=no_short,no_update_fpi=no_update_fpi,no_update_fgm=no_update_fgm,$
                                 no_bss=no_bss,full_bss=full_bss,no_load=no_load,dfg_ql=dfg_ql,no_output=no_output,$
                                 add_scpot=add_scpot,no_update_edp=no_update_edp,edp_comm=edp_comm,fpi_sitl=fpi_sitl,$
                                 plotdir=plotdir,plotcdir=plotcdir

  probe=strcompress(string(probe),/remove_all)

  mms_init
  loadct2,43
  if not undefined(delete) then store_data,'*',/delete

  status=mms_login_lasp(login_info=login_info,username=username)
  if username eq '' or username eq 'public' then public=1 else public=0

  stime=time_double(trange)
  if n_elements(stime) eq 1 then begin
    if public eq 0 then begin
      roi=mms_get_roi(stime,/next)
      trange=dblarr(2)
      trange[0]=roi[0]-60.d*30.d
      trange[1]=roi[1]+60.d*30.d
    endif else begin
      print
      print,'Please input start and end time to use public data'
      print
      return
    endelse
  endif else begin
    trange=stime
    roi=trange
  endelse

  timespan,trange[0],trange[1]-trange[0],/seconds

  if undefined(no_load) then begin
    if undefined(dfg_ql) then begin
      mms_load_fgm,trange=trange,instrument='fgm',probes=probe,data_rate='srvy',level='l2',no_update=no_update_fgm,/no_attitude_data
      if strlen(tnames('mms'+probe+'_fgm_b_gse_srvy_l2_bvec')) eq 0 then begin
        mms_load_fgm,trange=trange,instrument='dfg',probes=probe,data_rate='srvy',level='l2pre',no_update=no_update_fgm,/no_attitude_data
      endif else begin
        get_data,'mms'+probe+'_fgm_b_gse_srvy_l2_bvec',data=d
        if d.x[0] gt roi[1] or time_double(time_string(d.x[n_elements(d.x)-1]-10.d,format=0,precision=-3)) lt time_double(time_string(roi[1],format=0,precision=-3)) then begin
          store_data,'mms'+probe+'_fgm_*',/delete 
          mms_load_fgm,trange=trange,instrument='dfg',probes=probe,data_rate='srvy',level='l2pre',no_update=no_update_fgm,/no_attitude_data
        endif
      endelse
    endif
    if strlen(tnames('mms'+probe+'_fgm_b_gse_srvy_l2_bvec')) eq 0 and strlen(tnames('mms'+probe+'_dfg_srvy_l2pre_gse')) eq 0 then begin
      mms_load_fgm,trange=trange,instrument='dfg',probes=probe,data_rate='srvy',level='ql',no_update=no_update_fgm,/no_attitude_data
      get_data,'mms'+probe+'_dfg_srvy_gsm_dmpa',data=fgm_data,dlimits=fgm_dlimits
      store_data,'mms'+probe+'_dfg_srvy_gsm_dmpa_bvec',data={x:fgm_data.X,y:[[fgm_data.Y[*,0]],[fgm_data.Y[*,1]],[fgm_data.Y[*,2]]]},dlimits=fgm_dlimits
      store_data,'mms'+probe+'_dfg_srvy_gsm_dmpa_btot',data={x:fgm_data.X,y:fgm_data.Y[*, 3]},dlimits=fgm_dlimits
      options,'mms'+probe+'_dfg_srvy*dmpa_btot',colors=1
      undefine,fgm_data,fgm_dlimits
    endif else begin
      if strlen(tnames('mms'+probe+'_fgm_b_gse_srvy_l2_bvec')) eq 0 then begin
        get_data,'mms'+probe+'_dfg_srvy_l2pre_gse',data=d
        if d.x[0] gt roi[1] or time_double(time_string(d.x[n_elements(d.x)-1]-10.d,format=0,precision=-3)) lt time_double(time_string(roi[1],format=0,precision=-3)) then begin
          store_data,'mms'+probe+'_dfg_srvy_l2pre*',/delete
          store_data,'mms'+probe+'_pos*',/delete
          mms_load_fgm,trange=trange,instrument='dfg',probes=probe,data_rate='srvy',level='ql',no_update=no_update_fgm,/no_attitude_data
          get_data,'mms'+probe+'_dfg_srvy_gsm_dmpa',data=fgm_data,dlimits=fgm_dlimits
          store_data,'mms'+probe+'_dfg_srvy_gsm_dmpa_bvec',data={x:fgm_data.X,y:[[fgm_data.Y[*,0]],[fgm_data.Y[*,1]],[fgm_data.Y[*,2]]]},dlimits=fgm_dlimits
          store_data,'mms'+probe+'_dfg_srvy_gsm_dmpa_btot',data={x:fgm_data.X,y:fgm_data.Y[*, 3]},dlimits=fgm_dlimits
          options,'mms'+probe+'_dfg_srvy*dmpa_btot',colors=1
          undefine,fgm_data,fgm_dlimits
        endif
      endif
    endelse
;    mms_load_fpi,trange=trange,probes=probe,level='sitl',data_rate='fast',no_update=no_update_fpi
     mms_fpi_plot_kitamura,trange=trange,probe=probe,add_scpot=add_scpot,edp_comm=edp_comm,no_update_fpi=no_update_fpi,fpi_sitl=fpi_sitl,/load_fpi,/magplot,/gsm
  endif else begin
    mms_fpi_plot_kitamura,trange=trange,probe=probe,add_scpot=add_scpot,edp_comm=edp_comm,fpi_sitl=fpi_sitl,/magplot,/gsm
  endelse
  
  if undefined(no_bss) then begin
    time_stamp,/on
    if public eq 0 and not undefined(full_bss) then begin
      spd_mms_load_bss,trange=trange,datatype=['fast','status']
      split_vec,'mms_bss_status'
      calc,'"mms_bss_complete"="mms_bss_status_0"-0.1d'
      calc,'"mms_bss_incomplete"="mms_bss_status_1"-0.2d'
      calc,'"mms_bss_pending"="mms_bss_status_3"-0.3d'
      store_data,'mms_bss_status_?',/delete
      store_data,'mms_bss',data=['mms_bss_fast','mms_bss_complete','mms_bss_incomplete','mms_bss_pending']
      options,'mms_bss',colors=[6,2,3,4],panel_size=0.5,thick=10.0,xstyle=4,ystyle=4,ticklen=0,yrange=[-0.325d,0.025d],ylabel='',labels=['ROI','Complete','Incomplete','Pending'],labflag=-1
    endif else begin
      spd_mms_load_bss,trange=trange,datatype=['fast','burst']
      calc,'"mms_bss_burst"="mms_bss_burst"-0.1d'
      store_data,'mms_bss',data=['mms_bss_fast','mms_bss_burst']
      options,'mms_bss',colors=[6,2],panel_size=0.2,thick=10.0,xstyle=4,ystyle=4,ticklen=0,yrange=[-0.125d,0.025d],ylabel='',labels=['Fast','Burst'],labflag=-1
    endelse
  endif else begin
    time_stamp,/off
  endelse

  if strlen(tnames('mms'+probe+'_fpi_iBulkV_gsm')) eq 0 then ncoord='DSC' else ncoord='gsm'

  if strlen(tnames('mms'+probe+'_fgm_b_gsm_srvy_l2')) gt 0 then begin
    tplot,['mms_bss','mms'+probe+'_fpi_eEnergySpectr_omni','mms'+probe+'_fpi_iEnergySpectr_omni','mms'+probe+'_fpi_numberDensity','mms'+probe+'_fpi_temp','mms'+probe+'_fpi_iBulkV_'+ncoord,'mms'+probe+'_fgm_b_gsm_srvy_l2_bvec_avg','mms'+probe+'_fgm_b_gsm_srvy_l2_btot']
  endif else begin
    if strlen(tnames('mms'+probe+'_dfg_srvy_l2pre_gsm')) gt 0 then begin
;      tplot,['mms_bss','mms'+probe+'_fpi_eEnergySpectr_omni','mms'+probe+'_fpi_iEnergySpectr_omni','mms'+probe+'_fpi_numberDensity','mms'+probe+'_fpi_temp','mms'+probe+'_fpi_eBulkV_DSC','mms'+probe+'_fpi_iBulkV_DSC','mms'+probe+'_dfg_srvy_l2pre_gse_bvec_avg','mms'+probe+'_dfg_srvy_l2pre_gse_btot']
      tplot,['mms_bss','mms'+probe+'_fpi_eEnergySpectr_omni','mms'+probe+'_fpi_iEnergySpectr_omni','mms'+probe+'_fpi_numberDensity','mms'+probe+'_fpi_temp','mms'+probe+'_fpi_iBulkV_'+ncoord,'mms'+probe+'_dfg_srvy_l2pre_gsm_bvec_avg','mms'+probe+'_dfg_srvy_l2pre_gsm_btot']
;      tplot,['mms_bss','mms'+probe+'_fpi_eEnergySpectr_omni','mms'+probe+'_fpi_iEnergySpectr_omni','mms'+probe+'_fpi_numberDensity','mms'+probe+'_fpi_temp','mms'+probe+'_fpi_iBulkV_DSC','mms'+probe+'_dfg_srvy_l2pre_gse_bvec','mms'+probe+'_dfg_srvy_l2pre_gse_btot']
    endif else begin
;      tplot,['mms_bss','mms'+probe+'_fpi_eEnergySpectr_omni','mms'+probe+'_fpi_iEnergySpectr_omni','mms'+probe+'_fpi_numberDensity','mms'+probe+'_fpi_temp','mms'+probe+'_fpi_eBulkV_DSC','mms'+probe+'_fpi_iBulkV_DSC','mms'+probe+'_dfg_srvy_dmpa_bvec_avg','mms'+probe+'_dfg_srvy_dmpa_btot']
      tplot,['mms_bss','mms'+probe+'_fpi_eEnergySpectr_omni','mms'+probe+'_fpi_iEnergySpectr_omni','mms'+probe+'_fpi_numberDensity','mms'+probe+'_fpi_temp','mms'+probe+'_fpi_iBulkV_'+ncoord,'mms'+probe+'_dfg_srvy_gsm_dmpa_bvec_avg','mms'+probe+'_dfg_srvy_gsm_dmpa_btot']
;      tplot,['mms_bss','mms'+probe+'_fpi_eEnergySpectr_omni','mms'+probe+'_fpi_iEnergySpectr_omni','mms'+probe+'_fpi_numberDensity','mms'+probe+'_fpi_temp','mms'+probe+'_fpi_iBulkV_DSC','mms'+probe+'_dfg_srvy_dmpa_bvec','mms'+probe+'_dfg_srvy_dmpa_btot']
    endelse
  endelse

  if undefined(no_output) and not undefined(plotdir) then begin
    
    get_data,'mms'+probe+'_fpi_eEnergySpectr_pX',dlim=dl
    fpiver='v'+dl.cdf.gatt.data_version
    if fpiver eq 'v0.0.0' then fpiver='v'+strmid(dl.cdf.gatt.logical_file_id,4,5,/reverse_offset)
    
    if undefined(roi) then roi=trange
    ts=strsplit(time_string(time_double(roi[0]),format=3,precision=-2),/extract)
    dn=plotdir+'\'+ts[0]+'\'+ts[1]
    if ~file_test(dn) then file_mkdir,dn
    
    thisDevice=!D.NAME
    tplot_options,'ymargin'
    tplot_options,'tickinterval',3600
    set_plot,'ps'
    device,filename=dn+'\mms'+probe+'_fpi_ROI_'+time_string(roi[0],format=2,precision=0)+'_'+fpiver+'.ps',xsize=60.0,ysize=30.0,/color,/encapsulated,bits=8
    tplot,trange=trange
    device,/close
    set_plot,thisDevice
    !p.background=255
    !p.color=0
    if not undefined(full_bss) then options,'mms_bss',thick=5.0,panel_size=0.55,labsize=0.8 else options,'mms_bss',thick=5.0,panel_size=0.25,labsize=0.8
    window,xsize=1600,ysize=900
    tplot_options,'ymargin',[2.5,0.2]
    tplot,trange=trange
    makepng,dn+'\mms'+probe+'_fpi_ROI_'+time_string(roi[0],format=2,precision=0)+'_'+fpiver
    if not undefined(full_bss) then options,'mms_bss',thick=10.0,panel_size=0.5 else options,'mms_bss',thick=10.0,panel_size=0.2
    options,'mms_bss','labsize'
    tplot_options,'tickinterval'
    tplot_options,'ymargin'

    if undefined(no_short) then begin
      start_time=time_double(time_string(roi[0],format=0,precision=-2))-double(fix(ts[3]) mod 2)*3600.d
      tplot_options,'tickinterval',600
      while start_time lt roi[1] do begin
        set_plot,'ps'
        device,filename=dn+'\mms'+probe+'_fpi_'+time_string(start_time,format=2,precision=-2)+'_'+fpiver+'_2hours.ps',xsize=40.0,ysize=30.0,/color,/encapsulated,bits=8
        tplot,trange=[start_time,start_time+2.d*3600.d]
        device,/close
        set_plot,thisDevice
        !p.background=255
        !p.color=0
        if not undefined(full_bss) then options,'mms_bss',thick=5.0,panel_size=0.55,labsize=0.8 else options,'mms_bss',thick=5.0,panel_size=0.25,labsize=0.8
        window,xsize=1600,ysize=900
        tplot_options,'ymargin',[2.5,0.2]
        tplot,trange=[start_time,start_time+2.d*3600.d]
        makepng,dn+'\mms'+probe+'_fpi_'+time_string(start_time,format=2,precision=-2)+'_'+fpiver+'_2hours'
        if not undefined(full_bss) then options,'mms_bss',thick=10.0,panel_size=0.5 else options,'mms_bss',thick=10.0,panel_size=0.2
        options,'mms_bss','labsize'
        tplot_options,'ymargin'
        start_time=start_time+2.d*3600.d
      endwhile      
      tplot_options,'tickinterval'
    endif
    
  endif

  if undefined(no_output) and not undefined(plotcdir) then begin

    if undefined(roi) then roi=trange

    mms_curlometer,trange=[roi[0]-3600.d,roi[1]+3600.d],ref_probe=probe,data_rate='srvy',/gsm,/lmn
    tinterpol_mxn,'mms_avg_pos_gsm','mms'+probe+'_fpi_iBulkV_gsm',newname='mms_avg_pos_gsm_ion'
    get_data,'mms_avg_pos_gsm_ion',data=pos
    get_data,'mms'+probe+'_fpi_iBulkV_gsm',data=vi_gsm
    gsm2lmn,[[pos.x],[pos.y[*,0]],[pos.y[*,1]],[pos.y[*,2]]],vi_gsm.y,vi_lmn
    store_data,'mms'+probe+'_fpi_iBulkV_lmn',data={x:vi_gsm.x,y:vi_lmn}
    if not undefined(fpi_sitl) then begin
      dis_level='SITL'
    endif else begin
      if strlen(tnames('mms'+probe+'_dis_errorflags_fast')) gt 0 then dis_level='L2' else dis_level='QL'
    endelse
    options,'mms'+probe+'_fpi_iBulkV_lmn',constant=0.0,ytitle='MMS'+probe+'!CFPI_'+dis_level+'!CIon!CBulkV_LMN',ysubtitle='[km/s]',colors=[2,4,6],labels=['V!DL!N','V!DM!N','V!DN!N'],labflag=-1,datagap=4.6d
    undefine,pos,vi_gsm,vi_lmn
    tplot,['mms_bss','mms'+probe+'_fpi_eEnergySpectr_omni','mms'+probe+'_fpi_iEnergySpectr_omni','mms'+probe+'_fpi_numberDensity','mms'+probe+'_fpi_iBulkV_lmn','mms'+probe+'_b_for_curlometer_tlmn','Current_lmn','Current_magnitude','divB_over_rotB']

    ts=strsplit(time_string(time_double(roi[0]),format=3,precision=-2),/extract)
    dn=plotcdir+'\'+ts[0]+'\'+ts[1]
    if ~file_test(dn) then file_mkdir,dn

    thisDevice=!D.NAME
    start_time=time_double(time_string(roi[0],format=0,precision=-2))
    tplot_options,'tickinterval',300
    while start_time lt roi[1] do begin
      set_plot,'ps'
      device,filename=dn+'\mms'+probe+'_fpi_current_'+time_string(start_time,format=2,precision=-2)+'_1hour.ps',xsize=40.0,ysize=30.0,/color,/encapsulated,bits=8
      tplot,trange=[start_time,start_time+1.d*3600.d]
      device,/close
      set_plot,thisDevice
      !p.background=255
      !p.color=0
      if not undefined(full_bss) then options,'mms_bss',thick=5.0,panel_size=0.55,labsize=0.8 else options,'mms_bss',thick=5.0,panel_size=0.25,labsize=0.8
      window,xsize=1600,ysize=900
      tplot_options,'ymargin',[2.5,0.2]
      tplot,trange=[start_time,start_time+1.d*3600.d]
      makepng,dn+'\mms'+probe+'_fpi_current_'+time_string(start_time,format=2,precision=-2)+'_1hour'
      if not undefined(full_bss) then options,'mms_bss',thick=10.0,panel_size=0.5 else options,'mms_bss',thick=10.0,panel_size=0.2
      options,'mms_bss','labsize'
      tplot_options,'ymargin'
      start_time=start_time+1.d*3600.d
    endwhile
    tplot_options,'tickinterval'

  endif


end