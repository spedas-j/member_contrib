;+
; PROCEDURE:
;         mms_fgm_dsp_feeps_eis_fpi_plot_kitamura
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
;         dfg_ql:         set this flag to use DFG QL data (team member only) if not set, FGM L2 data is used
;         gsm:            set this flag to plot FGM(DFG) data in the GSM (or DMPA_GSM) coordinate
;         
;
; EXAMPLE:
;
;     MMS>  mms_fgm_dsp_feeps_eis_fpi_plot_kitamura,['2016-11-23/07:05:00','2016-11-23/07:20:00'],probe='1',/gsm,/no_eis,/no_feeps,/delete
;
; NOTES:
;     1) See the notes in mms_load_data for rules on the use of MMS data
;     2) Information of version of the first cdf files is shown in the plot,
;        if multiple cdf files are loaded for FGM(DFG)
;-

pro mms_fgm_dsp_feeps_eis_fpi_plot_kitamura,trange,probe=probe,gsm=gsm,mag=mag,no_feeps=no_feeps,$
                                            no_eis=no_eis,scm_brst=scm_brst,edp_brst=edp_brst,$
                                            eis_pa_energy=eis_pa_energy,feeps_pa_energy=feeps_pa_energy,dfg_ql=dfg_ql,$
                                            delete=delete,no_output=no_output,plotdir=plotdir,margin=margin

  loadct2,43
  time_stamp,/off
  
  if not undefined(delete) then store_data,'*',/delete
  status=mms_login_lasp(login_info=login_info,username=username)
  if username eq '' or username eq 'public' then public=1 else public=0

  if undefined(probe) then probe='1'
  probe=strcompress(string(probe),/remove_all)

  dsp_data_rate='fast'

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

  if undefined(gsm) then coord='gse' else coord='gsm'
  
  if undefined(dfg_ql) then begin
    
    mms_load_fgm,trange=trange,instrument='fgm',probes=probe,data_rate='srvy',level='l2',versions=fgm_versions

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
      
  endif else begin
    
    mms_load_fgm,trange=trange,instrument='dfg',probes=probe,data_rate='srvy',level='ql',versions=fgm_versions

    if strlen(tnames('mms'+probe+'_dfg_srvy_dmpa_bvec')) gt 0 then begin
      get_data,'mms'+probe+'_dfg_srvy_dmpa_bvec',dlim=dl
      if n_elements(dl.cdf.gatt.data_version) gt 0 then begin
        fgm_dv=dl.cdf.gatt.data_version

        if strlen(tnames('mms'+probe+'_dfg_srvy_dmpa_bvec')) gt 0 then begin
          options,'mms'+probe+'_dfg_srvy_gsm_dmpa_bvec',constant=0.0,colors=[2,4,6],labels=['B!DX!N','B!DY!N','B!DZ!N'],ytitle='MMS'+probe+'!CDFG_QL!CDMPA_GSM!C(near GSM)',ysubtitle='[nT]',labflag=-1,datagap=0.26d
          options,'mms'+probe+'_dfg_srvy_gsm_dmpa_btot',ytitle='MMS'+probe+'!CDFG!CBtotal',ysubtitle='[nT]',labels='L2!C  v'+fgm_dv,labflag=-1,datagap=0.26d
          options,'mms'+probe+'_dfg_srvy_gsm_dmpa_bvec',constant=0.0,colors=[2,4,6,0],labels=['B!DX!N','B!DY!N','B!DZ!N','|B|'],ytitle='MMS'+probe+'!CDFG_QL!CDMPA_GSM!C(near GSM)',ysubtitle='[nT]',labflag=-1,datagap=0.26d
          get_data,'mms'+probe+'_dfg_srvy_gsm_dmpa',data=b
          store_data,'mms'+probe+'_dfg_srvy_gsm_dmpa_mod',data={x:b.x,y:[[b.y[*,3]],[b.y[*,0]],[b.y[*,1]],[b.y[*,2]]]}
          options,'mms'+probe+'_dfg_srvy_gsm_dmpa_mod',constant=0.0,colors=[0,2,4,6],labels=['|B|','B!DX!N','B!DY!N','B!DZ!N'],ytitle='MMS'+probe+'!CDFG_QL!CDMPA_GSM!C(near GSM)',ysubtitle='[nT]',labflag=-1,datagap=0.26d
          options,'mms'+probe+'_dfg_srvy_dmpa_bvec',constant=0.0,colors=[2,4,6],labels=['B!DX!N','B!DY!N','B!DZ!N'],ytitle='MMS'+probe+'!CDFG_QL!CDMPA!C(near GSE)',ysubtitle='[nT]',labflag=-1,datagap=0.26d
          options,'mms'+probe+'_dfg_srvy_dmpa_btot',ytitle='MMS'+probe+'!CDFG!CBtotal',ysubtitle='[nT]',labels='L2!C  v'+fgm_dv,labflag=-1,datagap=0.26d
          options,'mms'+probe+'_dfg_srvy_dmpa',constant=0.0,colors=[2,4,6,0],labels=['B!DX!N','B!DY!N','B!DZ!N','|B|'],ytitle='MMS'+probe+'!CDFG_QL!CDMPA!C(near GSE)',ysubtitle='[nT]',labflag=-1,datagap=0.26d
          get_data,'mms'+probe+'_dfg_srvy_dmpa',data=b
          store_data,'mms'+probe+'_dfg_srvy_dmpa_mod',data={x:b.x,y:[[b.y[*,3]],[b.y[*,0]],[b.y[*,1]],[b.y[*,2]]]}
          options,'mms'+probe+'_dfg_srvy_dmpa_mod',constant=0.0,colors=[0,2,4,6],labels=['|B|','B!DX!N','B!DY!N','B!DZ!N'],ytitle='MMS'+probe+'!CDFG_QL!CDMPA',ysubtitle='[nT]',labflag=-1,datagap=0.26d
          undefine,b

        endif

        get_data,'mms'+probe+'_dfg_srvy_dmpa_btot',data=d
        fce=1.6022e-19*d.y*1.0e-9/(9.1094e-31*2.0*3.14159)
        fcp=1.6022e-19*d.y*1.0e-9/(1.6726e-27*2.0*3.14159)
        store_data,'mms'+probe+'_egyro',data={x:d.x,y:[[fce],[fce*0.5d]]}
        options,'mms'+probe+'_egyro',color_table=0,width=1,colors=[255,185]
        store_data,'mms'+probe+'_pgyro',data={x:d.x,y:fcp}
        options,'mms'+probe+'_pgyro',color=255,width=4

      endif
    endif else begin
      print
      print,'DFG data files are not found in this interval.'
      print
    endelse
    
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
    endif else begin
      tkm2re,'mms'+probe+ql+'_pos_gsm'
      split_vec,'mms'+probe+ql+'_pos_'+coord+'_re'
      options,'mms'+probe+ql+'_pos_'+coord+'_re_0',ytitle='MMS'+probe+' '+strupcase(coord)+'X [R!DE!N]',format='(f7.3)'
      options,'mms'+probe+ql+'_pos_'+coord+'_re_1',ytitle='MMS'+probe+' '+strupcase(coord)+'Y [R!DE!N]',format='(f7.3)'
      options,'mms'+probe+ql+'_pos_'+coord+'_re_2',ytitle='MMS'+probe+' '+strupcase(coord)+'Z [R!DE!N]',format='(f7.3)'
      options,'mms'+probe+ql+'_pos_'+coord+'_re_3',ytitle='MMS'+probe+' R [R!DE!N]',format='(f7.3)'
      tplot_options, var_label=['mms'+probe+ql+'_pos_'+coord+'_re_3','mms'+probe+ql+'_pos_'+coord+'_re_2','mms'+probe+ql+'_pos_'+coord+'_re_1','mms'+probe+ql+'_pos_'+coord+'_re_0']
    endelse    
  endif else begin
    options,'mms'+probe+'_mec_mlat',ytitle='MLAT [deg]',format='(f7.3)'
    options,'mms'+probe+'_mec_mlt',ytitle='MLT [hour]',format='(f7.3)'
    options,'mms'+probe+'_mec_l_dipole',ytitle='Dipole L [R!DE!N]',format='(f7.3)'
    tplot_options,var_label=['mms'+probe+'_mec_l_dipole','mms'+probe+'_mec_mlt','mms'+probe+'_mec_mlat']
  endelse

  mms_load_dsp,trange=trange,probes=probe,datatype='epsd',data_rate=dsp_data_rate,level='l2',versions=dspe_versions
  mms_load_dsp,trange=trange,probes=probe,datatype='bpsd',data_rate=dsp_data_rate,level='l2',versions=dspb_versions
  store_data,'mms'+probe+'_dsp_epsd_x_gyro',data=['mms'+probe+'_dsp_epsd_x','mms'+probe+'_egyro','mms'+probe+'_pgyro']
  store_data,'mms'+probe+'_dsp_epsd_y_gyro',data=['mms'+probe+'_dsp_epsd_y','mms'+probe+'_egyro','mms'+probe+'_pgyro']
  store_data,'mms'+probe+'_dsp_epsd_z_gyro',data=['mms'+probe+'_dsp_epsd_z','mms'+probe+'_egyro','mms'+probe+'_pgyro']
  store_data,'mms'+probe+'_dsp_bpsd_scm1_'+dsp_data_rate+'_l2_gyro',data=['mms'+probe+'_dsp_bpsd_scm1_'+dsp_data_rate+'_l2','mms'+probe+'_egyro','mms'+probe+'_pgyro']
  store_data,'mms'+probe+'_dsp_bpsd_scm2_'+dsp_data_rate+'_l2_gyro',data=['mms'+probe+'_dsp_bpsd_scm2_'+dsp_data_rate+'_l2','mms'+probe+'_egyro','mms'+probe+'_pgyro']
  store_data,'mms'+probe+'_dsp_bpsd_scm3_'+dsp_data_rate+'_l2_gyro',data=['mms'+probe+'_dsp_bpsd_scm3_'+dsp_data_rate+'_l2','mms'+probe+'_egyro','mms'+probe+'_pgyro']
  ylim,['mms'+probe+'_dsp_epsd_?_gyro','mms'+probe+'_dsp_bpsd_scm?_'+dsp_data_rate+'_l2_gyro'],30.d,8000.d,1
  options,['mms'+probe+'_dsp_epsd_x_gyro'],datagap=30.d,ytitle='MMS'+probe+'!CDSP_L2!CEx_wave',ysubtitle='[Hz]',ytickformat='mms_exponent2',ztitle='(V/m)!U2!N/Hz',panel_size=1.25d
  options,['mms'+probe+'_dsp_epsd_y_gyro'],datagap=30.d,ytitle='MMS'+probe+'!CDSP_L2!CEy_wave',ysubtitle='[Hz]',ytickformat='mms_exponent2',ztitle='(V/m)!U2!N/Hz',panel_size=1.25d
  options,['mms'+probe+'_dsp_epsd_z_gyro'],datagap=30.d,ytitle='MMS'+probe+'!CDSP_L2!CEz_wave',ysubtitle='[Hz]',ytickformat='mms_exponent2',ztitle='(V/m)!U2!N/Hz',panel_size=1.25d
  options,['mms'+probe+'_dsp_bpsd_scm1_'+dsp_data_rate+'_l2_gyro'],datagap=30.d,ytitle='MMS'+probe+'!CDSP_L2!CB1_wave',ysubtitle='[Hz]',ytickformat='mms_exponent2',ztitle='nT!U2!N/Hz',panel_size=1.25d
  options,['mms'+probe+'_dsp_bpsd_scm2_'+dsp_data_rate+'_l2_gyro'],datagap=30.d,ytitle='MMS'+probe+'!CDSP_L2!CB2_wave',ysubtitle='[Hz]',ytickformat='mms_exponent2',ztitle='nT!U2!N/Hz',panel_size=1.25d
  options,['mms'+probe+'_dsp_bpsd_scm3_'+dsp_data_rate+'_l2_gyro'],datagap=30.d,ytitle='MMS'+probe+'!CDSP_L2!CB3_wave',ysubtitle='[Hz]',ytickformat='mms_exponent2',ztitle='nT!U2!N/Hz',panel_size=1.25d
  zlim,['mms'+probe+'_dsp_epsd_?_gyro'],1e-10,1e-4,1
  zlim,['mms'+probe+'_dsp_bpsd_scm?_'+dsp_data_rate+'_l2_gyro'],1e-10,1e-3,1

  
  if not undefined(scm_brst) then begin
    mms_load_scm,trange=trange,probes=probe,datatype='scb',data_rate='brst',level='l2',versions=scm_versions
    cotrans_fac,trange,'mms'+probe+'_scm_acb_gse_scb_brst_l2','mms'+probe+'_fgm_b_gse_srvy_l2_bvec','mms'+probe+'_mec_r_gse',newname='mms'+probe+'_scm_acb_fac_scb_brst_l2'
    options,'mms'+probe+'_scm_acb_fac_scb_brst_l2',datagap=0.001d
    thigh_pass_filter,'mms'+probe+'_scm_acb_fac_scb_brst_l2',0.04d
    tdpwrspc,'mms'+probe+'_scm_acb_fac_scb_brst_l2',nboxpoints=1024
    ylim,'mms'+probe+'_scm_acb_fac_scb_brst_l2_?_dpwrspc',30.d,3000.d,1
    zlim,'mms'+probe+'_scm_acb_fac_scb_brst_l2_?_dpwrspc',1e-10,1e-6,1
    options,'mms'+probe+'_scm_acb_fac_scb_brst_l2_?_dpwrspc',datagap=5.d
    store_data,'mms'+probe+'_scm_acb_fac_scb_brst_l2_x_dpwrspc_gyro',data=['mms'+probe+'_scm_acb_fac_scb_brst_l2_x_dpwrspc','mms'+probe+'_egyro','mms'+probe+'_pgyro']
    ylim,'mms'+probe+'_scm_acb_fac_scb_brst_l2_?_dpwrspc_gyro',30.d,3000.d,1
    options,'mms'+probe+'_scm_acb_fac_scb_brst_l2_x_dpwrspc_gyro',ytitle='MMS'+probe+'!CSCM_L2!CBx_wave',ysubtitle='[Hz]',ztickformat='mms_exponent2'
  endif

  mms_fpi_plot_kitamura,trange=trange,probe=probe,/no_plot,/load_fpi
      
  if undefined(no_eis) then begin
    mms_load_eis,trange=trange,probes=probe,datatype=['electronenergy'],data_rate='srvy',level='l2',/no_interp,versions=eis_versions
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
    mms_load_feeps,trange=trange,probes=probe,datatype='ion',data_rate='srvy',level='l2',versions=feepsi_versions
    mms_load_feeps,trange=trange,probes=probe,datatype='electron',data_rate='srvy',level='l2',versions=feepse_versions
    ylim,'mms'+probe+'_epd_feeps_srvy_l2_ion_intensity_omni_spin',80.d,600.d,1
    zlim,'mms'+probe+'_epd_feeps_srvy_l2_ion_intensity_omni_spin',1.d,100000.d,1
    options,'mms'+probe+'_epd_feeps_srvy_l2_ion_intensity_omni_spin',yticks=3,ztickformat='mms_exponent2',panel_size=0.75,ytitle='MMS'+probe+'!CFEEPS_L2!CIon!Cintensity!Comni',ysubtitle='[keV]',datagap=600.d
    ylim,'mms'+probe+'_epd_feeps_srvy_l2_electron_intensity_omni_spin',70.d,550.d,1
    zlim,'mms'+probe+'_epd_feeps_srvy_l2_electron_intensity_omni_spin',1.d,10000.d,1
    options,'mms'+probe+'_epd_feeps_srvy_l2_electron_intensity_omni_spin',yticks=3,ztickformat='mms_exponent2',panel_size=0.75,ytitle='MMS'+probe+'!CFEEPS_L2!CElectron!Cintensity!Comni',ysubtitle='[keV]',datagap=600.d
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
  if undefined(dfg_ql) then begin
    tplot,['mms_bss','mms'+probe+'_fgm_b_'+coord+'_srvy_l2_mod','mms'+probe+'_dsp_epsd_x_gyro','mms'+probe+'_dsp_bpsd_scm1_'+dsp_data_rate+'_l2_gyro','mms'+probe+'_scm_acb_fac_scb_brst_l2_hpfilt','mms'+probe+'_scm_acb_fac_scb_brst_l2_x_dpwrspc_gyro','mms'+probe+'_epd_eis_electronenergy_'+eis_en_range_string+'_electron_flux_omni_pad','mms'+probe+'_epd_eis_electronenergy_electron_flux_omni_spin','mms'+probe+'_epd_feeps_srvy_l2_electron_intensity_'+feeps_en_range_string+'_pad_spin','mms'+probe+'_epd_feeps_srvy_l2_electron_intensity_omni_spin','mms'+probe+'_fpi_eEnergySpectr_omni','mms'+probe+'_epd_feeps_srvy_l2_ion_intensity_omni_spin','mms'+probe+'_fpi_iEnergySpectr_omni']
  endif else begin  
    tplot,['mms_bss','mms'+probe+'_dfg_srvy_dmpa_mod','mms'+probe+'_dsp_epsd_x_gyro','mms'+probe+'_dsp_bpsd_scm1_'+dsp_data_rate+'_l2_gyro','mms'+probe+'_epd_eis_electronenergy_electron_flux_omni_spin','mms'+probe+'_epd_eis_electronenergy_'+en_range_string+'_electron_flux_omni_pad_spin','mms'+probe+'_epd_feeps_srvy_l2_electron_intensity_omni_spin','mms'+probe+'_fpi_eEnergySpectr_omni','mms'+probe+'_epd_feeps_srvy_l2_ion_intensity_omni_spin','mms'+probe+'_fpi_iEnergySpectr_omni']
  endelse
