;+
; PROCEDURE:
;         mms_wavelet_spec_kitamura
;
; PURPOSE:
;         Plot wavelet spectra of magnetic and electric fields obtained by MMS
;
; KEYWORDS:
;         trange:       time range of interest [starttime, endtime] with the format
;                       ['YYYY-MM-DD','YYYY-MM-DD'] or to specify more or less than a day
;                       ['YYYY-MM-DD/hh:mm:ss','YYYY-MM-DD/hh:mm:ss']
;                       if the format is 'YYYY-MM-DD' or 'YYYY-MM-DD/hh:mm:ss' (one element)
;                       the time range is set as 2 hours (1 hour for slow survey or with 'short' flag).
;         probe:        a probe - value for MMS SC #
;         delete:       set this flag to delete all tplot variables at the beginning
;         ql:           set this flag to use DFG and EDP ql data forcibly (team member only)
;         gse:          set this flag to plot data in the GSE coordinate
;
; EXAMPLE:
;
;     To plot wavelet spectra of magnetic and electric fields
;     team members
;      (magnetic field only)
;        MMS> mms_wavelet_spec_kitamura,['2015-09-01/10:30:00','2015-09-01/12:46:32'],'1',freq_range=[0.d,0.4d],smooth_p=20.d,lowpass_p=5.d,Bspec_zrange=[1e-4,1e+2],min_powerB=1e+0,/fpi,/no_Ewave,/rad,/delete,/fft_filter
;        MMS> mms_wavelet_spec_kitamura,['2015-09-01/10:30:00','2015-09-01/12:46:32'],'1',freq_range=[0.d,0.4d],smooth_p=20.d,lowpass_p=5.d,Bspec_zrange=[1e-4,1e+2],min_powerB=1e+0,/fpi,/no_Ewave,/rad,/delete
;        MMS> mms_wavelet_spec_kitamura,['2015-09-01/10:00:00','2015-09-01/14:33:04'],'1',freq_range=[0.001d,0.3d],smooth_p=1200.d,lowpass_p=20.d,Bspec_zrange=[1e-3,1e+4],min_powerB=1e+1,/freq_log,/no_Ewave,/fpi,/rad,/delete
;
; NOTES:
;     See the notes in mms_load_data for rules on the use of MMS data
;-

; mms_wavelet_spec_kitamura,['2015-09-01/10:30:00','2015-09-01/12:46:32'],'1',freq_range=[0.d,0.4d],smooth_p=20.d,lowpass_p=5.d,Bspec_zrange=[1e-4,1e+2],min_powerB=1e+0,/fpi,/tail,/no_Ewave,/rad,/delete,/fft_filter
; mms_wavelet_spec_kitamura,['2015-09-01/11:30:00','2015-09-01/12:38:16'],'1',freq_range=[0.d,0.4d],smooth_p=20.d,lowpass_p=5.d,Bspec_zrange=[1e-4,1e+2],min_powerB=1e+0,Espec_zrange=[1e-4,1e+2],min_powerE=1e+0,/fpi,/tail,/rad,/delete,/fft_filter
; mms_wavelet_spec_kitamura,['2015-09-01/12:00:00','2015-09-01/12:34:08'],'1',freq_range=[0.d,0.5d],smooth_p=20.d,lowpass_p=5.d,Bspec_zrange=[1e-4,1e+2],min_powerB=1e+0,Espec_zrange=[1e-4,1e+2],min_powerE=1e+0,/fpi,/rad,/delete,/fft_filter
; mms_wavelet_spec_kitamura,['2015-09-01/10:00:00','2015-09-01/14:33:04'],'1',freq_range=[0.001d,0.2d],smooth_p=1200.d,lowpass_p=20.d,Bspec_zrange=[1e-3,1e+4],min_powerB=1e+1,Espec_zrange=[1e-3,1e+3],min_powerE=3e+0,/freq_log,/rad,/delete,/fft_filter
; mms_wavelet_spec_kitamura,'2015-10-01/04:00:00','3',freq_range=[0.d,1.d],smooth_p=15.d,lowpass_p=1.d,Bspec_zrange=[1e-4,1e+2],min_powerB=1e-2,Espec_zrange=[1e-4,1e+2],min_powerE=1e-2,/rad,/delete,/fft_filter,/pflux,/edp_slow,/mag

