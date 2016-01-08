;+
; PROCEDURE:
;         mms_dfg_plot_kitamura
;
; PURPOSE:
;         Plot magnetic field data obtained by MMS-DFG
;
; KEYWORDS:
;         trange:       time range of interest [starttime, endtime] with the format
;                       ['YYYY-MM-DD','YYYY-MM-DD'] or to specify more or less than a day
;                       ['YYYY-MM-DD/hh:mm:ss','YYYY-MM-DD/hh:mm:ss']
;                       if the format is 'YYYY-MM-DD' or 'YYYY-MM-DD/hh:mm:ss' (one element)
;                       the time range is set as from 30 minutes before the beginning of the
;                       ROI just after the specified time to 30 minutes after the end of the ROI.
;         probe:        a probe - value for MMS SC # (default value is '3')
;         load_dfg:     set this flag to load dfg data
;         no_update:    set this flag to preserve the original dfg data. if not set and
;                       newer data is found the existing data will be overwritten
;         no_plot:      set this flag to skip plotting
;         no_avg:       set this flag to skip making 2.5 sec averaged dfg data
;         dfg_ql:       set this flag to use dfg ql data forcibly. if not set, l2pre data
;                       is used, if available
;
; EXAMPLE:
;
;     To plot digital fluxgate magnetometer (dfg) data
;     MMS>  mms_dfg_plot_kitamura,trange=['2015-09-02/00:00:00','2015-09-03/00:00:00'],probe='1',/no_avg
;     MMS>  mms_dfg_plot_kitamura,trange=['2015-09-02/00:00:00','2015-09-03/00:00:00'],probe='1',/no_avg,/load_dfg,/no_update
;
; NOTES:
;     1) See the notes in mms_load_data for rules on the use of MMS data
;     2) DFG data should be loaded before running this procedure or use load_dfg flag
;     3) Information of version of the first cdf files is shown in the plot,
;        if multiple cdf files are loaded for DFG
;-