;  tplot,['mms'+probe+'_dsp_epsd_x_gyro','mms'+probe+'_dsp_bpsd_scm1_'+dsp_data_rate+'_l2_gyro','mms'+probe+'_epd_eis_electronenergy_electron_flux_omni_spin','mms'+probe+'_epd_eis_electronenergy_'+en_range_string+'_electron_flux_omni_pad_spin','mms'+probe+'_epd_feeps_srvy_l2_electron_intensity_omni_spin','mms'+probe+'_epd_feeps_srvy_l2_ion_intensity_omni_spin']
  mms_add_cdf_versions,'fgm',fgm_versions,/reset,/right_align
  if not undefined(scm_versions) then mms_add_cdf_versions,'scm',scm_versions,/right_align
  if not undefined(eis_versions) then mms_add_cdf_versions,'eis_e',eis_versions,/right_align
  if not undefined(feepsi_versions) then mms_add_cdf_versions,'feeps_i',feepsi_versions,/right_align
  if not undefined(feepse_versions) then mms_add_cdf_versions,'feeps_e',feepse_versions,/right_align
  if not undefined(dspe_versions) then mms_add_cdf_versions,'dsp_e',dspe_versions,/right_align
  if not undefined(dspb_versions) then mms_add_cdf_versions,'dsp_b',dspb_versions,/right_align

  if undefined(no_output) and not undefined(plotdir) then begin
  
    if undefined(roi) then roi=trange
    ts=strsplit(time_string(time_double(roi[0]),format=3,precision=-2),/extract)
    dn=plotdir+'\'+ts[0]+'\'+ts[1]
    if ~file_test(dn) then file_mkdir,dn
  
    thisDevice=!D.NAME
    tplot_options,'charsize',0.75
    tplot_options,'xmargin',[18,10]