PRO mms_wavelet_spec_kitamura,trange,probe,delete=delete,freq_range=freq_range,freq_log=freq_log,rad=rad,no_load=no_load,tail=tail,$
                              smooth_p=smooth_p,lowpass_p=lowpass_p,no_Ewave=no_Ewave,fpi=fpi,fft_filter=fft_filter,full_bss=full_bss,$
                              gse=gse,min_powerB=min_powerB,Bspec_zrange=Bspec_zrange,min_powerE=min_powerE,Espec_zrange=Espec_zrange,$
                              pflux=pflux,edp_slow=edp_slow,mag=mag,short=short,ql=ql

  status=mms_login_lasp(login_info=login_info,username=username)
  if username eq '' or username eq 'public' then public=1 else public=0

  if not undefined(delete) then store_data,'*',/delete

  if n_elements(trange) eq 1 then begin
    if undefined(edp_slow) and undefined(short) then begin
      trange_new=[time_double(trange)-496.d,time_double(trange)+7696.d]
      trange=trange_new
      trange_new=[trange[0]+496.d,trange[1]-496.d]
    endif else begin
      trange_new=[time_double(trange)-248.d,time_double(trange)+3848.d]
      trange=trange_new
      trange_new=[trange[0]+248.d,trange[1]-248.d]
    endelse
  endif

  if undefined(gse) then coord='gsm' else coord='gsm'

  dt=time_double(trange[1])-time_double(trange[0])
  timespan,trange[0],dt,/seconds
  
  if undefined(no_load) then begin
    if undefined(ql) then begin
      mms_load_fgm,trange=trange,probes=probe,level='l2',data_rate='srvy',/time_clip
    endif else begin
      mms_load_fgm,trange=trange,probes=probe,level='ql',data_rate='srvy',instrument='dfg',/time_clip
    endelse
    mms_load_mec,trange=trange,probes=probe,data_rate='srvy',varformat=['mms'+probe+'_mec_r_eci','mms'+probe+'_mec_r_gse','mms'+probe+'_mec_r_gsm','mms'+probe+'_mec_L_vec','mms'+probe+'_mec_mlat','mms'+probe+'_mec_mlt','mms'+probe+'_mec_l_dipole']
    if strlen(tnames('mms'+probe+'_mec_mlat')) gt 0 then begin
      get_data,'mms'+probe+'_mec_mlat',data=mlat
      cdata=where(mlat.y ne 0.d, cdnum)
      if cdnum eq 0 or time_double(trange[0]) gt mlat.x[max(cdata)] then store_data,['mms'+probe+'_mec_r_eci','mms'+probe+'_mec_r_gse','mms'+probe+'_mec_r_gsm','mms'+probe+'_mec_L_vec','mms'+probe+'_mec_mlat','mms'+probe+'_mec_mlt','mms'+probe+'_mec_l_dipole'],/delete
      undefine,mlat
    endif
  endif

  if undefined(ql) then get_data,'mms'+probe+'_fgm_b_gse_srvy_l2_btot',data=Btot else get_data,'mms'+probe+'_dfg_srvy_dmpa_btot',data=Btot
  fp=1.6022e-19*Btot.y*1.0e-9/(1.6726e-27*2.0*3.14159)
  fh=fp/4.d
  fo=fp/16.d
  store_data,'mms'+probe+'_gyro',data={x:Btot.x,y:[[fp],[fh],[fo]]}
  options,'mms'+probe+'_gyro',color_table=0,width=2,colors=[255,220,185]
  store_data,'mms'+probe+'_gyro_bk',data={x:Btot.x,y:[[fp],[fh],[fo]]}
  options,'mms'+probe+'_gyro_bk',color_table=0,width=2,colors=[8,78,148]
  undefine,Btot,fp,fh,fo

  if strlen(tnames('mms'+probe+'_defatt_spinras')) eq 0 then begin
    mms_load_state,trange=trange,level='def',probes=probe,/attitude_only
    if strlen(tnames('mms'+probe+'_defatt_spinras')) eq 0 then begin
      mms_load_state,trange=trange,level='pred',probes=probe,/attitude_only
      store_data,'mms'+probe+'_predatt_spinras',newname='mms'+probe+'_defatt_spinras'
      store_data,'mms'+probe+'_predatt_spindec',newname='mms'+probe+'_defatt_spindec'
    endif
  endif
  
  if strlen(tnames('mms'+probe+'_mec_r_gse')) gt 0 then begin
    pos_name='mms'+probe+'_mec_r_gse'
  endif else begin
    split_vec,'mms'+probe+'_ql_pos_gse'
    join_vec,'mms'+probe+'_ql_pos_gse_'+['0','1','2'],'mms'+probe+'_ql_pos_gse_vec'
    store_data,'mms'+probe+'_ql_pos_gse_?',/delete
    pos_name='mms'+probe+'_ql_pos_gse_vec'
    if undefined(gse) then begin
      split_vec,'mms'+probe+'_ql_pos_gsm'
      join_vec,'mms'+probe+'_ql_pos_gsm_'+['0','1','2'],'mms'+probe+'_ql_pos_gsm_vec'
      store_data,'mms'+probe+'_ql_pos_gsm_?',/delete
    endif
  endelse
  
  if undefined(ql) then begin
    name_Bvec='mms'+probe+'_fgm_b_gse_srvy_l2_bvec'
    name_B='mms'+probe+'_fgm_b_'+coord+'_srvy_l2'
  endif else begin
    mms_cotrans,'mms'+probe+'_dfg_srvy_dmpa_bvec','mms'+probe+'_dfg_b_gse_srvy_ql_bvec',out_coord='gse',/allow_dmpa
    if undefined(gse) then mms_cotrans,'mms'+probe+'_dfg_b_gse_srvy_ql_bvec','mms'+probe+'_dfg_b_gsm_srvy_ql_bvec',out_coord='gsm'
    name_Bvec='mms'+probe+'_dfg_b_gse_srvy_ql_bvec'
    options,'mms'+probe+'_dfg_b_'+coord+'_srvy_ql_bvec',colors=[2,4,6]
    name_B='mms'+probe+'_dfg_b_'+coord+'_srvy_ql'
    store_data,name_B,data=['mms'+probe+'_dfg_b_'+coord+'_srvy_ql_bvec','mms'+probe+'_dfg_srvy_dmpa_btot']
    options,name_B,labflag=-1
  endelse

  if undefined(fft_filter) then begin
    tsmooth_in_time,name_Bvec,smooth_p,newname='mms'+probe+'_B0_gse'
    dif_data,name_Bvec,'mms'+probe+'_B0_gse',newname='mms'+probe+'_Bwave_gse'
    if not undefined(lowpass_p) then begin
      thigh_pass_filter,name_Bvec,lowpass_p,newname='mms'+probe+'_Bhigh_gse'
      dif_data,'mms'+probe+'_Bwave_gse','mms'+probe+'_Bhigh_gse',newname='mms'+probe+'_Bwave_gse'
    endif
  endif else begin
    tinterpol_mxn,pos_name,name_Bvec,newname='mms'+probe+'_r_gse_intpl'
    get_data,'mms'+probe+'_r_gse_intpl',data=pos
    get_data,name_Bvec,data=B
    fftBx=fft(B.y[*,0])
    fftBy=fft(B.y[*,1])
    fftBz=fft(B.y[*,2])
    fact=dblarr(n_elements(fftBx))
    fact[*]=1.d
    fact[floor(dt/smooth_p):(n_elements(fftBx)-1-floor(dt/smooth_p))]=0.d
    lowpassB=[[fft(fftBx*fact,/inverse)],[fft(fftBy*fact,/inverse)],[fft(fftBz*fact,/inverse)]]
    if not undefined(lowpass_p) then begin
      facthigh=dblarr(n_elements(fftBx))
      facthigh[*]=0.d
      facthigh[floor(dt/lowpass_p):(n_elements(fftBx)-1-floor(dt/lowpass_p))]=1.d
      highpassB=[[fft(fftBx*facthigh,/inverse)],[fft(fftBy*facthigh,/inverse)],[fft(fftBz*facthigh,/inverse)]]
      store_data,'mms'+probe+'_Bhigh_gse',data={x:B.x,y:highpassB}
      B.y=B.y-highpassB
      undefine,highpassB,facthigh
    endif
    store_data,'mms'+probe+'_B0_gse',data={x:B.x,y:lowpassB}
    B.y=B.y-lowpassB
    store_data,'mms'+probe+'_Bwave_gse',data=B
    undefine,lowpassB,fact
  endelse
  
  if undefined(rad) then begin
    newname_B='mms'+probe+'_b_fac_xgse_srvy_bvec'
    newname_Bwave='mms'+probe+'_Bwave_fac'
  endif else begin
    newname_B='mms'+probe+'_b_fac_rad_srvy_bvec'
    newname_Bwave='mms'+probe+'_Bwave_fac_rad'
  endelse

  cotrans_fac,trange,name_Bvec,'mms'+probe+'_B0_gse',pos_name,rad=rad,newname=newname_B,/output_fac
  cotrans_fac,trange,'mms'+probe+'_Bwave_gse','mms'+probe+'_B0_gse',pos_name,rad=rad,newname=newname_Bwave,/skip_fac_calc
  options,newname_B,constant=0.0,colors=[2,4,6],ysubtitle='[nT]',labels=['fac_B!DX!N','fac_B!DY!N','fac_B!DZ!N'],labflag=-1
  options,newname_Bwave,constant=0.0,colors=[2,4,6],ysubtitle='[nT]',labels=['fac_dB!DX!N','fac_dB!DY!N','fac_dB!DZ!N'],labflag=-1

  split_vec,newname_B
  join_vec,newname_B+['_x','_y'],newname_B+'_xy'
  
  if undefined(freq_range) then min_period=4.d else min_period=1.d/max(freq_range)
  wav_data,newname_B+'_x',trange=trange,maxpoints=2.d^21,prange=[min_period,smooth_p*2.d]
  wav_data,newname_B+'_y',trange=trange,maxpoints=2.d^21,prange=[min_period,smooth_p*2.d]
  wav_data,newname_B+'_z',trange=trange,maxpoints=2.d^21,prange=[min_period,smooth_p*2.d]
  wav_data,newname_B+'_xy',trange=trange,maxpoints=2.d^21,prange=[min_period,smooth_p*2.d]
  options,newname_B+'_xy_wv_pol_perp',color_table=70,reverse_color_table=1
  store_data,newname_B+'_x_wv_pow_gyro',data=[newname_B+'_x_wv_pow','mms'+probe+'_gyro']
  store_data,newname_B+'_y_wv_pow_gyro',data=[newname_B+'_y_wv_pow','mms'+probe+'_gyro']
  store_data,newname_B+'_z_wv_pow_gyro',data=[newname_B+'_z_wv_pow','mms'+probe+'_gyro']
  store_data,newname_B+'_xy_wv_pow_gyro',data=[newname_B+'_xy_wv_pow','mms'+probe+'_gyro']
  if not undefined(min_powerB) then begin
    copy_data,newname_B+'_xy_wv_pow',newname_B+'_xy_wv_mask'
    get_data,newname_B+'_xy_wv_mask',data=dm,lim=lim,dlim=dlim
    dm.y[where(dm.y gt min_powerB)]=!values.d_nan
    store_data,newname_B+'_xy_wv_mask',data=dm,lim=lim,dlim=dlim
    options,newname_B+'_xy_wv_mask',color_table=0,fill_color=123
    store_data,newname_B+'_xy_wv_pol_perp_gyro',data=[newname_B+'_xy_wv_pol_perp',newname_B+'_xy_wv_mask','mms'+probe+'_gyro_bk']
  endif else begin
    store_data,newname_B+'_xy_wv_pol_perp_gyro',data=[newname_B+'_xy_wv_pol_perp','mms'+probe+'_gyro_bk']
  endelse
  if undefined(freq_log) then ylog=0 else ylog=1
  if not undefined(freq_range) then ylim,newname_B+'_*_wv_*_gyro',freq_range[0],freq_range[1],ylog else options,newname_B+'_*_wv_*_gyro',ylog=ylog
  options,newname_B+'_xy_wv_pow_gyro',ytitle='mms'+probe+'!CBperp!Cpower',ysubtitle='f [Hz]',ztickformat='mms_exponent2',ztitle='[nT!U2!N/Hz]'
  options,newname_B+'_x_wv_pow_gyro',ytitle='mms'+probe+'!CBx!Cpower',ysubtitle='f [Hz]',ztickformat='mms_exponent2',ztitle='[nT!U2!N/Hz]'
  options,newname_B+'_y_wv_pow_gyro',ytitle='mms'+probe+'!CBy!Cpower',ysubtitle='f [Hz]',ztickformat='mms_exponent2',ztitle='[nT!U2!N/Hz]'
  options,newname_B+'_z_wv_pow_gyro',ytitle='mms'+probe+'!CBpara!Cpower',ysubtitle='f [Hz]',ztickformat='mms_exponent2',ztitle='[nT!U2!N/Hz]'
  options,newname_B+'_xy_wv_pol_perp_gyro',ytitle='mms'+probe+'!CBperp!Cpol',ysubtitle='f [Hz]',zrange=[-1.d,1.d]
  if not undefined(Bspec_zrange) then zlim,newname_B+'_*_wv_pow_gyro',Bspec_zrange[0],Bspec_zrange[1],1

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

  if strlen(tnames('mms'+probe+'_mec_r_'+coord)) gt 0 then begin
    tkm2re,'mms'+probe+'_mec_r_'+coord
    split_vec,'mms'+probe+'_mec_r_'+coord+'_re'
    options,'mms'+probe+'_mec_r_'+coord+'_re_x',ytitle=strupcase(coord)+'X [R!DE!N]',format='(f8.4)'
    options,'mms'+probe+'_mec_r_'+coord+'_re_y',ytitle=strupcase(coord)+'Y [R!DE!N]',format='(f8.4)'
    options,'mms'+probe+'_mec_r_'+coord+'_re_z',ytitle=strupcase(coord)+'Z [R!DE!N]',format='(f8.4)'
    tplot_options,var_label=['mms'+probe+'_mec_r_'+coord+'_re_z','mms'+probe+'_mec_r_'+coord+'_re_y','mms'+probe+'_mec_r_'+coord+'_re_x']
    if not undefined(mag) then begin
      options,'mms'+probe+'_mec_mlat',ytitle='MLAT [deg]',format='(f7.3)'
      options,'mms'+probe+'_mec_mlt',ytitle='MLT [hour]',format='(f7.3)'
      options,'mms'+probe+'_mec_l_dipole',ytitle='Dipole L [R!DE!N]',format='(f7.3)'
      tplot_options,var_label=['mms'+probe+'_mec_l_dipole','mms'+probe+'_mec_mlt','mms'+probe+'_mec_mlat']
    endif
  endif else begin
    tkm2re,'mms'+probe+'_ql_pos_'+coord+'_vec'
    split_vec,'mms'+probe+'_ql_pos_'+coord+'_vec_re'
    options,'mms'+probe+'_ql_pos_'+coord+'_vec_re_x',ytitle=strupcase(coord)+'X [R!DE!N]',format='(f8.4)'
    options,'mms'+probe+'_ql_pos_'+coord+'_vec_re_y',ytitle=strupcase(coord)+'Y [R!DE!N]',format='(f8.4)'
    options,'mms'+probe+'_ql_pos_'+coord+'_vec_re_z',ytitle=strupcase(coord)+'Z [R!DE!N]',format='(f8.4)'
    tplot_options,var_label=['mms'+probe+'_ql_pos_'+coord+'_vec_re_z','mms'+probe+'_ql_pos_'+coord+'_vec_re_y','mms'+probe+'_ql_pos_'+coord+'_vec_re_x']
  endelse


  if not undefined(no_Ewave) then begin
    
    tplot,['mms_bss',name_B,newname_Bwave,newname_B+'_z_wv_pow_gyro',newname_B+'_xy_wv_pow_gyro',newname_B+'_xy_wv_pol_perp_gyro']
