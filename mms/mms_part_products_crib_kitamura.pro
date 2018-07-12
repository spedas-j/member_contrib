;+
;Procedure:
;  mms_part_products_crib_kitamura
;
;Purpose:
;  Basic example on how to use mms_part_products to generate pitch angle and gyrophase distributions
;
; mms_part_products_crib
; Modified by N. Kitamura
; MMS> mms_part_products_crib_kitamura,trange=['2015-11-18/02:09:00','2015-11-18/02:15:00'],probe='1',/load_fgm,/load_fpi,/load_mec,erange=[10.d,30000.d],parange=[0.d,180.d],gyrorange=[0.d,360.d],/ion,outputs='energy'
;-
;
;
PRO mms_part_products_crib_kitamura,trange=trange,probe=probe,load_fgm=load_fgm,dfg_ql=dfg_ql,load_fpi=load_fpi,load_mec=load_mec,erange=erange,$
                                    parange=parange,gyrorange=gyrorange,ion=ion,outputs=outputs,no_update=no_update,bname=bname,fac_type=fac_type,regrid=redrid,fpi_data_rate=fpi_data_rate

  if undefined(probe) then probe=['3']
  if undefined(fac_type) then fac_type='xgse'
  if undefined(regrid) then regrid=[32,16]
  if undefined(outputs) then outputs=['phi','theta','pa','gyro','energy']
  if undefined(fpi_data_rate) then begin
    fpi_data_rate='fast'
    datagap=4.6d
  endif else begin
    if fpi_data_rate eq 'fast' then datagap=4.6d
    if fpi_data_rate eq 'slow' then datagap=65.d
    if fpi_data_rate eq 'brst' then begin
      if undefined(ion) then datagap=0.032d else datagap=0.16d
    endif
  endelse
  if undefined(ion) then species='e' else species='i'
  
  probe=string(probe,format='(i0)')
  if undefined(trange) then begin
    if strlen(tnames('mms'+probe+'_fgm_b_gsm_srvy_l2')) gt 0 and undefined(dfg_ql) then begin
      get_data,'mms'+probe+'_fgm_b_gsm_srvy_l2',data=d
    endif else begin
      if strlen(tnames('mms'+probe+'_dfg_b_gse_srvy_l2pre')) gt 0 and undefined(dfg_ql) then get_data,'mms'+probe+'_dfg_b_gse_srvy_l2pre',data=d else get_data,'mms'+probe+'_dfg_srvy_dmpa',data=d
    endelse
    if n_elements(d.x) gt 0 then begin
      start_time=d.x[0]
      dt=d.x[n_elements(d.x)-1]-d.x[0]
      timespan,start_time,dt,/seconds
    endif else begin
      trange=timerange()
      dt=trange[1]-trange[0]
      timespan,trange[0],dt,/seconds
    endelse
  endif else begin
    if n_elements(trange) eq 1 then begin
      roi=mms_get_roi(trange,/next)
      trange=dblarr(2)
      trange[0]=roi[0]-60.d*30.d
      trange[1]=roi[1]+60.d*30.d
    endif else begin
      trange=time_double(trange)
      roi=trange
    endelse
    dt=trange[1]-trange[0]
    timespan,trange[0],dt,/seconds
  endelse
  
  ;load magnetic field data
  if not undefined(load_fgm) then begin
    if undefined(dfg_ql) then begin
      mms_load_fgm,trange=trange,instrument='fgm',probes=probe,data_rate='srvy',level='l2',no_update=no_update,/no_attitude_data
      if strlen(tnames('mms'+probe+'_fgm_b_gse_srvy_l2_bvec')) eq 0 then begin
        mms_load_fgm,trange=trange,instrument='dfg',probes=probe,data_rate='srvy',level='l2pre',no_update=no_update,/no_attitude_data
      endif else begin
        get_data,'mms'+probe+'_fgm_b_gse_srvy_l2_bvec',data=d
        if d.x[0] gt roi[1] or time_double(time_string(d.x[n_elements(d.x)-1]-10.d,format=0,precision=-3)) lt time_double(time_string(roi[1],format=0,precision=-3)) then begin
          store_data,'mms'+probe+'_fgm_*',/delete 
          mms_load_fgm,trange=trange,instrument='dfg',probes=probe,data_rate='srvy',level='l2pre',no_update=no_update,/no_attitude_data
        endif
      endelse
    endif
    if strlen(tnames('mms'+probe+'_fgm_b_gse_srvy_l2_bvec')) eq 0 and strlen(tnames('mms'+probe+'_dfg_b_gse_srvy_l2pre')) eq 0 then begin
      if undefined(dfg_ql) then mms_load_fgm,trange=trange,instrument='dfg',probes=probe,data_rate='srvy',level='l2pre',no_update=no_update,/no_attitude_data
      if strlen(tnames('mms'+probe+'_dfg_b_gse_srvy_l2pre')) eq 0 then begin
        mms_load_fgm,trange=trange,instrument='dfg',probes=probe,data_rate='srvy',level='ql',no_update=no_update,/no_attitude_data
      endif else begin
        get_data,'mms'+probe+'_dfg_b_gse_srvy_l2pre',data=d
        if d.x[0] gt roi[1] or time_double(time_string(d.x[n_elements(d.x)-1]-10.d,format=0,precision=-3)) lt time_double(time_string(roi[1],format=0,precision=-3)) then begin
          store_data,'mms'+probe+'_dfg_b_*_srvy_l2pre*',/delete
          store_data,'mms'+probe+'_pos*',/delete
          mms_load_fgm,trange=trange,instrument='dfg',probes=probe,data_rate='srvy',level='ql',no_update=no_update,/no_attitude_data
        endif
      endelse     
    endif
  endif

  if not undefined(load_mec) then mms_load_mec,trange=trange,probes=probe,no_update=no_update,varformat=['mms'+probe+'_mec_r_eci','mms'+probe+'_mec_r_gse','mms'+probe+'_mec_r_gsm','mms'+probe+'_mec_L_vec']
  pos_name='mms'+probe+'_mec_r_eci'

  ;load particle data
  
  if not undefined(load_fpi) then begin
    mms_load_fpi,probe=probe,trange=trange,data_rate=fpi_data_rate,level='l2',datatype='d'+species+'s-dist',no_update=no_update,/center_measurement,/time_clip
    if strlen(tnames('mms'+probe+'_d'+species+'s_dist_'+fpi_data_rate)) eq 0 then begin
      mms_load_fpi,probe=probe,trange=trange,data_rate=fpi_data_rate,level='l1b',datatype='d'+species+'s-dist',no_update=no_update,/time_clip
    endif
  endif
  if strlen(tnames('mms'+probe+'_d'+species+'s_dist_'+fpi_data_rate)) eq 0 then begin
    name='mms'+probe+'_d'+species+'s_brstSkyMap_'+fpi_data_rate
  endif else begin
    name='mms'+probe+'_d'+species+'s_dist_'+fpi_data_rate
  endelse

  if undefined(bname) then begin
    if strlen(tnames('mms'+probe+'_fgm_b_dmpa_srvy_l2_bvec')) gt 0 then begin
      bname='mms'+probe+'_fgm_b_dmpa_srvy_l2_bvec'
    endif else begin
      if strlen(tnames('mms'+probe+'_dfg_b_dmpa_srvy_l2pre_bvec')) eq 0 then begin
        ;Until coordinate systems are properly labeled in mms metadata, this variable must be dmpa
        bname='mms'+probe+'_dfg_srvy_dmpa_bvec'
      endif else begin
        ;Until coordinate systems are properly labeled in mms metadata, this variable must be dmpa
        bname='mms'+probe+'_dfg_b_dmpa_srvy_l2pre_bvec'
      endelse
    endelse
  endif

  if undefined(erange) then begin
    erange_tname=''
    erange_title=''
  endif else begin
    erange_tname='_energy'+strcompress(fix(erange[0]),/remove_all)+'-'+strcompress(fix(erange[1]),/remove_all)
    if erange[0] ge 1000.d then begin
      erange_title='!C'+strmid(strcompress((erange[0]/1000.d),/remove_all),0,4)+'-'+strmid(strcompress((erange[1]/1000.d),/remove_all),0,4)+'keV'
    endif else begin
      erange_title='!C'+strcompress(fix(erange[0]),/remove_all)+'-'+strcompress(fix(erange[1]),/remove_all)+'eV'      
    endelse
  endelse

  if undefined(parange) then begin
    parange_tname=''
    parange_title=''
  endif else begin
    parange_tname='_pa'+strcompress(fix(parange[0]),/remove_all)+'-'+strcompress(fix(parange[1]),/remove_all)
    parange_title='!CPA'+strcompress(fix(parange[0]),/remove_all)+'-'+strcompress(fix(parange[1]),/remove_all)+'deg'
  endelse

  if undefined(gyrorange) then begin
    gyrorange_tname=''
    gyrorange_title=''
  endif else begin
    gyrorange_tname='_gyro'+strcompress(fix(gyrorange[0]),/remove_all)+'-'+strcompress(fix(gyrorange[1]),/remove_all)
    gyrorange_title='!CGyro'+strcompress(fix(gyrorange[0]),/remove_all)+'-'+strcompress(fix(gyrorange[1]),/remove_all)+'deg'
  endelse


  for i=0,n_elements(outputs)-1 do begin
    mms_part_products,name,probe=probe,mag_name=bname,pos_name=pos_name,trange=trange,outputs=outputs,energy=erange,pitch=parange,gyro=gyrorange,regrid=regrid,fac_type=fac_type,datagap=datagap
    if strlen(tnames('mms'+probe+'_d'+species+'s_dist_'+fpi_data_rate+'_'+outputs[i])) eq 0 then begin
      copy_data,'mms'+probe+'_d'+species+'s_brstSkyMap_dist_'+outputs[i],'mms'+probe+'_d'+species+'s_dist_'+outputs[i]+erange_tname+parange_tname+gyrorange_tname
    endif else begin
      copy_data,'mms'+probe+'_d'+species+'s_dist_'+fpi_data_rate+'_'+outputs[i],'mms'+probe+'_d'+species+'s_dist_'+outputs[i]+erange_tname+parange_tname+gyrorange_tname     
    endelse
    options,'mms'+probe+'_d'+species+'s_dist_'+outputs[i]+erange_tname+parange_tname+gyrorange_tname,ytitle='mms'+probe+'!Cd'+species+'s_'+outputs[i]+erange_title+parange_title+gyrorange_title
    if outputs[i] eq 'phi' or outputs[i] eq 'theta' or outputs[i] eq 'pa' or outputs[i] eq 'gyro' then options,'mms'+probe+'_d'+species+'s_dist_'+outputs[i]+erange_tname+parange_tname+gyrorange_tname,yticks=4
    if outputs[i] eq 'energy' then options,'mms'+probe+'_d'+species+'s_dist_'+outputs[i]+erange_tname+parange_tname+gyrorange_tname,ytickformat='mms_exponent2'
    if outputs[i] eq 'gyro' then begin
      if strlen(tnames('mms'+probe+'_d'+species+'s_dist_'+outputs[i]+erange_tname+parange_tname+gyrorange_tname)) gt 0 then fpi_gyroasy,'mms'+probe+'_d'+species+'s_dist_'+outputs[i]+erange_tname+parange_tname+gyrorange_tname
;      if strlen(tnames('mms'+probe+'_d'+species+'s_'+outputs[i]+erange_tname+parange_tname+gyrorange_tname)) gt 0 then fpi_gyroasy,'mms'+probe+'_d'+species+'s_'+outputs[i]+erange_tname+parange_tname+gyrorange_tname
    endif
  endfor
 
end