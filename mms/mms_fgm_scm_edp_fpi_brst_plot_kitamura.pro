;+
; PROCEDURE:
;         mms_fgm_scm_edp_fpi_brst_plot_kitamura
;
; PURPOSE:
;         Plot magnetic field, wave spectrum, high energy electron data
;
; KEYWORDS:
;         trange:         time range of interest [starttime, endtime] with the format
;                         ['YYYY-MM-DD','YYYY-MM-DD'] or to specify more or less than a day
;                         ['YYYY-MM-DD/hh:mm:ss','YYYY-MM-DD/hh:mm:ss']
;                         if the format is 'YYYY-MM-DD' or 'YYYY-MM-DD/hh:mm:ss' (one element)
;                         the time range is set as from 30 minutes before the beginning of the
;                         ROI just after the specified time to 30 minutes after the end of the ROI.
;         probe:          a probe - value for MMS SC # (default value is '1')
;         load_fgm:       set this flag to load FGM data
;         no_feeps:       set this flag to skip plotting FEEPS data
;         no_eis:         set this flag to skip plotting EIS electron data
;         eis_pa_energy:  set this flag to plot EIS PA-t plot using specified energy range
;         feeps_pa_energy:set this flag to plot FEEPS PA-t plot using specified energy range
;         gsm:            set this flag to plot FGM(DFG) data in the GSM (or DMPA_GSM) coordinate
;         
;
; EXAMPLE:
;
;     MMS>  mms_fgm_scm_edp_fpi_brst_plot_kitamura,['2016-10-27/12:12:00','2016-10-27/12:21:00'],probe=probe,/gsm,/mag,/no_eis,/no_feeps,/delete,/png,nboxpoints=1024,nshiftpoints=512,freq_range=[30.d,300.d]
;
; NOTES:
;     1) See the notes in mms_load_data for rules on the use of MMS data
;     2) Information of version of the first cdf files is shown in the plot,
;        if multiple cdf files are loaded for FGM(DFG)
;-

