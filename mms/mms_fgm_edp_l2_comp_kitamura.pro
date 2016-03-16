PRO mms_fgm_edp_l2_comp_kitamura,trange,probe=probe,dce_2d=dce_2d,no_E=no_E,no_B=no_B,edp_brst=edp_brst,fgm_brst=fgm_brst,lmn=lmn,na=na,almn=almn,vn=vn,gsm=gsm,no_update=no_update,label_gsm=label_gsm,ion_plot=ion_plot,delete=delete

; MMS> mms_fgm_edp_l2_comp_kitamura,['2015-11-18/02:09','2015-11-18/02:15'],/gsm,/fgm_brst

  if not undefined(delete) then store_data, '*', /delete

  trange=time_double(trange)
  
  loadct2,43
  time_stamp,/off
  
  timespan,trange[0],trange[1]-trange[0],/seconds

  if undefined(gsm) then coord='gse' else coord='gsm'
  
  if undefined(probe) then probe=['1','2','3','4'] else probe=strcompress(string(probe),/remove_all)
  
  if undefined(fgm_brst) then fgm_data_rate='srvy' else fgm_data_rate='brst'
  if undefined(no_B) then begin
    for i=0,n_elements(probe)-1 do begin
      if strlen(tnames('mms'+probe[i]+'_fgm_r_gse_srvy_l2')) eq 0 and fgm_data_rate eq 'brst' then mms_load_fgm,trange=trange,instrument='fgm',probes=probe[i],data_rate='srvy',level='l2',no_update=no_update,/no_attitude_data
      mms_load_fgm,trange=trange,instrument='fgm',probes=probe[i],data_rate=fgm_data_rate,level='l2',no_update=no_update,/no_attitude_data
    endfor  
  endif
  
  for i=0,n_elements(probe)-1 do if undefined(no_update) then mms_load_state,trange=trange,probes=probe[i] else mms_load_state,trange=trange,probes=probe[i],/no_download
  
  if n_elements(probe) eq 4 then begin
    for p=1,4 do split_vec,'mms'+strcompress(string(p),/remove_all)+'_fgm_b_gse_'+fgm_data_rate+'_l2_bvec'
    store_data,'mms_fgm_b_gse_'+fgm_data_rate+'_l2_btot',data=['mms1_fgm_b_gse_'+fgm_data_rate+'_l2_btot','mms2_fgm_b_gse_'+fgm_data_rate+'_l2_btot','mms3_fgm_b_gse_'+fgm_data_rate+'_l2_btot','mms4_fgm_b_gse_'+fgm_data_rate+'_l2_btot']
    store_data,'mms_fgm_b_gse_'+fgm_data_rate+'_l2_bvec_x',data=['mms1_fgm_b_gse_'+fgm_data_rate+'_l2_bvec_x','mms2_fgm_b_gse_'+fgm_data_rate+'_l2_bvec_x','mms3_fgm_b_gse_'+fgm_data_rate+'_l2_bvec_x','mms4_fgm_b_gse_'+fgm_data_rate+'_l2_bvec_x']
    store_data,'mms_fgm_b_gse_'+fgm_data_rate+'_l2_bvec_y',data=['mms1_fgm_b_gse_'+fgm_data_rate+'_l2_bvec_y','mms2_fgm_b_gse_'+fgm_data_rate+'_l2_bvec_y','mms3_fgm_b_gse_'+fgm_data_rate+'_l2_bvec_y','mms4_fgm_b_gse_'+fgm_data_rate+'_l2_bvec_y']
    store_data,'mms_fgm_b_gse_'+fgm_data_rate+'_l2_bvec_z',data=['mms1_fgm_b_gse_'+fgm_data_rate+'_l2_bvec_z','mms2_fgm_b_gse_'+fgm_data_rate+'_l2_bvec_z','mms3_fgm_b_gse_'+fgm_data_rate+'_l2_bvec_z','mms4_fgm_b_gse_'+fgm_data_rate+'_l2_bvec_z']
    options,'mms_fgm_b_gse_'+fgm_data_rate+'_l2_btot',colors=[0,6,4,2],ytitle='MMS!CFGM!CB_total',ysubtitle='[nT]',labels=['mms1','mms2','mms3','mms4'],labflag=-1
    options,'mms_fgm_b_gse_'+fgm_data_rate+'_l2_bvec_x',constant=0.0,colors=[0,6,4,2],ytitle='MMS!CFGM!CGSE X',ysubtitle='[nT]',labels=['mms1','mms2','mms3','mms4'],labflag=-1
    options,'mms_fgm_b_gse_'+fgm_data_rate+'_l2_bvec_y',constant=0.0,colors=[0,6,4,2],ytitle='MMS!CFGM!CGSE Y',ysubtitle='[nT]',labels=['mms1','mms2','mms3','mms4'],labflag=-1
    options,'mms_fgm_b_gse_'+fgm_data_rate+'_l2_bvec_z',constant=0.0,colors=[0,6,4,2],ytitle='MMS!CFGM!CGSE Z',ysubtitle='[nT]',labels=['mms1','mms2','mms3','mms4'],labflag=-1
    for p=1,4 do split_vec,'mms'+strcompress(string(p),/remove_all)+'_fgm_b_gsm_'+fgm_data_rate+'_l2_bvec'
    store_data,'mms_fgm_b_gsm_'+fgm_data_rate+'_l2_btot',data=['mms1_fgm_b_gsm_'+fgm_data_rate+'_l2_btot','mms2_fgm_b_gsm_'+fgm_data_rate+'_l2_btot','mms3_fgm_b_gsm_'+fgm_data_rate+'_l2_btot','mms4_fgm_b_gsm_'+fgm_data_rate+'_l2_btot']
    store_data,'mms_fgm_b_gsm_'+fgm_data_rate+'_l2_bvec_x',data=['mms1_fgm_b_gsm_'+fgm_data_rate+'_l2_bvec_x','mms2_fgm_b_gsm_'+fgm_data_rate+'_l2_bvec_x','mms3_fgm_b_gsm_'+fgm_data_rate+'_l2_bvec_x','mms4_fgm_b_gsm_'+fgm_data_rate+'_l2_bvec_x']
    store_data,'mms_fgm_b_gsm_'+fgm_data_rate+'_l2_bvec_y',data=['mms1_fgm_b_gsm_'+fgm_data_rate+'_l2_bvec_y','mms2_fgm_b_gsm_'+fgm_data_rate+'_l2_bvec_y','mms3_fgm_b_gsm_'+fgm_data_rate+'_l2_bvec_y','mms4_fgm_b_gsm_'+fgm_data_rate+'_l2_bvec_y']
    store_data,'mms_fgm_b_gsm_'+fgm_data_rate+'_l2_bvec_z',data=['mms1_fgm_b_gsm_'+fgm_data_rate+'_l2_bvec_z','mms2_fgm_b_gsm_'+fgm_data_rate+'_l2_bvec_z','mms3_fgm_b_gsm_'+fgm_data_rate+'_l2_bvec_z','mms4_fgm_b_gsm_'+fgm_data_rate+'_l2_bvec_z']
    options,'mms_fgm_b_gsm_'+fgm_data_rate+'_l2_btot',colors=[0,6,4,2],ytitle='MMS!CFGM!CB_total',ysubtitle='[nT]',labels=['mms1','mms2','mms3','mms4'],labflag=-1
    options,'mms_fgm_b_gsm_'+fgm_data_rate+'_l2_bvec_x',constant=0.0,colors=[0,6,4,2],ytitle='MMS!CFGM!CGSM X',ysubtitle='[nT]',labels=['mms1','mms2','mms3','mms4'],labflag=-1
    options,'mms_fgm_b_gsm_'+fgm_data_rate+'_l2_bvec_y',constant=0.0,colors=[0,6,4,2],ytitle='MMS!CFGM!CGSM Y',ysubtitle='[nT]',labels=['mms1','mms2','mms3','mms4'],labflag=-1
    options,'mms_fgm_b_gsm_'+fgm_data_rate+'_l2_bvec_z',constant=0.0,colors=[0,6,4,2],ytitle='MMS!CFGM!CGSM Z',ysubtitle='[nT]',labels=['mms1','mms2','mms3','mms4'],labflag=-1
  endif

  if n_elements(na) eq 3 then begin
    na=na/sqrt(na[0]*na[0]+na[1]*na[1]+na[2]*na[2])
    for i=0,n_elements(probe)-1 do begin
      get_data,'mms'+probe[i]+'_fgm_b_'+coord+'_'+fgm_data_rate+'_l2_bvec',data=B
      B_a=dblarr(n_elements(B.x))
      for j=0l,n_elements(B.x)-1 do B_a[j]=B.y[j,0]*na[0]+B.y[j,1]*na[1]+B.y[j,2]*na[2]
      store_data,'mms'+probe[i]+'_fgm_b_'+fgm_data_rate+'_l2_arb',data={x:B.x,y:B_a}
    endfor

    if n_elements(probe) eq 4 then begin
      store_data,'mms_fgm_b_'+fgm_data_rate+'_l2_arb',data=['mms1_fgm_b_'+fgm_data_rate+'_l2_arb','mms2_fgm_b_'+fgm_data_rate+'_l2_arb','mms3_fgm_b_'+fgm_data_rate+'_l2_arb','mms4_fgm_b_'+fgm_data_rate+'_l2_arb']
      options,'mms_fgm_b_'+fgm_data_rate+'_l2_arb',constant=0.0,colors=[0,6,4,2],ytitle='MMS!CFGM!CArbitrary',ysubtitle='[nT]',labels=['mms1','mms2','mms3','mms4'],labflag=-1
    endif
  endif

  if n_elements(na) eq 3 and n_elements(lmn) eq 9 and not undefined(almn) then begin
    lmn_orig=lmn
    lmn[*,2]=na
    lmn[*,0]=crossp(lmn_orig[*,1],na)
    lmn[*,0]=lmn[*,0]/sqrt(lmn[0,0]*lmn[0,0]+lmn[1,0]*lmn[1,0]+lmn[2,0]*lmn[2,0])
    lmn[*,1]=crossp(na,lmn[*,0])
    lmn[*,1]=lmn[*,1]/sqrt(lmn[0,1]*lmn[0,1]+lmn[1,1]*lmn[1,1]+lmn[2,1]*lmn[2,1])
  endif
  
  if n_elements(lmn) eq 9 then begin
    for i=0,n_elements(probe)-1 do begin
      get_data,'mms'+probe[i]+'_fgm_b_'+coord+'_'+fgm_data_rate+'_l2_bvec',data=B
      B_lmn=dblarr(n_elements(B.x),3)
      for j=0l,n_elements(B.x)-1 do begin
        B_lmn[j,0]=B.y[j,0]*lmn[0,0]+B.y[j,1]*lmn[1,0]+B.y[j,2]*lmn[2,0]
        B_lmn[j,1]=B.y[j,0]*lmn[0,1]+B.y[j,1]*lmn[1,1]+B.y[j,2]*lmn[2,1]
        B_lmn[j,2]=B.y[j,0]*lmn[0,2]+B.y[j,1]*lmn[1,2]+B.y[j,2]*lmn[2,2]
      endfor
      store_data,'mms'+probe[i]+'_fgm_b_'+fgm_data_rate+'_l2_lmn',data={x:B.x,y:B_lmn}
    endfor
    
    if n_elements(probe) eq 4 then begin
      for p=1,4 do split_vec,'mms'+strcompress(string(p),/remove_all)+'_fgm_b_'+fgm_data_rate+'_l2_lmn',suffix=['_l','_m','_n']
      store_data,'mms_fgm_b_'+fgm_data_rate+'_l2_lmn_l',data=['mms1_fgm_b_'+fgm_data_rate+'_l2_lmn_l','mms2_fgm_b_'+fgm_data_rate+'_l2_lmn_l','mms3_fgm_b_'+fgm_data_rate+'_l2_lmn_l','mms4_fgm_b_'+fgm_data_rate+'_l2_lmn_l']
      store_data,'mms_fgm_b_'+fgm_data_rate+'_l2_lmn_m',data=['mms1_fgm_b_'+fgm_data_rate+'_l2_lmn_m','mms2_fgm_b_'+fgm_data_rate+'_l2_lmn_m','mms3_fgm_b_'+fgm_data_rate+'_l2_lmn_m','mms4_fgm_b_'+fgm_data_rate+'_l2_lmn_m']
      store_data,'mms_fgm_b_'+fgm_data_rate+'_l2_lmn_n',data=['mms1_fgm_b_'+fgm_data_rate+'_l2_lmn_n','mms2_fgm_b_'+fgm_data_rate+'_l2_lmn_n','mms3_fgm_b_'+fgm_data_rate+'_l2_lmn_n','mms4_fgm_b_'+fgm_data_rate+'_l2_lmn_n']
      options,'mms_fgm_b_'+fgm_data_rate+'_l2_lmn_l',constant=0.0,colors=[0,6,4,2],ytitle='MMS!CFGM!Clmn-l',ysubtitle='[nT]',labels=['mms1','mms2','mms3','mms4'],labflag=-1
      options,'mms_fgm_b_'+fgm_data_rate+'_l2_lmn_m',constant=0.0,colors=[0,6,4,2],ytitle='MMS!CFGM!Clmn-m',ysubtitle='[nT]',labels=['mms1','mms2','mms3','mms4'],labflag=-1
      options,'mms_fgm_b_'+fgm_data_rate+'_l2_lmn_n',constant=0.0,colors=[0,6,4,2],ytitle='MMS!CFGM!Clmn-n',ysubtitle='[nT]',labels=['mms1','mms2','mms3','mms4'],labflag=-1
    endif
    
  endif

   
  if undefined(edp_brst) then edp_data_rate='fast' else edp_data_rate='brst'
  if undefined(no_E) then begin
    if undefined(dce_2d) then efield_datatype='dce' else efield_datatype='dce2d'
    mms_load_edp,trange=trange,probes=probes,data_rate=edp_data_rate,level='l2',datatype=efield_datatype,no_update=no_update
    
    if n_elements(probe) eq 4 then begin
      for p=1,4 do split_vec,'mms'+strcompress(string(p),/remove_all)+'_edp_dce_dsl_'+edp_data_rate+'_l2'
      store_data,'mms_edp_dce_dsl_'+edp_data_rate+'_l2_x',data=['mms1_edp_dce_dsl_'+edp_data_rate+'_l2_x','mms2_edp_dce_dsl_'+edp_data_rate+'_l2_x','mms3_edp_dce_dsl_'+edp_data_rate+'_l2_x','mms4_edp_dce_dsl_'+edp_data_rate+'_l2_x']
      store_data,'mms_edp_dce_dsl_'+edp_data_rate+'_l2_y',data=['mms1_edp_dce_dsl_'+edp_data_rate+'_l2_y','mms2_edp_dce_dsl_'+edp_data_rate+'_l2_y','mms3_edp_dce_dsl_'+edp_data_rate+'_l2_y','mms4_edp_dce_dsl_'+edp_data_rate+'_l2_y']
      store_data,'mms_edp_dce_dsl_'+edp_data_rate+'_l2_z',data=['mms1_edp_dce_dsl_'+edp_data_rate+'_l2_z','mms2_edp_dce_dsl_'+edp_data_rate+'_l2_z','mms3_edp_dce_dsl_'+edp_data_rate+'_l2_z','mms4_edp_dce_dsl_'+edp_data_rate+'_l2_z']
      options,'mms_edp_dce_dsl_'+edp_data_rate+'_l2_x',constant=0.0,colors=[0,6,4,2],ytitle='MMS!CEDP!Cdsl-x',ysubtitle='[mV/m]',labels=['mms1','mms2','mms3','mms4'],labflag=-1
      options,'mms_edp_dce_dsl_'+edp_data_rate+'_l2_y',constant=0.0,colors=[0,6,4,2],ytitle='MMS!CEDP!Cdsl-y',ysubtitle='[mV/m]',labels=['mms1','mms2','mms3','mms4'],labflag=-1
      options,'mms_edp_dce_dsl_'+edp_data_rate+'_l2_z',constant=0.0,colors=[0,6,4,2],ytitle='MMS!CEDP!Cdsl-z',ysubtitle='[mV/m]',labels=['mms1','mms2','mms3','mms4'],labflag=-1
    endif

  endif

  if not undefined(label_gsm) then label_coord='gsm' else label_coord=coord

  tkm2re,'mms'+probe[0]+'_mec_r_'+label_coord
  split_vec,'mms'+probe[0]+'_mec_r_'+label_coord+'_re'
  options,'mms'+probe[0]+'_mec_r_'+label_coord+'_re_x',ytitle=strupcase(label_coord)+'X [R!DE!N]',format='(f8.4)'
  options,'mms'+probe[0]+'_mec_r_'+label_coord+'_re_y',ytitle=strupcase(label_coord)+'Y [R!DE!N]',format='(f8.4)'
  options,'mms'+probe[0]+'_mec_r_'+label_coord+'_re_z',ytitle=strupcase(label_coord)+'Z [R!DE!N]',format='(f8.4)'
  tplot_options,var_label=['mms'+probe[0]+'_mec_r_'+label_coord+'_re_z','mms'+probe[0]+'_mec_r_'+label_coord+'_re_y','mms'+probe[0]+'_mec_r_'+label_coord+'_re_x']

  tplot_options,'xmargin',[20,10]

  if undefined(ion_plot) then begin
    tplot,['mms_fgm_b_'+coord+'_'+fgm_data_rate+'_l2_btot','mms_fgm_b_'+coord+'_'+fgm_data_rate+'_l2_bvec_?','mms_fgm_b_'+fgm_data_rate+'_l2_lmn_?','mms_fgm_b_'+fgm_data_rate+'_l2_arb','mms_edp_dce_dsl_'+edp_data_rate+'_l2_?']
  endif else begin
    if undefined(gsm) then gse=1
    mms_fpi_l2_comp_kitamura,trange,probe=probe,/no_ele,lmn=lmn,va=na,vn=vn,gsm=gsm,gse=gse
    tplot,['mms_fgm_b_'+coord+'_'+fgm_data_rate+'_l2_btot','mms_dis_bulkVpara','mms_fgm_b_'+fgm_data_rate+'_l2_lmn_l','mms_dis_bulkVperpl','mms_dis_bulkl','mms_fgm_b_'+fgm_data_rate+'_l2_lmn_m','mms_dis_bulkVperpm','mms_dis_bulkm','mms_fgm_b_'+fgm_data_rate+'_l2_lmn_n','mms_dis_bulkVperpn','mms_dis_bulkn']