;    tplot_options,'ymargin'
    if roi[1]-roi[0] lt 18.d*3600.d then tplot_options,'tickinterval',3600
    set_plot,'ps'
    device,filename=dn+'\mms'+probe+'_VLF_ROI_'+time_string(roi[0],format=2,precision=0)+'.ps',xsize=60.0,ysize=30.0,/color,/encapsulated,bits=8
    tplot,trange=trange
    mms_add_cdf_versions,'fgm',fgm_versions,/reset,/right_align
    if not undefined(scm_versions) then mms_add_cdf_versions,'scm',scm_versions,/right_align
    if not undefined(eis_versions) then mms_add_cdf_versions,'eis',eis_versions,/right_align
    if not undefined(feepsi_versions) then mms_add_cdf_versions,'feeps_i',feepsi_versions,/right_align
    if not undefined(feepse_versions) then mms_add_cdf_versions,'feeps_e',feepse_versions,/right_align
    if not undefined(dspe_versions) then mms_add_cdf_versions,'dsp_e',dspe_versions,/right_align
    if not undefined(dspb_versions) then mms_add_cdf_versions,'dsp_b',dspb_versions,/right_align
    device,/close
    set_plot,thisDevice
    !p.background=255
    !p.color=0
    if not undefined(full_bss) then options,'mms_bss',thick=5.0,panel_size=0.55,labsize=0.8 else options,'mms_bss',thick=5.0,panel_size=0.25,labsize=0.8
    window,xsize=1920,ysize=1080