pro mms_fgm_scm_edp_fpi_brst_plot_kitamura,trange,probe=probe,gsm=gsm,mag=mag,no_feeps=no_feeps,delete=delete,freq_range=freq_range,$
                                           no_eis=no_eis,eis_pa_energy=eis_pa_energy,feeps_pa_energy=feeps_pa_energy,no_waveform=no_waveform,$
                                           png=png,nboxpoints=nboxpoints,nshiftpoints=nshiftpoints,plot_freq_range=plot_freq_range,freq_linear=freq_linear

  loadct2,43
  time_stamp,/off
  
  if not undefined(delete) then store_data,'*',/delete
  if undefined(probe) then probe='1'
  if undefined(nboxpoints) then nboxpoints=1024
  probe=strcompress(string(probe),/remove_all)
  if undefined(plot_freq_range) then plot_freq_range=[10.d,3000.d]
  if undefined(freq_linear) then freq_log=1 else fleq_log=0
  if plot_freq_range[0] eq 0.d then freq_log=0

  dsp_data_rate='fast'
  if undefined(freq_range) then freq_range=25.d

  trange=time_double(trange)
  dt=trange[1]-trange[0]
  timespan,trange[0],dt,/seconds

  if undefined(gsm) then coord='gse' else coord='gsm'
  
  mms_load_fgm,trange=trange,instrument='fgm',probes=probe,data_rate='srvy',level='l2'

  if strlen(tnames('mms'+probe+'_fgm_b_gse_srvy_l2_bvec')) gt 0 then begin
    get_data,'mms'+probe+'_fgm_b_'+coord+'_srvy_l2_bvec',dlim=dl
    if n_elements(dl.cdf.gatt.data_version) gt 0 then begin
      fgm_dv=dl.cdf.gatt.data_version

      if strlen(tnames('mms'+probe+'_fgm_b_'+coord+'_srvy_l2_bvec')) gt 0 then begin
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
      endif

      get_data,'mms'+probe+'_fgm_b_'+coord+'_srvy_l2_btot',data=d
      fce=1.6022e-19*d.y*1.0e-9/(9.1094e-31*2.0*3.14159)
      fcp=1.6022e-19*d.y*1.0e-9/(1.6726e-27*2.0*3.14159)
      store_data,'mms'+probe+'_egyro',data={x:d.x,y:[[fce],[fce*0.5d]]}
      options,'mms'+probe+'_egyro',color_table=0,width=1,colors=[255,185]
      store_data,'mms'+probe+'_pgyro',data={x:d.x,y:fcp}
      options,'mms'+probe+'_pgyro',color=255,width=4

    endif
  endif else begin
    print
    print,'FGM data files are not found in this interval.'
    print
  endelse
      
  mms_load_mec,trange=trange,probes=probe

  if undefined(mag) then begin
    if strlen(tnames('mms'+probe+'_mec_r_'+coord)) gt 0 then begin
      tkm2re,'mms'+probe+'_mec_r_'+coord
      split_vec,'mms'+probe+'_mec_r_'+coord+'_re'
      options,'mms'+probe+'_mec_r_'+coord+'_re_x',ytitle=strupcase(coord)+'X [R!DE!N]',format='(f8.4)'
      options,'mms'+probe+'_mec_r_'+coord+'_re_y',ytitle=strupcase(coord)+'Y [R!DE!N]',format='(f8.4)'
      options,'mms'+probe+'_mec_r_'+coord+'_re_z',ytitle=strupcase(coord)+'Z [R!DE!N]',format='(f8.4)'
      tplot_options,var_label=['mms'+probe+'_mec_r_'+coord+'_re_z','mms'+probe+'_mec_r_'+coord+'_re_y','mms'+probe+'_mec_r_'+coord+'_re_x']
    endif
  endif else begin
    options,'mms'+probe+'_mec_mlat',ytitle='MLAT [deg]',format='(f7.3)'
    options,'mms'+probe+'_mec_mlt',ytitle='MLT [hour]',format='(f7.3)'
    options,'mms'+probe+'_mec_l_dipole',ytitle='Dipole L [R!DE!N]',format='(f7.3)'
    tplot_options,var_label=['mms'+probe+'_mec_l_dipole','mms'+probe+'_mec_mlt','mms'+probe+'_mec_mlat']
  endelse

  mms_load_dsp,trange=trange,probes=probe,datatype=['epsd','bpsd'],data_rate=dsp_data_rate,level='l2'
  store_data,'mms'+probe+'_dsp_epsd_x_gyro',data=['mms'+probe+'_dsp_epsd_x','mms'+probe+'_egyro','mms'+probe+'_pgyro']
  store_data,'mms'+probe+'_dsp_bpsd_scm1_'+dsp_data_rate+'_l2_gyro',data=['mms'+probe+'_dsp_bpsd_scm1_'+dsp_data_rate+'_l2','mms'+probe+'_egyro','mms'+probe+'_pgyro']
  options,['mms'+probe+'_dsp_epsd_x_gyro'],datagap=30.d,ytitle='MMS'+probe+'!CDSP_L2!CEx_wave',ysubtitle='[Hz]',ytickformat='mms_exponent2',ztitle='(V/m)!U2!N/Hz'
  options,['mms'+probe+'_dsp_bpsd_scm1_'+dsp_data_rate+'_l2_gyro'],datagap=30.d,ytitle='MMS'+probe+'!CDSP_L2!CB1_wave',ysubtitle='[Hz]',ytickformat='mms_exponent2',ztitle='nT!U2!N/Hz'
  store_data,'mms'+probe+'_dsp_epsd_y_gyro',data=['mms'+probe+'_dsp_epsd_y','mms'+probe+'_egyro','mms'+probe+'_pgyro']
  store_data,'mms'+probe+'_dsp_bpsd_scm2_'+dsp_data_rate+'_l2_gyro',data=['mms'+probe+'_dsp_bpsd_scm2_'+dsp_data_rate+'_l2','mms'+probe+'_egyro','mms'+probe+'_pgyro']
  options,['mms'+probe+'_dsp_epsd_y_gyro'],datagap=30.d,ytitle='MMS'+probe+'!CDSP_L2!CEy_wave',ysubtitle='[Hz]',ytickformat='mms_exponent2',ztitle='(V/m)!U2!N/Hz'
  options,['mms'+probe+'_dsp_bpsd_scm2_'+dsp_data_rate+'_l2_gyro'],datagap=30.d,ytitle='MMS'+probe+'!CDSP_L2!CB2_wave',ysubtitle='[Hz]',ytickformat='mms_exponent2',ztitle='nT!U2!N/Hz'
  store_data,'mms'+probe+'_dsp_epsd_z_gyro',data=['mms'+probe+'_dsp_epsd_z','mms'+probe+'_egyro','mms'+probe+'_pgyro']
  store_data,'mms'+probe+'_dsp_bpsd_scm3_'+dsp_data_rate+'_l2_gyro',data=['mms'+probe+'_dsp_bpsd_scm3_'+dsp_data_rate+'_l2','mms'+probe+'_egyro','mms'+probe+'_pgyro']
  options,['mms'+probe+'_dsp_epsd_z_gyro'],datagap=30.d,ytitle='MMS'+probe+'!CDSP_L2!CEz_wave',ysubtitle='[Hz]',ytickformat='mms_exponent2',ztitle='(V/m)!U2!N/Hz'
  options,['mms'+probe+'_dsp_bpsd_scm3_'+dsp_data_rate+'_l2_gyro'],datagap=30.d,ytitle='MMS'+probe+'!CDSP_L2!CB3_wave',ysubtitle='[Hz]',ytickformat='mms_exponent2',ztitle='nT!U2!N/Hz'
  options,'mms'+probe+'_dsp_epsd_?_gyro',ztitle='(V/m)!U2!N/Hz'
  options,'mms'+probe+'_dsp_bpsd_scm?_'+dsp_data_rate+'_l2_gyro',ztitle='nT!U2!N/Hz'
  ylim,['mms'+probe+'_dsp_epsd_?_gyro','mms'+probe+'_dsp_bpsd_scm?_'+dsp_data_rate+'_l2_gyro'],30.d,8000.d,1
  zlim,['mms'+probe+'_dsp_epsd_?_gyro'],1e-10,1e-4,1
  zlim,['mms'+probe+'_dsp_bpsd_scm?_'+dsp_data_rate+'_l2_gyro'],1e-10,1e-3,1

  if undefined(no_waveform) then begin
    mms_load_scm,trange=trange,probes=probe,datatype='scb',data_rate='brst',level='l2'
    cotrans_fac,trange,'mms'+probe+'_scm_acb_gse_scb_brst_l2','mms'+probe+'_fgm_b_gse_srvy_l2_bvec','mms'+probe+'_mec_r_gse',newname='mms'+probe+'_scm_acb_fac_scb_brst_l2'
    options,'mms'+probe+'_scm_acb_fac_scb_brst_l2',datagap=0.001d
    if n_elements(freq_range) eq 1 then begin
      thigh_pass_filter,'mms'+probe+'_scm_acb_fac_scb_brst_l2',1.d/freq_range,newname='mms'+probe+'_scm_acb_fac_scb_brst_l2_wave'
    endif else begin
      thigh_pass_filter,'mms'+probe+'_scm_acb_fac_scb_brst_l2',1.d/freq_range[0],newname='mms'+probe+'_scm_acb_fac_scb_brst_l2_0'
      thigh_pass_filter,'mms'+probe+'_scm_acb_fac_scb_brst_l2',1.d/freq_range[1],newname='mms'+probe+'_scm_acb_fac_scb_brst_l2_1'
      dif_data,'mms'+probe+'_scm_acb_fac_scb_brst_l2_0','mms'+probe+'_scm_acb_fac_scb_brst_l2_1',newname='mms'+probe+'_scm_acb_fac_scb_brst_l2_wave'
      store_data,['mms'+probe+'_scm_acb_fac_scb_brst_l2_0','mms'+probe+'_scm_acb_fac_scb_brst_l2_1'],/delete
    endelse
    options,'mms'+probe+'_scm_acb_fac_scb_brst_l2_wave',ytitle='MMS'+probe+'!CSCM_L2!Cwave!CFAC',ysubtitle='[nT]',constant=0.0,colors=[2,4,6],labels=['B!DX!N','B!DY!N','B!DZ!N'],labflag=-1
    tdpwrspc,'mms'+probe+'_scm_acb_fac_scb_brst_l2',nboxpoints=nboxpoints,nshiftpoints=nshiftpoints
    ylim,'mms'+probe+'_scm_acb_fac_scb_brst_l2_?_dpwrspc',plot_freq_range[0],plot_freq_range[1],freq_log
    zlim,'mms'+probe+'_scm_acb_fac_scb_brst_l2_?_dpwrspc',1e-10,1e-3,1
    options,'mms'+probe+'_scm_acb_fac_scb_brst_l2_?_dpwrspc',datagap=5.d
    store_data,'mms'+probe+'_scm_acb_fac_scb_brst_l2_x_dpwrspc_gyro',data=['mms'+probe+'_scm_acb_fac_scb_brst_l2_x_dpwrspc','mms'+probe+'_egyro','mms'+probe+'_pgyro']
    store_data,'mms'+probe+'_scm_acb_fac_scb_brst_l2_y_dpwrspc_gyro',data=['mms'+probe+'_scm_acb_fac_scb_brst_l2_y_dpwrspc','mms'+probe+'_egyro','mms'+probe+'_pgyro']
    store_data,'mms'+probe+'_scm_acb_fac_scb_brst_l2_z_dpwrspc_gyro',data=['mms'+probe+'_scm_acb_fac_scb_brst_l2_z_dpwrspc','mms'+probe+'_egyro','mms'+probe+'_pgyro']
    ylim,'mms'+probe+'_scm_acb_fac_scb_brst_l2_?_dpwrspc_gyro',plot_freq_range[0],plot_freq_range[1],freq_log
    options,'mms'+probe+'_scm_acb_fac_scb_brst_l2_x_dpwrspc_gyro',ytitle='MMS'+probe+'!CSCM_L2!CBx_wave',ysubtitle='[Hz]',ztickformat='mms_exponent2',ztitle='nT!U2!N/Hz'
    options,'mms'+probe+'_scm_acb_fac_scb_brst_l2_y_dpwrspc_gyro',ytitle='MMS'+probe+'!CSCM_L2!CBy_wave',ysubtitle='[Hz]',ztickformat='mms_exponent2',ztitle='nT!U2!N/Hz'
    options,'mms'+probe+'_scm_acb_fac_scb_brst_l2_z_dpwrspc_gyro',ytitle='MMS'+probe+'!CSCM_L2!CBz_wave',ysubtitle='[Hz]',ztickformat='mms_exponent2',ztitle='nT!U2!N/Hz'
    if freq_log eq 1 then options,'mms'+probe+'_scm_acb_fac_scb_brst_l2_?_dpwrspc_gyro',ytickformat='mms_exponent2'

    mms_load_edp,trange=trange,probes=probe,datatype='dce',data_rate='brst',level='l2'
    cotrans_fac,trange,'mms'+probe+'_edp_dce_gse_brst_l2','mms'+probe+'_fgm_b_gse_srvy_l2_bvec','mms'+probe+'_mec_r_gse',newname='mms'+probe+'_edp_dce_fac_brst_l2'
    options,'mms'+probe+'_edp_dce_fac_brst_l2',datagap=0.001d
    if n_elements(freq_range) eq 1 then begin
      thigh_pass_filter,'mms'+probe+'_edp_dce_fac_brst_l2',1.d/freq_range,newname='mms'+probe+'_edp_dce_fac_brst_l2_wave'
    endif else begin
      thigh_pass_filter,'mms'+probe+'_edp_dce_fac_brst_l2',1.d/freq_range[0],newname='mms'+probe+'_edp_dce_fac_brst_l2_0'
      thigh_pass_filter,'mms'+probe+'_edp_dce_fac_brst_l2',1.d/freq_range[1],newname='mms'+probe+'_edp_dce_fac_brst_l2_1'
      dif_data,'mms'+probe+'_edp_dce_fac_brst_l2_0','mms'+probe+'_edp_dce_fac_brst_l2_1',newname='mms'+probe+'_edp_dce_fac_brst_l2_wave'
      store_data,['mms'+probe+'_edp_dce_fac_brst_l2_0','mms'+probe+'_edp_dce_fac_brst_l2_1'],/delete
    endelse
    options,'mms'+probe+'_edp_dce_fac_brst_l2_wave',ytitle='MMS'+probe+'!CEDP_L2!Cwave!CFAC',ysubtitle='[mV/m]',constant=0.0,colors=[2,4,6],labels=['E!DX!N','E!DY!N','E!DZ!N'],labflag=-1
    tdpwrspc,'mms'+probe+'_edp_dce_fac_brst_l2',nboxpoints=nboxpoints,nshiftpoints=nshiftpoints
    ylim,'mms'+probe+'_edp_dce_fac_brst_l2_?_dpwrspc',plot_freq_range[0],plot_freq_range[1],freq_log
    zlim,'mms'+probe+'_edp_dce_fac_brst_l2_?_dpwrspc',1e-8,1e0,1
    options,'mms'+probe+'_edp_dce_fac_brst_l2_?_dpwrspc',datagap=5.d
    store_data,'mms'+probe+'_edp_dce_fac_brst_l2_x_dpwrspc_gyro',data=['mms'+probe+'_edp_dce_fac_brst_l2_x_dpwrspc','mms'+probe+'_egyro','mms'+probe+'_pgyro']
    store_data,'mms'+probe+'_edp_dce_fac_brst_l2_y_dpwrspc_gyro',data=['mms'+probe+'_edp_dce_fac_brst_l2_y_dpwrspc','mms'+probe+'_egyro','mms'+probe+'_pgyro']
    store_data,'mms'+probe+'_edp_dce_fac_brst_l2_z_dpwrspc_gyro',data=['mms'+probe+'_edp_dce_fac_brst_l2_z_dpwrspc','mms'+probe+'_egyro','mms'+probe+'_pgyro']
    ylim,'mms'+probe+'_edp_dce_fac_brst_l2_?_dpwrspc_gyro',plot_freq_range[0],plot_freq_range[1],freq_log
    options,'mms'+probe+'_edp_dce_fac_brst_l2_x_dpwrspc_gyro',ytitle='MMS'+probe+'!CEDP_L2!CEx_wave',ysubtitle='[Hz]',ztickformat='mms_exponent2',ztitle='(mV/m)!U2!N/Hz'
    options,'mms'+probe+'_edp_dce_fac_brst_l2_y_dpwrspc_gyro',ytitle='MMS'+probe+'!CEDP_L2!CEy_wave',ysubtitle='[Hz]',ztickformat='mms_exponent2',ztitle='(mV/m)!U2!N/Hz'
    options,'mms'+probe+'_edp_dce_fac_brst_l2_z_dpwrspc_gyro',ytitle='MMS'+probe+'!CEDP_L2!CEz_wave',ysubtitle='[Hz]',ztickformat='mms_exponent2',ztitle='(mV/m)!U2!N/Hz'
    if freq_log eq 1 then options,'mms'+probe+'_edp_dce_fac_brst_l2_?_dpwrspc_gyro',ytickformat='mms_exponent2'
    
    tinterpol_mxn,'mms'+probe+'_scm_acb_fac_scb_brst_l2_wave','mms'+probe+'_edp_dce_fac_brst_l2_wave',newname='mms'+probe+'_scm_acb_fac_scb_brst_l2_wave_interp'
    tcrossp,'mms'+probe+'_edp_dce_fac_brst_l2_wave','mms'+probe+'_scm_acb_fac_scb_brst_l2_wave_interp',newname='mms'+probe+'_pvect_E_fac_wave'
    get_data,'mms'+probe+'_pvect_E_fac_wave',data=pvect_temp
    pvect=pvect_temp.y*1e-6/(4.d*!pi*1e-7)
    store_data,'mms'+probe+'_pvect_E_fac_wave',data={x:pvect_temp.x,y:pvect}
    options,'mms'+probe+'_pvect_E_fac_wave',datagap=1.1d*(pvect_temp.x[1]-pvect_temp.x[0]),ytitle='mms'+probe+'!CPvector!Cfac_wave',ysubtitle='[!4l!xW m!U-2!N]',constant=0.0,colors=[2,4,6],labels=['x','y','z'],labflag=-1
    store_data,'mms'+probe+'_pvect_E_mag_fac_wave',data={x:pvect_temp.x,y:[[sqrt(pvect[*,0]*pvect[*,0]+pvect[*,1]*pvect[*,1])],[pvect[*,2]],[-1.d*pvect[*,2]]]}
    options,'mms'+probe+'_pvect_E_mag_fac_wave',datagap=1.1d*(pvect_temp.x[1]-pvect_temp.x[0]),ytitle='mms'+probe+'!CPvector!Cfac_wave',ysubtitle='[!4l!xW m!U-2!N]',ytickformat='mms_exponent2',colors=[4,0,6],labels=['perp','para','mpara'],labflag=-1
    ylim,'mms'+probe+'_pvect_E_mag_fac_wave',5e-4,5e0,1
    undefine,pvect,pvect_temp
   
  endif

  mms_fpi_plot_kitamura,trange=trange,probe=probe,/no_plot,/load_fpi
  store_data,'mms'+probe+'_fpi_numberDensity',data=['mms'+probe+'_fpi_DESnumberDensity','mms'+probe+'_fpi_DISnumberDensity']
  options,['mms'+probe+'_fpi_iBulkV_'+coord,'mms'+probe+'_fpi_temp','mms'+probe+'_fpi_numberDensity'],panel_size=0.75d,ylog=0

  mms_fpi_brst_plot_kitamura,trange=trange,probe=probe,/no_plot
  options,'mms'+probe+'_fpi_dis_des_numberDensity',ytitle='MMS'+probe+'!CFPI_L2!CNumber!CDensity',ysubtitle='[cm!U-3!N]',ylog=0,ynozero=1,ystyle=0
  options,'mms'+probe+'_fpi_dis_des_numberDensity','yrange'
  options,['mms'+probe+'_fpi_dis_des_numberDensity','mms'+probe+'_fpi_DISnumberDensity','mms'+probe+'_dis_numberdensity_brst','mms'+probe+'_fpi_DESnumberDensity','mms'+probe+'_des_numberdensity_brst'],'ytickformat'
  store_data,'mms'+probe+'_fpi_des_temp',data=['mms'+probe+'_des_temppara_fast','mms'+probe+'_des_tempperp_fast','mms'+probe+'_des_temppara_brst','mms'+probe+'_des_tempperp_brst']
  options,'mms'+probe+'_fpi_des_temp',ytitle='MMS'+probe+'!CDES_L2!CTemp',ysubtitle='[eV]',colors=[0,6,3,1],labels=['T!Dpara!N_fast','T!Dperp!N_fast','T!Dpara!N_brst','T!Dperp!N_brst'],labflag=-1,ynozero=1,ystyle=0
      
  if undefined(no_eis) then begin
    mms_load_eis,trange=trange,probes=probe,datatype=['electronenergy'],data_rate='srvy',level='l2',/no_interp
    ylim,'mms'+probe+'_epd_eis_electronenergy_electron_flux_omni_spin',40.d,400.d,1
    zlim,'mms'+probe+'_epd_eis_electronenergy_electron_flux_omni_spin',1.d,10000.d,1
    options,'mms'+probe+'_epd_eis_electronenergy_electron_flux_omni_spin',ztickformat='mms_exponent2',panel_size=0.75,datagap=600.d
    if not undefined(eis_pa_energy) then begin
      mms_eis_pad,probe=probe,trange=trange,data_rate='srvy',energy=eis_pa_energy,datatype='electronenergy'
      eis_en_range_string=strcompress(string(fix(eis_pa_energy[0])),/remove_all)+'-'+strcompress(string(fix(eis_pa_energy[1])),/remove_all)+'keV'
      ylim,'mms'+probe+'_epd_eis_electronenergy_'+eis_en_range_string+'_electron_flux_omni_pad*',0.d,180.d
      zlim,'mms'+probe+'_epd_eis_electronenergy_'+eis_en_range_string+'_electron_flux_omni_pad*',1.d,10000.d,1
      options,'mms'+probe+'_epd_eis_electronenergy_'+eis_en_range_string+'_electron_flux_omni_pad*',yticks=4,panel_size=0.75,ztickformat='mms_exponent2',ytitle='MMS'+probe+'!CEIS_L2!CElectron!C'+eis_en_range_string,ysubtitle='PAD [deg]',datagap=600.d
    endif
  endif
  if undefined(eis_en_range_string) then eis_en_range_string=''
  if undefined(no_feeps) then begin
    mms_load_feeps,trange=trange,probes=probe,datatype=['ion','electron'],data_rate='srvy',level='l2'
    ylim,'mms'+probe+'_epd_feeps_srvy_l2_ion_intensity_omni_spin',80.d,600.d,1
    zlim,'mms'+probe+'_epd_feeps_srvy_l2_ion_intensity_omni_spin',1.d,100000.d,1
    options,'mms'+probe+'_epd_feeps_srvy_l2_ion_intensity_omni_spin',yticks=3,ztickformat='mms_exponent2',panel_size=0.75,ytitle='MMS'+probe+'!CFEEPS_L2!CElectron!Cintensity!Comni',ysubtitle='[keV]',datagap=600.d
    ylim,'mms'+probe+'_epd_feeps_srvy_l2_electron_intensity_omni_spin',70.d,550.d,1
    zlim,'mms'+probe+'_epd_feeps_srvy_l2_electron_intensity_omni_spin',1.d,10000.d,1
    options,'mms'+probe+'_epd_feeps_srvy_l2_electron_intensity_omni_spin',yticks=3,ztickformat='mms_exponent2',panel_size=0.75,ytitle='MMS'+probe+'!CFEEPS_L2!CIon!Cintensity!Comni',ysubtitle='[keV]',datagap=600.d
    if not undefined(feeps_pa_energy) then begin
      mms_feeps_pad,probe=probe,data_rate='srvy',energy=feeps_pa_energy,datatype='electron'
      feeps_en_range_string=strcompress(string(fix(feeps_pa_energy[0])),/remove_all)+'-'+strcompress(string(fix(feeps_pa_energy[1])),/remove_all)+'keV'
      ylim,'mms'+probe+'_epd_feeps_srvy_l2_electron_intensity_'+feeps_en_range_string+'_pad*',0.d,180.d
      zlim,'mms'+probe+'_epd_feeps_srvy_l2_electron_intensity_'+feeps_en_range_string+'_pad*',1.d,10000.d,1
      options,'mms'+probe+'_epd_feeps_srvy_l2_electron_intensity_'+feeps_en_range_string+'_pad*',yticks=4,panel_size=0.75,ztickformat='mms_exponent2',ytitle='MMS'+probe+'!CFEEPS_L2!CElectron!C'+feeps_en_range_string,ysubtitle='PAD [deg]',datagap=600.d
    endif
  endif
  if undefined(feeps_en_range_string) then feeps_en_range_string=''

  spd_mms_load_bss,trange=trange,datatype=['fast','burst']
  calc,'"mms_bss_burst"="mms_bss_burst"-0.1d'
  store_data,'mms_bss',data=['mms_bss_fast','mms_bss_burst']
  options,'mms_bss',colors=[6,2],panel_size=0.2,thick=10.0,xstyle=4,ystyle=4,ticklen=0,yrange=[-0.125d,0.025d],ylabel='',labels=['Fast','Burst'],labflag=-1

  tplot_options,'xmargin',[18,10]
  if not undefined(no_waveform) then begin
