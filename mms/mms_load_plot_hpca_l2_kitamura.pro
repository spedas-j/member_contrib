;+
; PROCEDURE:
;         mms_load_plot_hpca_l2_kitamura
;
; PURPOSE:
;         Plot magnetic field (FGM (or DFG)), FPI, and HPCA data obtained by MMS
;
; KEYWORDS:
;         trange:        time range of interest [starttime, endtime] with the format
;                        ['YYYY-MM-DD','YYYY-MM-DD'] or to specify more or less than a day
;                        ['YYYY-MM-DD/hh:mm:ss','YYYY-MM-DD/hh:mm:ss']
;                        if the format is 'YYYY-MM-DD' or 'YYYY-MM-DD/hh:mm:ss' (one element)
;                        the time range is set as from 210 (or 30 (brst)) minutes before the 
;                        beginning of the ROI just after the specified time to 210
;                        (or 30 (brst)) minutes after the end of the ROI.
;         probe:         a probe - value for MMS SC #
;         delete:        set this flag to delete all tplot variables at the beginning
;         brst:          set this flag to use HPCA burst data
;         no_load_fgm:   set this flag to skip loading FGM data
;         dfg_ql:        set this flag to use DFG ql data forcibly. if not set, DFG l2pre data
;                        are used, if available (team member only)
;         no_update_fgm: set this flag to preserve the original FGM data. if not set and
;                        newer data is found the existing data will be overwritten
;         no_load_fpi:   set this flag to skip loading FPI data
;         no_update_fpi: set this flag to preserve the original FPI data. if not set and
;                        newer data is found the existing data will be overwritten
;         no_update_hpca:set this flag to preserve the original HPCA data. if not set and
;                        newer data is found the existing data will be overwritten
;         no_update_mec: set this flag to preserve the original MEC data. if not set and
;                        newer data is found the existing data will be overwritten
;         no_bss:        set this flag to skip loading bss data
;         full_bss:      set this flag to load detailed bss data (team member only)
;         gsm:           set this flag to plot data in the GSM coordinate
;         flux:          set this flag to set the differential flux as the unit for HPCA
;                        E-t spectra
;         lowi_pa:       set this flag to plot PA-t spectra for FPI-DIS data  
;         lowh_pa:       set this flag to plot PA-t spectra for HPCA proton data
;         lowhe_pa:      set this flag to plot PA-t spectra for HPCA helium data
;         lowo_pa:       set this flag to plot PA-t spectra for HPCA oxygen data
;         pa_erange:     set this to specify energy range of PA-t spectra
;         hpa_erange:    set this to specify energy range of H+ PA-t spectra
;         hepa_erange:   set this to specify energy range of He+ PA-t spectra
;         opa_erange:    set this to specify energy range of O+ PA-t spectra
;         pa_zrange:     set this to specify color range of PA-t spectra
;         hpa_zrange:    set this to specify color range of H+ PA-t spectra
;         hepa_zrange:   set this to specify color range of He+ PA-t spectra
;         opa_zrange:    set this to specify color range of O+ PA-t spectra
;         zrange:        set this to specify zrange of HPCA E-t spectra 
;         v_hpca:        set this flag to use HPCA proton velocity data. if not set, ion
;                        velocity data from FPI-DIS are plotted
;         plot_wave:     set this flag to plot with wave data
;         plotdir:       set this to assine a directory for plots
;         esp_plotcdir:  set this to assine a directory for plots with high frequency electric field
;                        wave data
;         no_short:      set this flag to skip short plots (1 hour)
;         margin:        set this flag to use a specific margin
;         tail:          set this flag to use special ranges for tail region
;
; EXAMPLE:
;
;     To make plots of fluxgate magnetometers (FGM (or DFG)), fast plasma investigation (FPI), and
;     hot plasma composition analyzer (HPCA) data
;     team member
;     MMS>  mms_load_plot_hpca_l2_kitamura,'2015-09-03/08:00:00',probe='1',/delete,/gsm,/lowi_pa,/lowh_pa,/lowhe_pa,/lowo_pa
;     MMS>  mms_load_plot_hpca_l2_kitamura,'2015-09-03/08:00:00',probe='1',/delete,/brst,/gsm,/lowi_pa,/lowh_pa,/lowhe_pa,/lowo_pa
;     public user
;     MMS>  mms_load_plot_hpca_l2_kitamura,['2015-09-03/08:00:00','2015-09-04/00:00:00'],probe='1',/delete,/gsm,/lowi_pa,/lowh_pa,/lowhe_pa,/lowo_pa
;     MMS>  mms_load_plot_hpca_l2_kitamura,['2015-09-03/08:00:00','2015-09-04/00:00:00'],probe='1',/delete,/brst,/gsm,/lowi_pa,/lowh_pa,/lowhe_pa,/lowo_pa
;
; NOTES:
;     1) See the notes in mms_load_data for rules on the use of MMS data
;     2) Set plotdir before use if you output plots
;     3) Information of version of the first cdf files is shown in the plot,
;        if multiple cdf files are loaded for FPI
;-

