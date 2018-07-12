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
;         delete:       set this flag to delete all tplot variables at the beginning
;         no_update_fpi:set this flag to preserve the original FPI data. if not set and
;                       newer data are found the existing data will be overwritten
;         no_update_fgm:set this flag to preserve the original FGM data. if not set and
;                       newer data are found the existing data will be overwritten
;         no_bss:       set this flag to skip loading bss data
;         full_bss:     set this flag to load detailed bss data (team member only)
;         no_load:      set this flag to skip loading data
;         dfg_ql:       set this flag to use DFG ql data forcibly. if not set, DFG l2pre data
;                       are used, if available (team member only)
;         fpi_sitl:     set this flag to use FPI fast sitl data forcibly. if not set, FPI fast ql
;                       data are used, if available (team member only)
;         fpi_l1b:      set this flag to use FPI level-1b data if available (team member only)
;         time_clip:    set this flag to time clip the FPI and EDP data
;         gse:          set this flag to plot data in the GSE (or DMPA) coordinate
;         tail:         set this flag to use color scale for tail region
;
; EXAMPLE:
;
;     To plot fast plasma investigation (FPI) burst data with fast survey data and fluxgate magnetometer (FGM (or DFG)) data
;     MMS> mms_fpi_brst_fgm_kitamura,'2015-09-02/08:00:00','3',/delete
;     MMS> mms_fpi_brst_fgm_kitamura,['2015-09-02/08:00:00','2015-09-03/00:00:00'],'3',/delete
;
; NOTES:
;     See the notes in mms_load_data for rules on the use of MMS data
;-

