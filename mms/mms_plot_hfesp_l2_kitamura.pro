; MMS> mms_plot_hfesp_l2_kitamura,['2015-10-10/07:13:00','2015-10-10/07:20:00'],probe='1',/delete,/fpi_brst,/load_fgm,/load_fpi,/lowi_brst_pa,/lowi_brst_theta,/gsm

pro mms_plot_hfesp_l2_kitamura,trange,probe=probe,delete=delete,fpi_brst=fpi_brst,hpca_brst=hpca_brst,load_fgm=load_fgm,no_update_mec=no_update_mec,$
                               no_update_fgm=no_update_fgm,load_fpi=load_fpi,load_hpca=load_hpca,no_short=no_short,full_bss=full_bss,plotdir=plotdir,$
                               lowi_brst_pa=lowi_brst_pa,lowi_brst_theta=lowi_brst_theta,pa_erange=pa_erange,erangename=erangename,gsm=gsm

  if not undefined(delete) then store_data,'*',/delete
  if undefined(gsm) then coord='gse' else coord='gsm'
  
  status=mms_login_lasp(login_info=login_info,username=username)
  if username eq '' or username eq 'public' then public=1 else public=0

  trange=time_double(trange)
  if n_elements(trange) eq 1 then begin
    if public eq 0 then begin
      roi=mms_get_roi(trange,/next)
      trange=dblarr(2)
      trange[0]=roi[0]-60.d*210.d
      trange[1]=roi[1]+60.d*210.d
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
  probe=strcompress(string(probe),/remove_all)

  dt=trange[1]-trange[0]
  timespan,trange[0],dt,/seconds
  
  prefix='mms'+probe
  if not undefined(brst_hpca) then hpca_data_rate='brst' else hpca_data_rate='srvy'
  
  mms_init
  loadct2,43
  time_stamp,/off
  if not undefined(load_fgm) then mms_fgm_plot_kitamura,trange=trange,probe=probe,no_update=no_update_fgm,/no_avg,/load_fgm,/no_plot
  if strlen(tnames(prefix+'_fgm_b_dmpa_srvy_l2_btot')) gt 0 then begin
    get_data,prefix+'_fgm_b_dmpa_srvy_l2_btot',data=btot
    store_data,prefix+'_fgm_fce',data={x:btot.x,y:27.99d*btot.y}
    options,prefix+'_fgm_fce',colors=0,thick=1,datagap=0.13d
    undefine,btot
  endif
  if strlen(tnames('mms'+probe+'_mec_r_eci')) eq 0 then mms_load_mec,trange=trange,probes=probe,no_update=no_update_mec
  
  if not undefined(load_fpi) then mms_fpi_plot_kitamura,trange=trange,probe=probe,no_update_fpi=no_update_fpi,/no_plot,/load_fpi,/time_clip
  if strlen(tnames(prefix+'_dis_dist_fast_energy_omni')) eq 0 then copy_data,prefix+'_fpi_iEnergySpectr_omni',prefix+'_dis_dist_fast_energy_omni'
  if strlen(tnames(prefix+'_fpi_iEnergySpectr_omni')) gt 0 then begin
    get_data,prefix+'_fpi_iEnergySpectr_omni',lim=l
    store_data,prefix+'_dis_dist_fast_energy_omni',lim=l
  endif
  zlim,prefix+'_dis_dist_fast_energy_omni',1e4,1e8,1
  options,prefix+'_dis_dist_fast_energy_omni',minzlog=0,datagap=4.6d,ytitle='MMS'+probe+'_DIS!CiEnergySpectr!Comni',ysubtitle='[eV]',ztitle='eV/(cm!U2!N s sr eV)',ytickformat='mms_exponent2',ztickformat='mms_exponent2'
  
  if not undefined(fpi_brst) then begin
    if not undefined(load_fpi) then mms_load_fpi,probes=probe,trange=trange,datatype='dis-moms',level='l2',data_rate='brst',no_update=no_update_fpi,/center_measurement,/time_clip
    ylim,prefix+'_dis_energyspectr_omni_avg',1e1,3e4,1
    zlim,prefix+'_dis_energyspectr_omni_avg',1e4,1e8,1
    options,prefix+'_dis_energyspectr_omni_avg',minzlog=0,datagap=0.16d,ytitle='MMS'+probe+'_DIS!CiEnergySpectr!Comni',ysubtitle='[eV]',ztitle='eV/(cm!U2!N s sr eV)',ytickformat='mms_exponent2',ztickformat='mms_exponent2'
    if not undefined(lowi_brst_pa) or not undefined(lowi_brst_theta) then begin
      if undefined(pa_erange) then pa_erange=[1.d,300.d]
      if pa_erange[0] gt 100.d and pa_erange[1] ge 1000.d then begin
        erangename=strcompress(string(pa_erange[0]/1000.d,format='(f5.1)'),/remove_all)+'-'+strcompress(string(pa_erange[1]/1000.d,format='(f5.1)'),/remove_all)+'keV'
      endif else begin
        erangename=strcompress(string(pa_erange[0],format='(i6)'),/remove_all)+'-'+strcompress(string(pa_erange[1],format='(i6)'),/remove_all)+'eV'
      endelse
      if strlen(tnames(prefix+'_dis_dist_brst')) eq 0 then mms_load_fpi,probe=probe,trange=trange,data_rate='brst',level='l2',datatype='dis-dist',no_update=no_update_fpi,/center_measurement,/time_clip
      mms_part_products,prefix+'_dis_dist_brst',trange=trange,outputs='energy',suffix='_omni'
      ylim,prefix+'_dis_dist_brst_energy_omni',1e1,3e4,1
      zlim,prefix+'_dis_dist_brst_energy_omni',1e4,1e8,1
      options,prefix+'_dis_dist_brst_energy_omni',minzlog=0,datagap=0.16d,ytitle='MMS'+probe+'_DIS!CiEnergySpectr!Comni',ysubtitle='[eV]',ztitle='eV/(cm!U2!N s sr eV)',ytickformat='mms_exponent2',ztickformat='mms_exponent2'
      store_data,prefix+'_dis_energy_omni',data=[prefix+'_dis_dist_fast_energy_omni',prefix+'_dis_dist_brst_energy_omni']
    endif else begin
      store_data,prefix+'_dis_energy_omni',data=[prefix+'_dis_dist_fast_energy_omni',prefix+'_dis_energyspectr_omni_avg']
    endelse
    if not undefined(lowi_brst_pa) then begin
      mms_part_products,prefix+'_dis_dist_brst',trange=trange,mag_name=prefix+'_fgm_b_dmpa_srvy_l2_bvec',pos_name=prefix+'_mec_r_eci',energy=pa_erange,outputs='pa',suffix='_'+erangename
      ylim,prefix+'_dis_dist_brst_pa_'+erangename,0.d,180.d,0
      options,prefix+'_dis_dist_brst_pa_'+erangename,spec=1,ytitle='MMS'+probe+'!CFPI DIS!C'+erangename+'!CPA',ysubtitle='[deg]',datagap=0.16d,yticks=4,minzlog=0,ztitle='eV/(cm!U2!N s sr eV)',ztickformat='mms_exponent2'
      zlim,prefix+'_dis_dist_brst_pa_'+erangename,1e3,1e7,1
    endif
    if not undefined(lowi_brst_theta) then begin
      mms_part_products,prefix+'_dis_dist_brst',trange=trange,energy=pa_erange,outputs='theta',suffix='_'+erangename
      ylim,prefix+'_dis_dist_brst_theta_'+erangename,-90.d,90.d,0
      options,prefix+'_dis_dist_brst_theta_'+erangename,spec=1,constant=0.0,ytitle='MMS'+probe+'!CFPI DIS!C'+erangename+'!CTheta',ysubtitle='[deg]',datagap=0.16d,yticks=4,minzlog=0,ztitle='eV/(cm!U2!N s sr eV)',ztickformat='mms_exponent2'
      zlim,prefix+'_dis_dist_brst_theta_'+erangename,1e3,1e7,1
    endif
    dis_spec=prefix+'_dis_energy_omni'
    options,dis_spec,minzlog=0,ytitle='MMS'+probe+'_DIS!CiEnergySpectr!Comni',ysubtitle='[eV]',ztitle='eV/(cm!U2!N s sr eV)',ytickformat='mms_exponent2',ztickformat='mms_exponent2'
    ylim,dis_spec,1e1,3e4,1
    zlim,dis_spec,1e4,1e8,1
    join_vec,prefix+'_dis_bulk'+['x','y','z']+'_dbcs_brst','mms'+probe+'_dis_bulkV_DSC'
    options,prefix+'_dis_bulkV_DSC',constant=0.0,ytitle='MMS'+probe+'_DIS!CBulkV!CDBCS',ysubtitle='[km/s]',colors=[2,4,1],labels=['V!DX!N','V!DY!N','V!DZ!N'],labflag=-1,datagap=0.16d
    mms_cotrans,prefix+'_dis_bulkV',in_coord='dmpa',in_suffix='_DSC',out_coord='gse',out_suffix='_gse',/ignore_dlimits
    options,prefix+'_dis_bulkV_gse',constant=0.0,ytitle='MMS'+probe+'_DIS!CBulkV!CGSE',ysubtitle='[km/s]',colors=[2,4,6],labels=['V!DX!N','V!DY!N','V!DZ!N'],labflag=-1,datagap=0.16d
    mms_cotrans,prefix+'_dis_bulkV',in_coord='gse',in_suffix='_gse',out_coord='gsm',out_suffix='_gsm',/ignore_dlimits
    options,prefix+'_dis_bulkV_gsm',constant=0.0,ytitle='MMS'+probe+'_DIS!CBulkV!CGSM',ysubtitle='[km/s]',colors=[2,4,6],labels=['V!DX!N','V!DY!N','V!DZ!N'],labflag=-1,datagap=0.16d
    tname_velocity=prefix+'_dis_bulkV_'+coord
    ion_pa_rate='brst'
  endif else begin
    dis_spec=prefix+'_dis_dist_fast_energy_omni'
    tname_velocity=prefix+'_fpi_iBulkV_'+coord
    ion_pa_rate='fast'
  endelse

  if not undefined(load_hpca) then begin
    mms_load_hpca,probes=probe,trange=trange,datatype='moments',level='l2',data_rate=hpca_data_rate,no_update=no_update_hpca,/time_clip
    if undefined(hpca_brst) then begin
      options,prefix+'_hpca_*plus_number_density',datagap=600.d
    endif else begin
      options,prefix+'_hpca_*plus_number_density',datagap=25.d
    endelse
  endif
  
  if strlen(tnames(prefix+'_hpca_hplus_number_density')) gt 0 then begin
    store_data,prefix+'_fpi_hpca_numberDensity',data=[prefix+'_dis_numberdensity_dbcs_fast',prefix+'_hpca_hplus_number_density',prefix+'_hpca_heplusplus_number_density',prefix+'_hpca_heplus_number_density',prefix+'_hpca_oplus_number_density']
    options,prefix+'_fpi_hpca_numberDensity',ytitle='MMS'+probe+'!CFPI_HPCA!CNumber!CDensity',ysubtitle='[cm!U-3!N]',colors=[0,6,3,2,4],labels=['DIS','H+','He++','He+','O+'],labflag=-1,constant=[0.01,0.1,1.0,10.0],ytickformat='mms_exponent2'
    ylim,prefix+'_fpi_hpca_numberDensity',0.001d,100.0d,1
    tname_density=prefix+'_fpi_hpca_numberDensity'
    get_data,prefix+'_hpca_hplus_number_density',data=nh
    get_data,prefix+'_hpca_heplusplus_number_density',data=na
    get_data,prefix+'_hpca_heplus_number_density',data=nhe
    get_data,prefix+'_hpca_oplus_number_density',data=no
    store_data,prefix+'_hpca_total_number_density',data={x:nh.x,y:nh.y+nhe.y+na.y+no.y}
    store_data,prefix+'_hpca_fp',data={x:nh.x,y:8979.d*sqrt(nh.y+nhe.y+na.y+no.y)}
    if undefined(hpca_brst) then options,prefix+'_hpca_fp',colors=5,thick=1,datagap=600.d else options,prefix+'_hpca_fp',colors=5,thick=1,datagap=25.d
    undefine,nh,nhe,na,no
  endif else begin
    options,prefix+'_des_numberdensity_dbcs_fast',datagap=4.6d
    options,prefix+'_dis_numberdensity_dbcs_fast',datagap=4.6d
    options,prefix+'_dis_numberdensity_dbcs_brst',datagap=0.16d
    store_data,prefix+'_fpi_numberdensity',data=[prefix+'_des_numberdensity_dbcs_fast',prefix+'_dis_numberdensity_dbcs_fast',prefix+'_dis_numberdensity_dbcs_brst']
    options,prefix+'_fpi_numberdensity',ytitle='MMS'+probe+'!CFPI!CNumber!CDensity',ysubtitle='[cm!U-3!N]',colors=[0,6,4],labels=['Electron','Ion','Ion_brst'],labflag=-1,constant=[0.01,0.1,1.0,10.0],ytickformat='mms_exponent2'
    ylim,prefix+'_fpi_numberdensity',0.001d,100.0d,1
    tname_density=prefix+'_fpi_numberdensity'
  endelse
  get_data,prefix+'_dis_numberdensity_dbcs_fast',data=ni
  store_data,prefix+'_fpi_fp',data={x:ni.x,y:8979.d*sqrt(ni.y)}
  options,prefix+'_fpi_fp',colors=255,thick=1.25,datagap=4.6d
  undefine,ni

  mms_load_edp,trange=[trange[0]-60.d,trange[1]+60.d],probes=probe,level='l2',data_rate='srvy',datatype='hfesp',/time_clip
  ylim,prefix+'_edp_hfesp_srvy_l2',0.d,6.e4,0
  zlim,prefix+'_edp_hfesp_srvy_l2',1e-11,1e-5,1
  options,prefix+'_edp_hfesp_srvy_l2',panel_size=2.0,ytitle='MMS'+probe+'!CEDP!CHF',ysubtitle='[Hz]',ztitle='(V/m)!U2!N Hz!U-1!N',ztickformat='mms_exponent2',datagap=20.d
  store_data,prefix+'_fp_fc_hfesp',data=[prefix+'_edp_hfesp_srvy_l2',prefix+'_fgm_fce',prefix+'_hpca_fp',prefix+'_fpi_fp']
  ylim,prefix+'_fp_fc_hfesp',0.d,6.e4,0
  options,prefix+'_fp_fc_hfesp',panel_size=2.0,ytitle='MMS'+probe+'_EDP_HF!CFpe_DIS(White)!CFpe_HPCA(Yellow)!CFce_FGM(Black)',ysubtitle='[Hz]',ztitle='(V/m)!U2!N Hz!U-1!N',ztickformat='mms_exponent2'

  if undefined(no_bss) and not undefined(full_bss) then begin
    time_stamp,/on
    if public eq 0 then begin
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

  if undefined(erangename) then erangename=''

  tplot,['mms_bss','mms'+probe+'_fgm_b_'+coord+'_srvy_l2_mod','mms'+probe+'_fpi_eEnergySpectr_omni',dis_spec,'mms'+probe+'_dis_dist_'+ion_pa_rate+'_pa_'+erangename,'mms'+probe+'_dis_dist_brst_theta_'+erangename,'mms'+probe+'_hpca_hplus_phase_space_density_pa_'+erangename,'mms'+probe+'_hpca_hplus_eflux_elev_0-360','mms'+probe+'_fp_fc_hfesp',tname_density,tname_velocity]

  if not undefined(plotdir) then begin

    if strlen(tnames('mms'+probe+'_hpca_fp')) eq 0 then inst_name='fpi_hfesp' else inst_name='hpca_fpi_hfesp'
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
      while start_time lt trange[1]-1.d*3600.d do begin
        options,'mms_bss',labsize=0.9
        tplot_options,'xmargin',[15,15]
        set_plot,'ps'
        device,filename=dn+'\mms'+probe+'_'+inst_name+'_'+time_string(start_time,format=2,precision=-2)+'_1hour.ps',xsize=40.0,ysize=30.0,/color,/encapsulated,bits=8
        tplot,trange=[start_time,start_time+1.d*3600.d]
        device,/close
        set_plot,thisDevice
        !p.background=255
        !p.color=0
        if not undefined(full_bss) then options,'mms_bss',thick=5.0,panel_size=0.55,labsize=0.8 else options,'mms_bss',thick=5.0,panel_size=0.25,labsize=0.8 
        window,xsize=1920,ysize=1080
        tplot_options,'xmargin',[17,13]
        tplot_options,'ymargin',[2.5,0.2]
        tplot,trange=[start_time,start_time+1.d*3600.d]
        makepng,dn+'\mms'+probe+'_'+inst_name+'_'+time_string(start_time,format=2,precision=-2)+'_1hour'
        if not undefined(full_bss) then options,'mms_bss',thick=10.0,panel_size=0.5 else options,'mms_bss',thick=10.0,panel_size=0.2
        options,'mms_bss','labsize'
        tplot_options,'ymargin'
        start_time=start_time+1.d*3600.d
      endwhile
      tplot_options,'tickinterval'
      tplot_options,'xmargin'
    endif
    tplot_options,'charsize'
  endif
  
end
