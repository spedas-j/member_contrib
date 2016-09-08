;+
; PROCEDURE:
;         mms_fpi_fgm_hfesp_summary_kitamura
;
; PURPOSE:
;         Plot magnetic field (FGM (or DFG)), FPI, and high frequency electric field (EDP) data obtained by MMS
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
;         no_update_fpi:set this flag to preserve the original FPI data. if not set and
;                       newer data is found the existing data will be overwritten 
;         no_update_fgm:set this flag to preserve the original FGM data. if not set and
;                       newer data is found the existing data will be overwritten
;         add_scpot:    set this flag to additionally plot scpot data with number densities
;         no_bss:       set this flag to skip loading bss data
;         full_bss:     set this flag to load detailed bss data (team member only)
;         no_load:      set this flag to skip loading data
;         no_output:    set this flag to skip making png and ps files
;         no_update_edp:set this flag to preserve the original EDP data. if not set and
;                       newer data is found the existing data will be overwritten
;         edp_comm:     set this flag to use EDP comm data (team member only)
;         plotdir:      set this flag to assine a directory for plots
;
; EXAMPLE:
;
;     To make summary plots of fluxgate magnetometers (FGM (or DFG)), fast plasma investigation (FPI) and 
;     high frequency electric field wave data
;     team members
;     MMS>  mms_fpi_fgm_hfesp_summary_kitamura,'2015-09-01/08:00:00','3',/delete,/add_scpot,/no_output
;     public users
;     MMS>  mms_fpi_fgm_hfesp_summary_kitamura,['2015-09-01/08:00:00','2015-09-02/00:00:00'],'3',/delete,/add_scpot,/no_output
;
; NOTES:
;     1) See the notes in mms_load_data for rules on the use of MMS data
;     2) Set plotdir before use if you output plots
;     3) Information of version of the first cdf files is shown in the plot,
;        if multiple cdf files are loaded for FGM(DFG) or FPI
;-