pro mms_load_plot_hpca_l2_kitamura,trange_orig,probe=probe,delete=delete,brst=brst,no_load_fgm=no_load_fgm,dfg_ql=dfg_ql,no_update_fgm=no_update_fgm,$
                                   no_load_fpi=no_load_fpi,no_update_fpi=no_update_fpi,no_update_hpca=no_update_hpca,no_update_mec=no_update_mec,$
                                   no_bss=no_bss,full_bss=full_bss,gsm=gsm,flux=flux,lowi_pa=lowi_pa,lowh_pa=lowh_pa,lowhe_pa=lowhe_pa,lowo_pa=lowo_pa,$
                                   pa_erange=pa_erange,hpa_erange=hpa_erange,hepa_erange=hepa_erange,opa_erange=opa_erange,pa_zrange=pa_zrange,$
                                   hpa_zrange=hpa_zrange,hepa_zrange=hepa_zrange,opa_zrange=opa_zrange,zrange=zrange,v_hpca=v_hpca,plot_wave=plot_wave,$
                                   plotdir=plotdir,esp_plotdir=esp_plotdir,no_short=no_short,margin=margin,tail=tail

  if not undefined(delete) then store_data,'*',/delete
  if undefined(gsm) then coord='gse' else coord='gsm'
  
  status=mms_login_lasp(login_info=login_info,username=username)
  if username eq '' or username eq 'public' then public=1 else public=0

  hpca_min_version='3.2.0'
  if undefined(pa_zrange) then pa_zrange=[1e3,1e7]

  trange=time_double(trange_orig)
  if n_elements(trange) eq 1 then begin
    if public eq 0 then begin
      roi=mms_get_roi(trange,/next)
      trange=dblarr(2)
      if undefined(margin) then begin
        if undefined(brst) then margin=210.d else margin=30.d
      endif
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
      print
      print,'Please input start and end time to use public data'
      print
      return
    endelse
  endif else begin
    roi=trange
  endelse
  if undefined(probe) then probe='1'
  probe=strcompress(string(probe),/rem)

  dt=trange[1]-trange[0]
  timespan,trange[0],dt,/seconds
  
  prefix='mms'+probe
  if not undefined(brst) then begin
    data_rate='brst'
    gap_hpca=25.d
  endif else begin
    data_rate='srvy'
    gap_hpca=600.d
  endelse
  
  mms_init
  loadct2,43
  time_stamp,/off
  if undefined(no_load_fgm) then mms_fgm_plot_kitamura,trange=trange,probe=probe,dfg_ql=dfg_ql,no_update=no_update_fgm,/no_avg,/load_fgm,/no_plot
  if strlen(tnames('mms'+probe+'_mec_r_eci')) eq 0 then mms_load_mec,trange=trange,probes=probe,no_update=no_update_mec,varformat=['mms'+probe+'_mec_r_eci','mms'+probe+'_mec_r_gse','mms'+probe+'_mec_r_gsm','mms'+probe+'_mec_L_vec']
  
  if undefined(pa_erange) then pa_erange=[1.d,300.d]
  if pa_erange[0] gt 100.d and pa_erange[1] ge 1000.d then begin
    erangename=strcompress(string(pa_erange[0]/1000.d,format='(f5.1)'),/remove_all)+'-'+strcompress(string(pa_erange[1]/1000.d,format='(f5.1)'),/remove_all)+'keV'
  endif else begin
    erangename=strcompress(string(pa_erange[0],format='(i6)'),/remove_all)+'-'+strcompress(string(pa_erange[1],format='(i6)'),/remove_all)+'eV'
  endelse
  if undefined(hpa_erange) then hpa_erange=pa_erange
  if hpa_erange[0] gt 100.d and hpa_erange[1] ge 1000.d then begin
    erangename_h=strcompress(string(hpa_erange[0]/1000.d,format='(f5.1)'),/remove_all)+'-'+strcompress(string(hpa_erange[1]/1000.d,format='(f5.1)'),/remove_all)+'keV'
  endif else begin
    erangename_h=strcompress(string(hpa_erange[0],format='(i6)'),/remove_all)+'-'+strcompress(string(hpa_erange[1],format='(i6)'),/remove_all)+'eV'
  endelse
  if undefined(hepa_erange) then hepa_erange=pa_erange
  if hepa_erange[0] gt 100.d and hepa_erange[1] ge 1000.d then begin
    erangename_he=strcompress(string(hepa_erange[0]/1000.d,format='(f5.1)'),/remove_all)+'-'+strcompress(string(hepa_erange[1]/1000.d,format='(f5.1)'),/remove_all)+'keV'
  endif else begin
    erangename_he=strcompress(string(hepa_erange[0],format='(i6)'),/remove_all)+'-'+strcompress(string(hepa_erange[1],format='(i6)'),/remove_all)+'eV'
  endelse
  if undefined(opa_erange) then opa_erange=pa_erange
  if opa_erange[0] gt 100.d and opa_erange[1] ge 1000.d then begin
    erangename_o=strcompress(string(opa_erange[0]/1000.d,format='(f5.1)'),/remove_all)+'-'+strcompress(string(opa_erange[1]/1000.d,format='(f5.1)'),/remove_all)+'keV'
  endif else begin
    erangename_o=strcompress(string(opa_erange[0],format='(i6)'),/remove_all)+'-'+strcompress(string(opa_erange[1],format='(i6)'),/remove_all)+'eV'
  endelse
 
  if not undefined(lowi_pa) then begin
    mms_load_fpi,probe=probe,trange=trange,data_rate='fast',level='l2',datatype='dis-dist',no_update=no_update_fpi,versions=dis_versions,/center_measurement;,/time_clip
    if strlen(tnames(prefix+'_dis_dist_fast')) gt 0 then begin
      if dis_versions[0,0] le 2 then mms_part_products,prefix+'_dis_dist_fast',trange=trange,outputs='energy',suffix='_omni'
      mms_part_products,prefix+'_dis_dist_fast',trange=trange,mag_name=prefix+'_fgm_b_dmpa_srvy_l2_bvec',pos_name=prefix+'_mec_r_eci',energy=pa_erange,outputs='pa',suffix='_'+erangename
      store_data,prefix+'_dis_errorflags_fast',/delete
      store_data,prefix+'_dis_compressionloss_fast',/delete
      store_data,prefix+'_dis_startdelphi_count_fast',/delete
      store_data,prefix+'_dis_startdelphi_angle_fast',/delete
      store_data,prefix+'_dis_dist_fast',/delete
      store_data,prefix+'_dis_disterr_fast',/delete
      store_data,prefix+'_dis_sector_index_fast',/delete
      store_data,prefix+'_dis_pixel_index_fast',/delete
      store_data,prefix+'_dis_energy_index_fast',/delete
      store_data,prefix+'_dis_theta_fast',/delete
      store_data,prefix+'_dis_energy_fast',/delete
      store_data,prefix+'_dis_phi_fast',/delete
    endif
    if strlen(tnames(prefix+'_dis_dist_fast_pa_'+erangename)) eq 0 then store_data,prefix+'_dis_dist_fast_pa_'+erangename,data={x:[trange],y:[[!values.f_nan,!values.f_nan],[!values.f_nan,!values.f_nan]],v:[0.d,180.d]}
    ylim,prefix+'_dis_dist_fast_pa_'+erangename,0.d,180.d,0
    options,prefix+'_dis_dist_fast_pa_'+erangename,spec=1,ytitle='MMS'+probe+'!CFPI DIS!C'+erangename+'!CPA',ysubtitle='[deg]',datagap=5.d,yticks=4,ztitle='eV/(cm!U2!N s sr eV)',ztickformat='mms_exponent2'
    zlim,prefix+'_dis_dist_fast_pa_'+erangename,pa_zrange[0],pa_zrange[1],1
  endif
  
  if undefined(no_load_fpi) then mms_fpi_plot_kitamura,trange=trange,probe=probe,no_update_fpi=no_update_fpi,/no_plot,/load_fpi
  if strlen(tnames(prefix+'_dis_dist_fast_energy_omni')) eq 0 then copy_data,prefix+'_fpi_iEnergySpectr_omni',prefix+'_dis_dist_fast_energy_omni'
  if strlen(tnames(prefix+'_fpi_iEnergySpectr_omni')) gt 0 then begin
    get_data,prefix+'_fpi_iEnergySpectr_omni',lim=l
    store_data,prefix+'_dis_dist_fast_energy_omni',lim=l
  endif
  zlim,prefix+'_dis_dist_fast_energy_omni',1e4,1e8,1
  options,prefix+'_dis_dist_fast_energy_omni',minzlog=0

  mms_load_hpca,probes=probe,trange=trange,datatype='moments',level='l2',data_rate=data_rate,no_update=no_update_hpca,min_version=hpca_min_version,/center_measurement;,/time_clip
  mms_load_hpca,probes=probe,trange=trange,datatype='ion',level='l2',data_rate=data_rate,no_update=no_update_hpca,min_version=hpca_min_version,/center_measurement;,/time_clip
  mms_hpca_calc_anodes,fov=[0,360],probe=probe

  ion_sp=[['hplus','heplusplus','heplus','oplus'],['H!U+!N','He!U++!N','He!U+!N','O!U+!N']]
  for s=0,n_elements(ion_sp[*,0])-1 do begin
    if strlen(tnames(prefix+'_hpca_'+ion_sp[s,0]+'_flux_elev_0-360')) gt 0 then begin
      get_data,prefix+'_hpca_'+ion_sp[s,0]+'_flux_elev_0-360',data=d
      for i=0l,n_elements(d.x)-1 do begin
        for j=0l,n_elements(d.v)-1 do d.y[i,j]=d.y[i,j]*d.v[j]
      endfor
      store_data,prefix+'_hpca_'+ion_sp[s,0]+'_eflux_elev_0-360',data=d
    endif else begin
      store_data,prefix+'_hpca_'+ion_sp[s,0]+'_flux_elev_0-360',data={x:[trange],y:[[!values.f_nan,!values.f_nan],[!values.f_nan,!values.f_nan]],v:[1.d,40000.d]}
      store_data,prefix+'_hpca_'+ion_sp[s,0]+'_eflux_elev_0-360',data={x:[trange],y:[[!values.f_nan,!values.f_nan],[!values.f_nan,!values.f_nan]],v:[1.d,40000.d]}
    endelse
    if strlen(tnames(prefix+'_hpca_'+ion_sp[s,0]+'_number_density')) eq 0 then begin
      store_data,prefix+'_hpca_'+ion_sp[s,0]+'_number_density',data={x:[trange],y:[[!values.f_nan,!values.f_nan]]}
      store_data,prefix+'_hpca_'+ion_sp[s,0]+'_ion_bulk_velocity_GSM',data={x:[trange],y:[[!values.f_nan,!values.f_nan],[!values.f_nan,!values.f_nan],[!values.f_nan,!values.f_nan]]}
    endif
  endfor
  if not undefined(zrange) and not undefined(flux) then zlim,prefix+'_hpca_*plus_flux_elev_0-360',zrange[0],zrange[1],1 else zlim,prefix+'_hpca_*plus_flux_elev_0-360',0.3d,3e6,1
  ylim,prefix+'_hpca_*plus_eflux_elev_0-360',1e0,4e4,1
  if not undefined(zrange) and undefined(flux) then zlim,prefix+'_hpca_*plus_eflux_elev_0-360',zrange[0],zrange[1],1 else zlim,prefix+'_hpca_*plus_eflux_elev_0-360',1e4,1e8,1
  if undefined(brst) then begin
    for s=0,n_elements(ion_sp[*,0])-1 do begin
      options,prefix+'_hpca_'+ion_sp[s,0]+'_flux_elev_0-360',spec=1,datagap=600.d,ytitle='MMS'+probe+'!CHPCA L2!C'+ion_sp[s,1]+' srvy!CELEV!C0-360',ysubtitle='[eV]',ytickformat='mms_exponent2',ztitle='1/(cm!U2!N s sr eV)',ztickformat='mms_exponent2'
      options,prefix+'_hpca_'+ion_sp[s,0]+'_eflux_elev_0-360',spec=1,datagap=600.d,ytitle='MMS'+probe+'!CHPCA L2!C'+ion_sp[s,1]+' srvy!CELEV!C0-360',ysubtitle='[eV]',ytickformat='mms_exponent2',ztitle='eV/(cm!U2!N s sr eV)',ztickformat='mms_exponent2'
    endfor
    options,prefix+'_hpca_*plus_number_density',datagap=600.d
  endif else begin
    for s=0,n_elements(ion_sp[*,0])-1 do begin
      options,prefix+'_hpca_'+ion_sp[s,0]+'_flux_elev_0-360',spec=1,datagap=0.75d,ytitle='MMS'+probe+'!CHPCA L2!C'+ion_sp[s,1]+' burst!CELEV 0-360',ysubtitle='[eV]',ytickformat='mms_exponent2',ztitle='1/(cm!U2!N s sr eV)',ztickformat='mms_exponent2'
      options,prefix+'_hpca_'+ion_sp[s,0]+'_eflux_elev_0-360',spec=1,datagap=0.75d,ytitle='MMS'+probe+'!CHPCA L2!C'+ion_sp[s,1]+' burst!CELEV 0-360',ysubtitle='[eV]',ytickformat='mms_exponent2',ztitle='eV/(cm!U2!N s sr eV)',ztickformat='mms_exponent2'
    endfor
    options,prefix+'_hpca_*plus_number_density',datagap=25.d
  endelse
  
  if strlen(tnames(prefix+'_fpi_DISnumberDensity')) gt 0 then begin
    store_data,prefix+'_fpi_hpca_numberDensity',data=[prefix+'_fpi_DISnumberDensity',prefix+'_hpca_hplus_number_density',prefix+'_hpca_heplusplus_number_density',prefix+'_hpca_heplus_number_density',prefix+'_hpca_oplus_number_density']
    options,prefix+'_fpi_hpca_numberDensity',ytitle='MMS'+probe+'!CFPI_HPCA!CNumber!CDensity',ysubtitle='[cm!U-3!N]',colors=[0,6,3,2,4],labels=['DIS','H+','He++','He+','O+'],labflag=-1,constant=[0.001,0.01,0.1,1.0,10.0],ytickformat='mms_exponent2'
    if undefined(tail) then ylim,prefix+'_fpi_hpca_numberDensity',0.001d,100.0d,1 else ylim,prefix+'_fpi_hpca_numberDensity',0.0001d,20.0d,1
    tname_density=prefix+'_fpi_hpca_numberDensity'
  endif else begin
    store_data,prefix+'_hpca_numberDensity',data=[prefix+'_hpca_hplus_number_density',prefix+'_hpca_heplusplus_number_density',prefix+'_hpca_heplus_number_density',prefix+'_hpca_oplus_number_density']
    options,prefix+'_hpca_numberDensity',ytitle='MMS'+probe+'!CHPCA!CNumber!CDensity',ysubtitle='[cm!U-3!N]',colors=[6,3,2,4],labels=['H+','He++','He+','O+'],labflag=-1,constant=[0.001,0.01,0.1,1.0,10.0],ytickformat='mms_exponent2'
    if undefined(tail) then ylim,prefix+'_hpca_numberDensity',0.001d,100.0d,1 else ylim,prefix+'_hpca_numberDensity',0.0001d,20.0d,1
    tname_density=prefix+'_hpca_numberDensity'
  endelse


  if not undefined(lowh_pa) then begin
    if strlen(tnames(prefix+'_hpca_hplus_phase_space_density')) gt 0 then begin
      mms_part_products,prefix+'_hpca_hplus_phase_space_density',trange=trange,mag_name=prefix+'_fgm_b_dmpa_srvy_l2_bvec',pos_name=prefix+'_mec_r_eci',energy=hpa_erange,outputs='pa',suffix='_'+erangename_h
    endif else begin
      store_data,prefix+'_hpca_hplus_phase_space_density_pa_'+erangename_h,data={x:[trange],y:[[!values.f_nan,!values.f_nan],[!values.f_nan,!values.f_nan]],v:[0.d,180.d]}
    endelse
    if strlen(tnames(prefix+'_hpca_hplus_phase_space_density_pa_'+erangename_h)) eq 0 then store_data,prefix+'_hpca_hplus_phase_space_density_pa_'+erangename_h,data={x:[trange],y:[[!values.f_nan,!values.f_nan],[!values.f_nan,!values.f_nan]],v:[0.d,180.d]}
    ylim,prefix+'_hpca_hplus_phase_space_density_pa_'+erangename_h,0.d,180.d,0
    options,prefix+'_hpca_hplus_phase_space_density_pa_'+erangename_h,spec=1,ytitle='MMS'+probe+'!CHPCA H+!C'+erangename_h+'!CPA',ysubtitle='[deg]',datagap=gap_hpca,yticks=4,minzlog=0,ztitle='eV/(cm!U2!N s sr eV)',ztickformat='mms_exponent2'
    if undefined(hpa_zrange) then hpa_zrange=pa_zrange
    zlim,prefix+'_hpca_hplus_phase_space_density_pa_'+erangename_h,hpa_zrange[0],hpa_zrange[1],1
  endif
  if not undefined(lowhe_pa) then begin
    if strlen(tnames(prefix+'_hpca_heplus_phase_space_density')) gt 0 then begin
      mms_part_products,prefix+'_hpca_heplus_phase_space_density',trange=trange,mag_name=prefix+'_fgm_b_dmpa_srvy_l2_bvec',pos_name=prefix+'_mec_r_eci',energy=hepa_erange,outputs='pa',suffix='_'+erangename_he
    endif else begin
      store_data,prefix+'_hpca_heplus_phase_space_density_pa_'+erangename_he,data={x:[trange],y:[[!values.f_nan,!values.f_nan],[!values.f_nan,!values.f_nan]],v:[0.d,180.d]}
    endelse
    if strlen(tnames(prefix+'_hpca_heplus_phase_space_density_pa_'+erangename_he)) eq 0 then store_data,prefix+'_hpca_heplus_phase_space_density_pa_'+erangename_he,data={x:[trange],y:[[!values.f_nan,!values.f_nan],[!values.f_nan,!values.f_nan]],v:[0.d,180.d]}
    ylim,prefix+'_hpca_heplus_phase_space_density_pa_'+erangename_he,0.d,180.d,0
    options,prefix+'_hpca_heplus_phase_space_density_pa_'+erangename_he,spec=1,ytitle='MMS'+probe+'!CHPCA He+!C'+erangename_he+'!CPA',ysubtitle='[deg]',datagap=gap_hpca,yticks=4,minzlog=0,ztitle='eV/(cm!U2!N s sr eV)',ztickformat='mms_exponent2'
    if undefined(hepa_zrange) then hepa_zrange=pa_zrange
    zlim,prefix+'_hpca_heplus_phase_space_density_pa_'+erangename_he,hepa_zrange[0],hepa_zrange[1],1
  endif
  if not undefined(lowo_pa) then begin
    if strlen(tnames(prefix+'_hpca_oplus_phase_space_density')) gt 0 then begin
      mms_part_products,prefix+'_hpca_oplus_phase_space_density',trange=trange,mag_name=prefix+'_fgm_b_dmpa_srvy_l2_bvec',pos_name=prefix+'_mec_r_eci',energy=opa_erange,outputs='pa',suffix='_'+erangename_o
    endif else begin
      store_data,prefix+'_hpca_oplus_phase_space_density_pa_'+erangename_o,data={x:[trange],y:[[!values.f_nan,!values.f_nan],[!values.f_nan,!values.f_nan]],v:[0.d,180.d]}
    endelse
    if strlen(tnames(prefix+'_hpca_oplus_phase_space_density_pa_'+erangename_o)) eq 0 then store_data,prefix+'_hpca_oplus_phase_space_density_pa_'+erangename_o,data={x:[trange],y:[[!values.f_nan,!values.f_nan],[!values.f_nan,!values.f_nan]],v:[0.d,180.d]}
    ylim,prefix+'_hpca_oplus_phase_space_density_pa_'+erangename_o,0.d,180.d,0
    options,prefix+'_hpca_oplus_phase_space_density_pa_'+erangename_o,spec=1,ytitle='MMS'+probe+'!CHPCA O+!C'+erangename_o+'!CPA',ysubtitle='[deg]',datagap=gap_hpca,yticks=4,minzlog=0,ztitle='eV/(cm!U2!N s sr eV)',ztickformat='mms_exponent2'
    if undefined(opa_zrange) then opa_zrange=pa_zrange
    zlim,prefix+'_hpca_oplus_phase_space_density_pa_'+erangename_o,opa_zrange[0],opa_zrange[1],1
  endif

  if not undefined(tail) then begin
    zlim,'mms'+probe+'_dis_dist_fast_energy_omni',3e3,1e6,1
    zlim,'mms'+probe+'_fpi_eEnergySpectr_omni',1e4,3e7,1
  endif
  
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
  
  tkm2re,'mms'+probe+'_mec_r_'+coord
  split_vec,'mms'+probe+'_mec_r_'+coord+'_re'
  options,'mms'+probe+'_mec_r_'+coord+'_re_x',ytitle=strupcase(coord)+'X [R!DE!N]',format='(f8.4)'
  options,'mms'+probe+'_mec_r_'+coord+'_re_y',ytitle=strupcase(coord)+'Y [R!DE!N]',format='(f8.4)'
  options,'mms'+probe+'_mec_r_'+coord+'_re_z',ytitle=strupcase(coord)+'Z [R!DE!N]',format='(f8.4)'
  tplot_options,var_label=['mms'+probe+'_mec_r_'+coord+'_re_z','mms'+probe+'_mec_r_'+coord+'_re_y','mms'+probe+'_mec_r_'+coord+'_re_x']
  tplot_options,'xmargin',[17,10]

  if not undefined(v_hpca) then begin
    if coord eq 'gse' then begin
      mms_cotrans,'mms'+probe+'_hpca_hplus_ion_bulk_velocity',in_coord='gsm',in_suffix='_GSM',out_coord='gse',out_suffix='_GSE',/ignore_dlimits
      tname_velocity='mms'+probe+'_hpca_hplus_ion_bulk_velocity_GSE'
      options,tname_velocity,constant=0.0,ytitle='MMS'+probe+'!CHPCA!CH+!CBulkV_GSE',ysubtitle='[km/s]',colors=[2,4,6],labels=['V!DX!N','V!DY!N','V!DZ!N'],labflag=-1,datagap=600.d
    endif else begin
      tname_velocity='mms'+probe+'_hpca_hplus_ion_bulk_velocity_GSM'
      options,tname_velocity,constant=0.0,ytitle='MMS'+probe+'!CHPCA!CH+!CBulkV_GSM',ysubtitle='[km/s]',colors=[2,4,6],labels=['V!DX!N','V!DY!N','V!DZ!N'],labflag=-1,datagap=600.d
    endelse
    ylim,tname_velocity,-500.d,500.d,0
  endif else begin
    tname_velocity='mms'+probe+'_fpi_iBulkV_'+coord
  endelse
  
  if undefined(plot_wave) then begin
    if not undefined(flux) then begin
      tplot,['mms_bss','mms'+probe+'_fgm_b_'+coord+'_srvy_l2_mod','mms'+probe+'_fpi_eEnergySpectr_omni','mms'+probe+'_dis_dist_fast_energy_omni','mms'+probe+'_hpca_hplus_phase_space_density_pa_'+erangename_h,'mms'+probe+'_hpca_hplus_flux_elev_0-360','mms'+probe+'_hpca_heplusplus_flux_elev_0-360','mms'+probe+'_hpca_heplus_phase_space_density_pa_'+erangename_he,'mms'+probe+'_hpca_heplus_flux_elev_0-360','mms'+probe+'_hpca_oplus_phase_space_density_pa_'+erangename_o,'mms'+probe+'_hpca_oplus_flux_elev_0-360',tname_density,tname_velocity]
    endif else begin
