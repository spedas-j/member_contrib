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
;         no_short:     set this flag to skip short plots (1 or 2 hours)
;         no_update_fpi:set this flag to preserve the original FPI data. if not set and
;                       newer data is found the existing data will be overwritten 
;         no_update_fgm:set this flag to preserve the original FGM data. if not set and
;                       newer data is found the existing data will be overwritten
;         add_scpot:    set this flag to additionally plot scpot data with number densities
;         no_bss:       set this flag to skip loading bss data
;         full_bss:     set this flag to load detailed bss data (team member only)
;         no_load:      set this flag to skip loading data
;         dfg_ql:       set this flag to use DFG ql data forcibly. if not set, DFG l2pre data
;                       are used, if available (team member only)
;         no_output:    set this flag to skip making png and ps files
;         fpi_l1b:      set this flag to use FPI fast level-1b data if available. if not available,
;                       FPI fast ql data are used (team member only)
;         fpi_sitl:     set this flag to use FPI fast sitl data forcibly. if not set, FPI fast ql
;                       data are used, if available (team member only)
;         plotdir:      set this flag to assine a directory for plots
;         plotcdir:     set this flag to assine a directory for plots with currents
;         clmn:        set this flag to plot currents in the LMN coordinate (use with plotcdir)
;         gse:          set this flag to plot data in the GSE (or DMPA) coordinate
;         no_avg_fgm:   set this flag to skip making 2.5 sec averaged FGM(DFG) data
;         fom:          set this flag to plot FOMs (team member only)
;         day:          set this flag to use color scale for dayside regions
;         tail:         set this flag to use color scale for tail region
;
; EXAMPLE:
;
;     To make summary plots of fluxgate magnetometers (FGM (or DFG)) and fast plasma investigation (FPI) data
;      (normal use)
;        MMS>  mms_fpi_fgm_summary_kitamura,'2015-09-01/08:00:00','3',/delete,/add_scpot,/no_output,/no_avg_fgm
;        MMS>  mms_fpi_fgm_summary_kitamura,['2015-09-01/08:00:00','2015-09-02/00:00:00'],'3',/delete,/no_output,/add_scpot,/no_avg_fgm
;      (to check FOMs and status of data downlink)
;        MMS>  mms_fpi_fgm_summary_kitamura,'2015-09-01/08:00:00','3',/delete,/add_scpot,/no_output,/no_avg_fgm,/full_bss,/fom
;      (to check data in current SITL window)
;        MMS>  mms_fpi_fgm_summary_kitamura,'2015-09-01/08:00:00','3',/delete,/add_scpot,/no_output,/no_avg_fgm,/no_bss
;
; NOTES:
;     1) See the notes in mms_load_data for rules on the use of MMS data
;     2) Set plotdir before use if you output plots
;     3) Information of version of the first cdf files is shown in the plot,
;        if multiple cdf files are loaded for FGM(DFG) or FPI
;-

