;+
; PROCEDURE:
;         mms_fgm_dsp_feeps_eis_plot_kitamura
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
;         no_plot:      set this flag to skip plotting
;         no_avg:       set this flag to skip making 2.5 sec averaged FGM data
;         dfg_ql:       set this flag to use DFG ql data forcibly. if not set, DFG l2pre data
;                       is used, if available (team member only)
;         gsm:          set this flag to plot FGM(DFG) data in the GSM (or DMPA_GSM) coordinate
;
; EXAMPLE:
;
;     To plot data from fluxgate magnetometers (FGM)
;     MMS>  mms_fgm_dsp_feeps_eis_plot_kitamura,trange=['2015-09-02/00:00:00','2015-09-03/00:00:00'],probe='1',/no_avg
;     MMS>  mms_fgm_dsp_feeps_eis_plot_kitamura,trange=['2015-09-02/00:00:00','2015-09-03/00:00:00'],probe='1',/no_avg,/load_fgm
;
; NOTES:
;     1) See the notes in mms_load_data for rules on the use of MMS data
;     2) FGM(DFG) data should be loaded before running this procedure or use load_fgm flag
;     3) Information of version of the first cdf files is shown in the plot,
;        if multiple cdf files are loaded for FGM(DFG)
;-

pro mms_fgm_dsp_feeps_eis_plot_kitamura,trange=trange,probe=probe,gsm=gsm,no_wave=no_wave,no_feeps=no_feeps,no_eis=no_eis,eis_pa_energy=eis_pa_energy,delete=delete

  loadct2,43
  time_stamp,/off
  
  if not undefined(delete) then store_data,'*',/delete
  status=mms_login_lasp(login_info=login_info,username=username)
  if username eq '' or username eq 'public' then public=1 else public=0

  if undefined(probe) then probe='1'
  probe=strcompress(string(probe),/remove_all)

  if n_elements(trange) eq 1 then begin
    if public eq 0 and status eq 1 then begin
      roi=mms_get_roi(trange,/next)
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
    trange=time_double(trange)
    roi=trange
  endelse
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
      store_data,'mms'+probe+'_gyro',data={x:d.x,y:[[fce],[fcp]]}
      options,'mms'+probe+'_gyro',color=255,width=2

    endif  
      
  endif else begin
    print
    print,'FGM data files are not found in this interval.'
    print
  endelse

  mms_load_mec,trange=trange,probes=probe

  options,'mms'+probe+'_mec_mlat',ytitle='MLAT [deg]',format='(f7.3)'
  options,'mms'+probe+'_mec_mlt',ytitle='MLT [hour]',format='(f7.3)'
  options,'mms'+probe+'_mec_l_dipole',ytitle='Dipole L [R!DE!N]',format='(f7.3)'
  tplot_options,var_label=['mms'+probe+'_mec_l_dipole','mms'+probe+'_mec_mlt','mms'+probe+'_mec_mlat']

  if undefined(no_wave) then begin
    mms_load_dsp,trange=trange,probes=probe,datatype=['epsd','bpsd'],data_rate='slow',level='l2'
    store_data,'mms'+probe+'_dsp_epsd_x_gyro',data=['mms'+probe+'_dsp_epsd_x','mms'+probe+'_gyro']
    store_data,'mms'+probe+'_dsp_bpsd_scm1_slow_l2_gyro',data=['mms'+probe+'_dsp_bpsd_scm1_slow_l2','mms'+probe+'_gyro']
    ylim,['mms'+probe+'_dsp_epsd_x_gyro','mms'+probe+'_dsp_bpsd_scm1_slow_l2_gyro'],30.d,8000.d,1
    options,['mms'+probe+'_dsp_epsd_x_gyro','mms'+probe+'_dsp_bpsd_scm1_slow_l2_gyro'],datagap=30.d
    zlim,['mms'+probe+'_dsp_epsd_x_gyro'],1e-10,1e-6,1
    zlim,['mms'+probe+'_dsp_bpsd_scm1_slow_l2_gyro'],1e-10,1e-4,1
  endif
  if undefined(no_eis) then begin
    mms_load_eis,trange=trange,probes=probe,datatype=['electronenergy'],data_rate='srvy',level='l2',/no_interp
    ylim,'mms'+probe+'_epd_eis_electronenergy_electron_flux_omni_spin',40.d,400.d,1
    zlim,'mms'+probe+'_epd_eis_electronenergy_electron_flux_omni_spin',1.d,100000.d,1
    if not undefined(eis_pa_energy) then begin
      mms_eis_pad,probe=probe,trange=trange,data_rate='srvy',energy=eis_pa_energy,datatype='electronenergy'
      en_range_string=strcompress(string(eis_pa_energy[0]),/remove_all)+'-'+strcompress(string(eis_pa_energy[1]),/remove_all)+'keV'
      ylim,'mms'+probe+'_epd_eis_electronenergy_'+en_range_string+'_electron_flux_omni_pad_spin',0.d,180.d
      options,'mms'+probe+'_epd_eis_electronenergy_'+en_range_string+'_electron_flux_omni_pad_spin',yticks=4
    endif
  endif
  if undefined(en_range_string) then en_range_string=''
  if undefined(no_feeps) then begin
    mms_load_feeps,trange=trange,probes=probe,datatype=['ion','electron'],data_rate='srvy',level='l2'
    ylim,'mms'+probe+'_epd_feeps_srvy_l2_ion_intensity_omni_spin',80.d,600.d,1
    zlim,'mms'+probe+'_epd_feeps_srvy_l2_ion_intensity_omni_spin',1.d,100000.d,1
    options,'mms'+probe+'_epd_feeps_srvy_l2_ion_intensity_omni_spin',yticks=3
    ylim,'mms'+probe+'_epd_feeps_srvy_l2_electron_intensity_omni_spin',70.d,550.d,1
    zlim,'mms'+probe+'_epd_feeps_srvy_l2_electron_intensity_omni_spin',1.d,100000.d,1
    options,'mms'+probe+'_epd_feeps_srvy_l2_electron_intensity_omni_spin',yticks=3
  endif

  tplot_options,'xmargin',[18,10]
;  tplot,['mms'+probe+'_fgm_b_'+coord+'_srvy_l2_bvec','mms'+probe+'_dsp_epsd_x_gyro','mms'+probe+'_dsp_bpsd_scm1_slow_l2_gyro','mms'+probe+'_epd_eis_electronenergy_electron_flux_omni_spin','mms'+probe+'_epd_eis_electronenergy_'+en_range_string+'_electron_flux_omni_pad_spin','mms'+probe+'_epd_feeps_srvy_l2_electron_intensity_omni_spin','mms'+probe+'_epd_feeps_srvy_l2_ion_intensity_omni_spin']
  tplot,['mms'+probe+'_dsp_epsd_x_gyro','mms'+probe+'_dsp_bpsd_scm1_slow_l2_gyro','mms'+probe+'_epd_eis_electronenergy_electron_flux_omni_spin','mms'+probe+'_epd_eis_electronenergy_'+en_range_string+'_electron_flux_omni_pad_spin','mms'+probe+'_epd_feeps_srvy_l2_electron_intensity_omni_spin','mms'+probe+'_epd_feeps_srvy_l2_ion_intensity_omni_spin']

end