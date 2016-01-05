;+
; PROCEDURE:
;         mms_fpi_brst_specplot_kitamura
;
; PURPOSE:
;         Plot magnetic field (DFG) and FPI data obtained by MMS
;
; KEYWORDS:
;         trange:       time range of interest [starttime, endtime] with the format
;                       ['YYYY-MM-DD','YYYY-MM-DD'] or to specify more or less than a day
;                       ['YYYY-MM-DD/hh:mm:ss','YYYY-MM-DD/hh:mm:ss']
;         probe:        a probe - value for MMS SC # (default value is '3')
;         no_plot:      set this flag to skip plotting
;         magplot:      set this flag to plot with dfg data
;         no_load:      set this flag to skip loading data
;         dfg_ql:       set this flag to use dfg ql data forcibly. if not set, l2pre data
;                       is used, if available (use with magplot flag)
;         no_update:    set this flag to preserve the original fpi data. if not set and
;                       newer data is found the existing data will be overwritten
;         direc_prot:   set this flag to plot fpi burst E-t spectrogram (+/- X, Y, and Z
;                       directions) and velocities, and dfg data
;         no_ele:       set this flag to skip load and plot electron data
;         no_ion:       set this flag to skip load and plot ion data
;
; EXAMPLE:
;
;     To plot fast plasma investigation (FPI) burst E-t spectrogram (averaged) and moments, and dfg data
;     MMS>  mms_fpi_brst_specplot_kitamura,trange=['2015-09-02/15:25:00','2015-09-02/15:30:00'],probe='3',/magplot
;     MMS>  mms_fpi_brst_specplot_kitamura,trange=['2015-09-02/15:25:00','2015-09-02/15:30:00'],probe='3',/magplot,/no_update
;
;     To plot fast plasma investigation (FPI) burst E-t spectrogram (+/- X, Y, and Z directions) and velocities, and dfg data
;     MMS>  mms_fpi_brst_specplot_kitamura,trange=['2015-09-02/15:25:00','2015-09-02/15:30:00'],probe='3',/direc_plot
;     MMS>  mms_fpi_brst_specplot_kitamura,trange=['2015-09-02/15:25:00','2015-09-02/15:30:00'],probe='3',/direc_plot,/no_update
;
; NOTES:
;     1) See the notes in mms_load_data for rules on the use of MMS data
;     2) DFG data should be loaded before running this procedure if magplot flag is set
;     3) A very large memory space is necessary to plot longer than ~10 minutes for electrons
;     4) This calculate average of differential energy fluxes obtained by detectors (not for scientific use)
;        Soild angles that covered by each detector are not taken into account.
;     5) +/- X and Y directions include data within 45 degress from X-Y plane
;     6) +/- Z directions include data within 45 degress from Z axis
;-