pro mms_fpi_brst_fgm_kitamura,trange,probe,delete=delete,no_update_fpi=no_update_fpi,no_update_fgm=no_update_fgm,$
                              no_bss=no_bss,full_bss=full_bss,no_load=no_load,dfg_ql=dfg_ql,fpi_sitl=fpi_sitl,$
                              fpi_l1b=fpi_l1b,time_clip=time_clip,gse=gse,tail=tail,margin=margin

  mms_init
  
  status=mms_login_lasp(login_info=login_info,username=username)
  if username eq '' or username eq 'public' then public=1 else public=0
  if undefined(gse) then coord='gsm' else coord='gse'
  
  if not undefined(delete) then store_data,'*',/delete
  stime=time_double(trange)
  if n_elements(stime) eq 1 then begin
    if public eq 0 and status eq 1 then begin
      roi=mms_get_roi(stime,/next)
    endif else begin
      mms_data_time_takada,[stime,stime+3.d*86400.d],rois,datatype='fast'
      i=0
      while stime gt time_double(rois[0,i]) do i=i+1
      roi=[time_double(rois[0,i]),time_double(rois[1,i])]
    endelse
    trange=dblarr(2)
    if undefined(margin) then margin=30.d
    if n_elements(margin) eq 1 then begin
      smargin=margin
      emargin=margin
    endif else begin
      smargin=abs(margin[0])
      emargin=margin[1]
    endelse
    trange[0]=roi[0]-60.d*smargin
    trange[1]=roi[1]+60.d*emargin
  endif else begin
    trange=stime
    roi=trange
  endelse
  timespan,trange[0],trange[1]-trange[0],/seconds

  if undefined(no_load) then begin
    if undefined(dfg_ql) then begin
      mms_load_fgm,trange=trange,instrument='fgm',probes=probe,data_rate='srvy',level='l2',no_update=no_update_fgm,versions=fgm_versions
      if strlen(tnames('mms'+probe+'_fgm_b_gse_srvy_l2')) eq 0 then begin
        mms_load_fgm,trange=trange,instrument='dfg',probes=probe,data_rate='srvy',level='l2pre',no_update=no_update_fgm,versions=fgm_versions
        if strlen(tnames('mms'+probe+'_dfg_b_gse_srvy_l2pre')) eq 0 and strlen(tnames('mms'+probe+'_dfg_srvy_l2pre_gse')) gt 0 then begin
          copy_data,'mms'+probe+'_dfg_srvy_l2pre_gse','mms'+probe+'_dfg_b_gse_srvy_l2pre'
          copy_data,'mms'+probe+'_dfg_srvy_l2pre_gse_bvec','mms'+probe+'_dfg_b_gse_srvy_l2pre_bvec'
          copy_data,'mms'+probe+'_dfg_srvy_l2pre_gse_btot','mms'+probe+'_dfg_b_gse_srvy_l2pre_btot'
          store_data,'mms'+probe+'_dfg_srvy_l2pre_gse*',/delete
          copy_data,'mms'+probe+'_dfg_srvy_l2pre_gsm','mms'+probe+'_dfg_b_gsm_srvy_l2pre'
          copy_data,'mms'+probe+'_dfg_srvy_l2pre_gsm_bvec','mms'+probe+'_dfg_b_gsm_srvy_l2pre_bvec'
          copy_data,'mms'+probe+'_dfg_srvy_l2pre_gsm_btot','mms'+probe+'_dfg_b_gsm_srvy_l2pre_btot'
          store_data,'mms'+probe+'_dfg_srvy_l2pre_gsm*',/delete
          copy_data,'mms'+probe+'_dfg_srvy_l2pre_dmpa','mms'+probe+'_dfg_b_dmpa_srvy_l2pre'
          copy_data,'mms'+probe+'_dfg_srvy_l2pre_dmpa_bvec','mms'+probe+'_dfg_b_dmpa_srvy_l2pre_bvec'
          copy_data,'mms'+probe+'_dfg_srvy_l2pre_dmpa_btot','mms'+probe+'_dfg_b_dmpa_srvy_l2pre_btot'
          store_data,'mms'+probe+'_dfg_srvy_l2pre_dmpa*',/delete
        endif
      endif else begin
        get_data,'mms'+probe+'_fgm_b_gse_srvy_l2',data=d
        if d.x[0] gt roi[1] or time_double(time_string(d.x[n_elements(d.x)-1]-10.d,format=0,precision=-3)) lt time_double(time_string(roi[1],format=0,precision=-3)) then begin
          store_data,'mms'+probe+'_fgm_*_l2*',/delete
          mms_load_fgm,trange=trange,instrument='dfg',probes=probe,data_rate='srvy',level='l2pre',no_update=no_update_fgm,versions=fgm_versions
          if strlen(tnames('mms'+probe+'_dfg_b_gse_srvy_l2pre')) eq 0 and strlen(tnames('mms'+probe+'_dfg_srvy_l2pre_gse')) gt 0 then begin
            copy_data,'mms'+probe+'_dfg_srvy_l2pre_gse','mms'+probe+'_dfg_b_gse_srvy_l2pre'
            copy_data,'mms'+probe+'_dfg_srvy_l2pre_gse_bvec','mms'+probe+'_dfg_b_gse_srvy_l2pre_bvec'
            copy_data,'mms'+probe+'_dfg_srvy_l2pre_gse_btot','mms'+probe+'_dfg_b_gse_srvy_l2pre_btot'
            store_data,'mms'+probe+'_dfg_srvy_l2pre_gse*',/delete
            copy_data,'mms'+probe+'_dfg_srvy_l2pre_gsm','mms'+probe+'_dfg_b_gsm_srvy_l2pre'
            copy_data,'mms'+probe+'_dfg_srvy_l2pre_gsm_bvec','mms'+probe+'_dfg_b_gsm_srvy_l2pre_bvec'
            copy_data,'mms'+probe+'_dfg_srvy_l2pre_gsm_btot','mms'+probe+'_dfg_b_gsm_srvy_l2pre_btot'
            store_data,'mms'+probe+'_dfg_srvy_l2pre_gsm*',/delete
            copy_data,'mms'+probe+'_dfg_srvy_l2pre_dmpa','mms'+probe+'_dfg_b_dmpa_srvy_l2pre'
            copy_data,'mms'+probe+'_dfg_srvy_l2pre_dmpa_bvec','mms'+probe+'_dfg_b_dmpa_srvy_l2pre_bvec'
            copy_data,'mms'+probe+'_dfg_srvy_l2pre_dmpa_btot','mms'+probe+'_dfg_b_dmpa_srvy_l2pre_btot'
            store_data,'mms'+probe+'_dfg_srvy_l2pre_dmpa*',/delete
          endif
        endif
      endelse
    endif
    if strlen(tnames('mms'+probe+'_fgm_b_gse_srvy_l2')) eq 0 and strlen(tnames('mms'+probe+'_dfg_b_gse_srvy_l2pre')) eq 0 then begin
      mms_load_fgm,trange=trange,instrument='dfg',probes=probe,data_rate='srvy',level='ql',no_update=no_update_fgm,versions=fgm_versions
      get_data,'mms'+probe+'_dfg_srvy_gsm_dmpa',data=fgm_data,dlimits=fgm_dlimits
      store_data,'mms'+probe+'_dfg_srvy_gsm_dmpa_bvec',data={x:fgm_data.x,y:[[fgm_data.y[*,0]],[fgm_data.y[*,1]],[fgm_data.y[*,2]]]},dlimits=fgm_dlimits
      store_data,'mms'+probe+'_dfg_srvy_gsm_dmpa_btot',data={x:fgm_data.x,y:fgm_data.y[*, 3]},dlimits=fgm_dlimits
      options,'mms'+probe+'_dfg_srvy*dmpa_btot',colors=1
      undefine,fgm_data,fgm_dlimits
    endif else begin
      if strlen(tnames('mms'+probe+'_fgm_b_gse_srvy_l2')) eq 0 then begin
        get_data,'mms'+probe+'_dfg_b_gse_srvy_l2pre',data=d
        if d.x[0] gt roi[1] or time_double(time_string(d.x[n_elements(d.x)-1]-10.d,format=0,precision=-3)) lt time_double(time_string(roi[1],format=0,precision=-3)) then begin
          store_data,'mms'+probe+'_dfg_srvy_l2pre*',/delete
          store_data,'mms'+probe+'_pos*',/delete
          mms_load_fgm,trange=trange,instrument='dfg',probes=probe,data_rate='srvy',level='ql',no_update=no_update_fgm,versions=fgm_versions
          get_data,'mms'+probe+'_dfg_srvy_gsm_dmpa',data=fgm_data,dlimits=fgm_dlimits
          store_data,'mms'+probe+'_dfg_srvy_gsm_dmpa_bvec',data={x:fgm_data.x,y:[[fgm_data.y[*,0]],[fgm_data.y[*,1]],[fgm_data.y[*,2]]]},dlimits=fgm_dlimits
          store_data,'mms'+probe+'_dfg_srvy_gsm_dmpa_btot',data={x:fgm_data.x,y:fgm_data.y[*, 3]},dlimits=fgm_dlimits
          options,'mms'+probe+'_dfg_srvy*dmpa_btot',colors=1
          undefine,fgm_data,fgm_dlimits
        endif
      endif
    endelse
  endif
  
  if undefined(gse) then gsm=1
  mms_fpi_plot_kitamura,trange=trange,probe=probe,no_update_fpi=no_update_fpi,fpi_sitl=fpi_sitl,fpi_l1b=fpi_l1b,time_clip=time_clip,gsm=gsm,/load_fpi,/no_plot,/no_avg
  mms_fpi_brst_plot_kitamura,trange=trange,probe=probe,no_update=no_update_fpi,no_bss=no_bss,full_bss=full_bss,time_clip=time_clip,gsm=gsm,tail=tail,/magplot,/no_load_mec

end