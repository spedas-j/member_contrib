;+
; PROCEDURE:
;         mms_fpi_brst_dfg_kitamura
;
; PURPOSE:
;         Plot magnetic field (DFG) and FPI data obtained by MMS
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
;         no_update_dfg:set this flag to preserve the original dfg data. if not set and
;                       newer data are found the existing data will be overwritten
;         no_bss:       set this flag to skip loading bss data
;         no_load:      set this flag to skip loading data
;         delete:       set this flag to delete all tplot variables at the beginning
;         dfg_ql:       set this flag to use dfg ql data forcibly. if not set, l2pre data
;                       are used, if available
;         fpi_sitl:     set this flag to use fpi fast sitl data forcibly. if not set, fast ql data
;                       are used, if available
;         fpi_l1b:      set this flag to use fpi level-1b data if available
;
; EXAMPLE:
;
;     To plot fast plasma investigation (FPI) burst moments with fast_sitl data and digital fluxgate magnetometer (dfg) data
;     MMS> mms_fpi_brst_dfg_kitamura,'2015-09-02/08:00:00','3',/delete
;     MMS> mms_fpi_brst_dfg_kitamura,['2015-09-02/08:00:00','2015-09-03/00:00:00'],'3',/delete,/no_update_fpi,/no_update_dfg,/no_bss
;
; NOTES:
;     1) See the notes in mms_load_data for rules on the use of MMS data
;-

pro mms_fpi_brst_dfg_kitamura,trange,probe,no_update_fpi=no_update_fpi,no_update_dfg=no_update_dfg,no_bss=no_bss,$
                              no_load=no_load,delete=delete,dfg_ql=dfg_ql,fpi_sitl=fpi_sitl,fpi_l1b=fpi_l1b,no_load_state=no_load_state

  mms_init
  if not undefined(delete) then store_data,'*',/delete
  stime=time_double(trange)
  if n_elements(stime) eq 1 then begin
    roi=mms_get_roi(stime,/next)
    trange=dblarr(2)
    trange[0]=roi[0]-60.d*30.d
    trange[1]=roi[1]+60.d*30.d
  endif else begin
    trange=stime
  endelse
  timespan,trange[0],trange[1]-trange[0],/seconds

  if undefined(no_load) then begin
    if undefined(dfg_ql) then mms_load_fgm,trange=trange,instrument='dfg',probes=probe,data_rate='srvy',level='l2pre',no_update=no_update_dfg,/no_attitude_data
    if strlen(tnames('mms'+probe+'_dfg_srvy_l2pre_gse')) eq 0 then mms_load_fgm,trange=trange,instrument='dfg',probes=probe,data_rate='srvy',level='ql',no_update=no_update_dfg,/no_attitude_data
;    mms_load_fpi,trange=trange,probes=probe,level='sitl',data_rate='fast',no_update=no_update_fpi
  endif
  
  mms_fpi_plot_kitamura,trange=trange,probe=probe,no_update_fpi=no_update_fpi,fpi_sitl=fpi_sitl,fpi_l1b=fpi_l1b,/load_fpi,/no_plot,/no_avg,/gsm
  mms_fpi_brst_plot_kitamura,trange=trange,probe=probe,no_update=no_update_fpi,no_bss=no_bss,/magplot,/no_load_state,/gsm

end