;+
; PROCEDURE:
;         mms_fpi_plot_kitamura
;
; PURPOSE:
;         Plot ion and electron data obtained by MMS-FPI(fast survey)
;
; KEYWORDS:
;         trange:       time range of interest [starttime, endtime] with the format
;                       ['YYYY-MM-DD','YYYY-MM-DD'] or to specify more or less than a day
;                       ['YYYY-MM-DD/hh:mm:ss','YYYY-MM-DD/hh:mm:ss'].
;                       if the format is 'YYYY-MM-DD' or 'YYYY-MM-DD/hh:mm:ss' (one element)
;                       the time range is set as from 30 minutes before the beginning of the
;                       ROI just after the specified time to 30 minutes after the end of the ROI.
;         probe:        number of probe to plot data (default value is '1')
;         no_plot:      set this flag to skip plotting
;         magplot:      set this flag to plot with FGM(DFG) data
;         load_fgm:     set this flag to load FGM(DFG) data
;         no_avg:       set this flag to skip making 2.5 sec averaged FGM(DFG) data
;         dfg_ql:       set this flag to use DFG ql data forcibly. if not set, DFG l2pre data
;                       is used, if available (team member only)
;         no_update_fgm:set this flag to preserve the original FGM(DFG) data. if not set and
;                       newer data is found the existing data will be overwritten
;         load_fpi:     set this flag to load FPI data
;         no_update_fpi:set this flag to preserve the original FPI data. if not set and
;                       newer data is found the existing data will be overwritten
;         fpi_sitl:     set this flag to use FPI sitl data forcibly. if not set, FPI ql data
;                       is used, if available (team member only)
;         fpi_l1b:      set this flag to use FPI fast level-1b data if available. if not available,
;                       FPI fast ql data are used (team member only)
;         add_scpot:    set this flag to add spacecraft potential data to plot of number densities 
;         edp_comm:     set this flag to use EDP comm data (team member only)
;         no_update_edp:set this flag to preserve the original EDP data. if not set and
;                       newer data is found the existing data will be overwritten
;         gsm:          set this flag to plot data in the GSM (or DMPA_GSM) coordinate
;         no_load_mec:  set this flag to skip loading MEC data
;         time_clip:    set this flag to time clip the data
;
; EXAMPLE:
;
;     To plot fast plasma investigation (FPI) fast survey data
;     MMS>  mms_fpi_plot_kitamura,trange=['2015-09-01/12:00:00','2015-09-01/15:00:00'],probe='1',/no_avg
;
; NOTES:
;     1) See the notes in mms_load_data for rules on the use of MMS data
;     2) Information of version of the first cdf files is shown in the plot,
;        if multiple cdf files are loaded for FGM(DFG) or FPI
;-