pro mms_fpi_fgm_summary_kitamura,trange,probe,delete=delete,no_short=no_short,no_update_fpi=no_update_fpi,no_update_fgm=no_update_fgm,$
                                 no_bss=no_bss,full_bss=full_bss,no_load=no_load,dfg_ql=dfg_ql,no_output=no_output,$
                                 add_scpot=add_scpot,no_update_edp=no_update_edp,edp_comm=edp_comm,fpi_l1b=fpi_l1b,fpi_sitl=fpi_sitl,$
                                 plotdir=plotdir,plotcdir=plotcdir,gse=gse,no_avg_fgm=no_avg_fgm,fom=fom,day=day,tail=tail,clmn=clmn,margin=margin

  probe=strcompress(string(probe),/remove_all)

  mms_init
  loadct2,43
  if not undefined(delete) then store_data,'*',/delete

  status=mms_login_lasp(login_info=login_info,username=username)
  if username eq '' or username eq 'public' then public=1 else public=0
  if undefined(gse) then coord='gsm' else coord='gse'

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
      if strlen(tnames('mms'+probe+'_fgm_b_gse_srvy_l2_bvec')) eq 0 then begin
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
        get_data,'mms'+probe+'_fgm_b_gse_srvy_l2_bvec',data=d
        if d.x[0] gt roi[1] or time_double(time_string(d.x[n_elements(d.x)-1]+1.d,format=0,precision=-3)) lt time_double(time_string(roi[1],format=0,precision=-3)) then begin
          print,time_string(d.x[n_elements(d.x)-1]+1.d,format=0)
          print,time_string(roi[1],format=0)
          store_data,'mms'+probe+'_fgm_*',/delete 
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
    if strlen(tnames('mms'+probe+'_fgm_b_gse_srvy_l2_bvec')) eq 0 and strlen(tnames('mms'+probe+'_dfg_b_gse_srvy_l2pre')) eq 0 then begin
      mms_load_fgm,trange=trange,instrument='dfg',probes=probe,data_rate='srvy',level='ql',no_update=no_update_fgm,versions=fgm_versions
      get_data,'mms'+probe+'_dfg_srvy_gsm_dmpa',data=fgm_data,dlimits=fgm_dlimits
      store_data,'mms'+probe+'_dfg_srvy_gsm_dmpa_bvec',data={x:fgm_data.x,y:[[fgm_data.y[*,0]],[fgm_data.y[*,1]],[fgm_data.y[*,2]]]},dlimits=fgm_dlimits
      store_data,'mms'+probe+'_dfg_srvy_gsm_dmpa_btot',data={x:fgm_data.x,y:fgm_data.y[*, 3]},dlimits=fgm_dlimits
      options,'mms'+probe+'_dfg_srvy*dmpa_btot',colors=1
      undefine,fgm_data,fgm_dlimits
    endif else begin
      if strlen(tnames('mms'+probe+'_fgm_b_gse_srvy_l2_bvec')) eq 0 then begin
        get_data,'mms'+probe+'_dfg_b_gse_srvy_l2pre',data=d
        if d.x[0] gt roi[1] or time_double(time_string(d.x[n_elements(d.x)-1]+1.d,format=0,precision=-3)) lt time_double(time_string(roi[1],format=0,precision=-3)) then begin
          print,time_string(d.x[n_elements(d.x)-1]+1.d,format=0)
          print,time_string(roi[1],format=0)
          store_data,'mms'+probe+'_dfg_b_*_srvy_l2pre',/delete
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
    if undefined(gse) then gsm=1
    mms_fpi_plot_kitamura,trange=[trange[0]-3600.d*2.d,trange[1]+3600.d*2.d],probe=probe,add_scpot=add_scpot,edp_comm=edp_comm,no_update_fpi=no_update_fpi,fpi_l1b=fpi_l1b,fpi_sitl=fpi_sitl,gsm=gsm,no_avg=no_avg_fgm,/load_fpi,/magplot
  endif else begin
    if undefined(gse) then gsm=1
    mms_fpi_plot_kitamura,trange=[trange[0]-3600.d*2.d,trange[1]+3600.d*2.d],probe=probe,add_scpot=add_scpot,edp_comm=edp_comm,fpi_l1b=fpi_l1b,fpi_sitl=fpi_sitl,gsm=gsm,no_avg=no_avg_fgm,/magplot
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

  if not undefined(tail) then begin
    zlim,'mms'+probe+'_fpi_iEnergySpectr_omni',3e3,1e6,1
    zlim,'mms'+probe+'_fpi_eEnergySpectr_omni',1e4,3e7,1
  endif
  if not undefined(day) then begin
    zlim,'mms'+probe+'_fpi_iEnergySpectr_omni',3e4,3e8,1
    zlim,'mms'+probe+'_fpi_eEnergySpectr_omni',3e5,3e9,1
  endif

  if strlen(tnames('mms'+probe+'_fpi_iBulkV_gsm')) eq 0 then ncoord='DSC' else ncoord='gsm'
  if not undefined(gse) and strlen(tnames('mms'+probe+'_fpi_iBulkV_gse')) gt 0 then ncoord='gse'

  fpi_set=['mms'+probe+'_fpi_eEnergySpectr_omni','mms'+probe+'_fpi_iEnergySpectr_omni','mms'+probe+'_fpi_numberDensity','mms'+probe+'_fpi_temp','mms'+probe+'_fpi_iBulkV_'+ncoord]
  print,fpi_set

  if strlen(tnames('mms'+probe+'_fgm_b_gsm_srvy_l2')) gt 0 then begin
