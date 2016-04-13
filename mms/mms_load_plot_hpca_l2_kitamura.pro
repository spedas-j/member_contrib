;EXAMPLE:
;MMS>  mms_load_plot_hpca_l2_kitamura,'2015-09-01/08:00:00',probe='1',/delete,/gsm,/lowi_pa,/lowh_pa
;MMS>  mms_load_plot_hpca_l2_kitamura,['2015-09-01/12:00:00','2015-09-01/13:00:00'],probe='1',/no_update_dfg,/no_update_fpi,/no_update_hpca,/delete,/no_bss,/gsm
;MMS>  mms_load_plot_hpca_l2_kitamura,'2015-09-01/08:00:00',probe='1',/brst,/delete,/gsm
;MMS>  mms_load_plot_hpca_l2_kitamura,['2015-09-01/08:00:00','2015-09-02/00:00:00'],probe='1',/brst,/no_update_dfg,/no_update_fpi,/no_update_hpca,/delete,/no_bss,/gsm

pro mms_load_plot_hpca_l2_kitamura,trange,probe=probe,brst=brst,no_load_fgm=no_load_fgm,dfg_ql=dfg_ql,no_update_fgm=no_update_fgm,no_load_fpi=no_load_fpi,$
                                   no_update_fpi=no_update_fpi,no_update_hpca=no_update_hpca,no_update_mec=no_update_mec,delete=delete,plot_wave=plot_wave,$
                                   no_bss=no_bss,gsm=gsm,flux=flux,lowi_pa=lowi_pa,lowh_pa=lowh_pa,lowhe_pa=lowhe_pa,lowo_pa=lowo_pa,pa_erange=pa_erange,$
                                   zrange=zrange,plotdir=plotdir,no_short=no_short

  if not undefined(delete) then store_data,'*',/delete
  if undefined(gsm) then coord='gse' else coord='gsm'
  
  status=mms_login_lasp(login_info=login_info,username=username)
  if username eq '' or username eq 'public' then public=1 else public=0

  trange=time_double(trange)
  if n_elements(trange) eq 1 then begin
    if public eq 0 then begin
      roi=mms_get_roi(trange,/next)
      trange=dblarr(2)
      trange[0]=roi[0]-60.d*180.d
      trange[1]=roi[1]+60.d*180.d
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
  if keyword_set(brst) then data_rate='brst' else data_rate='srvy'
  
  mms_init
  loadct2,43
  time_stamp,/off
  if undefined(no_load_fgm) then mms_fgm_plot_kitamura,trange=trange,probe=probe,dfg_ql=dfg_ql,no_update=no_update_fgm,/no_avg,/load_fgm,/no_plot
  if strlen(tnames('mms'+probe+'_mec_r_eci')) eq 0 then mms_load_mec,trange=trange,probes=probe,no_update=no_update_mec
  
  if undefined(pa_erange) then pa_erange=[1.d,300.d]
  if pa_erange[0] gt 100.d and pa_erange[1] ge 1000.d then begin
    erangename=strcompress(string(pa_erange[0]/1000.d,format='(f5.1)'),/remove_all)+'-'+strcompress(string(pa_erange[1]/1000.d,format='(f5.1)'),/remove_all)+'keV'
  endif else begin
    erangename=strcompress(string(pa_erange[0],format='(i6)'),/remove_all)+'-'+strcompress(string(pa_erange[1],format='(i6)'),/remove_all)+'eV'
  endelse
 
  if not undefined(lowi_pa) then begin
    mms_load_fpi,probe=probe,trange=trange,data_rate='fast',level='l2',datatype='dis-dist',no_update=no_update_fpi,/center_measurement,/time_clip
    if strlen(tnames(prefix+'_dis_dist_fast')) gt 0 then begin
      mms_part_products,prefix+'_dis_dist_fast',trange=trange,outputs='energy',suffix='_omni'
      mms_part_products,prefix+'_dis_dist_fast',trange=trange,mag_name=prefix+'_fgm_b_dmpa_srvy_l2_bvec',pos_name=prefix+'_mec_r_eci',energy=pa_erange,outputs='pa',suffix='_'+erangename
      ylim,prefix+'_dis_dist_fast_pa_'+erangename,0.d,180.d,0
      options,prefix+'_dis_dist_fast_pa_'+erangename,spec=1,ytitle='MMS'+probe+'!CFPI DIS!C'+erangename+'!CPA',ysubtitle='[deg]',datagap=5.d,yticks=4,minzlog=0,ztitle='eV/(cm!U2!N s sr eV)',ztickformat='mms_exponent2'
      zlim,prefix+'_dis_dist_fast_pa_'+erangename,1e3,1e7,1
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
  endif
  
  if undefined(no_load_fpi) then mms_fpi_plot_kitamura,trange=trange,probe=probe,no_update_fpi=no_update_fpi,/no_plot,/load_fpi
  if strlen(tnames(prefix+'_dis_dist_fast_energy_omni')) eq 0 then copy_data,prefix+'_fpi_iEnergySpectr_omni',prefix+'_dis_dist_fast_energy_omni'
  if strlen(tnames(prefix+'_fpi_iEnergySpectr_omni')) gt 0 then begin
    get_data,prefix+'_fpi_iEnergySpectr_omni',lim=l
    store_data,prefix+'_dis_dist_fast_energy_omni',lim=l
  endif
  zlim,prefix+'_dis_dist_fast_energy_omni',1e4,1e8,1
  options,prefix+'_dis_dist_fast_energy_omni',minzlog=0

  mms_load_hpca,probes=probe,trange=trange,datatype='moments',level='l2',data_rate=data_rate,no_update=no_update_hpca,/time_clip
  mms_load_hpca,probes=probe,trange=trange,datatype='ion',level='l2',data_rate=data_rate,no_update=no_update_hpca,/time_clip
  mms_hpca_calc_anodes,fov=[0,360],probe=probe

  ion_sp=[['hplus','heplusplus','heplus','oplus'],['H!U+!N','He!U++!N','He!U+!N','O!U+!N']]
  if undefined(brst) then begin
    for s=0,n_elements(ion_sp[*,0])-1 do begin
      get_data,prefix+'_hpca_'+ion_sp[s,0]+'_flux_elev_0-360',data=d
      for i=0l,n_elements(d.x)-1 do begin
        for j=0l,n_elements(d.v)-1 do d.y[i,j]=d.y[i,j]*d.v[j]
      endfor
      store_data,prefix+'_hpca_'+ion_sp[s,0]+'_eflux_elev_0-360',data=d
      options,prefix+'_hpca_'+ion_sp[s,0]+'_flux_elev_0-360',spec=1,datagap=600.d,ytitle='MMS'+probe+'!CHPCA L2!C'+ion_sp[s,1]+' srvy!CELEV!C0-360',ysubtitle='[eV]',ytickformat='mms_exponent2',ztitle='1/(cm!U2!N s sr eV)',ztickformat='mms_exponent2'
      options,prefix+'_hpca_'+ion_sp[s,0]+'_eflux_elev_0-360',spec=1,datagap=600.d,ytitle='MMS'+probe+'!CHPCA L2!C'+ion_sp[s,1]+' srvy!CELEV!C0-360',ysubtitle='[eV]',ytickformat='mms_exponent2',ztitle='eV/(cm!U2!N s sr eV)',ztickformat='mms_exponent2'
    endfor
    if not undefined(zrange) and not undefined(flux) then zlim,prefix+'_hpca_*plus_flux_elev_0-360',zrange[0],zrange[1],1 else zlim,prefix+'_hpca_*plus_flux_elev_0-360',0.3d,3e6,1 
    ylim,prefix+'_hpca_*plus_eflux_elev_0-360',1e0,4e4,1
    if not undefined(zrange) and undefined(flux) then zlim,prefix+'_hpca_*plus_eflux_elev_0-360',zrange[0],zrange[1],1 else zlim,prefix+'_hpca_*plus_eflux_elev_0-360',1e4,1e8,1
    options,prefix+'_hpca_*plus_number_density',datagap=600.d
  endif else begin
    for s=0,n_elements(ion_sp[*,0])-1 do options,[prefix+'_hpca_'+ion_sp[s,0]+'_flux_elev_0-360'],spec=1,datagap=0.75d,ytitle='MMS'+probe+'!CHPCA L2!C'+ion_sp[s,1]+' burst!CELEV 0-360',ysubtitle='[eV]',ytickformat='mms_exponent2',ztitle='1/(cm!U2!N s sr eV)',ztickformat='mms_exponent2'
    zlim,[prefix+'_hpca_*plus_flux_elev_0-360'],1.d,1000.d,1
    options,prefix+'_hpca_*plus_number_density',datagap=25.d
  endelse
  
  if strlen(tnames(prefix+'_fpi_DISnumberDensity')) gt 0 then begin
    store_data,prefix+'_fpi_hpca_numberDensity',data=[prefix+'_fpi_DISnumberDensity',prefix+'_hpca_hplus_number_density',prefix+'_hpca_heplusplus_number_density',prefix+'_hpca_heplus_number_density',prefix+'_hpca_oplus_number_density']
    options,prefix+'_fpi_hpca_numberDensity',ytitle='MMS'+probe+'!CFPI_HPCA!CNumber!CDensity',ysubtitle='[cm!U-3!N]',colors=[0,6,3,2,4],labels=['DIS','H+','He++','He+','O+'],labflag=-1,constant=[0.01,0.1,1.0,10.0],ytickformat='mms_exponent2'
    ylim,prefix+'_fpi_hpca_numberDensity',0.001d,100.0d,1
    tname_density=prefix+'_fpi_hpca_numberDensity'
  endif else begin
    store_data,prefix+'_hpca_numberDensity',data=[prefix+'_hpca_hplus_number_density',prefix+'_hpca_heplusplus_number_density',prefix+'_hpca_heplus_number_density',prefix+'_hpca_oplus_number_density']
    options,prefix+'_hpca_numberDensity',ytitle='MMS'+probe+'!CHPCA!CNumber!CDensity',ysubtitle='[cm!U-3!N]',colors=[6,3,2,4],labels=['H+','He++','He+','O+'],labflag=-1,constant=[0.01,0.1,1.0,10.0],ytickformat='mms_exponent2'
    ylim,prefix+'_hpca_numberDensity',0.001d,100.0d,1
    tname_density=prefix+'_hpca_numberDensity'
  endelse

  if not undefined(lowh_pa) then begin
    mms_part_products,prefix+'_hpca_hplus_phase_space_density',trange=trange,mag_name=prefix+'_fgm_b_dmpa_srvy_l2_bvec',pos_name=prefix+'_mec_r_eci',energy=pa_erange,outputs='pa',suffix='_'+erangename
    ylim,prefix+'_hpca_hplus_phase_space_density_pa_'+erangename,0.d,180.d,0
    options,prefix+'_hpca_hplus_phase_space_density_pa_'+erangename,spec=1,ytitle='MMS'+probe+'!CHPCA H+!C'+erangename+'!CPA',ysubtitle='[deg]',datagap=600.d,yticks=4,minzlog=0,ztitle='eV/(cm!U2!N s sr eV)',ztickformat='mms_exponent2'
    zlim,prefix+'_hpca_hplus_phase_space_density_pa_'+erangename,1e3,1e7,1
  endif
  if not undefined(lowhe_pa) then begin
    mms_part_products,prefix+'_hpca_heplus_phase_space_density',trange=trange,mag_name=prefix+'_fgm_b_dmpa_srvy_l2_bvec',pos_name=prefix+'_mec_r_eci',energy=pa_erange,outputs='pa',suffix='_'+erangename
    ylim,prefix+'_hpca_heplus_phase_space_density_pa_'+erangename,0.d,180.d,0
    options,prefix+'_hpca_heplus_phase_space_density_pa_'+erangename,spec=1,ytitle='MMS'+probe+'!CHPCA He+!C'+erangename+'!CPA',ysubtitle='[deg]',datagap=600.d,yticks=4,minzlog=0,ztitle='eV/(cm!U2!N s sr eV)',ztickformat='mms_exponent2'
    zlim,prefix+'_hpca_heplus_phase_space_density_pa_'+erangename,1e3,1e7,1
  endif
  if not undefined(lowo_pa) then begin
    mms_part_products,prefix+'_hpca_oplus_phase_space_density',trange=trange,mag_name=prefix+'_fgm_b_dmpa_srvy_l2_bvec',pos_name=prefix+'_mec_r_eci',energy=pa_erange,outputs='pa',suffix='_'+erangename
    ylim,prefix+'_hpca_oplus_phase_space_density_pa_'+erangename,0.d,180.d,0
    options,prefix+'_hpca_oplus_phase_space_density_pa_'+erangename,spec=1,ytitle='MMS'+probe+'!CHPCA O+!C'+erangename+'!CPA',ysubtitle='[deg]',datagap=600.d,yticks=4,minzlog=0,ztitle='eV/(cm!U2!N s sr eV)',ztickformat='mms_exponent2'
    zlim,prefix+'_hpca_oplus_phase_space_density_pa_'+erangename,1e3,1e7,1
  endif
  
  if undefined(no_bss) and public eq 0 then begin
    time_stamp,/on
    spd_mms_load_bss,datatype=['fast','status']
    split_vec,'mms_bss_status'
    calc,'"mms_bss_complete"="mms_bss_status_0"-0.1d'
    calc,'"mms_bss_incomplete"="mms_bss_status_1"-0.2d'
    calc,'"mms_bss_pending"="mms_bss_status_3"-0.3d'
    del_data,'mms_bss_status_?'
    store_data,'mms_bss',data=['mms_bss_fast','mms_bss_complete','mms_bss_incomplete','mms_bss_pending']
    options,'mms_bss',colors=[6,2,3,4],panel_size=0.5,thick=10.0,xstyle=4,ystyle=4,ticklen=0,yrange=[-0.325d,0.025d],ylabel='',labels=['ROI','Complete','Incomplete','Pending'],labflag=-1
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

  if coord eq 'gse' then begin
    mms_cotrans,'mms'+probe+'_hpca_hplus_ion_bulk_velocity',in_coord='gsm',in_suffix='_GSM',out_coord='gse',out_suffix='_GSE',/ignore_dlimits
    tname_velocity='mms'+probe+'_hpca_hplus_ion_bulk_velocity_GSE'
    options,tname_velocity,constant=0.0,ytitle='MMS'+probe+'!CHPCA!CH+!CBulkV_GSE',ysubtitle='[km/s]',colors=[2,4,6],labels=['V!DX!N','V!DY!N','V!DZ!N'],labflag=-1,datagap=600.d
  endif else begin
    tname_velocity='mms'+probe+'_hpca_hplus_ion_bulk_velocity_GSM'
    options,tname_velocity,constant=0.0,ytitle='MMS'+probe+'!CHPCA!CH+!CBulkV_GSM',ysubtitle='[km/s]',colors=[2,4,6],labels=['V!DX!N','V!DY!N','V!DZ!N'],labflag=-1,datagap=600.d
  endelse    
  
  if undefined(wave_plot) then begin
    if not undefined(flux) then begin
      tplot,['mms_bss','mms'+probe+'_fgm_b_'+coord+'_srvy_l2_mod','mms'+probe+'_fpi_eEnergySpectr_omni','mms'+probe+'_dis_dist_fast_energy_omni','mms'+probe+'_hpca_hplus_phase_space_density_pa_'+erangename,'mms'+probe+'_hpca_hplus_flux_elev_0-360','mms'+probe+'_hpca_heplusplus_flux_elev_0-360','mms'+probe+'_hpca_heplus_phase_space_density_pa_'+erangename,'mms'+probe+'_hpca_heplus_flux_elev_0-360','mms'+probe+'_hpca_oplus_phase_space_density_pa_'+erangename,'mms'+probe+'_hpca_oplus_flux_elev_0-360',tname_density]
    endif else begin
