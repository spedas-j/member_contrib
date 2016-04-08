;+
; PROCEDURE:
;         mms_fpi_brst_fgm_kitamura
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
;         no_update_fpi:set this flag to preserve the original fpi data. if not set and
;                       newer data are found the existing data will be overwritten
;         no_update_fgm:set this flag to preserve the original fgm data. if not set and
;                       newer data are found the existing data will be overwritten
;         no_bss:       set this flag to skip loading bss data
;         no_load:      set this flag to skip loading data
;         delete:       set this flag to delete all tplot variables at the beginning
;         dfg_ql:       set this flag to use dfg ql data forcibly. if not set, l2pre data
;                       are used, if available
;         fpi_sitl:     set this flag to use fpi fast sitl data forcibly. if not set, fast ql data
;                       are used, if available
;         fpi_l1b:      set this flag to use fpi level-1b data if available
;         time_clip:    set this flag to time clip the fpi and edp data
;
; EXAMPLE:
;
;     To plot fast plasma investigation (FPI) burst moments with fast_sitl data and digital fluxgate magnetometer (FGM (or DFG)) data
;     MMS> mms_fpi_brst_fgm_kitamura,'2015-09-02/08:00:00','3',/delete
;     MMS> mms_fpi_brst_fgm_kitamura,['2015-09-02/08:00:00','2015-09-03/00:00:00'],'3',/delete,/no_update_fpi,/no_update_fgm,/no_bss
;
; NOTES:
;     1) See the notes in mms_load_data for rules on the use of MMS data
;-

pro mms_fpi_brst_fgm_kitamura,trange,probe,no_update_fpi=no_update_fpi,no_update_fgm=no_update_fgm,no_bss=no_bss,$
                              no_load=no_load,delete=delete,dfg_ql=dfg_ql,fpi_sitl=fpi_sitl,fpi_l1b=fpi_l1b,time_clip=time_clip

  mms_init
  
  status=mms_login_lasp(login_info=login_info,username=username)
  if username eq '' or username eq 'public' then public=1 else public=0
  
  if not undefined(delete) then store_data,'*',/delete
  stime=time_double(trange)
  if n_elements(stime) eq 1 then begin
    if public eq 0 and status eq 1 then begin
      roi=mms_get_roi(stime,/next)
      trange=dblarr(2)
      trange[0]=roi[0]-60.d*30.d
      trange[1]=roi[1]+60.d*30.d
    endif else begin
      print,''
      print,'Please input start and end time to use public data'
      print,''
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
      if strlen(tnames('mms'+probe+'_fgm_b_gse_srvy_l2')) eq 0 then begin
        mms_load_fgm,trange=trange,instrument='dfg',probes=probe,data_rate='srvy',level='l2pre',no_update=no_update_fgm,/no_attitude_data
      endif else begin
        get_data,'mms'+probe+'_fgm_b_gse_srvy_l2',data=d
        if d.x[0] gt roi[1] or time_double(time_string(d.x[n_elements(d.x)-1]-10.d,format=0,precision=-3)) lt time_double(time_string(roi[1],format=0,precision=-3)) then begin
          store_data,'mms'+probe+'_fgm_*_l2*',/delete
          mms_load_fgm,trange=trange,instrument='dfg',probes=probe,data_rate='srvy',level='l2pre',no_update=no_update_fgm,/no_attitude_data
        endif
      endelse
    endif
    if strlen(tnames('mms'+probe+'_fgm_b_gse_srvy_l2')) eq 0 and strlen(tnames('mms'+probe+'_dfg_srvy_l2pre_gse')) eq 0 then begin
      mms_load_fgm,trange=trange,instrument='dfg',probes=probe,data_rate='srvy',level='ql',no_update=no_update_fgm,/no_attitude_data
      get_data,'mms'+probe+'_dfg_srvy_gsm_dmpa',data=fgm_data,dlimits=fgm_dlimits
      store_data,'mms'+probe+'_dfg_srvy_gsm_dmpa_bvec',data={x:fgm_data.X,y:[[fgm_data.Y[*,0]],[fgm_data.Y[*,1]],[fgm_data.Y[*,2]]]},dlimits=fgm_dlimits
      store_data,'mms'+probe+'_dfg_srvy_gsm_dmpa_btot',data={x:fgm_data.X,y:fgm_data.Y[*, 3]},dlimits=fgm_dlimits
      options,'mms'+probe+'_dfg_srvy*dmpa_btot',colors=1
      undefine,fgm_data,fgm_dlimits
    endif else begin
      if strlen(tnames('mms'+probe+'_fgm_b_gse_srvy_l2')) eq 0 then begin
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
  endif
  
  mms_fpi_plot_kitamura,trange=trange,probe=probe,no_update_fpi=no_update_fpi,fpi_sitl=fpi_sitl,fpi_l1b=fpi_l1b,time_clip=time_clip,/load_fpi,/no_plot,/no_avg,/gsm
  mms_fpi_brst_plot_kitamura,trange=trange,probe=probe,no_update=no_update_fpi,no_bss=no_bss,time_clip=time_clip,/magplot,/no_load_mec,/gsm

end