;    tplot,['mms_bss','mms'+probe+'_fpi_eEnergySpectr_omni','mms'+probe+'_fpi_iEnergySpectr_omni','mms'+probe+'_fpi_numberDensity','mms'+probe+'_fpi_temp','mms'+probe+'_fpi_iBulkV_'+ncoord,'mms'+probe+'_fgm_b_'+coord+'_srvy_l2_bvec_avg','mms'+probe+'_fgm_b_'+coord+'_srvy_l2_btot']
    if undefined(no_avg_fgm) then fgm_set=['mms'+probe+'_fgm_b_'+coord+'_srvy_l2_bvec_avg','mms'+probe+'_fgm_b_'+coord+'_srvy_l2_btot'] else fgm_set=['mms'+probe+'_fgm_b_'+coord+'_srvy_l2_bvec','mms'+probe+'_fgm_b_'+coord+'_srvy_l2_btot']
  endif else begin
    if strlen(tnames('mms'+probe+'_dfg_b_gsm_srvy_l2pre')) gt 0 then begin
;      tplot,['mms_bss','mms'+probe+'_fpi_eEnergySpectr_omni','mms'+probe+'_fpi_iEnergySpectr_omni','mms'+probe+'_fpi_numberDensity','mms'+probe+'_fpi_temp','mms'+probe+'_fpi_iBulkV_'+ncoord,'mms'+probe+'_dfg_b_'+coord+'_srvy_l2pre_bvec_avg','mms'+probe+'_dfg_b_'+coord+'_srvy_l2pre_btot']
     if undefined(no_avg_fgm) then fgm_set=['mms'+probe+'_dfg_b_'+coord+'_srvy_l2pre_bvec_avg','mms'+probe+'_dfg_b_'+coord+'_srvy_l2pre_btot'] else fgm_set=['mms'+probe+'_dfg_b_'+coord+'_srvy_l2pre_bvec','mms'+probe+'_dfg_b_'+coord+'_srvy_l2pre_btot']
    endif else begin
      if not undefined(gse) then coord='dmpa' else coord='gsm_dmpa'