;    tplot_options,'ymargin',[2.5,0.2]
    tplot,trange=trange
    mms_add_cdf_versions,'fgm',fgm_versions,/reset,/right_align
    if not undefined(scm_versions) then mms_add_cdf_versions,'scm',scm_versions,/right_align
    if not undefined(eis_versions) then mms_add_cdf_versions,'eis',eis_versions,/right_align
    if not undefined(feepsi_versions) then mms_add_cdf_versions,'feeps_i',feepsi_versions,/right_align
    if not undefined(feepse_versions) then mms_add_cdf_versions,'feeps_e',feepse_versions,/right_align
    if not undefined(dspe_versions) then mms_add_cdf_versions,'dsp_e',dspe_versions,/right_align
    if not undefined(dspb_versions) then mms_add_cdf_versions,'dsp_b',dspb_versions,/right_align
    makepng,dn+'\mms'+probe+'_VLF_ROI_'+time_string(roi[0],format=2,precision=0)
    if not undefined(full_bss) then options,'mms_bss',thick=10.0,panel_size=0.5 else options,'mms_bss',thick=10.0,panel_size=0.2
    options,'mms_bss','labsize'
    tplot_options,'tickinterval'
;    tplot_options,'ymargin'
  
    if undefined(no_short) then begin
      start_time=time_double(time_string(roi[0],format=0,precision=-2))
      tplot_options,'tickinterval',300
      while start_time lt roi[1] do begin
        ts=strsplit(time_string(time_double(start_time),format=3,precision=-2),/extract)
        dn=plotdir+'\'+ts[0]+'\'+ts[1]
        if ~file_test(dn) then file_mkdir,dn
        set_plot,'ps'
        device,filename=dn+'\mms'+probe+'_VLF_'+time_string(start_time,format=2,precision=-2)+'_1hour.ps',xsize=40.0,ysize=30.0,/color,/encapsulated,bits=8
        tplot,trange=[start_time,time_double(time_string(start_time+3601.d,format=0,precision=-2))]
        mms_add_cdf_versions,' fgm',fgm_versions,/reset,/right_align
        if not undefined(scm_versions) then mms_add_cdf_versions,'scm',scm_versions,/right_align
        if not undefined(eis_versions) then mms_add_cdf_versions,'eis',eis_versions,/right_align
        if not undefined(feepsi_versions) then mms_add_cdf_versions,'feeps_i',feepsi_versions,/right_align
        if not undefined(feepse_versions) then mms_add_cdf_versions,'feeps_e',feepse_versions,/right_align
        if not undefined(dspe_versions) then mms_add_cdf_versions,'dsp_e',dspe_versions,/right_align
        if not undefined(dspb_versions) then mms_add_cdf_versions,'dsp_b',dspb_versions,/right_align
        device,/close
        set_plot,thisDevice
        !p.background=255
        !p.color=0
        if not undefined(full_bss) then options,'mms_bss',thick=5.0,panel_size=0.55,labsize=0.8 else options,'mms_bss',thick=5.0,panel_size=0.25,labsize=0.8
        window,xsize=1920,ysize=1080