pro mms_fpi_plot_kitamura,trange=trange,probe=probe,no_plot=no_plot,magplot=magplot,no_avg=no_avg,load_fgm=load_fgm,$
                          dfg_ql=dfg_ql,no_update_fgm=no_update_fgm,load_fpi=load_fpi,no_update_fpi=no_update_fpi,$
                          fpi_sitl=fpi_sitl,fpi_l1b=fpi_l1b,add_scpot=add_scpot,edp_comm=edp_comm,no_update_edp=no_update_edp,$
                          gsm=gsm,no_load_mec=no_load_mec,time_clip=time_clip

  loadct2,43
  time_stamp,/off
  
  status=mms_login_lasp(login_info=login_info,username=username)
  if username eq '' or username eq 'public' then public=1 else public=0
  
  if undefined(trange) then trange=timerange()
  if n_elements(trange) eq 1 then begin
    if public eq 0 and status eq 1 then begin
      trange=mms_get_roi(trange,/next)
      trange[0]=trange[0]-60.d*30.d
      trange[1]=trange[1]+60.d*30.d
    endif else begin
      print
      print,'Please input start and end time to use public data'
      print
      return
    endelse
  endif
  trange=time_double(trange)
  if undefined(probe) then probe='1'
  probe=string(probe,format='(i0)')

  dt=trange[1]-trange[0]
  timespan,trange[0],dt,/seconds

  if not undefined(load_fpi) then begin
    if undefined(fpi_sitl) then begin
      if not undefined(fpi_l1b) then begin
        fpi_suffix='_fast_l1b'
        mms_load_fpi,trange=trange,probes=probe,level='l1b',data_rate='fast',no_update=no_update_fpi,suffix=fpi_suffix,datatype='des-moms',time_clip=time_clip,versions=des_versions
        mms_load_fpi,trange=trange,probes=probe,level='l1b',data_rate='fast',no_update=no_update_fpi,suffix=fpi_suffix,datatype='dis-moms',time_clip=time_clip,versions=dis_versions
        if not undefined(des_versions) then begin
          if des_versions[0,0] le 2 then begin
            mms_load_fpi,trange=trange,probes=probe,level='l1b',data_rate='fast',no_update=no_update_fpi,datatype='des-dist',time_clip=time_clip
            if strlen(tnames('mms'+probe+'_des_fastSkyMap_dist')) gt 0 then begin
              mms_fpi_specplot_kitamura,trange=trange,probe=probe,suffix=fpi_suffix,/fast,/no_load,/no_plot,/no_ion
              copy_data,'mms'+probe+'_des_fast_energySpectr_pX'+fpi_suffix,'mms'+probe+'_des_energySpectr_pX'+fpi_suffix
              copy_data,'mms'+probe+'_des_fast_energySpectr_mX'+fpi_suffix,'mms'+probe+'_des_energySpectr_mX'+fpi_suffix
              copy_data,'mms'+probe+'_des_fast_energySpectr_pY'+fpi_suffix,'mms'+probe+'_des_energySpectr_pY'+fpi_suffix
              copy_data,'mms'+probe+'_des_fast_energySpectr_mY'+fpi_suffix,'mms'+probe+'_des_energySpectr_mY'+fpi_suffix
              copy_data,'mms'+probe+'_des_fast_energySpectr_pZ'+fpi_suffix,'mms'+probe+'_des_energySpectr_pZ'+fpi_suffix
              copy_data,'mms'+probe+'_des_fast_energySpectr_mZ'+fpi_suffix,'mms'+probe+'_des_energySpectr_mZ'+fpi_suffix
              copy_data,'mms'+probe+'_des_fast_energySpectr_omni'+fpi_suffix,'mms'+probe+'_des_energySpectr_omni'+fpi_suffix
              store_data,'mms'+probe+'_des_fast_energySpectr_??'+fpi_suffix,/delete
              store_data,'mms'+probe+'_des_fast_energySpectr_omni'+fpi_suffix,/delete
            endif
          endif else begin
            copy_data,'mms'+probe+'_des_energyspectr_px_fast'+fpi_suffix,'mms'+probe+'_des_energySpectr_pX'+fpi_suffix
            copy_data,'mms'+probe+'_des_energyspectr_mx_fast'+fpi_suffix,'mms'+probe+'_des_energySpectr_mX'+fpi_suffix
            copy_data,'mms'+probe+'_des_energyspectr_py_fast'+fpi_suffix,'mms'+probe+'_des_energySpectr_pY'+fpi_suffix
            copy_data,'mms'+probe+'_des_energyspectr_my_fast'+fpi_suffix,'mms'+probe+'_des_energySpectr_mY'+fpi_suffix
            copy_data,'mms'+probe+'_des_energyspectr_pz_fast'+fpi_suffix,'mms'+probe+'_des_energySpectr_pZ'+fpi_suffix
            copy_data,'mms'+probe+'_des_energyspectr_mz_fast'+fpi_suffix,'mms'+probe+'_des_energySpectr_mZ'+fpi_suffix
            copy_data,'mms'+probe+'_des_energyspectr_omni_fast'+fpi_suffix,'mms'+probe+'_des_energySpectr_omni'+fpi_suffix
          endelse
        endif
        if not undefined(des_versions) then begin
          if dis_versions[0,0] le 2 then begin
            mms_load_fpi,trange=trange,probes=probe,level='l1b',data_rate='fast',no_update=no_update_fpi,datatype='dis-dist',time_clip=time_clip
            if strlen(tnames('mms'+probe+'_dis_fastSkyMap_dist')) gt 0 then begin
              mms_fpi_specplot_kitamura,trange=trange,probe=probe,suffix=fpi_suffix,/fast,/no_load,/no_plot,/no_ele
              copy_data,'mms'+probe+'_dis_fast_energySpectr_pX'+fpi_suffix,'mms'+probe+'_dis_energySpectr_pX'+fpi_suffix
              copy_data,'mms'+probe+'_dis_fast_energySpectr_mX'+fpi_suffix,'mms'+probe+'_dis_energySpectr_mX'+fpi_suffix
              copy_data,'mms'+probe+'_dis_fast_energySpectr_pY'+fpi_suffix,'mms'+probe+'_dis_energySpectr_pY'+fpi_suffix
              copy_data,'mms'+probe+'_dis_fast_energySpectr_mY'+fpi_suffix,'mms'+probe+'_dis_energySpectr_mY'+fpi_suffix
              copy_data,'mms'+probe+'_dis_fast_energySpectr_pZ'+fpi_suffix,'mms'+probe+'_dis_energySpectr_pZ'+fpi_suffix
              copy_data,'mms'+probe+'_dis_fast_energySpectr_mZ'+fpi_suffix,'mms'+probe+'_dis_energySpectr_mZ'+fpi_suffix
              copy_data,'mms'+probe+'_dis_fast_energySpectr_omni'+fpi_suffix,'mms'+probe+'_dis_energySpectr_omni'+fpi_suffix
              store_data,'mms'+probe+'_dis_fast_energySpectr_??'+fpi_suffix,/delete
              store_data,'mms'+probe+'_dis_fast_energySpectr_omni'+fpi_suffix,/delete
            endif
          endif else begin
            copy_data,'mms'+probe+'_dis_energyspectr_px_fast'+fpi_suffix,'mms'+probe+'_dis_energySpectr_pX'+fpi_suffix
            copy_data,'mms'+probe+'_dis_energyspectr_mx_fast'+fpi_suffix,'mms'+probe+'_dis_energySpectr_mX'+fpi_suffix
            copy_data,'mms'+probe+'_dis_energyspectr_py_fast'+fpi_suffix,'mms'+probe+'_dis_energySpectr_pY'+fpi_suffix
            copy_data,'mms'+probe+'_dis_energyspectr_my_fast'+fpi_suffix,'mms'+probe+'_dis_energySpectr_mY'+fpi_suffix
            copy_data,'mms'+probe+'_dis_energyspectr_pz_fast'+fpi_suffix,'mms'+probe+'_dis_energySpectr_pZ'+fpi_suffix
            copy_data,'mms'+probe+'_dis_energyspectr_mz_fast'+fpi_suffix,'mms'+probe+'_dis_energySpectr_mZ'+fpi_suffix
            copy_data,'mms'+probe+'_dis_energyspectr_omni_fast'+fpi_suffix,'mms'+probe+'_dis_energySpectr_omni'+fpi_suffix
          endelse
        endif
        if strlen(tnames('mms'+probe+'_dis_energySpectr_omni_fast_l1b')) eq 0 or strlen(tnames('mms'+probe+'_des_energySpectr_omni_fast_l1b')) eq 0 then begin
          fpi_suffix='_fast_ql'
          mms_load_fpi,trange=trange,probes=probe,level='ql',data_rate='fast',no_update=no_update_fpi,suffix=fpi_suffix,datatype='des',time_clip=time_clip,versions=des_versions
          if des_versions[0,0] gt 2 then begin
            copy_data,'mms'+probe+'_des_energyspectr_px_fast'+fpi_suffix,'mms'+probe+'_des_energySpectr_pX'+fpi_suffix
            copy_data,'mms'+probe+'_des_energyspectr_mx_fast'+fpi_suffix,'mms'+probe+'_des_energySpectr_mX'+fpi_suffix
            copy_data,'mms'+probe+'_des_energyspectr_py_fast'+fpi_suffix,'mms'+probe+'_des_energySpectr_pY'+fpi_suffix
            copy_data,'mms'+probe+'_des_energyspectr_my_fast'+fpi_suffix,'mms'+probe+'_des_energySpectr_mY'+fpi_suffix
            copy_data,'mms'+probe+'_des_energyspectr_pz_fast'+fpi_suffix,'mms'+probe+'_des_energySpectr_pZ'+fpi_suffix
            copy_data,'mms'+probe+'_des_energyspectr_mz_fast'+fpi_suffix,'mms'+probe+'_des_energySpectr_mZ'+fpi_suffix
            copy_data,'mms'+probe+'_des_energyspectr_omni_fast'+fpi_suffix,'mms'+probe+'_des_energySpectr_omni'+fpi_suffix
          endif
          mms_load_fpi,trange=trange,probes=probe,level='ql',data_rate='fast',no_update=no_update_fpi,suffix=fpi_suffix,datatype='dis',time_clip=time_clip,versions=dis_versions
          if dis_versions[0,0] gt 2 then begin
            copy_data,'mms'+probe+'_dis_energyspectr_px_fast'+fpi_suffix,'mms'+probe+'_dis_energySpectr_pX'+fpi_suffix
            copy_data,'mms'+probe+'_dis_energyspectr_mx_fast'+fpi_suffix,'mms'+probe+'_dis_energySpectr_mX'+fpi_suffix
            copy_data,'mms'+probe+'_dis_energyspectr_py_fast'+fpi_suffix,'mms'+probe+'_dis_energySpectr_pY'+fpi_suffix
            copy_data,'mms'+probe+'_dis_energyspectr_my_fast'+fpi_suffix,'mms'+probe+'_dis_energySpectr_mY'+fpi_suffix
            copy_data,'mms'+probe+'_dis_energyspectr_pz_fast'+fpi_suffix,'mms'+probe+'_dis_energySpectr_pZ'+fpi_suffix
            copy_data,'mms'+probe+'_dis_energyspectr_mz_fast'+fpi_suffix,'mms'+probe+'_dis_energySpectr_mZ'+fpi_suffix
            copy_data,'mms'+probe+'_dis_energyspectr_omni_fast'+fpi_suffix,'mms'+probe+'_dis_energySpectr_omni'+fpi_suffix
          endif
        endif
      endif else begin
        fpi_suffix=''
        mms_load_fpi,trange=trange,probes=probe,level='l2',data_rate='fast',no_update=no_update_fpi,datatype='des-moms',/center_measurement,time_clip=time_clip,versions=des_versions
        mms_load_fpi,trange=trange,probes=probe,level='l2',data_rate='fast',no_update=no_update_fpi,datatype='dis-moms',/center_measurement,time_clip=time_clip,versions=dis_versions
        if strlen(tnames('mms'+probe+'_dis_energyspectr_px_fast')) eq 0 or strlen(tnames('mms'+probe+'_des_energyspectr_px_fast')) eq 0 then begin
          store_data,'mms'+probe+'_d?s_errorflags_fast_moms',/delete
          fpi_suffix='_fast_ql'
          mms_load_fpi,trange=trange,probes=probe,level='ql',data_rate='fast',no_update=no_update_fpi,suffix=fpi_suffix,datatype='des',time_clip=time_clip,versions=des_versions
          if des_versions[0,0] gt 2 then begin
            copy_data,'mms'+probe+'_des_energyspectr_px_fast'+fpi_suffix,'mms'+probe+'_des_energySpectr_pX'+fpi_suffix
            copy_data,'mms'+probe+'_des_energyspectr_mx_fast'+fpi_suffix,'mms'+probe+'_des_energySpectr_mX'+fpi_suffix
            copy_data,'mms'+probe+'_des_energyspectr_py_fast'+fpi_suffix,'mms'+probe+'_des_energySpectr_pY'+fpi_suffix
            copy_data,'mms'+probe+'_des_energyspectr_my_fast'+fpi_suffix,'mms'+probe+'_des_energySpectr_mY'+fpi_suffix
            copy_data,'mms'+probe+'_des_energyspectr_pz_fast'+fpi_suffix,'mms'+probe+'_des_energySpectr_pZ'+fpi_suffix
            copy_data,'mms'+probe+'_des_energyspectr_mz_fast'+fpi_suffix,'mms'+probe+'_des_energySpectr_mZ'+fpi_suffix
            copy_data,'mms'+probe+'_des_energyspectr_omni_fast'+fpi_suffix,'mms'+probe+'_des_energySpectr_omni'+fpi_suffix
          endif
          mms_load_fpi,trange=trange,probes=probe,level='ql',data_rate='fast',no_update=no_update_fpi,suffix=fpi_suffix,datatype='dis',time_clip=time_clip,versions=dis_versions
          if dis_versions[0,0] gt 2 then begin
            copy_data,'mms'+probe+'_dis_energyspectr_px_fast'+fpi_suffix,'mms'+probe+'_dis_energySpectr_pX'+fpi_suffix
            copy_data,'mms'+probe+'_dis_energyspectr_mx_fast'+fpi_suffix,'mms'+probe+'_dis_energySpectr_mX'+fpi_suffix
            copy_data,'mms'+probe+'_dis_energyspectr_py_fast'+fpi_suffix,'mms'+probe+'_dis_energySpectr_pY'+fpi_suffix
            copy_data,'mms'+probe+'_dis_energyspectr_my_fast'+fpi_suffix,'mms'+probe+'_dis_energySpectr_mY'+fpi_suffix
            copy_data,'mms'+probe+'_dis_energyspectr_pz_fast'+fpi_suffix,'mms'+probe+'_dis_energySpectr_pZ'+fpi_suffix
            copy_data,'mms'+probe+'_dis_energyspectr_mz_fast'+fpi_suffix,'mms'+probe+'_dis_energySpectr_mZ'+fpi_suffix
            copy_data,'mms'+probe+'_dis_energyspectr_omni_fast'+fpi_suffix,'mms'+probe+'_dis_energySpectr_omni'+fpi_suffix
          endif
        endif else begin
          copy_data,'mms'+probe+'_des_energyspectr_px_fast','mms'+probe+'_des_energySpectr_pX'
          copy_data,'mms'+probe+'_des_energyspectr_mx_fast','mms'+probe+'_des_energySpectr_mX'
          copy_data,'mms'+probe+'_des_energyspectr_py_fast','mms'+probe+'_des_energySpectr_pY'
          copy_data,'mms'+probe+'_des_energyspectr_my_fast','mms'+probe+'_des_energySpectr_mY'
          copy_data,'mms'+probe+'_des_energyspectr_pz_fast','mms'+probe+'_des_energySpectr_pZ'
          copy_data,'mms'+probe+'_des_energyspectr_mz_fast','mms'+probe+'_des_energySpectr_mZ'
          if strlen(tnames('mms'+probe+'_des_energyspectr_omni_fast')) gt 0 then copy_data,'mms'+probe+'_des_energyspectr_omni_fast','mms'+probe+'_des_energySpectr_omni' else copy_data,'mms'+probe+'_des_energyspectr_omni_avg','mms'+probe+'_des_energySpectr_omni'
          copy_data,'mms'+probe+'_dis_energyspectr_px_fast','mms'+probe+'_dis_energySpectr_pX'
          copy_data,'mms'+probe+'_dis_energyspectr_mx_fast','mms'+probe+'_dis_energySpectr_mX'
          copy_data,'mms'+probe+'_dis_energyspectr_py_fast','mms'+probe+'_dis_energySpectr_pY'
          copy_data,'mms'+probe+'_dis_energyspectr_my_fast','mms'+probe+'_dis_energySpectr_mY'
          copy_data,'mms'+probe+'_dis_energyspectr_pz_fast','mms'+probe+'_dis_energySpectr_pZ'
          copy_data,'mms'+probe+'_dis_energyspectr_mz_fast','mms'+probe+'_dis_energySpectr_mZ'
          if strlen(tnames('mms'+probe+'_dis_energyspectr_omni_fast')) gt 0 then copy_data,'mms'+probe+'_dis_energyspectr_omni_fast','mms'+probe+'_dis_energySpectr_omni' else copy_data,'mms'+probe+'_dis_energyspectr_omni_avg','mms'+probe+'_dis_energySpectr_omni'
        endelse
      endelse
    endif else begin
      fpi_suffix=''
    endelse
    if strlen(tnames('mms'+probe+'_dis_energySpectr_pX'+fpi_suffix)) eq 0 or strlen(tnames('mms'+probe+'_des_energySpectr_pX'+fpi_suffix)) eq 0 then begin
      mms_load_fpi,trange=trange,probes=probe,level='sitl',data_rate='fast',no_update=no_update_fpi,time_clip=time_clip,versions=dis_versions
      if not undefined(dis_versions) then des_versions=dis_versions
      fpi_suffix=''
    endif
  endif else begin
    if strlen(tnames('mms'+probe+'_des_numberdensity_fast'+fpi_suffix)) gt 0 then begin
      get_data,'mms'+probe+'_des_numberdensity_fast'+fpi_suffix,dlimit=dl
      versions_temp=stregex(dl.cdf.gatt.logical_file_id,'v([0-9]+)\.([0-9]+)\.([0-9])',/extract,/subexpr)
    endif else begin
      if strlen(tnames('mms'+probes[i]+'_des_numberdensity_dbcs_fast'+fpi_suffix)) gt 0 then begin
        get_data,'mms'+probes[i]+'_des_numberdensity_dbcs_fast'+fpi_suffix,dlimit=dl
        versions_temp=stregex(dl.cdf.gatt.logical_file_id,'v([0-9]+)\.([0-9]+)\.([0-9])',/extract,/subexpr)
      endif else begin
        versions_temp=['no des data','0','0','0']
      endelse
    endelse
    des_versions=intarr(1,3)
    for i_version=0,2 do des_versions[0,i_version]=fix(versions_temp[i_version+1])
    if strlen(tnames('mms'+probe+'_dis_numberdensity_fast'+fpi_suffix)) gt 0 then begin
      get_data,'mms'+probe+'_dis_numberdensity_fast'+fpi_suffix,dlimit=dl
      versions_temp=stregex(dl.cdf.gatt.logical_file_id,'v([0-9]+)\.([0-9]+)\.([0-9])',/extract,/subexpr)
    endif else begin
      if strlen(tnames('mms'+probes[i]+'_dis_numberdensity_dbcs_fast'+fpi_suffix)) gt 0 then begin
        get_data,'mms'+probes[i]+'_dis_numberdensity_dbcs_fast'+fpi_suffix,dlimit=dl
        versions_temp=stregex(dl.cdf.gatt.logical_file_id,'v([0-9]+)\.([0-9]+)\.([0-9])',/extract,/subexpr)
      endif else begin
        versions_temp=['no dis data','0','0','0']
      endelse
    endelse
    dis_versions=intarr(1,3)
    for i_version=0,2 do dis_versions[0,i_version]=fix(versions_temp[i_version+1])
  endelse
  
  if strlen(tnames('mms'+probe+'_dis_energySpectr_pX'+fpi_suffix)) gt 0 and undefined(fpi_sitl) then begin
    get_data,'mms'+probe+'_dis_energySpectr_pX'+fpi_suffix,data=d
    if d.x[n_elements(d.x)-1] lt trange[0] then begin
      store_data,'mms'+probe+'_d?s_*_ql',/delete
      fpi_sitl=1
    endif
  endif
  
  if strlen(tnames('mms'+probe+'_dis_energySpectr_pX'+fpi_suffix)) gt 0 and undefined(fpi_sitl) then begin
    if fpi_suffix eq '_fast_l1b' then dis_level='L1B' else dis_level='QL'
    dgap_i=4.6d
    copy_data,'mms'+probe+'_dis_energySpectr_pX'+fpi_suffix,'mms'+probe+'_fpi_iEnergySpectr_pX'
    copy_data,'mms'+probe+'_dis_energySpectr_mX'+fpi_suffix,'mms'+probe+'_fpi_iEnergySpectr_mX'
    copy_data,'mms'+probe+'_dis_energySpectr_pY'+fpi_suffix,'mms'+probe+'_fpi_iEnergySpectr_pY'
    copy_data,'mms'+probe+'_dis_energySpectr_mY'+fpi_suffix,'mms'+probe+'_fpi_iEnergySpectr_mY'
    copy_data,'mms'+probe+'_dis_energySpectr_pZ'+fpi_suffix,'mms'+probe+'_fpi_iEnergySpectr_pZ'
    copy_data,'mms'+probe+'_dis_energySpectr_mZ'+fpi_suffix,'mms'+probe+'_fpi_iEnergySpectr_mZ'
    
    if (strlen(tnames('mms'+probe+'_dis_errorflags_fast_moms*')))[0] eq 0 and strlen(tnames('mms'+probe+'_dis_errorflags_fast'+fpi_suffix)) eq 0 then begin
      copy_data,'mms'+probe+'_dis_numberDensity'+fpi_suffix,'mms'+probe+'_fpi_DISnumberDensity'
      copy_data,'mms'+probe+'_dis_bulkX'+fpi_suffix,'mms'+probe+'_fpi_iBulkV_X_DSC'
      copy_data,'mms'+probe+'_dis_bulkY'+fpi_suffix,'mms'+probe+'_fpi_iBulkV_Y_DSC'
      copy_data,'mms'+probe+'_dis_bulkZ'+fpi_suffix,'mms'+probe+'_fpi_iBulkV_Z_DSC'

      get_data,'mms'+probe+'_dis_TempXX'+fpi_suffix,data=tixx
      get_data,'mms'+probe+'_dis_TempYY'+fpi_suffix,data=tiyy
      get_data,'mms'+probe+'_dis_TempZZ'+fpi_suffix,data=tizz
      get_data,'mms'+probe+'_dis_TempXY'+fpi_suffix,data=tixy
      get_data,'mms'+probe+'_dis_TempXZ'+fpi_suffix,data=tixz
      get_data,'mms'+probe+'_dis_TempYZ'+fpi_suffix,data=tiyz
      store_data,'mms'+probe+'_ti_tensor'+fpi_suffix,data={x:tixx.x,y:[[tixx.y],[tiyy.y],[tizz.y],[tixy.y],[tixz.y],[tiyz.y]]}
      diag_t,'mms'+probe+'_ti_tensor'+fpi_suffix
      copy_data,'T_diag','mms'+probe+'_fpi_DIS_T_diag'
      copy_data,'Saxis','mms'+probe+'_fpi_DIS_T_Saxis'
      get_data,'T_diag',data=t_diag
      store_data,'mms'+probe+'_fpi_DIStempPerp',data={x:t_diag.x,y:(t_diag.y[*,1]+t_diag.y[*,2])/2.d}
      store_data,'mms'+probe+'_fpi_DIStempPara',data={x:t_diag.x,y:t_diag.y[*,0]}
    endif else begin
      if fpi_suffix ne '_fast_ql' then dis_level='L2' else dis_level='QL'
      if strlen(tnames('mms'+probe+'_dis_numberdensity_dbcs_fast'+fpi_suffix)) gt 0 and strlen(tnames('mms'+probe+'_dis_numberdensity_fast'+fpi_suffix)) eq 0 then copy_data,'mms'+probe+'_dis_numberdensity_dbcs_fast'+fpi_suffix,'mms'+probe+'_dis_numberdensity_fast'+fpi_suffix
      copy_data,'mms'+probe+'_dis_numberdensity_fast'+fpi_suffix,'mms'+probe+'_fpi_DISnumberDensity'
      if strlen(tnames('mms'+probe+'_dis_bulkx_dbcs_fast'+fpi_suffix)) gt 0 then begin
        copy_data,'mms'+probe+'_dis_bulkx_dbcs_fast'+fpi_suffix,'mms'+probe+'_fpi_iBulkV_X_DSC'
        copy_data,'mms'+probe+'_dis_bulky_dbcs_fast'+fpi_suffix,'mms'+probe+'_fpi_iBulkV_Y_DSC'
        copy_data,'mms'+probe+'_dis_bulkz_dbcs_fast'+fpi_suffix,'mms'+probe+'_fpi_iBulkV_Z_DSC'
      endif
      copy_data,'mms'+probe+'_dis_tempperp_fast'+fpi_suffix,'mms'+probe+'_fpi_DIStempPerp'
      copy_data,'mms'+probe+'_dis_temppara_fast'+fpi_suffix,'mms'+probe+'_fpi_DIStempPara'
    endelse
  endif else begin
    if not undefined(dis_versions) then dis_level='SITL' else dis_level='L2' 
    dgap_i=10.5d
  endelse
  if strlen(tnames('mms'+probe+'_des_energySpectr_pX'+fpi_suffix)) gt 0 and undefined(fpi_sitl) then begin
    if fpi_suffix eq '_fast_l1b' then des_level='L1B' else des_level='QL'
    dgap_e=4.6d
    copy_data,'mms'+probe+'_des_energySpectr_pX'+fpi_suffix,'mms'+probe+'_fpi_eEnergySpectr_pX'
    copy_data,'mms'+probe+'_des_energySpectr_mX'+fpi_suffix,'mms'+probe+'_fpi_eEnergySpectr_mX'
    copy_data,'mms'+probe+'_des_energySpectr_pY'+fpi_suffix,'mms'+probe+'_fpi_eEnergySpectr_pY'
    copy_data,'mms'+probe+'_des_energySpectr_mY'+fpi_suffix,'mms'+probe+'_fpi_eEnergySpectr_mY'
    copy_data,'mms'+probe+'_des_energySpectr_pZ'+fpi_suffix,'mms'+probe+'_fpi_eEnergySpectr_pZ'
    copy_data,'mms'+probe+'_des_energySpectr_mZ'+fpi_suffix,'mms'+probe+'_fpi_eEnergySpectr_mZ'
    
    if (strlen(tnames('mms'+probe+'_des_errorflags_fast_moms*')))[0] eq 0 and strlen(tnames('mms'+probe+'_des_errorflags_fast'+fpi_suffix)) eq 0 then begin
      copy_data,'mms'+probe+'_des_numberDensity'+fpi_suffix,'mms'+probe+'_fpi_DESnumberDensity'
      copy_data,'mms'+probe+'_des_bulkX'+fpi_suffix,'mms'+probe+'_fpi_eBulkV_X_DSC'
      copy_data,'mms'+probe+'_des_bulkY'+fpi_suffix,'mms'+probe+'_fpi_eBulkV_Y_DSC'
      copy_data,'mms'+probe+'_des_bulkZ'+fpi_suffix,'mms'+probe+'_fpi_eBulkV_Z_DSC'

      get_data,'mms'+probe+'_des_TempXX'+fpi_suffix,data=texx
      get_data,'mms'+probe+'_des_TempYY'+fpi_suffix,data=teyy
      get_data,'mms'+probe+'_des_TempZZ'+fpi_suffix,data=tezz
      get_data,'mms'+probe+'_des_TempXY'+fpi_suffix,data=texy
      get_data,'mms'+probe+'_des_TempXZ'+fpi_suffix,data=texz
      get_data,'mms'+probe+'_des_TempYZ'+fpi_suffix,data=teyz
      store_data,'mms'+probe+'_te_tensor'+fpi_suffix,data={x:texx.x,y:[[texx.y],[teyy.y],[tezz.y],[texy.y],[texz.y],[teyz.y]]}
      diag_t,'mms'+probe+'_te_tensor'+fpi_suffix
      copy_data,'T_diag','mms'+probe+'_fpi_DES_T_diag'
      copy_data,'Saxis','mms'+probe+'_fpi_DES_T_Saxis'
      get_data,'T_diag',data=t_diag
      store_data,'mms'+probe+'_fpi_DEStempPerp',data={x:t_diag.x,y:(t_diag.y[*,1]+t_diag.y[*,2])/2.d}
      store_data,'mms'+probe+'_fpi_DEStempPara',data={x:t_diag.x,y:t_diag.y[*,0]}
    endif else begin
      if fpi_suffix ne '_fast_ql' then des_level='L2' else des_level='QL'
      if strlen(tnames('mms'+probe+'_des_numberdensity_dbcs_fast'+fpi_suffix)) gt 0 and strlen(tnames('mms'+probe+'_des_numberdensity_fast'+fpi_suffix)) eq 0 then copy_data,'mms'+probe+'_des_numberdensity_dbcs_fast'+fpi_suffix,'mms'+probe+'_des_numberdensity_fast'+fpi_suffix
      copy_data,'mms'+probe+'_des_numberdensity_fast'+fpi_suffix,'mms'+probe+'_fpi_DESnumberDensity'
      if strlen(tnames('mms'+probe+'_des_bulkx_dbcs_fast'+fpi_suffix)) gt 0 then begin
        copy_data,'mms'+probe+'_des_bulkx_dbcs_fast'+fpi_suffix,'mms'+probe+'_fpi_eBulkV_X_DSC'
        copy_data,'mms'+probe+'_des_bulky_dbcs_fast'+fpi_suffix,'mms'+probe+'_fpi_eBulkV_Y_DSC'
        copy_data,'mms'+probe+'_des_bulkz_dbcs_fast'+fpi_suffix,'mms'+probe+'_fpi_eBulkV_Z_DSC'
      endif  
      if des_versions[0,0] gt 2 then begin
        copy_data,'mms'+probe+'_des_tempperp_fast'+fpi_suffix,'mms'+probe+'_fpi_DEStempPerp'
        copy_data,'mms'+probe+'_des_temppara_fast'+fpi_suffix,'mms'+probe+'_fpi_DEStempPara'
      endif else begin
        get_data,'mms'+probe+'_des_tempxx_dbcs_fast'+fpi_suffix,data=texx
        get_data,'mms'+probe+'_des_tempyy_dbcs_fast'+fpi_suffix,data=teyy
        get_data,'mms'+probe+'_des_tempzz_dbcs_fast'+fpi_suffix,data=tezz
        get_data,'mms'+probe+'_des_tempxy_dbcs_fast'+fpi_suffix,data=texy
        get_data,'mms'+probe+'_des_tempxz_dbcs_fast'+fpi_suffix,data=texz
        get_data,'mms'+probe+'_des_tempyz_dbcs_fast'+fpi_suffix,data=teyz
        store_data,'mms'+probe+'_te_tensor',data={x:texx.x,y:[[texx.y],[teyy.y],[tezz.y],[texy.y],[texz.y],[teyz.y]]}
        diag_t,'mms'+probe+'_te_tensor'
        copy_data,'T_diag','mms'+probe+'_fpi_DES_T_diag'
        copy_data,'Saxis','mms'+probe+'_fpi_DES_T_Saxis'
        get_data,'T_diag',data=t_diag
        store_data,'mms'+probe+'_fpi_DEStempPerp',data={x:t_diag.x,y:(t_diag.y[*,1]+t_diag.y[*,2])/2.d}
        store_data,'mms'+probe+'_fpi_DEStempPara',data={x:t_diag.x,y:t_diag.y[*,0]}
      endelse
    endelse
  endif else begin
    if not undefined(des_versions) then des_level='SITL' else des_level='L2'
    dgap_e=10.5d
  endelse

  if not undefined(add_scpot) then begin
    if undefined(edp_comm) then begin
      mms_load_edp,trange=[trange[0]-600.d,trange[1]+600.d],data_rate='slow',probes=probe,datatype='scpot',level='l2',no_update=no_update_edp,time_clip=time_clip
      mms_load_edp,trange=[trange[0]-600.d,trange[1]+600.d],data_rate='fast',probes=probe,datatype='scpot',level='l2',no_update=no_update_edp,time_clip=time_clip
      if strlen(tnames('mms'+probe+'_edp_scpot_fast_l2')) gt 0 then copy_data,'mms'+probe+'_edp_scpot_fast_l2','mms'+probe+'_edp_fast_scpot'
      if strlen(tnames('mms'+probe+'_edp_scpot_slow_l2')) gt 0 then copy_data,'mms'+probe+'_edp_scpot_slow_l2','mms'+probe+'_edp_slow_scpot'
      avg_data,'mms'+probe+'_edp_slow_scpot',10.d,trange=[time_double(time_string(trange[0],format=0,precision=-3)),time_double(time_string(trange[1],format=0,precision=-3))+24.d*3600.d]
      avg_data,'mms'+probe+'_edp_fast_scpot',10.d,trange=[time_double(time_string(trange[0],format=0,precision=-3)),time_double(time_string(trange[1],format=0,precision=-3))+24.d*3600.d]