;      tplot,['mms_bss','mms'+probe+'_fpi_eEnergySpectr_omni','mms'+probe+'_fpi_iEnergySpectr_omni','mms'+probe+'_fpi_numberDensity','mms'+probe+'_fpi_temp','mms'+probe+'_fpi_iBulkV_'+ncoord,'mms'+probe+'_dfg_srvy_'+coord+'_bvec_avg','mms'+probe+'_dfg_srvy_'+coord+'_btot']
       if undefined(no_avg_fgm) then fgm_set=['mms'+probe+'_dfg_srvy_'+coord+'_bvec_avg','mms'+probe+'_dfg_srvy_'+coord+'_btot'] else fgm_set=['mms'+probe+'_dfg_srvy_'+coord+'_bvec','mms'+probe+'_dfg_srvy_'+coord+'_btot']
    endelse
  endelse

  if not undefined(fom) then begin
    spd_mms_load_bss,trange=trange,datatype='fom'
    options,'mms_bss_fom',colors=6,constant=[50.d,100.d,150.d,200.d,250.d],panel_size=0.66
    tplot,['mms_bss',fpi_set,fgm_set,'mms_bss_fom']
  endif else begin
    tplot,['mms_bss',fpi_set,fgm_set]
  endelse

  if undefined(no_output) and not undefined(plotdir) then begin
    
    if undefined(roi) then roi=trange
    ts=strsplit(time_string(time_double(roi[0]),format=3,precision=-2),/extract)
    dn=plotdir+'\'+ts[0]+'\'+ts[1]
    if ~file_test(dn) then file_mkdir,dn
    
    thisDevice=!D.NAME
    tplot_options,'charsize'
    tplot_options,'xmargin',[20,12]
    tplot_options,'ymargin'
    if roi[1]-roi[0] lt 18.d*3600.d then tplot_options,'tickinterval',3600
    set_plot,'ps'
    device,filename=dn+'\mms'+probe+'_fpi_ROI_'+time_string(roi[0],format=2,precision=0)+'.ps',xsize=60.0,ysize=30.0,/color,/encapsulated,bits=8
    tplot,trange=trange
    device,/close
    set_plot,thisDevice
    !p.background=255
    !p.color=0
    if not undefined(full_bss) then options,'mms_bss',thick=5.0,panel_size=0.55,labsize=0.8 else options,'mms_bss',thick=5.0,panel_size=0.25,labsize=0.8
    window,xsize=1600,ysize=900
    tplot_options,'ymargin',[2.5,0.2]
    tplot,trange=trange
    makepng,dn+'\mms'+probe+'_fpi_ROI_'+time_string(roi[0],format=2,precision=0)
    if not undefined(full_bss) then options,'mms_bss',thick=10.0,panel_size=0.5 else options,'mms_bss',thick=10.0,panel_size=0.2
    options,'mms_bss','labsize'
    tplot_options,'tickinterval'
    tplot_options,'ymargin'

    if undefined(no_short) then begin
      start_time=time_double(time_string(roi[0],format=0,precision=-2))-double(fix(ts[3]) mod 2)*3600.d
      tplot_options,'tickinterval',600
      while start_time lt roi[1] do begin
        ts=strsplit(time_string(time_double(start_time),format=3,precision=-2),/extract)
        dn=plotdir+'\'+ts[0]+'\'+ts[1]
        if ~file_test(dn) then file_mkdir,dn
        set_plot,'ps'
        device,filename=dn+'\mms'+probe+'_fpi_'+time_string(start_time,format=2,precision=-2)+'_2hours.ps',xsize=40.0,ysize=30.0,/color,/encapsulated,bits=8
        tplot,trange=[start_time,time_double(time_string(start_time+7201.d,format=0,precision=-2))]
        device,/close
        set_plot,thisDevice
        !p.background=255
        !p.color=0
        if not undefined(full_bss) then options,'mms_bss',thick=5.0,panel_size=0.55,labsize=0.8 else options,'mms_bss',thick=5.0,panel_size=0.25,labsize=0.8
        window,xsize=1600,ysize=900
        tplot_options,'ymargin',[2.5,0.2]
        tplot,trange=[start_time,time_double(time_string(start_time+7201.d,format=0,precision=-2))]
        makepng,dn+'\mms'+probe+'_fpi_'+time_string(start_time,format=2,precision=-2)+'_2hours'
        if not undefined(full_bss) then options,'mms_bss',thick=10.0,panel_size=0.5 else options,'mms_bss',thick=10.0,panel_size=0.2
        options,'mms_bss','labsize'
        tplot_options,'ymargin'
        start_time=time_double(time_string(start_time+7201.d,format=0,precision=-2))
      endwhile      
      tplot_options,'tickinterval'
    endif
    tplot_options,'xmargin'
  endif

  if undefined(no_output) and not undefined(plotcdir) then begin

    if undefined(roi) then roi=trange

    mms_curlometer,trange=[roi[0]-3600.d,roi[1]+3600.d],ref_probe=probe,data_rate='srvy',/gsm,/lmn
    if not undefined(gse) then begin
      mms_cotrans,'Current_gsm','Current_gse',in_coord='gsm',out_coord='gse',/ignore_dlimit
      options,'Current_gse',constant=0.0,ytitle='Current!CDensity!CGSE',ysubtitle='[nA/m!U2!N]',colors=[2,4,6],labels=['J!DX!N','J!DY!N','J!DZ!N'],labflag=-1,datagap=0.13d
      bt=dblarr(n_elements(b.x))
      get_data,'mms'+probe+'_b_for_curlometer',data=b
      for i=0l,n_elements(b.x)-1 do bt[i]=norm(reform(b.y[i,*]),/double)
      store_data,'mms'+probe+'_b_for_curlometer_tgse',data={x:b.x,y:[[bt],[b.y[*,0]],[b.y[*,1]],[b.y[*,2]]]}
      options,'mms'+probe+'_b_for_curlometer_tgse',constant=0.0,ytitle='MMS'+probe+'!CFGM_srvy!CGSE',ysubtitle='[nT]',colors=[0,2,4,6],labels=['|B|','B!DX!N','B!DY!N','B!DZ!N'],labflag=-1,datagap=0.13d
      undefine,b
    endif else begin
      get_data,'mms'+probe+'_b_for_curlometer_gsm',data=b
      bt=dblarr(n_elements(b.x))
      for i=0l,n_elements(b.x)-1 do bt[i]=norm(reform(b.y[i,*]),/double)
      store_data,'mms'+probe+'_b_for_curlometer_tgsm',data={x:b.x,y:[[bt],[b.y[*,0]],[b.y[*,1]],[b.y[*,2]]]}
      options,'mms'+probe+'_b_for_curlometer_tgsm',constant=0.0,ytitle='MMS'+probe+'!CFGM_srvy!CGSM',ysubtitle='[nT]',colors=[0,2,4,6],labels=['|B|','B!DX!N','B!DY!N','B!DZ!N'],labflag=-1,datagap=0.13d
      undefine,b      
    endelse
    if strlen(tnames('mms'+probe+'_fpi_iBulkV_gsm')) gt 0 then begin
      tinterpol_mxn,'mms_avg_pos_gsm','mms'+probe+'_fpi_iBulkV_gsm',newname='mms_avg_pos_gsm_ion'
      get_data,'mms_avg_pos_gsm_ion',data=pos
      get_data,'mms'+probe+'_fpi_iBulkV_gsm',data=vi_gsm,dlimit=dl
      gsm2lmn,[[pos.x],[pos.y[*,0]],[pos.y[*,1]],[pos.y[*,2]]],vi_gsm.y,vi_lmn
      store_data,'mms'+probe+'_fpi_iBulkV_lmn',data={x:vi_gsm.x,y:vi_lmn}
      if not undefined(fpi_sitl) then begin
        dis_level='SITL'
      endif else begin
        if dl.cdf.gatt.data_type ne 'fast_ql_dis' then dis_level='L2' else dis_level='QL'
      endelse
      undefine,pos,vi_gsm,vi_lmn,dl
    endif else begin
      dis_level='L2'
      store_data,'mms'+probe+'_fpi_iBulkV_gsm',data={x:[trange],y:[[!values.f_nan,!values.f_nan],[!values.f_nan,!values.f_nan],[!values.f_nan,!values.f_nan]]}
      store_data,'mms'+probe+'_fpi_iBulkV_gse',data={x:[trange],y:[[!values.f_nan,!values.f_nan],[!values.f_nan,!values.f_nan],[!values.f_nan,!values.f_nan]]}
      store_data,'mms'+probe+'_fpi_iBulkV_lmn',data={x:[trange],y:[[!values.f_nan,!values.f_nan],[!values.f_nan,!values.f_nan],[!values.f_nan,!values.f_nan]]}
      options,'mms'+probe+'_fpi_iBulkV_gsm',constant=0.0,ytitle='MMS'+probe+'!CFPI_'+dis_level+'!CIon!CBulkV_GSM',ysubtitle='[km/s]',colors=[2,4,6],labels=['V!DX!N','V!DY!N','V!DZ!N'],labflag=-1,datagap=4.6d
      options,'mms'+probe+'_fpi_iBulkV_gse',constant=0.0,ytitle='MMS'+probe+'!CFPI_'+dis_level+'!CIon!CBulkV_GSE',ysubtitle='[km/s]',colors=[2,4,6],labels=['V!DX!N','V!DY!N','V!DZ!N'],labflag=-1,datagap=4.6d
      ylim,'mms'+probe+'_fpi_iBulkV_???',-100.d,100.d
    endelse
    options,'mms'+probe+'_fpi_iBulkV_lmn',constant=0.0,ytitle='MMS'+probe+'!CFPI_'+dis_level+'!CIon!CBulkV_LMN',ysubtitle='[km/s]',colors=[2,4,6],labels=['V!DL!N','V!DM!N','V!DN!N'],labflag=-1,datagap=4.6d
    if not undefined(clmn) then begin
      tplot,['mms_bss','mms'+probe+'_fpi_eEnergySpectr_omni','mms'+probe+'_fpi_iEnergySpectr_omni','mms'+probe+'_fpi_numberDensity','mms'+probe+'_fpi_iBulkV_lmn','mms'+probe+'_b_for_curlometer_tlmn','Current_lmn','Current_magnitude','divB_over_rotB']
    endif else begin
      tplot,['mms_bss','mms'+probe+'_fpi_eEnergySpectr_omni','mms'+probe+'_fpi_iEnergySpectr_omni','mms'+probe+'_fpi_numberDensity','mms'+probe+'_fpi_iBulkV_'+coord,'mms'+probe+'_b_for_curlometer_t'+coord,'Current_'+coord,'Current_magnitude','divB_over_rotB']
    endelse

    thisDevice=!D.NAME
    start_time=time_double(time_string(roi[0],format=0,precision=-2))
    tplot_options,'tickinterval',300
    tplot_options,'xmargin',[20,12]
    while start_time lt roi[1] do begin
      ts=strsplit(time_string(time_double(start_time),format=3,precision=-2),/extract)
      dn=plotcdir+'\'+ts[0]+'\'+ts[1]
      if ~file_test(dn) then file_mkdir,dn
      set_plot,'ps'
      device,filename=dn+'\mms'+probe+'_fpi_current_'+time_string(start_time,format=2,precision=-2)+'_1hour.ps',xsize=40.0,ysize=30.0,/color,/encapsulated,bits=8
      tplot,trange=[start_time,time_double(time_string(start_time+3601.d,format=0,precision=-2))]
      device,/close
      set_plot,thisDevice
      !p.background=255
      !p.color=0
      if not undefined(full_bss) then options,'mms_bss',thick=5.0,panel_size=0.55,labsize=0.8 else options,'mms_bss',thick=5.0,panel_size=0.25,labsize=0.8
      window,xsize=1600,ysize=900
      tplot_options,'ymargin',[2.5,0.2]
      tplot,trange=[start_time,time_double(time_string(start_time+3601.d,format=0,precision=-2))]
      makepng,dn+'\mms'+probe+'_fpi_current_'+time_string(start_time,format=2,precision=-2)+'_1hour'
      if not undefined(full_bss) then options,'mms_bss',thick=10.0,panel_size=0.5 else options,'mms_bss',thick=10.0,panel_size=0.2
      options,'mms_bss','labsize'
      tplot_options,'ymargin'
      start_time=time_double(time_string(start_time+3601.d,format=0,precision=-2))
    endwhile
    tplot_options,'tickinterval'
    tplot_options,'xmargin'
  endif


end