;      tplot,['mms_bss','mms'+probe+'_fgm_b_'+coord+'_srvy_l2_btot','mms'+probe+'_fgm_b_'+coord+'_srvy_l2_bvec','mms'+probe+'_fpi_eEnergySpectr_omni','mms'+probe+'_dis_dist_fast_energy_omni','mms'+probe+'_hpca_hplus_flux_elev_0-360','mms'+probe+'_hpca_heplusplus_flux_elev_0-360','mms'+probe+'_hpca_heplus_flux_elev_0-360','mms'+probe+'_hpca_oplus_flux_elev_0-360','mms'+probe+'_fpi_hpca_numberDensity']
      tplot,['mms_bss','mms'+probe+'_fgm_b_'+coord+'_srvy_l2_mod','mms'+probe+'_fpi_eEnergySpectr_omni','mms'+probe+'_dis_dist_fast_energy_omni','mms'+probe+'_dis_dist_fast_pa_'+erangename,'mms'+probe+'_hpca_hplus_phase_space_density_pa_'+erangename,'mms'+probe+'_hpca_hplus_eflux_elev_0-360','mms'+probe+'_hpca_heplusplus_eflux_elev_0-360','mms'+probe+'_hpca_heplus_phase_space_density_pa_'+erangename,'mms'+probe+'_hpca_heplus_eflux_elev_0-360','mms'+probe+'_hpca_oplus_phase_space_density_pa_'+erangename,'mms'+probe+'_hpca_oplus_eflux_elev_0-360',tname_density,tname_velocity]
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
    tplot_options,'tickinterval',3600
    set_plot,'ps'
    device,filename=dn+'\mms'+probe+'_'+inst_name+'_ROI_'+time_string(roi[0],format=2,precision=0)+'.ps',xsize=60.0,ysize=30.0,/color,/encapsulated,bits=8
    tplot,trange=trange
    device,/close
    set_plot,thisDevice
    !p.background=255
    !p.color=0
    options,'mms_bss',thick=5.0,panel_size=0.55,labsize=0.8
    window,xsize=1920,ysize=1080
    tplot_options,'ymargin',[2.5,0.2]
    tplot,trange=trange
    makepng,dn+'\mms'+probe+'_'+inst_name+'_ROI_'+time_string(roi[0],format=2,precision=0)
    options,'mms_bss',thick=10.0,panel_size=0.5
    options,'mms_bss','labsize'
    tplot_options,'tickinterval'
    tplot_options,'ymargin'

    if undefined(no_short) then begin
      start_time=time_double(time_string(trange[0],format=0,precision=-2))
      tplot_options,'tickinterval',300
      while start_time lt roi[1]+2.d*3600.d do begin
        set_plot,'ps'
        device,filename=dn+'\mms'+probe+'_'+inst_name+'_'+time_string(start_time,format=2,precision=-2)+'_1hour.ps',xsize=40.0,ysize=30.0,/color,/encapsulated,bits=8
        tplot,trange=[start_time,start_time+1.d*3600.d]
        device,/close
        set_plot,thisDevice
        !p.background=255
        !p.color=0
        options,'mms_bss',thick=5.0,panel_size=0.55,labsize=0.8
        window,xsize=1920,ysize=1080
        tplot_options,'ymargin',[2.5,0.2]
        tplot,trange=[start_time,start_time+1.d*3600.d]
        makepng,dn+'\mms'+probe+'_'+inst_name+'_'+time_string(start_time,format=2,precision=-2)+'_1hour'
        options,'mms_bss',thick=10.0,panel_size=0.5
        options,'mms_bss','labsize'
        tplot_options,'ymargin'
        start_time=start_time+1.d*3600.d
      endwhile
      tplot_options,'tickinterval'
    endif

  endif

end