;    tplot,['mms1_des_brst_energySpectr_omni','mms1_dis_brst_energySpectr_omni','mms_fgm_b_'+coord+'_'+fgm_data_rate+'_l2_btot','mms_dis_bulkVpara','mms_fgm_b_'+fgm_data_rate+'_l2_lmn_l','mms_dis_bulkVperpl','mms_dis_bulkl','mms_fgm_b_'+fgm_data_rate+'_l2_lmn_m','mms_dis_bulkVperpm','mms_dis_bulkm','mms_fgm_b_'+fgm_data_rate+'_l2_lmn_n','mms_dis_bulkVperpn','mms_dis_bulkn']
  endelse
  if not undefined(lmn_orig) then print,'lmn_orig=[['+strcompress(lmn_orig[0,0])+','+strcompress(lmn_orig[1,0])+','+strcompress(lmn_orig[2,0])+'],['+strcompress(lmn_orig[0,1])+','+strcompress(lmn_orig[1,1])+','+strcompress(lmn_orig[2,1])+'],['+strcompress(lmn_orig[0,2])+','+strcompress(lmn_orig[1,2])+','+strcompress(lmn_orig[2,2])+']]'
  if not undefined(almn) then print,'almn=[['+strcompress(lmn[0,0])+','+strcompress(lmn[1,0])+','+strcompress(lmn[2,0])+'],['+strcompress(lmn[0,1])+','+strcompress(lmn[1,1])+','+strcompress(lmn[2,1])+'],['+strcompress(lmn[0,2])+','+strcompress(lmn[1,2])+','+strcompress(lmn[2,2])+']]'

END