;    tplot,[name_B,newname_Bwave,newname_B+'_?_wv_pow_gyro',newname_B+'_xy_wv_pow_gyro',newname_B+'_xy_wv_pol_perp_gyro']

  endif else begin
    
    if not undefined(edp_slow) then edp_data_rate='slow' else edp_data_rate='fast'
    if undefined(no_load) then begin
      if undefined(ql) then begin
        mms_load_edp,trange=trange,probes=probe,level='l2',data_rate=edp_data_rate,datatype='dce',/time_clip
      endif else begin
        mms_load_edp,trange=trange,probes=probe,level='ql',data_rate=edp_data_rate,datatype='dce',/time_clip
      endelse
    endif
    
    if undefined(ql) then begin
      name_Evec='mms'+probe+'_edp_dce_gse_'+edp_data_rate+'_l2'
    endif else begin
      mms_cotrans,'mms'+probe+'_edp_dce_xyz_dsl','mms'+probe+'_edp_dce_gse_'+edp_data_rate+'_ql',in_coord='dmpa',out_coord='gse',/ignore_dlimit,/allow_dmpa
      name_Evec='mms'+probe+'_edp_dce_gse_'+edp_data_rate+'_ql'
    endelse
    
    if undefined(fft_filter) then begin
      tsmooth_in_time,name_Evec,smooth_p,newname='mms'+probe+'_E0_gse'
      dif_data,name_Evec,'mms'+probe+'_E0_gse',newname='mms'+probe+'_Ewave_gse'
      if not undefined(lowpass_p) then begin
        thigh_pass_filter,name_Evec,lowpass_p,newname='mms'+probe+'_Ehigh_gse'
        dif_data,'mms'+probe+'_Ewave_gse','mms'+probe+'_Ehigh_gse',newname='mms'+probe+'_Ewave_gse'
      endif
    endif else begin
      tinterpol_mxn,pos_name,name_Evec,newname='mms'+probe+'_r_gse_intpl'
      get_data,'mms'+probe+'_r_gse_intpl',data=pos
      get_data,name_Evec,data=E
      fftEx=fft(E.y[*,0])
      fftEy=fft(E.y[*,1])
      fftEz=fft(E.y[*,2])
      fact=dblarr(n_elements(fftEx))
      fact[*]=1.d
      fact[floor(dt/smooth_p):(n_elements(fftEx)-1-floor(dt/smooth_p))]=0.d
      lowpassE=[[fft(fftEx*fact,/inverse)],[fft(fftEy*fact,/inverse)],[fft(fftEz*fact,/inverse)]]
      if not undefined(lowpass_p) then begin
        facthigh=dblarr(n_elements(fftEx))
        facthigh[*]=0.d
        facthigh[floor(dt/lowpass_p):(n_elements(fftEx)-1-floor(dt/lowpass_p))]=1.d
        highpassE=[[fft(fftEx*facthigh,/inverse)],[fft(fftEy*facthigh,/inverse)],[fft(fftEz*facthigh,/inverse)]]
        store_data,'mms'+probe+'_Ehigh_gse',data={x:E.x,y:highpassE}
        E.y=E.y-highpassE
        undefine,highpassE,facthigh
      endif
      store_data,'mms'+probe+'_E0_gse',data={x:E.x,y:lowpassE}
      E.y=E.y-lowpassE
      store_data,'mms'+probe+'_Ewave_gse',data=E
      undefine,lowpassE,fact
    endelse

    if undefined(rad) then begin
      newname_E='mms'+probe+'_edp_dce_fac_'+edp_data_rate
      newname_Ewave='mms'+probe+'_Ewave_fac'
    endif else begin
      newname_E='mms'+probe+'_edp_dce_fac_rad_'+edp_data_rate
      newname_Ewave='mms'+probe+'_Ewave_fac_rad'
    endelse

    cotrans_fac,trange,name_Evec,'mms'+probe+'_B0_gse',pos_name,rad=rad,newname=newname_E,/output_fac
    cotrans_fac,trange,'mms'+probe+'_Ewave_gse','mms'+probe+'_B0_gse',pos_name,rad=rad,newname=newname_Ewave,/skip_fac_calc
    options,newname_E,constant=0.0,colors=[2,4,6],ysubtitle='[mV m!U-1!N]',labels=['fac_E!DX!N','fac_E!DY!N','fac_E!DZ!N'],labflag=-1
    options,newname_Ewave,constant=0.0,colors=[2,4,6],ysubtitle='[mV m!U-1!N]',labels=['fac_dE!DX!N','fac_dE!DY!N','fac_dE!DZ!N'],labflag=-1

    split_vec,newname_E
    join_vec,newname_E+['_x','_y'],newname_E+'_xy'

    if undefined(freq_range) then min_period=4.d else min_period=1.d/max(freq_range)
    wav_data,newname_E+'_x',trange=trange,maxpoints=2.d^22,prange=[min_period,smooth_p*2.d]
    wav_data,newname_E+'_y',trange=trange,maxpoints=2.d^22,prange=[min_period,smooth_p*2.d]
    wav_data,newname_E+'_z',trange=trange,maxpoints=2.d^22,prange=[min_period,smooth_p*2.d]
    wav_data,newname_E+'_xy',trange=trange,maxpoints=2.d^22,prange=[min_period,smooth_p*2.d]
    options,newname_E+'_xy_wv_pol_perp',color_table=70,reverse_color_table=1
    store_data,newname_E+'_x_wv_pow_gyro',data=[newname_E+'_x_wv_pow','mms'+probe+'_gyro']
    store_data,newname_E+'_y_wv_pow_gyro',data=[newname_E+'_y_wv_pow','mms'+probe+'_gyro']
    store_data,newname_E+'_z_wv_pow_gyro',data=[newname_E+'_z_wv_pow','mms'+probe+'_gyro']
    store_data,newname_E+'_xy_wv_pow_gyro',data=[newname_E+'_xy_wv_pow','mms'+probe+'_gyro']
    if not undefined(min_powerE) then begin
      copy_data,newname_E+'_xy_wv_pow',newname_E+'_xy_wv_mask'
      get_data,newname_E+'_xy_wv_mask',data=dm,lim=lim,dlim=dlim
      dm.y[where(dm.y gt min_powerE)]=!values.d_nan
      store_data,newname_E+'_xy_wv_mask',data=dm,lim=lim,dlim=dlim
      options,newname_E+'_xy_wv_mask',color_table=0,fill_color=123
      store_data,newname_E+'_xy_wv_pol_perp_gyro',data=[newname_E+'_xy_wv_pol_perp',newname_E+'_xy_wv_mask','mms'+probe+'_gyro_bk']
    endif else begin
      store_data,newname_E+'_xy_wv_pol_perp_gyro',data=[newname_E+'_xy_wv_pol_perp','mms'+probe+'_gyro_bk']
    endelse
    if undefined(freq_log) then ylog=0 else ylog=1
    if not undefined(freq_range) then ylim,newname_E+'_*_wv_*_gyro',freq_range[0],freq_range[1],ylog else options,newname_E+'_*_wv_*_gyro',ylog=ylog
    options,newname_E+'_xy_wv_pow_gyro',ytitle='mms'+probe+'!CEperp!Cpower',ysubtitle='f [Hz]',ztickformat='mms_exponent2',ztitle='[(mV/m)!U2!N/Hz]'
    options,newname_E+'_x_wv_pow_gyro',ytitle='mms'+probe+'!CEx!Cpower',ysubtitle='f [Hz]',ztickformat='mms_exponent2',ztitle='[(mV/m)!U2!N/Hz]'
    options,newname_E+'_y_wv_pow_gyro',ytitle='mms'+probe+'!CEy!Cpower',ysubtitle='f [Hz]',ztickformat='mms_exponent2',ztitle='[(mV/m)!U2!N/Hz]'
    options,newname_E+'_z_wv_pow_gyro',ytitle='mms'+probe+'!CEz!Cpower',ysubtitle='f [Hz]',ztickformat='mms_exponent2',ztitle='[(mV/m)!U2!N/Hz]'
    options,newname_E+'_xy_wv_pol_perp_gyro',ytitle='mms'+probe+'!CEperp!Cpol',ysubtitle='f [Hz]',zrange=[-1.d,1.d]
    if not undefined(Espec_zrange) then zlim,newname_E+'_*_wv_pow_gyro',Espec_zrange[0],Espec_zrange[1],1

    if strlen(tnames(newname_Ewave)) gt 0 and not undefined(pflux) then begin
      tinterpol_mxn,newname_Bwave,newname_Ewave,newname=newname_Bwave+'_interp'
      if undefined(rad) then begin
        newname_pvect='mms'+probe+'_pvect_E_fac_hpfilt'
      endif else begin
        newname_pvect='mms'+probe+'_pvect_E_fac_rad_hpfilt'
      endelse
      tcrossp,newname_Ewave,newname_Bwave+'_interp',newname=newname_pvect
      get_data,newname_pvect,data=pvect_temp
      pvect=pvect_temp.y*1e-6/(4.d*!pi*1e-7)
      store_data,newname_pvect,data={x:pvect_temp.x,y:pvect}
      options,newname_pvect,datagap=1.1d*(pvect_temp.x[1]-pvect_temp.x[0]),ytitle='mms'+probe+'!CPvector!Cfac_hpfilt',ysubtitle='[!4l!xW m!U-2!N]',constant=0.0,colors=[2,4,6],labels=['x','y','z'],labflag=-1
    endif

    if undefined(newname_pvect) then newname_pvect=''
    
