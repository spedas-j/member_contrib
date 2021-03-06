;+
; PROCEDURE:
;         mms_fgm_plot_kitamura
;
; PURPOSE:
;         Plot magnetic field data obtained by MMS-FGM(DFG)
;
; KEYWORDS:
;         trange:       time range of interest [starttime, endtime] with the format
;                       ['YYYY-MM-DD','YYYY-MM-DD'] or to specify more or less than a day
;                       ['YYYY-MM-DD/hh:mm:ss','YYYY-MM-DD/hh:mm:ss']
;                       if the format is 'YYYY-MM-DD' or 'YYYY-MM-DD/hh:mm:ss' (one element)
;                       the time range is set as from 30 minutes before the beginning of the
;                       ROI just after the specified time to 30 minutes after the end of the ROI.
;         probe:        a probe - value for MMS SC # (default value is '1')
;         load_fgm:     set this flag to load FGM data
;         no_update:    set this flag to preserve the original FGM data. if not set and
;                       newer data is found the existing data will be overwritten
;         no_plot:      set this flag to skip plotting
;         no_avg:       set this flag to skip making 2.5 sec averaged FGM data
;         dfg_ql:       set this flag to use DFG ql data forcibly. if not set, DFG l2pre data
;                       is used, if available (team member only)
;         gsm:          set this flag to plot FGM(DFG) data in the GSM (or DMPA_GSM) coordinate
;
; EXAMPLE:
;
;     To plot data from fluxgate magnetometers (FGM)
;     MMS>  mms_fgm_plot_kitamura,trange=['2015-09-02/00:00:00','2015-09-03/00:00:00'],probe='1',/no_avg
;     MMS>  mms_fgm_plot_kitamura,trange=['2015-09-02/00:00:00','2015-09-03/00:00:00'],probe='1',/no_avg,/load_fgm,/no_update
;
; NOTES:
;     1) See the notes in mms_load_data for rules on the use of MMS data
;     2) FGM(DFG) data should be loaded before running this procedure or use load_fgm flag
;     3) Information of version of the first cdf files is shown in the plot,
;        if multiple cdf files are loaded for FGM(DFG)
;-