pro mms_fpi_brst_specplot_kitamura,trange=trange,probe=probe,no_plot=no_plot,magplot=magplot,no_load=no_load,dfg_ql=dfg_ql,direc_plot=direc_plot,no_update=no_update,no_ele=no_ele,no_ion=no_ion

  del_data,'mms'+probe+'_d?s_brst_EnergySpectr_omni'
  del_data,'mms'+probe+'_d?s_brst_EnergySpectr_??'

  if undefined(probe) then probe=['3']
  probe=string(probe,format='(i0)')
  if undefined(trange) then begin
    get_data,'mms'+probe+'_des_numberDensity',data=d
    trange=[d.x[0],d.x[n_elements(d.x)-1]]
  endif else begin
    trange=time_double(trange)
  endelse

  if undefined(no_ele) then begin
    if undefined(no_load) then mms_load_fpi,trange=trange,probes=probe,level='l1b',data_rate='brst',datatype=['des-dist'],no_update=no_update
    
    mms_part_products,'mms'+probe+'_des_brstSkyMap_dist',trange=trange,outputs='energy'
    store_data,'mms'+probe+'_des_brstSkyMap_distenergy',newname='mms'+probe+'_des_brst_EnergySpectr_omni'
  
    phi_cent=180.d
    mms_part_products,'mms'+probe+'_des_brstSkyMap_dist',trange=trange,theta=[-45.,45.],phi=[phi_cent-45.d,phi_cent+45.d],outputs='energy'
    store_data,'mms'+probe+'_des_brstSkyMap_distenergy',newname='mms'+probe+'_des_brst_EnergySpectr_pX'
    
    phi_cent=0.d
    mms_part_products,'mms'+probe+'_des_brstSkyMap_dist',trange=trange,theta=[-45.,45.],phi=[phi_cent-45.d,phi_cent+45.d],outputs='energy'
    store_data,'mms'+probe+'_des_brstSkyMap_distenergy',newname='mms'+probe+'_des_brst_EnergySpectr_mX'

    phi_cent=270.d
    mms_part_products,'mms'+probe+'_des_brstSkyMap_dist',trange=trange,theta=[-45.,45.],phi=[phi_cent-45.d,phi_cent+45.d],outputs='energy'
    store_data,'mms'+probe+'_des_brstSkyMap_distenergy',newname='mms'+probe+'_des_brst_EnergySpectr_pY'

    phi_cent=90.d
    mms_part_products,'mms'+probe+'_des_brstSkyMap_dist',trange=trange,theta=[-45.,45.],phi=[phi_cent-45.d,phi_cent+45.d],outputs='energy'
    store_data,'mms'+probe+'_des_brstSkyMap_distenergy',newname='mms'+probe+'_des_brst_EnergySpectr_mY'

    mms_part_products,'mms'+probe+'_des_brstSkyMap_dist',trange=trange,theta=[-90.,-45.],outputs='energy'
    store_data,'mms'+probe+'_des_brstSkyMap_distenergy',newname='mms'+probe+'_des_brst_EnergySpectr_pZ'

    mms_part_products,'mms'+probe+'_des_brstSkyMap_dist',trange=trange,theta=[45.,90.],outputs='energy'
    store_data,'mms'+probe+'_des_brstSkyMap_distenergy',newname='mms'+probe+'_des_brst_EnergySpectr_mZ'
    
  endif

  if undefined(no_ion) then begin    
    if undefined(no_load) then mms_load_fpi,trange=trange,probes=probe,level='l1b',data_rate='brst',datatype=['dis-dist'],no_update=no_update
  
    mms_part_products,'mms'+probe+'_dis_brstSkyMap_dist',trange=trange,outputs='energy'
    store_data,'mms'+probe+'_dis_brstSkyMap_distenergy',newname='mms'+probe+'_dis_brst_EnergySpectr_omni'
  
    phi_cent=180.d
    mms_part_products,'mms'+probe+'_dis_brstSkyMap_dist',trange=trange,theta=[-45.,45.],phi=[phi_cent-45.d,phi_cent+45.d],outputs='energy'
    store_data,'mms'+probe+'_dis_brstSkyMap_distenergy',newname='mms'+probe+'_dis_brst_EnergySpectr_pX'
    
    phi_cent=0.d
    mms_part_products,'mms'+probe+'_dis_brstSkyMap_dist',trange=trange,theta=[-45.,45.],phi=[phi_cent-45.d,phi_cent+45.d],outputs='energy'
    store_data,'mms'+probe+'_dis_brstSkyMap_distenergy',newname='mms'+probe+'_dis_brst_EnergySpectr_mX'

    phi_cent=270.d
    mms_part_products,'mms'+probe+'_dis_brstSkyMap_dist',trange=trange,theta=[-45.,45.],phi=[phi_cent-45.d,phi_cent+45.d],outputs='energy'
    store_data,'mms'+probe+'_dis_brstSkyMap_distenergy',newname='mms'+probe+'_dis_brst_EnergySpectr_pY'

    phi_cent=90.d
    mms_part_products,'mms'+probe+'_dis_brstSkyMap_dist',trange=trange,theta=[-45.,45.],phi=[phi_cent-45.d,phi_cent+45.d],outputs='energy'
    store_data,'mms'+probe+'_dis_brstSkyMap_distenergy',newname='mms'+probe+'_dis_brst_EnergySpectr_mY'

    mms_part_products,'mms'+probe+'_dis_brstSkyMap_dist',trange=trange,theta=[-90.,-45.],outputs='energy'
    store_data,'mms'+probe+'_dis_brstSkyMap_distenergy',newname='mms'+probe+'_dis_brst_EnergySpectr_pZ'

    mms_part_products,'mms'+probe+'_dis_brstSkyMap_dist',trange=trange,theta=[45.,90.],outputs='energy'
    store_data,'mms'+probe+'_dis_brstSkyMap_distenergy',newname='mms'+probe+'_dis_brst_EnergySpectr_mZ'
    
  endif
  

  if undefined(no_ele) then begin  
    options,'mms'+probe+'_des_brst_EnergySpectr_omni',spec=1,datagap=0.032,ytitle='mms'+probe+'_des!CEnergySpectr!Comni',ysubtitle='[eV]',ztitle='eV/cm!U2!N/sr/s/eV',ytickformat='mms_exponent2'
    ylim,'mms'+probe+'_des_brst_EnergySpectr_omni',10.d,30000.d,1
    zlim,'mms'+probe+'_des_brst_EnergySpectr_omni',3e5,3e9,1
    
    options,'mms'+probe+'_des_brst_EnergySpectr_pX',spec=1,datagap=0.032,ytitle='mms'+probe+'_des!CEnergySpectr!CTailward',ysubtitle='[eV]',ztitle='eV/cm!U2!N/sr/s/eV',ytickformat='mms_exponent2'
    options,'mms'+probe+'_des_brst_EnergySpectr_mX',spec=1,datagap=0.032,ytitle='mms'+probe+'_des!CEnergySpectr!CSunward',ysubtitle='[eV]',ztitle='eV/cm!U2!N/sr/s/eV',ytickformat='mms_exponent2'
    options,'mms'+probe+'_des_brst_EnergySpectr_pY',spec=1,datagap=0.032,ytitle='mms'+probe+'_des!CEnergySpectr!CDawnward',ysubtitle='[eV]',ztitle='eV/cm!U2!N/sr/s/eV',ytickformat='mms_exponent2'
    options,'mms'+probe+'_des_brst_EnergySpectr_mY',spec=1,datagap=0.032,ytitle='mms'+probe+'_des!CEnergySpectr!CDuskward',ysubtitle='[eV]',ztitle='eV/cm!U2!N/sr/s/eV',ytickformat='mms_exponent2'
    options,'mms'+probe+'_des_brst_EnergySpectr_pZ',spec=1,datagap=0.032,ytitle='mms'+probe+'_des!CEnergySpectr!CSouthward',ysubtitle='[eV]',ztitle='eV/cm!U2!N/sr/s/eV',ytickformat='mms_exponent2'
    options,'mms'+probe+'_des_brst_EnergySpectr_mZ',spec=1,datagap=0.032,ytitle='mms'+probe+'_des!CEnergySpectr!CNorthward',ysubtitle='[eV]',ztitle='eV/cm!U2!N/sr/s/eV',ytickformat='mms_exponent2'
    ylim,'mms'+probe+'_des_brst_EnergySpectr_??',10.d,30000.d,1
    zlim,'mms'+probe+'_des_brst_EnergySpectr_??',3e5,3e9,1
  endif

  if undefined(no_ion) then begin
    options,'mms'+probe+'_dis_brst_EnergySpectr_omni',spec=1,datagap=0.16,ytitle='mms'+probe+'_dis!CiEnergySpectr!Comni',ysubtitle='[eV]',ztitle='eV/cm!U2!N/sr/s/eV',ytickformat='mms_exponent2'
    ylim,'mms'+probe+'_dis_brst_EnergySpectr_omni',10.d,30000.d,1
    zlim,'mms'+probe+'_dis_brst_EnergySpectr_omni',3e4,3e8,1
    
    options,'mms'+probe+'_dis_brst_EnergySpectr_pX',spec=1,datagap=0.16,ytitle='mms'+probe+'_dis!CEnergySpectr!CTailward',ysubtitle='[eV]',ztitle='eV/cm!U2!N/sr/s/eV',ytickformat='mms_exponent2'
    options,'mms'+probe+'_dis_brst_EnergySpectr_mX',spec=1,datagap=0.16,ytitle='mms'+probe+'_dis!CEnergySpectr!CSunward',ysubtitle='[eV]',ztitle='eV/cm!U2!N/sr/s/eV',ytickformat='mms_exponent2'
    options,'mms'+probe+'_dis_brst_EnergySpectr_pY',spec=1,datagap=0.16,ytitle='mms'+probe+'_dis!CEnergySpectr!CDawnward',ysubtitle='[eV]',ztitle='eV/cm!U2!N/sr/s/eV',ytickformat='mms_exponent2'
    options,'mms'+probe+'_dis_brst_EnergySpectr_mY',spec=1,datagap=0.16,ytitle='mms'+probe+'_dis!CEnergySpectr!CDuskward',ysubtitle='[eV]',ztitle='eV/cm!U2!N/sr/s/eV',ytickformat='mms_exponent2'
    options,'mms'+probe+'_dis_brst_EnergySpectr_pZ',spec=1,datagap=0.16,ytitle='mms'+probe+'_dis!CEnergySpectr!CSouthward',ysubtitle='[eV]',ztitle='eV/cm!U2!N/sr/s/eV',ytickformat='mms_exponent2'
    options,'mms'+probe+'_dis_brst_EnergySpectr_mZ',spec=1,datagap=0.16,ytitle='mms'+probe+'_dis!CEnergySpectr!CNorthward',ysubtitle='[eV]',ztitle='eV/cm!U2!N/sr/s/eV',ytickformat='mms_exponent2'
    ylim,'mms'+probe+'_dis_brst_EnergySpectr_??',10.d,30000.d,1
    zlim,'mms'+probe+'_dis_brst_EnergySpectr_??',3e4,3e8,1
  endif
  
  
  if not undefined(direc_plot) then begin
    mms_dfg_plot_kitamura,trange=trange,probe=probe,dfg_ql=dfg_ql,/no_avg,/no_plot
    tplot_options,'xmargin',[20,10]
    if strlen(tnames('mms'+probe+'_dfg_srvy_l2pre_gse')) eq 0 then begin
      tplot,['mms'+probe+'_des_brst_EnergySpectr_mX','mms'+probe+'_des_brst_EnergySpectr_mY','mms'+probe+'_des_brst_EnergySpectr_pX','mms'+probe+'_des_brst_EnergySpectr_pY','mms'+probe+'_des_brst_EnergySpectr_pZ','mms'+probe+'_des_brst_EnergySpectr_mZ','mms'+probe+'_des_bulkV','mms'+probe+'_dis_brst_EnergySpectr_mX','mms'+probe+'_dis_brst_EnergySpectr_mY','mms'+probe+'_dis_brst_EnergySpectr_pX','mms'+probe+'_dis_brst_EnergySpectr_pY','mms'+probe+'_dis_brst_EnergySpectr_pZ','mms'+probe+'_dis_brst_EnergySpectr_mZ','mms'+probe+'_dis_bulkV','mms'+probe+'_dfg_srvy_dmpa_bvec']
    endif else begin
      tplot,['mms'+probe+'_des_brst_EnergySpectr_mX','mms'+probe+'_des_brst_EnergySpectr_mY','mms'+probe+'_des_brst_EnergySpectr_pX','mms'+probe+'_des_brst_EnergySpectr_pY','mms'+probe+'_des_brst_EnergySpectr_pZ','mms'+probe+'_des_brst_EnergySpectr_mZ','mms'+probe+'_des_bulkV','mms'+probe+'_dis_brst_EnergySpectr_mX','mms'+probe+'_dis_brst_EnergySpectr_mY','mms'+probe+'_dis_brst_EnergySpectr_pX','mms'+probe+'_dis_brst_EnergySpectr_pY','mms'+probe+'_dis_brst_EnergySpectr_pZ','mms'+probe+'_dis_brst_EnergySpectr_mZ','mms'+probe+'_dis_bulkV','mms'+probe+'_dfg_srvy_l2pre_gse_bvec']
    endelse
  endif else begin
    if not undefined(magplot) then begin
      mms_dfg_plot_kitamura,trange=trange,probe=probe,dfg_ql=dfg_ql,/no_avg,/no_plot
      tplot_options,'xmargin',[20,10]
      if strlen(tnames('mms'+probe+'_dfg_srvy_l2pre_gse')) eq 0 then begin
        tplot,['mms_bss','mms'+probe+'_fpi_eEnergySpectr_omni','mms'+probe+'_des_brst_EnergySpectr_omni','mms'+probe+'_fpi_iEnergySpectr_omni','mms'+probe+'_dis_brst_EnergySpectr_omni','mms'+probe+'_fpi_dis_des_numberDensity','mms'+probe+'_fpi_temp','mms'+probe+'_fpi_eBulkV_DSC','mms'+probe+'_des_bulkV','mms'+probe+'_fpi_iBulkV_DSC','mms'+probe+'_dis_bulkV','mms'+probe+'_dfg_srvy_dmpa_bvec','mms'+probe+'_dfg_srvy_dmpa_btot']
      endif else begin
        tplot,['mms_bss','mms'+probe+'_fpi_eEnergySpectr_omni','mms'+probe+'_des_brst_EnergySpectr_omni','mms'+probe+'_fpi_iEnergySpectr_omni','mms'+probe+'_dis_brst_EnergySpectr_omni','mms'+probe+'_fpi_dis_des_numberDensity','mms'+probe+'_fpi_temp','mms'+probe+'_fpi_eBulkV_DSC','mms'+probe+'_des_bulkV','mms'+probe+'_fpi_iBulkV_DSC','mms'+probe+'_dis_bulkV','mms'+probe+'_dfg_srvy_l2pre_gse_bvec','mms'+probe+'_dfg_srvy_l2pre_gse_btot']
      endelse
    endif else begin
      if undefined(no_plot) then begin
        tplot_options,'xmargin',[20,10]
        tplot,['mms'+probe+'_fpi_eEnergySpectr_omni','mms'+probe+'_des_brst_EnergySpectr_omni','mms'+probe+'_fpi_iEnergySpectr_omni','mms'+probe+'_dis_brst_EnergySpectr_omni','mms'+probe+'_fpi_dis_des_numberDensity','mms'+probe+'_fpi_temp','mms'+probe+'_fpi_iBulkV_DSC','mms'+probe+'_dis_bulkV','mms'+probe+'_fpi_eBulkV_DSC','mms'+probe+'_des_bulkV','mms'+probe+'_fpi_bentPipeB_DSC']
      endif
    endelse
  endelse

end