;        tplot_options,'ymargin',[2.5,0.2]
        tplot,trange=[start_time,time_double(time_string(start_time+3601.d,format=0,precision=-2))]
        mms_add_cdf_versions,' fgm',fgm_versions,/reset,/right_align
        if not undefined(scm_versions) then mms_add_cdf_versions,'scm',scm_versions,/right_align
        if not undefined(eis_versions) then mms_add_cdf_versions,'eis',eis_versions,/right_align
        if not undefined(feepsi_versions) then mms_add_cdf_versions,'feeps_i',feepsi_versions,/right_align
        if not undefined(feepse_versions) then mms_add_cdf_versions,'feeps_e',feepse_versions,/right_align
        if not undefined(dspe_versions) then mms_add_cdf_versions,'dsp_e',dspe_versions,/right_align
        if not undefined(dspb_versions) then mms_add_cdf_versions,'dsp_b',dspb_versions,/right_align
        makepng,dn+'\mms'+probe+'_VLF_'+time_string(start_time,format=2,precision=-2)+'_1hour'
        if not undefined(full_bss) then options,'mms_bss',thick=10.0,panel_size=0.5 else options,'mms_bss',thick=10.0,panel_size=0.2
        options,'mms_bss','labsize'
;        tplot_options,'ymargin'
        start_time=time_double(time_string(start_time+3601.d,format=0,precision=-2))
      endwhile
      tplot_options,'tickinterval'
    endif
    tplot_options,'xmargin'
    tplot_options,'charsize'
  endif 
 
end
