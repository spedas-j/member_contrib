;+
; PROCEDURE:
;         mms_fpi_brst_specplot_dist_kitamura
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
;
; EXAMPLE:
;
;     To plot fast plasma investigation (FPI) burst anglemap and moments, and dfg data
;     MMS>  mms_fpi_brst_specplot_dist_kitamura,trange=['2015-09-02/15:25:00','2015-09-02/15:30:00'],probe='3',erange=[3000.d,30000.d],taverage=2,init_az=0,/ion,/no_update
;     MMS>  mms_fpi_brst_specplot_dist_kitamura,trange=['2015-09-02/15:25:00','2015-09-02/15:30:00'],probe='3',erange=[3000.d,30000.d],taverage=2,init_az=0,/no_update
;
;
; NOTES:
;     1) See the notes in mms_load_data for rules on the use of MMS data
;     2) DFG data should be loaded before running this procedure if magplot flag is set
;     3) A very large memory space is necessary to plot longer than ~10 minutes for electrons
;-

pro mms_fpi_brst_specplot_dist_kitamura,trange=trange,probe=probe,no_plot=no_plot,no_load=no_load,dfg_ql=dfg_ql,erange=erange,estep=estep,ion=ion,log=log,taverage=taverage,init_az=init_az,no_update=no_update

  if undefined(probe) then probe=['3']
  probe=string(probe,format='(i0)')
  if undefined(ion) then begin
    specie='e'
    nonspecie='i'
    dt=0.03d
    fact=6.1869e+30
    etable=mms_fpi_energies('e')
  endif else begin
    specie='i'
    nonspecie='e'
    dt=0.15d
    fact=1.8351e+24
    etable=mms_fpi_energies('i')
  endelse
  if undefined(trange) then trange=timerange() else trange=time_double(trange)
  if undefined(estep) then begin
    if undefined(erange) then estep=[0,31]
    estep=[min(where(etable ge erange[0])),max(where(etable le erange[1]))]
  endif
  if undefined(taverage) or fix(taverage) lt 1 then taverage=2.d else taverage=double(fix(taverage))
  if undefined(init_az) then init_az=0l
  if undefined(no_load) then mms_load_fpi,trange=trange,probes=probe,level='l1b',data_rate='brst',datatype=['d'+specie+'s-dist'],no_update=no_update
  
  v=(double(indgen(16))*11.25d)+11.25d/2.d
  get_data,'mms'+probe+'_d'+specie+'s_brstSkyMap_dist',data=skymap
  x=dblarr(n_elements(skymap.x)*double(fix(35.d/taverage)+100))
  y=dblarr(n_elements(x),16)
  i=0l
  j=0l
  while i+taverage-1 le n_elements(skymap.x)-1 and j+35l le n_elements(x)-1 do begin
    x[j]=skymap.x[i]
    y[j,*]=!values.d_nan
    for az=0l,32l do begin
      x[j+az+1]=skymap.x[i]+double(az+1)*dt*taverage/35.d
      az_sector=az+init_az
      if az_sector gt 31l then az_sector=az_sector-32l
      if skymap.x[i+taverage-1] lt skymap.x[i]+taverage*dt*1.01d then begin
        for k=0,15 do y[j+az+1,k]=total(skymap.y[i:i+long(taverage)-1,az_sector,k,estep[0]:estep[1]]*fact*(etable[estep[0]:estep[1]])^2)/(estep[1]-estep[0]+1)/double(taverage)
      endif else begin
        y[j+az+1,*]=!values.d_nan
      endelse
    endfor
    x[j+34l]=skymap.x[i]+34.d*dt*taverage/35.d
    y[j+34l,*]=!values.d_nan
    j=j+35l
    i=i+long(taverage)
  endwhile

  store_data,'mms'+probe+'_d'+specie+'s_brst_Anglemaps_'+string(estep[0],format='(i0)')+'_'+string(estep[1],format='(i0)'),data={x:x[0:j-1],y:y[0:j-1,*],v:v}
  ylim,'mms'+probe+'_d'+specie+'s_brst_Anglemaps_'+string(estep[0],format='(i0)')+'_'+string(estep[1],format='(i0)'),0.0,180.0,0
  if not undefined(log) then options,'mms'+probe+'_d'+specie+'s_brst_Anglemaps_'+string(estep[0],format='(i0)')+'_'+string(estep[1],format='(i0)'),zlog=1
  options,'mms'+probe+'_d'+specie+'s_brst_Anglemaps_'+string(estep[0],format='(i0)')+'_'+string(estep[1],format='(i0)'),spec=1

  if undefined(no_plot) then begin
      tplot_options,'xmargin',[20,10]
      if strlen(tnames('mms'+probe+'_dfg_srvy_l2pre_gse')) gt 0 then begin
        tplot,['mms'+probe+'_d'+nonspecie+'s_brst_EnergySpectr_omni','mms'+probe+'_d'+specie+'s_brst_EnergySpectr_omni','mms'+probe+'_d'+specie+'s_brst_Anglemaps_'+string(estep[0],format='(i0)')+'_'+string(estep[1],format='(i0)'),'mms'+probe+'_fpi_d'+probe+'s_numberDensity','mms'+probe+'_d'+probe+'s_bulkV','mms'+probe+'_dfg_srvy_l2pre_dmpa_bvec']
      endif else begin
        tplot,['mms'+probe+'_d'+nonspecie+'s_brst_EnergySpectr_omni','mms'+probe+'_d'+specie+'s_brst_EnergySpectr_omni','mms'+probe+'_d'+specie+'s_brst_Anglemaps_'+string(estep[0],format='(i0)')+'_'+string(estep[1],format='(i0)'),'mms'+probe+'_fpi_d'+probe+'s_numberDensity','mms'+probe+'_d'+probe+'s_bulkV','mms'+probe+'_dfg_srvy_dmpa_bvec']
      endelse
  endif

end