pro mms_fgm_plot_kitamura,trange=trange,probe=probe,load_fgm=load_fgm,no_plot=no_plot,no_avg=no_avg,no_update=no_update,dfg_ql=dfg_ql,gsm=gsm,margin=margin

  loadct2,43
  time_stamp,/off

  status=mms_login_lasp(login_info=login_info,username=username)
  if username eq '' or username eq 'public' then public=1 else public=0

  if undefined(probe) then probe='1'
  probe=strcompress(string(probe),/remove_all)
  if undefined(trange) then begin
    if strlen(tnames('mms'+probe+'_fgm_b_gse_srvy_l2')) gt 0 and undefined(dfg_ql) then begin
      get_data,'mms'+probe+'_fgm_b_gse_srvy_l2',data=d
    endif else begin
      if strlen(tnames('mms'+probe+'_dfg_b_gse_srvy_l2pre')) gt 0 and undefined(dfg_ql) then get_data,'mms'+probe+'_dfg_b_gse_srvy_l2pre',data=d else get_data,'mms'+probe+'_dfg_srvy_dmpa',data=d
    endelse
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
    trange=time_double(trange)
    if n_elements(trange) eq 1 then begin
      if public eq 0 and status eq 1 then begin
        roi=mms_get_roi(trange,/next)
      endif else begin
        mms_data_time_takada,[trange,trange+3.d*86400.d],rois,datatype='fast'
        i=0
        while trange gt time_double(rois[0,i]) do i=i+1
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
      roi=trange
    endelse
    dt=trange[1]-trange[0]
    timespan,trange[0],dt,/seconds
  endelse

  if not undefined(load_fgm) then begin
    if undefined(dfg_ql) then begin
      if undefined(gsm) then coord='gse' else coord='gsm' 
      mms_load_fgm,trange=trange,instrument='fgm',probes=probe,data_rate='srvy',level='l2',no_update=no_update,/no_attitude_data
      if strlen(tnames('mms'+probe+'_fgm_b_gse_srvy_l2')) eq 0 and public eq 0 then begin
        mms_load_fgm,trange=trange,instrument='dfg',probes=probe,data_rate='srvy',level='l2pre',no_update=no_update,/no_attitude_data
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
        if public eq 0 then begin
          get_data,'mms'+probe+'_fgm_b_gse_srvy_l2_bvec',data=d
          if d.x[0] gt roi[1] or time_double(time_string(d.x[n_elements(d.x)-1]+1.d,format=0,precision=-3)) lt time_double(time_string(roi[1],format=0,precision=-3)) then begin
            store_data,'mms'+probe+'_fgm_*',/delete
            mms_load_fgm,trange=trange,instrument='dfg',probes=probe,data_rate='srvy',level='l2pre',no_update=no_update,/no_attitude_data
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
        endif
      endelse
    endif
    if strlen(tnames('mms'+probe+'_fgm_b_gse_srvy_l2')) eq 0 and strlen(tnames('mms'+probe+'_dfg_b_gse_srvy_l2pre')) eq 0 and public eq 0 then begin
      mms_load_fgm,trange=trange,instrument='dfg',probes=probe,data_rate='srvy',level='ql',no_update=no_update,/no_attitude_data
      get_data,'mms'+probe+'_dfg_srvy_gsm_dmpa',data=fgm_data,dlimits=fgm_dlimits
      store_data,'mms'+probe+'_dfg_srvy_gsm_dmpa_bvec',data={x:fgm_data.X,y:[[fgm_data.Y[*,0]],[fgm_data.Y[*,1]],[fgm_data.Y[*,2]]]},dlimits=fgm_dlimits
      store_data,'mms'+probe+'_dfg_srvy_gsm_dmpa_btot',data={x:fgm_data.X,y:fgm_data.Y[*, 3]},dlimits=fgm_dlimits
      options,'mms'+probe+'_dfg_srvy*dmpa_btot',colors=1
      undefine,fgm_data,fgm_dlimits
      if undefined(gsm) then coord='dmpa' else coord='gsm_dmpa'
    endif else begin
      if strlen(tnames('mms'+probe+'_fgm_b_gse_srvy_l2')) eq 0 and public eq 0 then begin
        get_data,'mms'+probe+'_dfg_b_gse_srvy_l2pre',data=d
        if d.x[0] gt roi[1] or time_double(time_string(d.x[n_elements(d.x)-1]+1.d,format=0,precision=-3)) lt time_double(time_string(roi[1],format=0,precision=-3)) then begin
          store_data,'mms'+probe+'_dfg_b_*_srvy_l2pre*',/delete
          store_data,'mms'+probe+'_pos*',/delete
          mms_load_fgm,trange=trange,instrument='dfg',probes=probe,data_rate='srvy',level='ql',no_update=no_update,/no_attitude_data
          get_data,'mms'+probe+'_dfg_srvy_gsm_dmpa',data=fgm_data,dlimits=fgm_dlimits
          store_data,'mms'+probe+'_dfg_srvy_gsm_dmpa_bvec',data={x:fgm_data.X,y:[[fgm_data.Y[*,0]],[fgm_data.Y[*,1]],[fgm_data.Y[*,2]]]},dlimits=fgm_dlimits
          store_data,'mms'+probe+'_dfg_srvy_gsm_dmpa_btot',data={x:fgm_data.X,y:fgm_data.Y[*, 3]},dlimits=fgm_dlimits
          options,'mms'+probe+'_dfg_srvy*dmpa_btot',colors=1
          undefine,fgm_data,fgm_dlimits
          if undefined(gsm) then coord='dmpa' else coord='gsm_dmpa'
        endif
      endif
    endelse    
  endif else begin
    if strlen(tnames('mms'+probe+'_fgm_b_gse_srvy_l2')) gt 0 and undefined(dfg_ql) then begin
      if undefined(gsm) then coord='gse' else coord='gsm'
    endif else begin
      if strlen(tnames('mms'+probe+'_dfg_b_gse_srvy_l2pre')) gt 0 and undefined(dfg_ql) then begin
        if undefined(gsm) then coord='gse' else coord='gsm'
      endif else begin
        if undefined(gsm) then coord='dmpa' else coord='gsm_dmpa'
      endelse
    endelse
    
  endelse

  if strlen(tnames('mms'+probe+'_fgm_b_gse_srvy_l2_bvec')) gt 0 and undefined(dfg_ql) then begin
    get_data,'mms'+probe+'_fgm_b_'+coord+'_srvy_l2_bvec',dlim=dl
  endif else begin
    if strlen(tnames('mms'+probe+'_dfg_b_gse_srvy_l2pre')) gt 0 and undefined(dfg_ql) then begin
      get_data,'mms'+probe+'_dfg_b_'+coord+'_srvy_l2pre',dlim=dl
      level_name='b_'+coord+'_srvy_l2pre'
    endif else begin
      get_data,'mms'+probe+'_dfg_srvy_'+coord,dlim=dl
      level_name='srvy_'+coord
    endelse
  endelse
  
  if n_elements(dl.cdf.gatt.data_version) gt 0 then begin
    fgm_dv=dl.cdf.gatt.data_version
    
    if undefined(no_avg) then begin
      if strlen(tnames('mms'+probe+'_fgm_b_'+coord+'_srvy_l2_bvec')) gt 0 and undefined(dfg_ql) then begin
        avg_data,'mms'+probe+'_fgm_b_'+coord+'_srvy_l2_bvec',2.5d,trange=[time_double(time_string(trange[0],format=0,precision=-3)),time_double(time_string(trange[1],format=0,precision=-3))+24.d*3600.d]
        ncoord=strupcase(coord)
        options,'mms'+probe+'_fgm_b_'+coord+'_srvy_l2_bvec_avg',constant=0.0,colors=[2,4,6],labels=['B!DX!N','B!DY!N','B!DZ!N'],ytitle='MMS'+probe+'_FGM!CL2_'+ncoord+'!C2.5 sec!Caveraged',ysubtitle='[nT]',labflag=-1
      endif else begin
        if strlen(tnames('mms'+probe+'_dfg_b_'+coord+'_srvy_l2pre')) gt 0 and undefined(dfg_ql) then begin
          avg_data,'mms'+probe+'_dfg_b_'+coord+'_srvy_l2pre_bvec',2.5d,trange=[time_double(time_string(trange[0],format=0,precision=-3)),time_double(time_string(trange[1],format=0,precision=-3))+24.d*3600.d]
          ncoord=strupcase(coord)
          options,'mms'+probe+'_dfg_b_'+coord+'_srvy_l2pre_bvec_avg',constant=0.0,colors=[2,4,6],labels=['B!DX!N','B!DY!N','B!DZ!N'],ytitle='MMS'+probe+'_DFG!CL2pre_'+ncoord+'!C2.5 sec!Caveraged',ysubtitle='[nT]',labflag=-1
        endif else begin
          avg_data,'mms'+probe+'_dfg_srvy_'+coord+'_bvec',2.5d,trange=[time_double(time_string(trange[0],format=0,precision=-3)),time_double(time_string(trange[1],format=0,precision=-3))+24.d*3600.d]
          if coord eq 'dmpa' then ncoord='GSE' else ncoord='GSM'
          options,'mms'+probe+'_dfg_srvy_'+coord+'_bvec_avg',constant=0.0,colors=[2,4,6],labels=['B!DX!N','B!DY!N','B!DZ!N'],ytitle='MMS'+probe+'_DFG!C'+strupcase(coord)+'!C(near '+ncoord+')!C2.5 sec!Caveraged',ysubtitle='[nT]',labflag=-1
        endelse
      endelse
    endif else begin
      if strlen(tnames('mms'+probe+'_fgm_b_'+coord+'_srvy_l2_bvec')) gt 0 and undefined(dfg_ql) then begin
        ncoord=strupcase(coord)
      endif else begin
        if strlen(tnames('mms'+probe+'_dfg_srvy_l2pre_'+coord)) gt 0 and undefined(dfg_ql) then ncoord=strupcase(coord) else if coord eq 'dmpa' then ncoord='GSE' else ncoord='GSM'
      endelse
    endelse
    
    if strlen(tnames('mms'+probe+'_fgm_b_'+coord+'_srvy_l2_bvec')) gt 0 and undefined(dfg_ql) then begin
      options,'mms'+probe+'_fgm_b_gse_srvy_l2_bvec',constant=0.0,colors=[2,4,6],labels=['B!DX!N','B!DY!N','B!DZ!N'],ytitle='MMS'+probe+'!CFGM_L2!CGSE',ysubtitle='[nT]',labflag=-1,datagap=0.26d
      options,'mms'+probe+'_fgm_b_gse_srvy_l2_btot',ytitle='MMS'+probe+'!CFGM!CBtotal',ysubtitle='[nT]',labels='L2!C  v'+fgm_dv,labflag=-1,datagap=0.26d
      options,'mms'+probe+'_fgm_b_gse_srvy_l2',constant=0.0,colors=[2,4,6,0],labels=['B!DX!N','B!DY!N','B!DZ!N','|B|'],ytitle='MMS'+probe+'!CFGM_L2!CGSE',ysubtitle='[nT]',labflag=-1,datagap=0.26d
      get_data,'mms'+probe+'_fgm_b_gse_srvy_l2',data=b
      store_data,'mms'+probe+'_fgm_b_gse_srvy_l2_mod',data={x:b.x,y:[[b.y[*,3]],[b.y[*,0]],[b.y[*,1]],[b.y[*,2]]]}
      options,'mms'+probe+'_fgm_b_gse_srvy_l2_mod',constant=0.0,colors=[0,2,4,6],labels=['|B|','B!DX!N','B!DY!N','B!DZ!N'],ytitle='MMS'+probe+'!CFGM_L2!CGSE',ysubtitle='[nT]',labflag=-1,datagap=0.26d
      options,'mms'+probe+'_fgm_b_gsm_srvy_l2_bvec',constant=0.0,colors=[2,4,6],labels=['B!DX!N','B!DY!N','B!DZ!N'],ytitle='MMS'+probe+'!CFGM_L2!CGSM',ysubtitle='[nT]',labflag=-1,datagap=0.26d
      options,'mms'+probe+'_fgm_b_gsm_srvy_l2_btot',ytitle='MMS'+probe+'!CFGM!CBtotal',ysubtitle='[nT]',labels='L2!C  v'+fgm_dv,labflag=-1,datagap=0.26d
      options,'mms'+probe+'_fgm_b_gsm_srvy_l2',constant=0.0,colors=[2,4,6,0],labels=['B!DX!N','B!DY!N','B!DZ!N','|B|'],ytitle='MMS'+probe+'!CFGM_L2!CGSM',ysubtitle='[nT]',labflag=-1,datagap=0.26d
      get_data,'mms'+probe+'_fgm_b_gsm_srvy_l2',data=b
      store_data,'mms'+probe+'_fgm_b_gsm_srvy_l2_mod',data={x:b.x,y:[[b.y[*,3]],[b.y[*,0]],[b.y[*,1]],[b.y[*,2]]]}
      options,'mms'+probe+'_fgm_b_gsm_srvy_l2_mod',constant=0.0,colors=[0,2,4,6],labels=['|B|','B!DX!N','B!DY!N','B!DZ!N'],ytitle='MMS'+probe+'!CFGM_L2!CGSM',ysubtitle='[nT]',labflag=-1,datagap=0.26d
      options,'mms'+probe+'_fgm_b_dmpa_srvy_l2_bvec',constant=0.0,colors=[2,4,6],labels=['B!DX!N','B!DY!N','B!DZ!N'],ytitle='MMS'+probe+'!CFGM_L2!CDMPA!C(near GSE)',ysubtitle='[nT]',labflag=-1,datagap=0.26d
      options,'mms'+probe+'_fgm_b_dmpa_srvy_l2_btot',ytitle='MMS'+probe+'!CFGM!CBtotal',ysubtitle='[nT]',labels='L2!C  v'+fgm_dv,labflag=-1,datagap=0.26d
      options,'mms'+probe+'_fgm_b_dmpa_srvy_l2',constant=0.0,colors=[2,4,6,0],labels=['B!DX!N','B!DY!N','B!DZ!N','|B|'],ytitle='MMS'+probe+'!CFGM_L2!CDMPA!C(near GSE)',ysubtitle='[nT]',labflag=-1,datagap=0.26d
      get_data,'mms'+probe+'_fgm_b_dmpa_srvy_l2',data=b
      store_data,'mms'+probe+'_fgm_b_dmpa_srvy_l2_mod',data={x:b.x,y:[[b.y[*,3]],[b.y[*,0]],[b.y[*,1]],[b.y[*,2]]]}
      options,'mms'+probe+'_fgm_b_dmpa_srvy_l2_mod',constant=0.0,colors=[0,2,4,6],labels=['|B|','B!DX!N','B!DY!N','B!DZ!N'],ytitle='MMS'+probe+'!CFGM_L2!CDMPA',ysubtitle='[nT]',labflag=-1,datagap=0.26d
      undefine,b

      if strlen(tnames('mms'+probe+'_mec_r_'+strlowcase(ncoord))) eq 0 then mms_load_mec,trange=trange,probes=probe,no_update=no_update,varformat=['mms'+probe+'_mec_r_eci','mms'+probe+'_mec_r_gse','mms'+probe+'_mec_r_gsm','mms'+probe+'_mec_L_vec']

      if strlen(tnames('mms'+probe+'_mec_r_'+strlowcase(ncoord))) gt 0 then begin
        tkm2re,'mms'+probe+'_mec_r_'+strlowcase(ncoord)
        split_vec,'mms'+probe+'_mec_r_'+strlowcase(ncoord)+'_re'
        options,'mms'+probe+'_mec_r_'+strlowcase(ncoord)+'_re_x',ytitle=ncoord+'X [R!DE!N]',format='(f8.4)'
        options,'mms'+probe+'_mec_r_'+strlowcase(ncoord)+'_re_y',ytitle=ncoord+'Y [R!DE!N]',format='(f8.4)'
        options,'mms'+probe+'_mec_r_'+strlowcase(ncoord)+'_re_z',ytitle=ncoord+'Z [R!DE!N]',format='(f8.4)'
        tplot_options,var_label=['mms'+probe+'_mec_r_'+strlowcase(ncoord)+'_re_z','mms'+probe+'_mec_r_'+strlowcase(ncoord)+'_re_y','mms'+probe+'_mec_r_'+strlowcase(ncoord)+'_re_x']
      endif else begin
        tkm2re,'mms'+probe+'_fgm_r_'+strlowcase(ncoord)+'_srvy_l2'
        split_vec,'mms'+probe+'_fgm_r_'+strlowcase(ncoord)+'_srvy_l2_re'
        options,'mms'+probe+'_fgm_r_'+strlowcase(ncoord)+'_srvy_l2_re_0',ytitle=ncoord+'X [R!DE!N]',format='(f8.4)'
        options,'mms'+probe+'_fgm_r_'+strlowcase(ncoord)+'_srvy_l2_re_1',ytitle=ncoord+'Y [R!DE!N]',format='(f8.4)'
        options,'mms'+probe+'_fgm_r_'+strlowcase(ncoord)+'_srvy_l2_re_2',ytitle=ncoord+'Z [R!DE!N]',format='(f8.4)'
        ;  options,'mms'+probe+'_fgm_r_'+strlowcase(ncoord)+'_srvy_l2_re_3',ytitle='R [R!DE!N]',format='(f8.4)'
        ;  tplot_options, var_label=['mms'+probe+'_fgm_r_'+strlowcase(ncoord)+'_srvy_l2_re_3','mms'+probe+'_fgm_r_'+strlowcase(ncoord)+'_srvy_l2_re_2','mms'+probe+'_fgm_r_'+strlowcase(ncoord)+'_srvy_l2_re_1','mms'+probe+'_fgm_r_'+strlowcase(ncoord)+'_srvy_l2_re_0']
        tplot_options, var_label=['mms'+probe+'_fgm_r_'+strlowcase(ncoord)+'_srvy_l2_re_2','mms'+probe+'_fgm_r_'+strlowcase(ncoord)+'_srvy_l2_re_1','mms'+probe+'_fgm_r_'+strlowcase(ncoord)+'_srvy_l2_re_0']
      endelse

      if undefined(no_plot) then begin
        tplot_options,'xmargin',[15,10]
        tplot,['mms'+probe+'_fgm_b_gse_srvy_l2_btot','mms'+probe+'_fgm_b_gse_srvy_l2_bvec','mms'+probe+'_fgm_b_gse_srvy_l2_bvec_avg']
      endif

    endif else begin
      if strlen(tnames('mms'+probe+'_dfg_b_gse_srvy_l2pre')) gt 0 and undefined(dfg_ql) then begin
        options,'mms'+probe+'_dfg_b_gse_srvy_l2pre_bvec',constant=0.0,colors=[2,4,6],labels=['B!DX!N','B!DY!N','B!DZ!N'],ytitle='MMS'+probe+'_DFG!CL2pre_GSE',ysubtitle='[nT]',labflag=-1,datagap=0.26d
        options,'mms'+probe+'_dfg_b_gse_srvy_l2pre_btot',ytitle='MMS'+probe+'_DFG!CBtotal',ysubtitle='[nT]',labels='L2pre!C  v'+fgm_dv,labflag=-1,datagap=0.26d
        options,'mms'+probe+'_dfg_b_gse_srvy_l2pre',constant=0.0,colors=[2,4,6,0],labels=['B!DX!N','B!DY!N','B!DZ!N','|B|'],ytitle='MMS'+probe+'_DFG!CL2pre_GSE',ysubtitle='[nT]',labflag=-1,datagap=0.26d
        get_data,'mms'+probe+'_dfg_b_gse_srvy_l2pre',data=b
        store_data,'mms'+probe+'_dfg_b_gse_srvy_l2pre_mod',data={x:b.x,y:[[b.y[*,3]],[b.y[*,0]],[b.y[*,1]],[b.y[*,2]]]}
        options,'mms'+probe+'_dfg_b_gse_srvy_l2pre_mod',constant=0.0,colors=[0,2,4,6],labels=['|B|','B!DX!N','B!DY!N','B!DZ!N'],ytitle='MMS'+probe+'_DFG!CL2pre_GSE',ysubtitle='[nT]',labflag=-1,datagap=0.26d
        options,'mms'+probe+'_dfg_b_gsm_srvy_l2pre_bvec',constant=0.0,colors=[2,4,6],labels=['B!DX!N','B!DY!N','B!DZ!N'],ytitle='MMS'+probe+'_DFG!CL2pre_GSM',ysubtitle='[nT]',labflag=-1,datagap=0.26d
        options,'mms'+probe+'_dfg_b_gsm_srvy_l2pre_btot',ytitle='MMS'+probe+'_DFG!CBtotal',ysubtitle='[nT]',labels='L2pre!C  v'+fgm_dv,labflag=-1,datagap=0.26d
        options,'mms'+probe+'_dfg_b_gsm_srvy_l2pre',constant=0.0,colors=[2,4,6,0],labels=['B!DX!N','B!DY!N','B!DZ!N','|B|'],ytitle='MMS'+probe+'_DFG!CL2pre_GSM',ysubtitle='[nT]',labflag=-1,datagap=0.26d
        get_data,'mms'+probe+'_dfg_b_gsm_srvy_l2pre',data=b
        store_data,'mms'+probe+'_dfg_b_gsm_srvy_l2pre_mod',data={x:b.x,y:[[b.y[*,3]],[b.y[*,0]],[b.y[*,1]],[b.y[*,2]]]}
        options,'mms'+probe+'_dfg_b_gsm_srvy_l2pre_mod',constant=0.0,colors=[0,2,4,6],labels=['|B|','B!DX!N','B!DY!N','B!DZ!N'],ytitle='MMS'+probe+'_DFG!CL2pre_GSM',ysubtitle='[nT]',labflag=-1,datagap=0.26d
        options,'mms'+probe+'_dfg_b_dmpa_srvy_l2pre_bvec',constant=0.0,colors=[2,4,6],labels=['B!DX!N','B!DY!N','B!DZ!N'],ytitle='MMS'+probe+'_DFG!CL2pre_DMPA!C(near GSE)',ysubtitle='[nT]',labflag=-1,datagap=0.26d
        options,'mms'+probe+'_dfg_b_dmpa_srvy_l2pre_btot',ytitle='MMS'+probe+'_DFG!CBtotal',ysubtitle='[nT]',labels='L2pre!C  v'+fgm_dv,labflag=-1,datagap=0.26d
        options,'mms'+probe+'_dfg_b_dmpa_srvy_l2pre',constant=0.0,colors=[2,4,6,0],labels=['B!DX!N','B!DY!N','B!DZ!N','|B|'],ytitle='MMS'+probe+'_DFG!CL2pre_DMPA!C(near GSE)',ysubtitle='[nT]',labflag=-1,datagap=0.26d
        get_data,'mms'+probe+'_dfg_b_dmpa_srvy_l2pre',data=b
        store_data,'mms'+probe+'_dfg_b_dmpa_srvy_l2pre_mod',data={x:b.x,y:[[b.y[*,3]],[b.y[*,0]],[b.y[*,1]],[b.y[*,2]]]}
        options,'mms'+probe+'_dfg_b_dmpa_srvy_l2pre_mod',constant=0.0,colors=[0,2,4,6],labels=['|B|','B!DX!N','B!DY!N','B!DZ!N'],ytitle='MMS'+probe+'_DFG!CL2pre_DMPA',ysubtitle='[nT]',labflag=-1,datagap=0.26d
        undefine,b
      endif else begin
        options,'mms'+probe+'_dfg_srvy_dmpa_bvec',constant=0.0,colors=[2,4,6],labels=['B!DX!N','B!DY!N','B!DZ!N'],ytitle='MMS'+probe+'_DFG!CQL_DMPA!C(near GSE)',ysubtitle='[nT]',labflag=-1,datagap=0.26d
        options,'mms'+probe+'_dfg_srvy_dmpa_btot',ytitle='MMS'+probe+'_DFG!CBtotal',ysubtitle='[nT]',labels='QL!C  v'+fgm_dv,labflag=-1,datagap=0.26d
        options,'mms'+probe+'_dfg_srvy_dmpa',constant=0.0,colors=[2,4,6,0],labels=['B!DX!N','B!DY!N','B!DZ!N','|B|'],ytitle='MMS'+probe+'_DFG!CQL_DMPA!C(near GSE)',ysubtitle='[nT]',labflag=-1,datagap=0.26d
        get_data,'mms'+probe+'_dfg_srvy_dmpa',data=b
        store_data,'mms'+probe+'_dfg_srvy_dmpa_mod',data={x:b.x,y:[[b.y[*,3]],[b.y[*,0]],[b.y[*,1]],[b.y[*,2]]]}
        options,'mms'+probe+'_dfg_srvy_dmpa_mod',constant=0.0,colors=[0,2,4,6],labels=['|B|','B!DX!N','B!DY!N','B!DZ!N'],ytitle='MMS'+probe+'_DFG!CQL_DMPA!C(near GSE)',ysubtitle='[nT]',labflag=-1,datagap=0.26d
        options,'mms'+probe+'_dfg_srvy_gsm_dmpa_bvec',constant=0.0,colors=[2,4,6],labels=['B!DX!N','B!DY!N','B!DZ!N'],ytitle='MMS'+probe+'_DFG!CQL!CGSM_DMPA!C(near GSM)',ysubtitle='[nT]',labflag=-1,datagap=0.26d
        options,'mms'+probe+'_dfg_srvy_gsm_dmpa_btot',ytitle='MMS'+probe+'_DFG!CBtotal',ysubtitle='[nT]',labels='QL!C  v'+fgm_dv,labflag=-1,datagap=0.26d
        options,'mms'+probe+'_dfg_srvy_gsm_dmpa',constant=0.0,colors=[2,4,6,0],labels=['B!DX!N','B!DY!N','B!DZ!N','|B|'],ytitle='MMS'+probe+'_DFG!CQLQL!CGSM_DMPA!C(near GSM)',ysubtitle='[nT]',labflag=-1,datagap=0.26d
        get_data,'mms'+probe+'_dfg_srvy_gsm_dmpa',data=b
        store_data,'mms'+probe+'_dfg_srvy_gsm_dmpa_mod',data={x:b.x,y:[[b.y[*,3]],[b.y[*,0]],[b.y[*,1]],[b.y[*,2]]]}
        options,'mms'+probe+'_dfg_srvy_gsm_dmpa_mod',constant=0.0,colors=[0,2,4,6],labels=['|B|','B!DX!N','B!DY!N','B!DZ!N'],ytitle='MMS'+probe+'_DFG!CQLQL!CGSM_DMPA!C(near GSM)',ysubtitle='[nT]',labflag=-1,datagap=0.26d
        undefine,b
      endelse
  
      if strlen(tnames('mms'+probe+'_dfg_b_gse_srvy_l2pre')) gt 0 and undefined(dfg_ql) then ql_name='' else ql_name='_ql' 

      if strlen(tnames('mms'+probe+'_mec_r_'+strlowcase(ncoord))) eq 0 then mms_load_mec,trange=trange,probes=probe,no_update=no_update,varformat=['mms'+probe+'_mec_r_eci','mms'+probe+'_mec_r_gse','mms'+probe+'_mec_r_gsm','mms'+probe+'_mec_L_vec']
      if strlen(tnames('mms'+probe+'_mec_r_'+strlowcase(ncoord))) gt 0 then begin
        time_clip,'mms'+probe+'_mec_r_'+strlowcase(ncoord),trange[0],trange[1],newname='mms'+probe+'_mec_r_'+strlowcase(ncoord)+'_temp'
        get_data,'mms'+probe+'_mec_r_'+strlowcase(ncoord)+'_temp',data=d_temp
        if finite(d_temp.y[n_elements(d_temp.x)-1l,0],/nan) eq 1 then begin
          store_data,['mms'+probe+'_mec_r_eci','mms'+probe+'_mec_r_gse','mms'+probe+'_mec_r_gsm','mms'+probe+'_mec_L_vec','mms'+probe+'_defatt_spin???'],/delete
        endif  
        store_data,'mms'+probe+'_mec_r_'+strlowcase(ncoord)+'_temp',/delete
        undefine,d_temp
      endif  

      if strlen(tnames('mms'+probe+'_mec_r_'+strlowcase(ncoord))) gt 0 then begin
        tkm2re,'mms'+probe+'_mec_r_'+strlowcase(ncoord)
        split_vec,'mms'+probe+'_mec_r_'+strlowcase(ncoord)+'_re'
        options,'mms'+probe+'_mec_r_'+strlowcase(ncoord)+'_re_x',ytitle=ncoord+'X [R!DE!N]',format='(f8.4)'
        options,'mms'+probe+'_mec_r_'+strlowcase(ncoord)+'_re_y',ytitle=ncoord+'Y [R!DE!N]',format='(f8.4)'
        options,'mms'+probe+'_mec_r_'+strlowcase(ncoord)+'_re_z',ytitle=ncoord+'Z [R!DE!N]',format='(f8.4)'
        tplot_options,var_label=['mms'+probe+'_mec_r_'+strlowcase(ncoord)+'_re_z','mms'+probe+'_mec_r_'+strlowcase(ncoord)+'_re_y','mms'+probe+'_mec_r_'+strlowcase(ncoord)+'_re_x']
      endif else begin
        tkm2re,'mms'+probe+ql_name+'_pos_'+strlowcase(ncoord)
        split_vec,'mms'+probe+ql_name+'_pos_'+strlowcase(ncoord)+'_re'
        options,'mms'+probe+ql_name+'_pos_'+strlowcase(ncoord)+'_re_0',ytitle=ncoord+'X [R!DE!N]',format='(f8.4)'
        options,'mms'+probe+ql_name+'_pos_'+strlowcase(ncoord)+'_re_1',ytitle=ncoord+'Y [R!DE!N]',format='(f8.4)'
        options,'mms'+probe+ql_name+'_pos_'+strlowcase(ncoord)+'_re_2',ytitle=ncoord+'Z [R!DE!N]',format='(f8.4)'
        ;  options,'mms'+probe+ql_name+'_pos_'+coord+'_re_3',ytitle='R [R!DE!N]',format='(f8.4)'
        ;  tplot_options, var_label=['mms'+probe+ql_name+'_pos_'+strlowcase(ncoord)+'_re_3','mms'+probe+ql_name+'_pos_'+strlowcase(ncoord)+'_re_2','mms'+probe+ql_name+'_pos_'+strlowcase(ncoord)+'_re_1','mms'+probe+ql_name+'_pos_'+strlowcase(ncoord)+'_re_0']
        tplot_options, var_label=['mms'+probe+ql_name+'_pos_'+strlowcase(ncoord)+'_re_2','mms'+probe+ql_name+'_pos_'+strlowcase(ncoord)+'_re_1','mms'+probe+ql_name+'_pos_'+strlowcase(ncoord)+'_re_0']
      endelse

      if undefined(no_plot) then begin
        tplot_options,'xmargin',[15,10]
        tplot,['mms'+probe+'_dfg_'+level_name+'_btot','mms'+probe+'_dfg_'+level_name+'_bvec','mms'+probe+'_dfg_'+level_name+'_bvec_avg']
      endif
    endelse
      
  endif else begin
    print
    print,'FGM/DFG data files are not found in this interval.'
    print
  endelse

end