;  tplot,['mms_bss','mms'+probe+'_fgm_b_'+coord+'_srvy_l2_mod','mms'+probe+'_dsp_epsd_x_gyro','mms'+probe+'_dsp_bpsd_scm1_'+dsp_data_rate+'_l2_gyro','mms'+probe+'_scm_acb_fac_scb_brst_l2_wave','mms'+probe+'_scm_acb_fac_scb_brst_l2_x_dpwrspc_gyro','mms'+probe+'_edp_dce_fac_brst_l2_x_dpwrspc_gyro','mms'+probe+'_epd_eis_electronenergy_'+eis_en_range_string+'_electron_flux_omni_pad','mms'+probe+'_epd_eis_electronenergy_electron_flux_omni_spin','mms'+probe+'_epd_feeps_srvy_l2_electron_intensity_'+feeps_en_range_string+'_pad_spin','mms'+probe+'_epd_feeps_srvy_l2_electron_intensity_omni_spin','mms'+probe+'_fpi_eEnergySpectr_omni_mix','mms'+probe+'_epd_feeps_srvy_l2_ion_intensity_omni_spin','mms'+probe+'_fpi_iEnergySpectr_omni_mix']
    tplot,['mms_bss','mms'+probe+'_fgm_b_'+coord+'_srvy_l2_mod','mms'+probe+'_dsp_epsd_x_gyro','mms'+probe+'_dsp_bpsd_scm1_'+dsp_data_rate+'_l2_gyro','mms'+probe+'_epd_eis_electronenergy_'+eis_en_range_string+'_electron_flux_omni_pad','mms'+probe+'_epd_eis_electronenergy_electron_flux_omni_spin','mms'+probe+'_epd_feeps_srvy_l2_electron_intensity_'+feeps_en_range_string+'_pad_spin','mms'+probe+'_epd_feeps_srvy_l2_electron_intensity_omni_spin','mms'+probe+'_fpi_eEnergySpectr_omni_mix','mms'+probe+'_epd_feeps_srvy_l2_ion_intensity_omni_spin','mms'+probe+'_fpi_iEnergySpectr_omni_mix','mms'+probe+'_fpi_iBulkV_'+coord,'mms'+probe+'_fpi_des_temp','mms'+probe+'_fpi_dis_des_numberDensity']
  endif else begin
    tplot,['mms_bss','mms'+probe+'_pvect_E_mag_fac_wave','mms'+probe+'_fgm_b_'+coord+'_srvy_l2_mod','mms'+probe+'_scm_acb_fac_scb_brst_l2_wave','mms'+probe+'_scm_acb_fac_scb_brst_l2_x_dpwrspc_gyro','mms'+probe+'_edp_dce_fac_brst_l2_wave','mms'+probe+'_edp_dce_fac_brst_l2_x_dpwrspc_gyro','mms'+probe+'_epd_eis_electronenergy_'+eis_en_range_string+'_electron_flux_omni_pad','mms'+probe+'_epd_eis_electronenergy_electron_flux_omni_spin','mms'+probe+'_epd_feeps_srvy_l2_electron_intensity_'+feeps_en_range_string+'_pad_spin','mms'+probe+'_epd_feeps_srvy_l2_electron_intensity_omni_spin','mms'+probe+'_fpi_eEnergySpectr_omni_mix','mms'+probe+'_epd_feeps_srvy_l2_ion_intensity_omni_spin','mms'+probe+'_fpi_iEnergySpectr_omni_mix','mms'+probe+'_fpi_iBulkV_'+coord,'mms'+probe+'_fpi_des_temp','mms'+probe+'_fpi_dis_des_numberDensity']
  endelse
  
  if undefined(no_output) and not undefined(png) then begin
    if n_elements(freq_range) eq 1 then freq_name='above'+strcompress(long(freq_range),/remove_all)+'Hz' else freq_name=strcompress(long(freq_range[0]),/remove_all)+'-'+strcompress(long(freq_range[1]),/remove_all)+'Hz'
    makepng,'mms'+probe+'_VLF_'+time_string(trange[0],format=2)+'_'+freq_name
  endif

  if undefined(no_output) and not undefined(plotdir) then begin
  
    if undefined(roi) then roi=trange
    ts=strsplit(time_string(time_double(roi[0]),format=3,precision=-2),/extract)
    dn=plotdir+'\'+ts[0]+'\'+ts[1]
    if ~file_test(dn) then file_mkdir,dn
  
    thisDevice=!D.NAME
    tplot_options,'charsize',0.75
    tplot_options,'xmargin',[18,10]

    if not undefined(full_bss) then options,'mms_bss',thick=10.0,panel_size=0.5 else options,'mms_bss',thick=10.0,panel_size=0.2
    options,'mms_bss','labsize'
    tplot_options,'tickinterval'
  
    start_time=time_double(time_string(roi[0],format=0,precision=-2))
    tplot_options,'tickinterval',300
    ts=strsplit(time_string(time_double(start_time),format=3,precision=-2),/extract)
    dn=plotdir+'\'+ts[0]+'\'+ts[1]
    if ~file_test(dn) then file_mkdir,dn
    set_plot,'ps'
    device,filename=dn+'\mms'+probe+'_VLF_'+time_string(start_time,format=2,precision=-2)+'_1hour.ps',xsize=40.0,ysize=30.0,/color,/encapsulated,bits=8
    tplot,trange=[start_time,time_double(time_string(start_time+3601.d,format=0,precision=-2))]
    device,/close
    set_plot,thisDevice
    !p.background=255
    !p.color=0
    if not undefined(full_bss) then options,'mms_bss',thick=5.0,panel_size=0.55,labsize=0.8 else options,'mms_bss',thick=5.0,panel_size=0.25,labsize=0.8
    window,xsize=1920,ysize=1080
    tplot,trange=[start_time,time_double(time_string(start_time+3601.d,format=0,precision=-2))]
    makepng,dn+'\mms'+probe+'_VLF_'+time_string(start_time,format=2,precision=-2)+'_1hour'
    if not undefined(full_bss) then options,'mms_bss',thick=10.0,panel_size=0.5 else options,'mms_bss',thick=10.0,panel_size=0.2
    options,'mms_bss','labsize'
    tplot_options,'tickinterval'
    tplot_options,'xmargin'
    tplot_options,'charsize'

  endif
 
end