pro mms_fpi_fgm_hfesp_summary_kitamura,trange,probe,delete=delete,no_short=no_short,no_update_fpi=no_update_fpi,no_update_fgm=no_update_fgm,$
                                       add_scpot=add_scpot,no_bss=no_bss,full_bss=full_bss,no_load=no_load,no_output=no_output,$
                                       no_update_edp=no_update_edp,edp_comm=edp_comm,plotdir=plotdir
                                       

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
      endif
    endif
    mms_fpi_plot_kitamura,trange=trange,probe=probe,add_scpot=add_scpot,no_update_edp=no_update_edp,edp_comm=edp_comm,no_update_fpi=no_update_fpi,/load_fpi,/magplot,/gsm
  endif else begin
    mms_fpi_plot_kitamura,trange=trange,probe=probe,add_scpot=add_scpot,no_update_edp=no_update_edp,edp_comm=edp_comm,/magplot,/gsm
  endelse
  
  if strlen(tnames('mms'+probe+'_fgm_b_gsm_srvy_l2_bvec')) ne 0 then begin
    get_data,'mms'+probe+'_fgm_b_gsm_srvy_l2_bvec',dlim=dl
    fgm_dv=dl.cdf.gatt.data_version
    options,'mms'+probe+'_fgm_b_gsm_srvy_l2_mod',constant=0.0,colors=[0,2,4,6],labels=['|B|','B!DX!N','B!DY!N','B!DZ!N'],ytitle='MMS'+probe+'!CFGM_L2!CGSM!Cv'+fgm_dv,ysubtitle='[nT]',labflag=-1,datagap=0.26d
  endif else begin
    if strlen(tnames('mms'+probe+'_fgm_b_gsm_srvy_l2_bvec')) ne 0 then begin
      get_data,'mms'+probe+'_dfg_b_gsm_srvy_l2pre_mod',dlim=dl
      fgm_dv=dl.cdf.gatt.data_version
      options,'mms'+probe+'_dfg_b_gsm_srvy_l2pre_mod',constant=0.0,colors=[0,2,4,6],labels=['|B|','B!DX!N','B!DY!N','B!DZ!N'],ytitle='MMS'+probe+'!CDFG_L2pre!CGSM!Cv'+fgm_dv,ysubtitle='[nT]',labflag=-1,datagap=0.26d
    endif
  endelse  
  
  get_data,'mms'+probe+'_dis_numberdensity_dbcs_fast',data=n_dis
  get_data,'mms'+probe+'_des_numberdensity_dbcs_fast',data=n_des
  store_data,'mms'+probe+'_dis_fp',data={x:n_dis.x,y:8979.d*sqrt(n_dis.y)}
  store_data,'mms'+probe+'_des_fp',data={x:n_des.x,y:8979.d*sqrt(n_des.y)}
  options,'mms'+probe+'_dis_fp',colors=255,thick=1.25,datagap=4.6d
  options,'mms'+probe+'_des_fp',colors=1,thick=1.25,datagap=4.6d
  
  mms_load_edp,trange=[trange[0]-60.d*300.d,trange[1]+60.d*300.d],probes=probe,level='l2',data_rate='srvy',datatype='hfesp'
  
  tplot_force_monotonic,'mms'+probe+'_edp_hfesp_srvy_l2',/forward
  get_data,'mms'+probe+'_edp_hfesp_srvy_l2',data=hfesp,lim=l,dlim=dl
  store_data,'mms'+probe+'_edp_hfesp_srvy_l2',data={x:hfesp.x,y:hfesp.y,v:hfesp.v[0:321]},lim=l,dlim=dl
  
  ylim,'mms'+probe+'_edp_hfesp_srvy_l2',0.d,6.e4,0
  zlim,'mms'+probe+'_edp_hfesp_srvy_l2',1e-11,1e-5,1
  options,'mms'+probe+'_edp_hfesp_srvy_l2',panel_size=2.0,ytitle='MMS'+probe+'!CEDP!CHF',ysubtitle='[Hz]',ztitle='(V/m)!U2!N Hz!U-1!N',ztickformat='mms_exponent2',datagap=20.d
  store_data,'mms'+probe+'_fp_hfesp',data=['mms'+probe+'_edp_hfesp_srvy_l2','mms'+probe+'_des_fp','mms'+probe+'_dis_fp']
  ylim,'mms'+probe+'_fp_hfesp',3e3,7e4,1
  options,'mms'+probe+'_fp_hfesp',panel_size=2.0,ytitle='MMS'+probe+'_EDP_HF!CFpe_DIS(White)!CFpe_DES(Magenta)',ysubtitle='[Hz]',ztitle='(V/m)!U2!N Hz!U-1!N',ztickformat='mms_exponent2',ytickformat='mms_exponent2'
  
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

  if strlen(tnames('mms'+probe+'_fgm_b_gsm_srvy_l2')) gt 0 then begin
    tplot,['mms_bss','mms'+probe+'_des_errorflags_fast_moms_flagbars','mms'+probe+'_fpi_eEnergySpectr_omni','mms'+probe+'_dis_errorflags_fast_moms_flagbars','mms'+probe+'_fpi_iEnergySpectr_omni','mms'+probe+'_fpi_numberDensity','mms'+probe+'_fp_hfesp','mms'+probe+'_fpi_iBulkV_gsm','mms'+probe+'_fgm_b_gsm_srvy_l2_mod']
  endif else begin
    tplot,['mms_bss','mms'+probe+'_des_errorflags_fast_moms_flagbars','mms'+probe+'_fpi_eEnergySpectr_omni','mms'+probe+'_dis_errorflags_fast_moms_flagbars','mms'+probe+'_fpi_iEnergySpectr_omni','mms'+probe+'_fpi_numberDensity','mms'+probe+'_fp_hfesp','mms'+probe+'_fpi_iBulkV_gsm','mms'+probe+'_dfg_b_gsm_srvy_l2pre_mod']
  endelse

  if undefined(no_output) and not undefined(plotdir) then begin
    
    get_data,'mms'+probe+'_fpi_eEnergySpectr_pX',dlim=dl
    fpiver=stregex(dl.cdf.gatt.logical_file_id,'v([0-9]+)\.([0-9]+)\.([0-9])',/extract)
    
    if undefined(roi) then roi=trange
    ts=strsplit(time_string(time_double(roi[0]),format=3,precision=-2),/extract)
    dn=plotdir+'\'+ts[0]+'\'+ts[1]
    if ~file_test(dn) then file_mkdir,dn
    
    thisDevice=!D.NAME
    tplot_options,'ymargin'
    tplot_options,'tickinterval',3600
    set_plot,'ps'
    device,filename=dn+'\mms'+probe+'_fpi_hfesp_ROI_'+time_string(roi[0],format=2,precision=0)+'_'+fpiver+'.ps',xsize=60.0,ysize=30.0,/color,/encapsulated,bits=8
    tplot,trange=trange
    device,/close
    set_plot,thisDevice
    !p.background=255
    !p.color=0
    if not undefined(full_bss) then options,'mms_bss',thick=5.0,panel_size=0.55,labsize=0.8 else options,'mms_bss',thick=5.0,panel_size=0.25,labsize=0.8
    window,xsize=1920,ysize=1080
    tplot_options,'ymargin',[2.5,0.2]
    tplot,trange=trange
    makepng,dn+'\mms'+probe+'_fpi_hfesp_ROI_'+time_string(roi[0],format=2,precision=0)+'_'+fpiver
    if not undefined(full_bss) then options,'mms_bss',thick=10.0,panel_size=0.5 else options,'mms_bss',thick=10.0,panel_size=0.2
    options,'mms_bss','labsize'
    tplot_options,'tickinterval'
    tplot_options,'ymargin'

    if undefined(no_short) then begin
      start_time=time_double(time_string(roi[0],format=0,precision=-2))-double(fix(ts[3]) mod 2)*3600.d
      tplot_options,'tickinterval',600
      while start_time lt roi[1] do begin
        set_plot,'ps'
        device,filename=dn+'\mms'+probe+'_fpi_hfesp_'+time_string(start_time,format=2,precision=-2)+'_'+fpiver+'_2hours.ps',xsize=40.0,ysize=30.0,/color,/encapsulated,bits=8
        tplot,trange=[start_time,start_time+2.d*3600.d]
        device,/close
        set_plot,thisDevice
        !p.background=255
        !p.color=0
        if not undefined(full_bss) then options,'mms_bss',thick=5.0,panel_size=0.55,labsize=0.8 else options,'mms_bss',thick=5.0,panel_size=0.25,labsize=0.8
        window,xsize=1920,ysize=1080
        tplot_options,'ymargin',[2.5,0.2]
        tplot,trange=[start_time,start_time+2.d*3600.d]
        makepng,dn+'\mms'+probe+'_fpi_hfesp_'+time_string(start_time,format=2,precision=-2)+'_'+fpiver+'_2hours'
        if not undefined(full_bss) then options,'mms_bss',thick=10.0,panel_size=0.5 else options,'mms_bss',thick=10.0,panel_size=0.2
        options,'mms_bss','labsize'
        tplot_options,'ymargin'
        start_time=start_time+2.d*3600.d
      endwhile      
      tplot_options,'tickinterval'
    endif
    
  endif

end