pro mms_dfg_plot_kitamura,trange=trange,probe=probe,load_dfg=load_dfg,no_plot=no_plot,no_avg=no_avg,no_update=no_update,dfg_ql=dfg_ql

  loadct2,43
  time_stamp,/off
  
  if undefined(probe) then probe=['3']
  probe=string(probe,format='(i0)')
  if undefined(trange) then begin
    if strlen(tnames('mms'+probe+'_dfg_srvy_l2pre_gse')) gt 0 and undefined(dfg_ql) then get_data,'mms'+probe+'_dfg_srvy_l2pre_gse',data=d else get_data,'mms'+probe+'_dfg_srvy_dmpa',data=d
    if n_elements(d.x) gt 0 then begin
      start_time=d.x[0]
      dt=d.x[n_elements(d.x)-1]-d.x[0]
      timespan,start_time,dt,/seconds      
    endif else begin
      trange=timerange()
      dt=trange[1]-trange[0]
      timespan,trange[0],dt,/seconds
    endelse
  endif else begin
    if n_elements(trange) eq 1 then begin
      roi=mms_get_roi(trange,/next)
      trange=dblarr(2)
      trange[0]=roi[0]-60.d*30.d
      trange[1]=roi[1]+60.d*30.d
    endif else begin
      trange=time_double(trange)
      roi=trange
    endelse
    dt=trange[1]-trange[0]
    timespan,trange[0],dt,/seconds
  endelse

  if not undefined(load_dfg) then begin
    if undefined(dfg_ql) then mms_load_fgm,trange=trange,instrument='dfg',probes=probe,data_rate='srvy',level='l2pre',no_update=no_update,/no_attitude_data
    if strlen(tnames('mms'+probe+'_dfg_srvy_l2pre_gse')) eq 0 then begin
      mms_load_fgm,trange=trange,instrument='dfg',probes=probe,data_rate='srvy',level='ql',no_update=no_update,/no_attitude_data
    endif else begin
      get_data,'mms'+probe+'_dfg_srvy_l2pre_gse',data=d
      if d.x[0] gt roi[1] or time_double(time_string(d.x[n_elements(d.x)-1]-10.d,format=0,precision=-3)) lt time_double(time_string(roi[1],format=0,precision=-3)) then begin
        store_data,'mms'+probe+'_dfg_srvy_l2pre*',/delete
        store_data,'mms'+probe+'_pos*',/delete
        mms_load_fgm,trange=trange,instrument='dfg',probes=probe,data_rate='srvy',level='ql',no_update=no_update,/no_attitude_data
      endif
    endelse
  endif

  if strlen(tnames('mms'+probe+'_dfg_srvy_l2pre_gse')) gt 0 and undefined(dfg_ql) then get_data,'mms'+probe+'_dfg_srvy_l2pre_gse',data=d,dlim=dl else get_data,'mms'+probe+'_dfg_srvy_dmpa',data=d,dlim=dl
  
  if strlen(tnames('mms'+probe+'_dfg_srvy_l2pre_gse')) gt 0 and undefined(dfg_ql) then level_name='srvy_l2pre_gse' else level_name='srvy_dmpa' 
  
  if n_elements(dl.cdf.gatt.data_version) gt 0 then begin
    dfg_dv=dl.cdf.gatt.data_version
    
    if undefined(no_avg) then begin
      avg_data,'mms'+probe+'_dfg_'+level_name+'_bvec',2.5d,trange=[time_double(time_string(trange[0],format=0,precision=-3)),time_double(time_string(trange[1],format=0,precision=-3))+24.d*3600.d]
      if strlen(tnames('mms'+probe+'_dfg_srvy_l2pre_gse')) gt 0 and undefined(dfg_ql) then begin
        options,'mms'+probe+'_dfg_srvy_l2pre_gse_bvec_avg',constant=0.0,colors=[2,4,6],labels=['B!DX!N','B!DY!N','B!DZ!N'],ytitle='mms'+probe+'_dfg!CL2pre_GSE!C2.5 sec!Caveraged',ysubtitle='[nT]',labflag=-1
      endif else begin
        options,'mms'+probe+'_dfg_srvy_dmpa_bvec_avg',constant=0.0,colors=[2,4,6],labels=['B!DX!N','B!DY!N','B!DZ!N'],ytitle='mms'+probe+'_dfg!CDMPA!C(near GSE)!C2.5 sec!Caveraged',ysubtitle='[nT]',labflag=-1
      endelse
    endif
    
    if strlen(tnames('mms'+probe+'_dfg_srvy_l2pre_gse')) gt 0 and undefined(dfg_ql) then begin
      options,'mms'+probe+'_dfg_srvy_l2pre_gse_bvec',constant=0.0,colors=[2,4,6],labels=['B!DX!N','B!DY!N','B!DZ!N'],ytitle='mms'+probe+'_dfg!CL2pre_GSE',ysubtitle='[nT]',labflag=-1,datagap=0.26d
      options,'mms'+probe+'_dfg_srvy_l2pre_gse_btot',ytitle='mms'+probe+'_dfg!CBtotal',ysubtitle='[nT]',labels='L2pre!C  v'+dfg_dv,labflag=-1,datagap=0.26d
      options,'mms'+probe+'_dfg_srvy_l2pre_gse',constant=0.0,colors=[2,4,6,0],labels=['B!DX!N','B!DY!N','B!DZ!N','|B|'],ytitle='mms'+probe+'_dfg!CL2pre_GSE',ysubtitle='[nT]',labflag=-1,datagap=0.26d
      options,'mms'+probe+'_dfg_srvy_l2pre_gsm_bvec',constant=0.0,colors=[2,4,6],labels=['B!DX!N','B!DY!N','B!DZ!N'],ytitle='mms'+probe+'_dfg!CL2pre_GSM',ysubtitle='[nT]',labflag=-1,datagap=0.26d
      options,'mms'+probe+'_dfg_srvy_l2pre_gsm_btot',ytitle='mms'+probe+'_dfg!CBtotal',ysubtitle='[nT]',labels='L2pre!C  v'+dfg_dv,labflag=-1,datagap=0.26d
      options,'mms'+probe+'_dfg_srvy_l2pre_gsm',constant=0.0,colors=[2,4,6,0],labels=['B!DX!N','B!DY!N','B!DZ!N','|B|'],ytitle='mms'+probe+'_dfg!CL2pre_GSM',ysubtitle='[nT]',labflag=-1,datagap=0.26d
      options,'mms'+probe+'_dfg_srvy_l2pre_dmpa_bvec',constant=0.0,colors=[2,4,6],labels=['B!DX!N','B!DY!N','B!DZ!N'],ytitle='mms'+probe+'_dfg!CL2pre_DMPA!C(near GSE)',ysubtitle='[nT]',labflag=-1,datagap=0.26d
      options,'mms'+probe+'_dfg_srvy_l2pre_dmpa_btot',ytitle='mms'+probe+'_dfg!CBtotal',ysubtitle='[nT]',labels='L2pre!C  v'+dfg_dv,labflag=-1,datagap=0.26d
      options,'mms'+probe+'_dfg_srvy_l2pre_dmpa',constant=0.0,colors=[2,4,6,0],labels=['B!DX!N','B!DY!N','B!DZ!N','|B|'],ytitle='mms'+probe+'_dfg!CL2pre_DMPA!C(near GSE)',ysubtitle='[nT]',labflag=-1,datagap=0.26d
    endif else begin
      options,'mms'+probe+'_dfg_srvy_dmpa_bvec',constant=0.0,colors=[2,4,6],labels=['B!DX!N','B!DY!N','B!DZ!N'],ytitle='mms'+probe+'_dfg!CQL_DMPA!C(near GSE)',ysubtitle='[nT]',labflag=-1,datagap=0.26d
      options,'mms'+probe+'_dfg_srvy_dmpa_btot',ytitle='mms'+probe+'_dfg!CBtotal',ysubtitle='[nT]',labels='QL!C  v'+dfg_dv,labflag=-1,datagap=0.26d
      options,'mms'+probe+'_dfg_srvy_dmpa',constant=0.0,colors=[2,4,6,0],labels=['B!DX!N','B!DY!N','B!DZ!N','|B|'],ytitle='mms'+probe+'_dfg!CQL_DMPA!C(near GSE)',ysubtitle='[nT]',labflag=-1,datagap=0.26d
    endelse
    
    if strlen(tnames('mms'+probe+'_dfg_srvy_l2pre_gse')) gt 0 and undefined(dfg_ql) then ql_name='' else ql_name='_ql' 
    
      tkm2re,'mms'+probe+ql_name+'_pos_gse'
      split_vec,'mms'+probe+ql_name+'_pos_gse_re'
      options,'mms'+probe+ql_name+'_pos_gse_re_0',ytitle='GSEX [R!DE!N]',format='(f8.4)'
      options,'mms'+probe+ql_name+'_pos_gse_re_1',ytitle='GSEY [R!DE!N]',format='(f8.4)'
      options,'mms'+probe+ql_name+'_pos_gse_re_2',ytitle='GSEZ [R!DE!N]',format='(f8.4)'
    ;  options,'mms'+probe+ql_name+'_pos_gse_re_3',ytitle='R [R!DE!N]',format='(f8.4)'
    ;  tplot_options, var_label=['mms'+probe+ql_name+'_ql_pos_gse_re_3','mms'+probe+ql_name+'_pos_gse_re_2','mms'+probe+ql_name+'_pos_gse_re_1','mms'+probe+ql_name+'_pos_gse_re_0']
      tplot_options, var_label=['mms'+probe+ql_name+'_pos_gse_re_2','mms'+probe+ql_name+'_pos_gse_re_1','mms'+probe+ql_name+'_pos_gse_re_0']
      
    if undefined(no_plot) then begin
      tplot_options,'xmargin',[15,10]
      tplot,['mms'+probe+'_dfg_'+level_name+'_btot','mms'+probe+'_dfg_'+level_name+'_bvec','mms'+probe+'_dfg_'+level_name+'_bvec_avg']
    endif
  endif else begin
    print,'DFG data files are not found in this interval.'
  endelse

end