;      store_data,'mms'+probe+'_edp_scpot_avg',data=['mms'+probe+'_edp_slow_scpot_avg','mms'+probe+'_edp_fast_scpot_avg']
;      options,'mms'+probe+'_edp'+['','_slow','_fast']+'_scpot_avg',ystyle=9,ylog=1,axis={yaxis:1,ytitle:'MMS'+probe+'_EDP!Cs/c pot!C[V]',yrange:[0.05d,300.d],ytickformat:'mms_exponent2'}
      options,'mms'+probe+'_edp'+['_slow','_fast']+'_scpot_avg',axis={yaxis:1,ytitle:'MMS'+probe+'_EDP!Cs/c pot!C[-V]',ylog:1,ystyle:9,yrange:[0.05d,300.d],ytickformat:'mms_exponent2'}      
    endif else begin
      mms_load_edp,trange=[trange[0]-600.d,trange[1]+600.d],data_rate='comm',probes=probe,datatype='scpot',level='l2',no_update=no_update_edp,time_clip=time_clip
      avg_data,'mms'+probe+'_edp_comm_scpot',10.d,trange=[time_double(time_string(trange[0],format=0,precision=-3)),time_double(time_string(trange[1],format=0,precision=-3))+24.d*3600.d]
      options,'mms'+probe+'_edp_comm_scpot_avg',axis={yaxis:1,ytitle:'MMS'+probe+'_EDP!Cs/c pot!C[-V]',ylog:1,ystyle:9,yrange:[0.05d,300.d],ytickformat:'mms_exponent2'}      
    endelse

  endif  

 
  if strlen(tnames('mms'+probe+'_fpi_eEnergySpectr_pX')) gt 0 then begin
    if fpi_suffix eq '_fast_l1b' then get_data,'mms'+probe+'_fpi_DESnumberDensity',dlimit=dl else get_data,'mms'+probe+'_fpi_eEnergySpectr_pX',dlimit=dl
    fpiver_e=stregex(dl.cdf.gatt.logical_file_id,'v([0-9]+)\.([0-9]+)\.([0-9])',/extract)
  endif else begin
    fpiver_e='no data'
  endelse  
  if strlen(tnames('mms'+probe+'_fpi_iEnergySpectr_pX')) gt 0 then begin
    if fpi_suffix eq '_fast_l1b' then get_data,'mms'+probe+'_fpi_DISnumberDensity',dlimit=dl else get_data,'mms'+probe+'_fpi_iEnergySpectr_pX',dlimit=dl
    fpiver_i=stregex(dl.cdf.gatt.logical_file_id,'v([0-9]+)\.([0-9]+)\.([0-9])',/extract)
  endif else begin
    fpiver_i='no data'
  endelse
 
  options,['mms'+probe+'_fpi_eEnergySpectr_??'],datagap=dgap_e
  options,['mms'+probe+'_fpi_iEnergySpectr_??'],datagap=dgap_i
  
  if fpi_suffix eq '_fast_l1b' then begin
    copy_data,'mms'+probe+'_des_energySpectr_omni_fast_l1b','mms'+probe+'_fpi_eEnergySpectr_omni'
    copy_data,'mms'+probe+'_dis_energySpectr_omni_fast_l1b','mms'+probe+'_fpi_iEnergySpectr_omni'
  endif else begin
    if (strlen(tnames('mms'+probe+'_des_errorflags_fast_moms*')))[0] eq 0 and strlen(tnames('mms'+probe+'_des_errorflags_fast'+fpi_suffix)) eq 0 then begin
      mms_load_fpi_calc_omni,probe,datatype='des',level='sitl'
      store_data,'mms'+probe+'_fpi_eEnergySpectr_omni_avg',newname='mms'+probe+'_fpi_eEnergySpectr_omni'
    endif else begin
      copy_data,'mms'+probe+'_des_energySpectr_omni'+fpi_suffix,'mms'+probe+'_fpi_eEnergySpectr_omni'
    endelse
    if (strlen(tnames('mms'+probe+'_dis_errorflags_fast_moms*')))[0] eq 0 and strlen(tnames('mms'+probe+'_dis_errorflags_fast'+fpi_suffix)) eq 0 then begin
      mms_load_fpi_calc_omni,probe,datatype='dis',level='sitl'
      store_data,'mms'+probe+'_fpi_iEnergySpectr_omni_avg',newname='mms'+probe+'_fpi_iEnergySpectr_omni'
    endif else begin
      copy_data,'mms'+probe+'_dis_energySpectr_omni'+fpi_suffix,'mms'+probe+'_fpi_iEnergySpectr_omni'      
    endelse
  endelse
  
  if strlen(tnames('mms'+probe+'_fpi_eEnergySpectr_omni')) eq 0 then store_data,'mms'+probe+'_fpi_eEnergySpectr_omni',data={x:[trange],y:[[!values.f_nan,!values.f_nan],[!values.f_nan,!values.f_nan]],v:[10.d,30000.d]}
  options,'mms'+probe+'_fpi_eEnergySpectr_omni',spec=1,ytitle='MMS'+probe+'_FPI!CElectron!C'+des_level+'!C'+fpiver_e+'!Comni',ysubtitle='[eV]',datagap=dgap_e,ytickformat='mms_exponent2',ztickformat='mms_exponent2'
  ylim,'mms'+probe+'_fpi_eEnergySpectr_omni',6.d,30000.d,1
  if fpi_suffix ne '_fast_l1b' and (strlen(tnames('mms'+probe+'_des_errorflags_fast_moms')))[0] eq 0 and strlen(tnames('mms'+probe+'_des_errorflags_fast'+fpi_suffix)) eq 0 then zlim,'mms'+probe+'_fpi_eEnergySpectr_omni',0.1d,50000.d,1
  if (strlen(tnames('mms'+probe+'_des_errorflags_fast_moms')))[0] gt 0 or strlen(tnames('mms'+probe+'_des_errorflags_fast'+fpi_suffix)) gt 0 then zlim,'mms'+probe+'_fpi_eEnergySpectr_omni',3e5,3e9,1
  
  if strlen(tnames('mms'+probe+'_fpi_iEnergySpectr_omni')) eq 0 then store_data,'mms'+probe+'_fpi_iEnergySpectr_omni',data={x:[trange],y:[[!values.f_nan,!values.f_nan],[!values.f_nan,!values.f_nan]],v:[10.d,30000.d]}
  options,'mms'+probe+'_fpi_iEnergySpectr_omni',spec=1,ytitle='MMS'+probe+'_FPI!CIon!C'+dis_level+'!C'+fpiver_i+'!Comni',ysubtitle='[eV]',datagap=dgap_i,ytickformat='mms_exponent2',ztickformat='mms_exponent2'
  ylim,'mms'+probe+'_fpi_iEnergySpectr_omni',2.d,30000.d,1
  if fpi_suffix ne '_fast_l1b' and (strlen(tnames('mms'+probe+'_dis_errorflags_fast_moms')))[0] eq 0 and strlen(tnames('mms'+probe+'_dis_errorflags_fast'+fpi_suffix)) eq 0 then zlim,'mms'+probe+'_fpi_iEnergySpectr_omni',0.1d,2000.d,1
  if (strlen(tnames('mms'+probe+'_dis_errorflags_fast_moms')))[0] gt 0 or strlen(tnames('mms'+probe+'_dis_errorflags_fast'+fpi_suffix)) gt 0 then zlim,'mms'+probe+'_fpi_iEnergySpectr_omni',3e4,3e8,1

  if strlen(tnames('mms'+probe+'_fpi_DISnumberDensity')) eq 0 then store_data,'mms'+probe+'_fpi_DISnumberDensity',data={x:[trange],y:[!values.f_nan,!values.f_nan]}
  options,'mms'+probe+'_fpi_DISnumberDensity',ytitle='MMS'+probe+'!CFPI_'+dis_level+'!CIon!CNumber!CDensity',ysubtitle='[cm!U-3!N]',colors=6,ylog=1,datagap=dgap_i,ytickformat='mms_exponent2',labels=''
  ylim,'mms'+probe+'_fpi_DISnumberDensity',0.05d,300.d,1
  
  if strlen(tnames('mms'+probe+'_fpi_DESnumberDensity')) gt 0 and (des_level eq 'QL' or des_level eq 'L1B' or des_level eq 'L2') then begin
    if strlen(tnames('mms'+probe+'_fpi_DESnumberDensity')) eq 0 then store_data,'mms'+probe+'_fpi_DESnumberDensity',data={x:[trange],y:[!values.f_nan,!values.f_nan]}
    options,'mms'+probe+'_fpi_DESnumberDensity',ytitle='MMS'+probe+'!CFPI_'+des_level+'!CElectron!CNumber!CDensity',ysubtitle='[cm!U-3!N]',colors=6,ylog=1,datagap=dgap_e,ytickformat='mms_exponent2',labels=''
    ylim,'mms'+probe+'_fpi_DESnumberDensity',0.05d,300.d,1
  endif
  
  if undefined(add_scpot) and strlen(tnames('mms'+probe+'_edp_fast_scpot_avg')) gt 0 then begin
    if des_level eq 'QL' or des_level eq 'L1B' or des_level eq 'L2' then begin
      store_data,'mms'+probe+'_fpi_numberDensity',data=['mms'+probe+'_fpi_DISnumberDensity','mms'+probe+'_fpi_DESnumberDensity']
      options,'mms'+probe+'_fpi_numberDensity',ytitle='MMS'+probe+'!CFPI_'+dis_level+'!CNumber!CDensity',ysubtitle='[cm!U-3!N]',ylog=1,colors=[0,6],labels=['Ni','Ne'],labflag=-1,ytickformat='mms_exponent2'
    endif else begin
      copy_data,'mms'+probe+'_fpi_DISnumberDensity','mms'+probe+'_fpi_numberDensity'
    endelse
  endif else begin
    options,'mms'+probe+'_fpi_DISnumberDensity',ystyle=9
    if des_level eq 'QL' or des_level eq 'L1B' or des_level eq 'L2' then begin
      options,'mms'+probe+'_fpi_DESnumberDensity',colors=2,ystyle=9
      store_data,'mms'+probe+'_fpi_numberDensity',data=['mms'+probe+'_edp_comm_scpot_avg','mms'+probe+'_edp_slow_scpot_avg','mms'+probe+'_edp_fast_scpot_avg','mms'+probe+'_fpi_DESnumberDensity','mms'+probe+'_fpi_DISnumberDensity']
      options,'mms'+probe+'_fpi_numberDensity',ytitle='MMS'+probe+'!CFPI_'+dis_level+'!CElectron(blue)!CIon(red)!CNumber!CDensity',ysubtitle='[cm!U-3!N]',ytickformat='mms_exponent2'
      options,'mms'+probe+'_fpi_numberDensity','labels'
    endif else begin
      store_data,'mms'+probe+'_fpi_numberDensity',data=['mms'+probe+'_edp_comm_scpot_avg','mms'+probe+'_edp_slow_scpot_avg','mms'+probe+'_edp_fast_scpot_avg','mms'+probe+'_fpi_DISnumberDensity']
      options,'mms'+probe+'_fpi_numberDensity',ytitle='MMS'+probe+'!CFPI_'+dis_level+'!CIon(red)!CNumber!CDensity',ysubtitle='[cm!U-3!N]',ytickformat='mms_exponent2'
      options,'mms'+probe+'_fpi_numberDensity','labels'
    endelse
  endelse
  ylim,'mms'+probe+'_fpi_numberDensity',0.05d,300.d,1

  if undefined(skip_cotrans) and undefined(no_load_mec) then mms_load_mec,trange=trange,probes=probe,no_update=no_update,varformat=['mms'+probe+'_mec_r_eci','mms'+probe+'_mec_r_gse','mms'+probe+'_mec_r_gsm','mms'+probe+'_mec_L_vec']
  if not undefined(dis_versions) and not undefined(des_versions) then begin
    if dis_versions[0,0] le 2 or des_versions[0,0] le 2 then if strlen(tnames('mms'+probe+'_defatt_spinras')) eq 0 or strlen(tnames('mms'+probe+'_defatt_spindec')) eq 0 then skip_cotrans=1
  endif
  
  if strlen(tnames('mms'+probe+'_dis_bulkv_gse_fast'+fpi_suffix)) gt 0 then begin
    copy_data,'mms'+probe+'_dis_bulkv_dbcs_fast'+fpi_suffix,'mms'+probe+'_fpi_iBulkV_DSC'
    copy_data,'mms'+probe+'_dis_bulkv_gse_fast'+fpi_suffix,'mms'+probe+'_fpi_iBulkV_gse'
    if strlen(tnames('mms'+probe+'_fpi_iBulkV_DSC')) eq 0 then begin
      store_data,'mms'+probe+'_fpi_iBulkV_DSC',data={x:[trange],y:[[!values.f_nan,!values.f_nan],[!values.f_nan,!values.f_nan],[!values.f_nan,!values.f_nan]]}
      ylim,'mms'+probe+'_fpi_iBulkV_DSC',-100.d,100.d,0
    endif
    if strlen(tnames('mms'+probe+'_fpi_iBulkV_gse')) eq 0 then begin
      store_data,'mms'+probe+'_fpi_iBulkV_gse',data={x:[trange],y:[[!values.f_nan,!values.f_nan],[!values.f_nan,!values.f_nan],[!values.f_nan,!values.f_nan]]}
      ylim,'mms'+probe+'_fpi_iBulkV_gse',-100.d,100.d,0
    endif
  endif else begin
    join_vec,'mms'+probe+'_fpi_iBulkV'+['_X_DSC','_Y_DSC','_Z_DSC'],'mms'+probe+'_fpi_iBulkV_DSC'
    if strlen(tnames('mms'+probe+'_fpi_iBulkV_DSC')) eq 0 then begin
      store_data,'mms'+probe+'_fpi_iBulkV_DSC',data={x:[trange],y:[[!values.f_nan,!values.f_nan],[!values.f_nan,!values.f_nan],[!values.f_nan,!values.f_nan]]}
      ylim,'mms'+probe+'_fpi_iBulkV_DSC',-100.d,100.d,0
    endif
    if undefined(skip_cotrans) then mms_cotrans,'mms'+probe+'_fpi_iBulkV',in_coord='dmpa',in_suffix='_DSC',out_coord='gse',out_suffix='_gse',/ignore_dlimits
  endelse
  options,'mms'+probe+'_fpi_iBulkV_DSC',constant=0.0,ytitle='MMS'+probe+'!CFPI_'+dis_level+'!CIon!CBulkV_DBCS',ysubtitle='[km/s]',colors=[2,4,1],labels=['V!DX_DBCS!N','V!DY_DBCS!N','V!DZ_DBCS!N'],labflag=-1,datagap=dgap_i
  options,'mms'+probe+'_fpi_iBulkV_gse',constant=0.0,ytitle='MMS'+probe+'!CFPI_'+dis_level+'!CIon!CBulkV_GSE',ysubtitle='[km/s]',colors=[2,4,6],labels=['V!DX!N','V!DY!N','V!DZ!N'],labflag=-1,datagap=dgap_i
  if undefined(skip_cotrans) then begin
    mms_cotrans,'mms'+probe+'_fpi_iBulkV',in_coord='gse',in_suffix='_gse',out_coord='gsm',out_suffix='_gsm',/ignore_dlimits
    options,'mms'+probe+'_fpi_iBulkV_gsm',constant=0.0,ytitle='MMS'+probe+'!CFPI_'+dis_level+'!CIon!CBulkV_GSM',ysubtitle='[km/s]',colors=[2,4,6],labels=['V!DX!N','V!DY!N','V!DZ!N'],labflag=-1,datagap=dgap_i
  endif
  
  if des_level eq 'QL' or des_level eq 'L1B' or des_level eq 'L2' then begin
    if strlen(tnames('mms'+probe+'_des_bulkv_gse_fast'+fpi_suffix)) gt 0 then begin
      copy_data,'mms'+probe+'_des_bulkv_dbcs_fast'+fpi_suffix,'mms'+probe+'_fpi_eBulkV_DSC'
      copy_data,'mms'+probe+'_des_bulkv_gse_fast'+fpi_suffix,'mms'+probe+'_fpi_eBulkV_gse'
      if strlen(tnames('mms'+probe+'_fpi_eBulkV_DSC')) eq 0 then begin
        store_data,'mms'+probe+'_fpi_eBulkV_DSC',data={x:[trange],y:[[!values.f_nan,!values.f_nan],[!values.f_nan,!values.f_nan],[!values.f_nan,!values.f_nan]]}
        ylim,'mms'+probe+'_fpi_eBulkV_DSC',-100.d,100.d,0
      endif
      if strlen(tnames('mms'+probe+'_fpi_eBulkV_gse')) eq 0 then begin
        store_data,'mms'+probe+'_fpi_eBulkV_gse',data={x:[trange],y:[[!values.f_nan,!values.f_nan],[!values.f_nan,!values.f_nan],[!values.f_nan,!values.f_nan]]}
        ylim,'mms'+probe+'_fpi_eBulkV_gse',-100.d,100.d,0
      endif
    endif else begin
      join_vec,'mms'+probe+'_fpi_eBulkV'+['_X_DSC','_Y_DSC','_Z_DSC'],'mms'+probe+'_fpi_eBulkV_DSC'
      if strlen(tnames('mms'+probe+'_fpi_eBulkV_DSC')) eq 0 then begin
        store_data,'mms'+probe+'_fpi_eBulkV_DSC',data={x:[trange],y:[[!values.f_nan,!values.f_nan],[!values.f_nan,!values.f_nan],[!values.f_nan,!values.f_nan]]}
        ylim,'mms'+probe+'_fpi_eBulkV_gse',-100.d,100.d,0
      endif
      if undefined(skip_cotrans) then mms_cotrans,'mms'+probe+'_fpi_eBulkV',in_coord='dmpa',in_suffix='_DSC',out_coord='gse',out_suffix='_gse',/ignore_dlimits
    endelse
    options,'mms'+probe+'_fpi_eBulkV_DSC',constant=0.0,ytitle='MMS'+probe+'!CFPI_'+dis_level+'!CElectron!CBulkV_DBCS',ysubtitle='[km/s]',colors=[2,4,1],labels=['V!DX_DBCS!N','V!DY_DBCS!N','V!DZ_DBCS!N'],labflag=-1,datagap=dgap_e
    options,'mms'+probe+'_fpi_eBulkV_gse',constant=0.0,ytitle='MMS'+probe+'!CFPI_'+dis_level+'!CElectron!CBulkV_GSE',ysubtitle='[km/s]',colors=[2,4,6],labels=['V!DX!N','V!DY!N','V!DZ!N'],labflag=-1,datagap=dgap_e
    if undefined(skip_cotrans) then begin
      mms_cotrans,'mms'+probe+'_fpi_eBulkV',in_coord='gse',in_suffix='_gse',out_coord='gsm',out_suffix='_gsm',/ignore_dlimits
      options,'mms'+probe+'_fpi_eBulkV_gsm',constant=0.0,ytitle='MMS'+probe+'!CFPI_'+dis_level+'!CElectron!CBulkV_GSM',ysubtitle='[km/s]',colors=[2,4,6],labels=['V!DX!N','V!DY!N','V!DZ!N'],labflag=-1,datagap=dgap_e
    endif
  endif  
  
  if strlen(tnames('mms'+probe+'_fpi_DEStempPerp')) gt 0 or strlen(tnames('mms'+probe+'_fpi_DEStempPara')) gt 0 then begin
    store_data,'mms'+probe+'_fpi_DEStemp',data=['mms'+probe+'_fpi_DEStempPerp','mms'+probe+'_fpi_DEStempPara']
  endif else begin
    store_data,'mms'+probe+'_fpi_DEStemp',data={x:[trange],y:[[!values.f_nan,!values.f_nan],[!values.f_nan,!values.f_nan]]}
    ylim,'mms'+probe+'_fpi_DEStemp',5.d,50000.d,1
  endelse
  options,'mms'+probe+'_fpi_DEStemp',ylog=1,ytitle='MMS'+probe+'!Cfpi_'+des_level+'!CeTemp',ysubtitle='[eV]',colors=[6,0],labels=['Perp','Para'],labflag=-1,datagap=dgap_e,ytickformat='mms_exponent2'
  if strlen(tnames('mms'+probe+'_fpi_DIStempPerp')) gt 0 or strlen(tnames('mms'+probe+'_fpi_DIStempPara')) gt 0 then begin
    store_data,'mms'+probe+'_fpi_DIStemp',data=['mms'+probe+'_fpi_DIStempPerp','mms'+probe+'_fpi_DIStempPara']
  endif else begin
    store_data,'mms'+probe+'_fpi_DIStemp',data={x:[trange],y:[[!values.f_nan,!values.f_nan],[!values.f_nan,!values.f_nan]]}
    ylim,'mms'+probe+'_fpi_DIStemp',5.d,50000.d,1
  endelse
  options,'mms'+probe+'_fpi_DIStemp',ylog=1,ytitle='MMS'+probe+'!Cfpi_'+dis_level+'!CiTemp',ysubtitle='[eV]',colors=[6,0],labels=['Perp','Para'],labflag=-1,datagap=dgap_i,ytickformat='mms_exponent2'
  if strlen(tnames('mms'+probe+'_fpi_DEStempPerp')) gt 0 or strlen(tnames('mms'+probe+'_fpi_DEStempPara')) gt 0 or strlen(tnames('mms'+probe+'_fpi_DIStempPerp')) gt 0 or strlen(tnames('mms'+probe+'_fpi_DIStempPara')) gt 0 then begin
    store_data,'mms'+probe+'_fpi_temp',data=['mms'+probe+'_fpi_DIStempPerp','mms'+probe+'_fpi_DIStempPara','mms'+probe+'_fpi_DEStempPerp','mms'+probe+'_fpi_DEStempPara']
  endif else begin
    store_data,'mms'+probe+'_fpi_temp',data={x:[trange],y:[[!values.f_nan,!values.f_nan],[!values.f_nan,!values.f_nan],[!values.f_nan,!values.f_nan],[!values.f_nan,!values.f_nan]]}
  endelse
  ylim,'mms'+probe+'_fpi_temp',5.d,50000.d,1
  options,'mms'+probe+'_fpi_temp',ylog=1,ytitle='MMS'+probe+'!CFPI_'+dis_level+'!CTemp',ysubtitle='[eV]',colors=[2,4,6,0],labels=['Ti_Perp','Ti_Para','Te_Perp','Te_Para'],labflag=-1,datagap=(dgap_i > dgap_e),ytickformat='mms_exponent2'

  if strlen(tnames('mms'+probe+'_fpi_bentPipeB_X_DSC')) gt 0 then begin
    options,'mms'+probe+'_fpi_bentPipeB_?_DSC',constant=0.0,datagap=10.5d
    store_data,'mms'+probe+'_fpi_bentPipeB_DSC',data=['mms'+probe+'_fpi_bentPipeB_X_DSC','mms'+probe+'_fpi_bentPipeB_Y_DSC','mms'+probe+'_fpi_bentPipeB_Z_DSC']
    options,'mms'+probe+'_fpi_bentPipeB_DSC',ytitle='MMS'+probe+'_FPI!CbentPipeB!CDSC',constant=0.0,colors=[2,4,6],labels=['B!DX!N_DSC','B!DY!N_DSC','B!DZ!N_DSC'],labflag=-1,datagap=10.5d
    ylim,'mms'+probe+'_fpi_bentPipeB_DSC',-1.0,1.0,0
  endif
  
  if not undefined(magplot) then begin
    mms_fgm_plot_kitamura,trange=trange,probe=probe,no_avg=no_avg,dfg_ql=dfg_ql,load_fgm=load_fgm,no_update=no_update_fgm,gsm=gsm,/no_plot
    tplot_options,'xmargin',[20,12]
    if strlen(tnames('mms'+probe+'_fgm_b_gse_srvy_l2')) eq 0 then begin
      if not undefined(gsm) then coord='gsm' else coord='gse'
      if strlen(tnames('mms'+probe+'_fpi_iBulkV_'+coord)) eq 0 then fpi_coord='DSC' else fpi_coord=coord
      tplot,['mms'+probe+'_fpi_eEnergySpectr_omni','mms'+probe+'_fpi_iEnergySpectr_omni','mms'+probe+'_fpi_numberDensity','mms'+probe+'_fpi_temp','mms'+probe+'_fpi_iBulkV_'+fpi_coord,'mms'+probe+'_fgm_b_'+coord+'_srvy_l2_bvec_avg','mms'+probe+'_fgm_b_'+coord+'_srvy_l2_btot']
    endif else begin
      if strlen(tnames('mms'+probe+'_dfg_srvy_l2pre_gse')) eq 0 then begin
        if not undefined(gsm) then begin
          fpi_coord='gsm'
          dfg_coord='gsm_dmpa'
        endif else begin
          fpi_coord='gse'
          dfg_coord='dmpa'
        endelse
        if strlen(tnames('mms'+probe+'_fpi_iBulkV_'+fpi_coord)) eq 0 then fpi_coord='DSC'
        tplot,['mms'+probe+'_fpi_eEnergySpectr_omni','mms'+probe+'_fpi_iEnergySpectr_omni','mms'+probe+'_fpi_numberDensity','mms'+probe+'_fpi_temp','mms'+probe+'_fpi_iBulkV_'+fpi_coord,'mms'+probe+'_dfg_srvy_'+dfg_coord+'_bvec_avg','mms'+probe+'_dfg_srvy_'+dfg_coord+'_btot']
      endif else begin
        if not undefined(gsm) then coord='gsm' else coord='gse'
        if strlen(tnames('mms'+probe+'_fpi_iBulkV_'+coord)) eq 0 then fpi_coord='DSC' else fpi_coord=coord
        tplot,['mms'+probe+'_fpi_eEnergySpectr_omni','mms'+probe+'_fpi_iEnergySpectr_omni','mms'+probe+'_fpi_numberDensity','mms'+probe+'_fpi_temp','mms'+probe+'_fpi_iBulkV_'+fpi_coord,'mms'+probe+'_dfg_srvy_l2pre_'+coord+'_bvec_avg','mms'+probe+'_dfg_srvy_l2pre_'+coord+'_btot']
      endelse
    endelse
  endif else begin
    if undefined(no_plot) then begin
      tplot_options,'xmargin',[20,12]
      tplot,['mms'+probe+'_fpi_eEnergySpectr_omni','mms'+probe+'_fpi_iEnergySpectr_omni','mms'+probe+'_fpi_numberDensity','mms'+probe+'_fpi_temp','mms'+probe+'_fpi_iBulkV_DSC','mms'+probe+'_fpi_bentPipeB_DSC']
    endif
  endelse

end