;    tplot,['mms_bss',name_B,newname_Bwave,newname_B+'_z_wv_pow_gyro',newname_B+'_xy_wv_pow_gyro',newname_B+'_xy_wv_pol_perp_gyro',newname_Ewave,newname_E+'_xy_wv_pow_gyro',newname_E+'_xy_wv_pol_perp_gyro']
    tplot,['mms_bss',newname_pvect,name_B,newname_Bwave,newname_B+'_z_wv_pow_gyro',newname_B+'_xy_wv_pow_gyro',newname_B+'_xy_wv_pol_perp_gyro',newname_Ewave,newname_E+'_xy_wv_pow_gyro',newname_E+'_xy_wv_pol_perp_gyro']
    
  endelse

  if not undefined(fpi) then begin
    if undefined(no_load) then mms_load_fpi,trange=trange,probes=probe,data_rate='fast',datatype=['dis-moms','des-moms']
    if strlen(tnames('mms'+probe+'_des_energyspectr_omni_fast')) eq 0 then store_data,'mms'+probe+'_des_energyspectr_omni_fast',data={x:[trange],y:[[!values.f_nan,!values.f_nan],[!values.f_nan,!values.f_nan]],v:[10.d,30000.d]}
    options,'mms'+probe+'_des_energyspectr_omni_fast',spec=1,ytitle='MMS'+probe+'_FPI!CElectron!Comni',ysubtitle='[eV]',datagap=dgap_e,ytickformat='mms_exponent2',ztitle='eV/(cm!U2!N s sr eV)',ztickformat='mms_exponent2'
    ylim,'mms'+probe+'_des_energyspectr_omni_fast',6.d,30000.d,1

    if strlen(tnames('mms'+probe+'_dis_energyspectr_omni_fast')) eq 0 then store_data,'mms'+probe+'_dis_energyspectr_omni_fast',data={x:[trange],y:[[!values.f_nan,!values.f_nan],[!values.f_nan,!values.f_nan]],v:[10.d,30000.d]}
    options,'mms'+probe+'_dis_energyspectr_omni_fast',spec=1,ytitle='MMS'+probe+'_FPI!CIon!Comni',ysubtitle='[eV]',datagap=dgap_i,ytickformat='mms_exponent2',ztitle='eV/(cm!U2!N s sr eV)',ztickformat='mms_exponent2'
    ylim,'mms'+probe+'_dis_energyspectr_omni_fast',2.d,30000.d,1
    
    if not undefined(tail) then begin
      zlim,'mms'+probe+'_dis_energyspectr_omni_fast',3e3,1e6,1
      zlim,'mms'+probe+'_des_energyspectr_omni_fast',1e4,3e7,1
    endif else begin
      zlim,'mms'+probe+'_dis_energyspectr_omni_fast',3e4,3e8,1
      zlim,'mms'+probe+'_des_energyspectr_omni_fast',3e5,3e9,1
    endelse  
    tplot,['mms'+probe+'_des_energyspectr_omni_fast','mms'+probe+'_dis_energyspectr_omni_fast'],add=2
  endif

  if not undefined(trange_new) then tlimit,trange_new[0],trange_new[1]
 
END