;      tplot,['mms_bss','mms'+probe+'_fgm_b_'+coord+'_srvy_l2_btot','mms'+probe+'_fgm_b_'+coord+'_srvy_l2_bvec','mms'+probe+'_fpi_eEnergySpectr_omni','mms'+probe+'_dis_dist_fast_energy_omni','mms'+probe+'_hpca_hplus_flux_elev_0-360','mms'+probe+'_hpca_heplusplus_flux_elev_0-360','mms'+probe+'_hpca_heplus_flux_elev_0-360','mms'+probe+'_hpca_oplus_flux_elev_0-360','mms'+probe+'_fpi_hpca_numberDensity']
      tplot,['mms_bss','mms'+probe+'_fgm_b_'+coord+'_srvy_l2_mod','mms'+probe+'_fpi_eEnergySpectr_omni','mms'+probe+'_dis_dist_fast_energy_omni','mms'+probe+'_dis_dist_fast_pa_'+erangename,'mms'+probe+'_hpca_hplus_phase_space_density_pa_'+erangename_h,'mms'+probe+'_hpca_hplus_eflux_elev_0-360','mms'+probe+'_hpca_heplusplus_eflux_elev_0-360','mms'+probe+'_hpca_heplus_phase_space_density_pa_'+erangename_he,'mms'+probe+'_hpca_heplus_eflux_elev_0-360','mms'+probe+'_hpca_oplus_phase_space_density_pa_'+erangename_o,'mms'+probe+'_hpca_oplus_eflux_elev_0-360',tname_density,tname_velocity]
    endelse
  endif else begin
    tplot,['mms_bss','mms'+probe+'_fgm_b_'+coord+'_srvy_l2_bvec','mms'+probe+'_fgm_srvy_fac_hpfilt','mms'+probe+'_fgm_srvy_fac_xy_dpwrspc_gyro','mms'+probe+'_edp_slow_fast_dce_fac_xy_dpwrspc_gyro','mms'+probe+'_fpi_eEnergySpectr_omni','mms'+probe+'_fpi_iEnergySpectr_omni','mms'+probe+'_hpca_hplus_flux_elev_0-360','mms'+probe+'_hpca_heplus_flux_elev_0-360','mms'+probe+'_hpca_oplus_flux_elev_0-360',tname_density]
  endelse

  if not undefined(plotdir) then begin

    if strlen(tnames('mms'+probe+'_dis_dist_fast_energy_omni')) eq 0 then inst_name='hpca' else inst_name='hpca_fpi'
    if undefined(roi) then roi=trange
    ts=strsplit(time_string(time_double(roi[0]),format=3,precision=-2),/extract)
    dn=plotdir+'\'+ts[0]+'\'+ts[1]
    if ~file_test(dn) then file_mkdir,dn

    thisDevice=!D.NAME
    tplot_options,'ymargin'
    tplot_options,'charsize',0.7
    tplot_options,'tickinterval',3600
    tplot_options,'xmargin',[15,15]
    options,'mms_bss',labsize=0.9
    set_plot,'ps'
    device,filename=dn+'\mms'+probe+'_'+inst_name+'_ROI_'+time_string(roi[0],format=2,precision=0)+'.ps',xsize=60.0,ysize=30.0,/color,/encapsulated,bits=8
    tplot,trange=trange
    device,/close
    set_plot,thisDevice
    !p.background=255
    !p.color=0
    if not undefined(full_bss) then options,'mms_bss',thick=5.0,panel_size=0.55,labsize=0.8 else options,'mms_bss',thick=5.0,panel_size=0.25,labsize=0.8
    window,xsize=1920,ysize=1080
    tplot_options,'xmargin',[17,13]
    tplot_options,'ymargin',[2.5,0.2]
    tplot,trange=trange
    makepng,dn+'\mms'+probe+'_'+inst_name+'_ROI_'+time_string(roi[0],format=2,precision=0)
    if not undefined(full_bss) then options,'mms_bss',thick=10.0,panel_size=0.5 else options,'mms_bss',thick=10.0,panel_size=0.2
    options,'mms_bss','labsize'
    tplot_options,'tickinterval'
    tplot_options,'ymargin'

    if undefined(no_short) then begin
      start_time=time_double(time_string(trange[0],format=0,precision=-2))
      tplot_options,'tickinterval',300
      while start_time lt trange[1] do begin
        ts=strsplit(time_string(time_double(start_time),format=3,precision=-2),/extract)
        dn=plotdir+'\'+ts[0]+'\'+ts[1]
        if ~file_test(dn) then file_mkdir,dn
        options,'mms_bss',labsize=0.9
        tplot_options,'xmargin',[15,15]
        set_plot,'ps'
        device,filename=dn+'\mms'+probe+'_'+inst_name+'_'+time_string(start_time,format=2,precision=-2)+'_1hour.ps',xsize=40.0,ysize=30.0,/color,/encapsulated,bits=8
        tplot,trange=[start_time,time_double(time_string(start_time+3601.d,format=0,precision=-2))]
        device,/close
        set_plot,thisDevice
        !p.background=255
        !p.color=0
        if not undefined(full_bss) then options,'mms_bss',thick=5.0,panel_size=0.55,labsize=0.8 else options,'mms_bss',thick=5.0,panel_size=0.25,labsize=0.8
        window,xsize=1920,ysize=1080
        tplot_options,'xmargin',[17,13]
        tplot_options,'ymargin',[2.5,0.2]
        tplot,trange=[start_time,time_double(time_string(start_time+3601.d,format=0,precision=-2))]
        makepng,dn+'\mms'+probe+'_'+inst_name+'_'+time_string(start_time,format=2,precision=-2)+'_1hour'
        if not undefined(full_bss) then options,'mms_bss',thick=10.0,panel_size=0.5 else options,'mms_bss',thick=10.0,panel_size=0.2
        options,'mms_bss','labsize'
        tplot_options,'ymargin'
        start_time=time_double(time_string(start_time+3601.d,format=0,precision=-2))
      endwhile
      tplot_options,'tickinterval'
      tplot_options,'xmargin'
    endif
    tplot_options,'charsize'
  endif
  
  if not undefined(esp_plotdir) then mms_plot_hfesp_l2_kitamura,trange_orig,probe=probe,erangename=erangename,h_erangename=erangename_h,hpca_brst=brst,full_bss=full_bss,plotdir=esp_plotdir,no_short=no_short,margin=margin,tail=tail,v_hpca=v_hpca,/gsm
  
end
