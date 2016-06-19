PRO mms_dfg_edp_comp_kitamura,trange,probe=probe,dce_2d=dce_2d,no_E=no_E,no_B=no_B,no_mec=no_mec,edp_brst=edp_brst,dfg_brst=dfg_brst,lmn=lmn,na=na,almn=almn,vn=vn,gsm=gsm,no_update=no_update,label_gsm=label_gsm,ion_plot=ion_plot,delete=delete

; MMS> mms_dfg_edp_comp_kitamura,['2015-11-18/02:09','2015-11-18/02:15'],/gsm,/dfg_brst

  if not undefined(delete) then store_data, '*', /delete

  trange=time_double(trange)
  
  loadct2,43
  time_stamp,/off
  
  timespan,trange[0],trange[1]-trange[0],/seconds

  if undefined(gsm) then coord='gse' else coord='gsm'
  
  if undefined(probe) then probe=['1','2','3','4'] else probe=strcompress(string(probe),/remove_all)
  
  if undefined(dfg_brst) then dfg_data_rate='srvy' else dfg_data_rate='brst'
  if undefined(no_B) then mms_load_fgm,trange=trange,instrument='dfg',probes=probe,data_rate=dfg_data_rate,level='l2pre',no_update=no_update,/no_attitude_data
  if undefined(no_mec) then mms_load_mec,trange=trange,probes=probe,no_update=no_update
  
  if n_elements(probe) eq 4 then begin
    for p=1,4 do split_vec,'mms'+strcompress(string(p),/remove_all)+'_dfg_b_gse_'+dfg_data_rate+'_l2pre_bvec'
    store_data,'mms_dfg_b_gse_'+dfg_data_rate+'_l2pre_btot',data=['mms1_dfg_b_gse_'+dfg_data_rate+'_l2pre_btot','mms2_dfg_b_gse_'+dfg_data_rate+'_l2pre_btot','mms3_dfg_b_gse_'+dfg_data_rate+'_l2pre_btot','mms4_dfg_b_gse_'+dfg_data_rate+'_l2pre_btot']
    store_data,'mms_dfg_b_gse_'+dfg_data_rate+'_l2pre_bvec_x',data=['mms1_dfg_b_gse_'+dfg_data_rate+'_l2pre_bvec_x','mms2_dfg_b_gse_'+dfg_data_rate+'_l2pre_bvec_x','mms3_dfg_b_gse_'+dfg_data_rate+'_l2pre_bvec_x','mms4_dfg_b_gse_'+dfg_data_rate+'_l2pre_bvec_x']
    store_data,'mms_dfg_b_gse_'+dfg_data_rate+'_l2pre_bvec_y',data=['mms1_dfg_b_gse_'+dfg_data_rate+'_l2pre_bvec_y','mms2_dfg_b_gse_'+dfg_data_rate+'_l2pre_bvec_y','mms3_dfg_b_gse_'+dfg_data_rate+'_l2pre_bvec_y','mms4_dfg_b_gse_'+dfg_data_rate+'_l2pre_bvec_y']
    store_data,'mms_dfg_b_gse_'+dfg_data_rate+'_l2pre_bvec_z',data=['mms1_dfg_b_gse_'+dfg_data_rate+'_l2pre_bvec_z','mms2_dfg_b_gse_'+dfg_data_rate+'_l2pre_bvec_z','mms3_dfg_b_gse_'+dfg_data_rate+'_l2pre_bvec_z','mms4_dfg_b_gse_'+dfg_data_rate+'_l2pre_bvec_z']
    options,'mms_dfg_b_gse_'+dfg_data_rate+'_l2pre_btot',colors=[0,6,4,2],ytitle='MMS!CDFG!CB_total',ysubtitle='[nT]',labels=['mms1','mms2','mms3','mms4'],labflag=-1
    options,'mms_dfg_b_gse_'+dfg_data_rate+'_l2pre_bvec_x',constant=0.0,colors=[0,6,4,2],ytitle='MMS!CDFG!CGSE X',ysubtitle='[nT]',labels=['mms1','mms2','mms3','mms4'],labflag=-1
    options,'mms_dfg_b_gse_'+dfg_data_rate+'_l2pre_bvec_y',constant=0.0,colors=[0,6,4,2],ytitle='MMS!CDFG!CGSE Y',ysubtitle='[nT]',labels=['mms1','mms2','mms3','mms4'],labflag=-1
    options,'mms_dfg_b_gse_'+dfg_data_rate+'_l2pre_bvec_z',constant=0.0,colors=[0,6,4,2],ytitle='MMS!CDFG!CGSE Z',ysubtitle='[nT]',labels=['mms1','mms2','mms3','mms4'],labflag=-1
    for p=1,4 do split_vec,'mms'+strcompress(string(p),/remove_all)+'_dfg_b_gsm_'+dfg_data_rate+'_l2pre_bvec'
    store_data,'mms_dfg_b_gsm_'+dfg_data_rate+'_l2pre_btot',data=['mms1_dfg_b_gsm_'+dfg_data_rate+'_l2pre_btot','mms2_dfg_b_gsm_'+dfg_data_rate+'_l2pre_btot','mms3_dfg_b_gsm_'+dfg_data_rate+'_l2pre_btot','mms4_dfg_b_gsm_'+dfg_data_rate+'_l2pre_btot']
    store_data,'mms_dfg_b_gsm_'+dfg_data_rate+'_l2pre_bvec_x',data=['mms1_dfg_b_gsm_'+dfg_data_rate+'_l2pre_bvec_x','mms2_dfg_b_gsm_'+dfg_data_rate+'_l2pre_bvec_x','mms3_dfg_b_gsm_'+dfg_data_rate+'_l2pre_bvec_x','mms4_dfg_b_gsm_'+dfg_data_rate+'_l2pre_bvec_x']
    store_data,'mms_dfg_b_gsm_'+dfg_data_rate+'_l2pre_bvec_y',data=['mms1_dfg_b_gsm_'+dfg_data_rate+'_l2pre_bvec_y','mms2_dfg_b_gsm_'+dfg_data_rate+'_l2pre_bvec_y','mms3_dfg_b_gsm_'+dfg_data_rate+'_l2pre_bvec_y','mms4_dfg_b_gsm_'+dfg_data_rate+'_l2pre_bvec_y']
    store_data,'mms_dfg_b_gsm_'+dfg_data_rate+'_l2pre_bvec_z',data=['mms1_dfg_b_gsm_'+dfg_data_rate+'_l2pre_bvec_z','mms2_dfg_b_gsm_'+dfg_data_rate+'_l2pre_bvec_z','mms3_dfg_b_gsm_'+dfg_data_rate+'_l2pre_bvec_z','mms4_dfg_b_gsm_'+dfg_data_rate+'_l2pre_bvec_z']
    options,'mms_dfg_b_gsm_'+dfg_data_rate+'_l2pre_btot',colors=[0,6,4,2],ytitle='MMS!CDFG!CB_total',ysubtitle='[nT]',labels=['mms1','mms2','mms3','mms4'],labflag=-1
    options,'mms_dfg_b_gsm_'+dfg_data_rate+'_l2pre_bvec_x',constant=0.0,colors=[0,6,4,2],ytitle='MMS!CDFG!CGSM X',ysubtitle='[nT]',labels=['mms1','mms2','mms3','mms4'],labflag=-1
    options,'mms_dfg_b_gsm_'+dfg_data_rate+'_l2pre_bvec_y',constant=0.0,colors=[0,6,4,2],ytitle='MMS!CDFG!CGSM Y',ysubtitle='[nT]',labels=['mms1','mms2','mms3','mms4'],labflag=-1
    options,'mms_dfg_b_gsm_'+dfg_data_rate+'_l2pre_bvec_z',constant=0.0,colors=[0,6,4,2],ytitle='MMS!CDFG!CGSM Z',ysubtitle='[nT]',labels=['mms1','mms2','mms3','mms4'],labflag=-1
  endif

  if n_elements(na) eq 3 then begin
    na=na/sqrt(na[0]*na[0]+na[1]*na[1]+na[2]*na[2])
    for i=0,n_elements(probe)-1 do begin
      get_data,'mms'+probe[i]+'_dfg_'+dfg_data_rate+'_l2pre_'+coord+'_bvec',data=B
      B_a=dblarr(n_elements(B.x))
      for j=0l,n_elements(B.x)-1 do B_a[j]=B.y[j,0]*na[0]+B.y[j,1]*na[1]+B.y[j,2]*na[2]
      store_data,'mms'+probe[i]+'_dfg_'+dfg_data_rate+'_l2pre_arb',data={x:B.x,y:B_a}
    endfor

    if n_elements(probe) eq 4 then begin
      store_data,'mms_dfg_'+dfg_data_rate+'_l2pre_arb',data=['mms1_dfg_'+dfg_data_rate+'_l2pre_arb','mms2_dfg_'+dfg_data_rate+'_l2pre_arb','mms3_dfg_'+dfg_data_rate+'_l2pre_arb','mms4_dfg_'+dfg_data_rate+'_l2pre_arb']
      options,'mms_dfg_'+dfg_data_rate+'_l2pre_arb',constant=0.0,colors=[0,6,4,2],ytitle='MMS!CDFG!CArbitrary',ysubtitle='[nT]',labels=['mms1','mms2','mms3','mms4'],labflag=-1
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
      get_data,'mms'+probe[i]+'_dfg_'+dfg_data_rate+'_l2pre_'+coord+'_bvec',data=B
      B_lmn=dblarr(n_elements(B.x),3)
      for j=0l,n_elements(B.x)-1 do begin
        B_lmn[j,0]=B.y[j,0]*lmn[0,0]+B.y[j,1]*lmn[1,0]+B.y[j,2]*lmn[2,0]
        B_lmn[j,1]=B.y[j,0]*lmn[0,1]+B.y[j,1]*lmn[1,1]+B.y[j,2]*lmn[2,1]
        B_lmn[j,2]=B.y[j,0]*lmn[0,2]+B.y[j,1]*lmn[1,2]+B.y[j,2]*lmn[2,2]
      endfor
      store_data,'mms'+probe[i]+'_dfg_'+dfg_data_rate+'_l2pre_lmn',data={x:B.x,y:B_lmn}
    endfor
    
    if n_elements(probe) eq 4 then begin
      for p=1,4 do split_vec,'mms'+strcompress(string(p),/remove_all)+'_dfg_'+dfg_data_rate+'_l2pre_lmn',suffix=['_l','_m','_n']
      store_data,'mms_dfg_'+dfg_data_rate+'_l2pre_lmn_l',data=['mms1_dfg_'+dfg_data_rate+'_l2pre_lmn_l','mms2_dfg_'+dfg_data_rate+'_l2pre_lmn_l','mms3_dfg_'+dfg_data_rate+'_l2pre_lmn_l','mms4_dfg_'+dfg_data_rate+'_l2pre_lmn_l']
      store_data,'mms_dfg_'+dfg_data_rate+'_l2pre_lmn_m',data=['mms1_dfg_'+dfg_data_rate+'_l2pre_lmn_m','mms2_dfg_'+dfg_data_rate+'_l2pre_lmn_m','mms3_dfg_'+dfg_data_rate+'_l2pre_lmn_m','mms4_dfg_'+dfg_data_rate+'_l2pre_lmn_m']
      store_data,'mms_dfg_'+dfg_data_rate+'_l2pre_lmn_n',data=['mms1_dfg_'+dfg_data_rate+'_l2pre_lmn_n','mms2_dfg_'+dfg_data_rate+'_l2pre_lmn_n','mms3_dfg_'+dfg_data_rate+'_l2pre_lmn_n','mms4_dfg_'+dfg_data_rate+'_l2pre_lmn_n']
      options,'mms_dfg_'+dfg_data_rate+'_l2pre_lmn_l',constant=0.0,colors=[0,6,4,2],ytitle='MMS!CDFG!Clmn-l',ysubtitle='[nT]',labels=['mms1','mms2','mms3','mms4'],labflag=-1
      options,'mms_dfg_'+dfg_data_rate+'_l2pre_lmn_m',constant=0.0,colors=[0,6,4,2],ytitle='MMS!CDFG!Clmn-m',ysubtitle='[nT]',labels=['mms1','mms2','mms3','mms4'],labflag=-1
      options,'mms_dfg_'+dfg_data_rate+'_l2pre_lmn_n',constant=0.0,colors=[0,6,4,2],ytitle='MMS!CDFG!Clmn-n',ysubtitle='[nT]',labels=['mms1','mms2','mms3','mms4'],labflag=-1
    endif
    
  endif

   
  if undefined(edp_brst) then edp_data_rate='fast' else edp_data_rate='brst'
  if undefined(no_E) then begin
    if undefined(dce_2d) then efield_datatype='dce' else efield_datatype='dce2d'
    mms_load_edp,trange=trange,probes=probes,data_rate=edp_data_rate,level='ql',datatype=efield_datatype,no_update=no_update
    
    if n_elements(probe) eq 4 then begin
      for p=1,4 do split_vec,'mms'+strcompress(string(p),/remove_all)+'_edp_dce_xyz_dsl'
      store_data,'mms_edp_dce_xyz_dsl_x',data=['mms1_edp_dce_xyz_dsl_x','mms2_edp_dce_xyz_dsl_x','mms3_edp_dce_xyz_dsl_x','mms4_edp_dce_xyz_dsl_x']
      store_data,'mms_edp_dce_xyz_dsl_y',data=['mms1_edp_dce_xyz_dsl_y','mms2_edp_dce_xyz_dsl_y','mms3_edp_dce_xyz_dsl_y','mms4_edp_dce_xyz_dsl_y']
      store_data,'mms_edp_dce_xyz_dsl_z',data=['mms1_edp_dce_xyz_dsl_z','mms2_edp_dce_xyz_dsl_z','mms3_edp_dce_xyz_dsl_z','mms4_edp_dce_xyz_dsl_z']
      options,'mms_edp_dce_xyz_dsl_x',constant=0.0,colors=[0,6,4,2],ytitle='MMS!CEDP!Cdsl-x',ysubtitle='[mV/m]',labels=['mms1','mms2','mms3','mms4'],labflag=-1
      options,'mms_edp_dce_xyz_dsl_y',constant=0.0,colors=[0,6,4,2],ytitle='MMS!CEDP!Cdsl-y',ysubtitle='[mV/m]',labels=['mms1','mms2','mms3','mms4'],labflag=-1
      options,'mms_edp_dce_xyz_dsl_z',constant=0.0,colors=[0,6,4,2],ytitle='MMS!CEDP!Cdsl-z',ysubtitle='[mV/m]',labels=['mms1','mms2','mms3','mms4'],labflag=-1
    endif

  endif

  if not undefined(label_gsm) then label_coord='gsm' else label_coord=coord

  if strlen(tnames('mms'+probe[0]+'_mec_r_'+label_coord)) gt 0 then begin
    tkm2re,'mms'+probe[0]+'_mec_r_'+label_coord
    split_vec,'mms'+probe[0]+'_mec_r_'+label_coord+'_re'
    options,'mms'+probe[0]+'_mec_r_'+label_coord+'_re_x',ytitle=strupcase(label_coord)+'X [R!DE!N]',format='(f8.4)'
    options,'mms'+probe[0]+'_mec_r_'+label_coord+'_re_y',ytitle=strupcase(label_coord)+'Y [R!DE!N]',format='(f8.4)'
    options,'mms'+probe[0]+'_mec_r_'+label_coord+'_re_z',ytitle=strupcase(label_coord)+'Z [R!DE!N]',format='(f8.4)'
    tplot_options,var_label=['mms'+probe[0]+'_mec_r_'+label_coord+'_re_z','mms'+probe[0]+'_mec_r_'+label_coord+'_re_y','mms'+probe[0]+'_mec_r_'+label_coord+'_re_x']
  endif else begin
    tkm2re,'mms'+probe[0]+'_pos_'+label_coord
    split_vec,'mms'+probe[0]+'_pos_'+label_coord+'_re'
    options,'mms'+probe[0]+'_pos_'+label_coord+'_re_0',ytitle=strupcase(label_coord)+'X [R!DE!N]',format='(f8.4)'
    options,'mms'+probe[0]+'_pos_'+label_coord+'_re_1',ytitle=strupcase(label_coord)+'Y [R!DE!N]',format='(f8.4)'
    options,'mms'+probe[0]+'_pos_'+label_coord+'_re_2',ytitle=strupcase(label_coord)+'Z [R!DE!N]',format='(f8.4)'
    tplot_options,var_label=['mms'+probe[0]+'_pos_'+label_coord+'_re_2','mms'+probe[0]+'_pos_'+label_coord+'_re_1','mms'+probe[0]+'_pos_'+label_coord+'_re_0']
  endelse

  tplot_options,'xmargin',[20,10]

  if undefined(ion_plot) then begin
    tplot,['mms_dfg_'+dfg_data_rate+'_l2pre_'+coord+'_btot','mms_dfg_'+dfg_data_rate+'_l2pre_'+coord+'_bvec_?','mms_dfg_'+dfg_data_rate+'_l2pre_lmn_?','mms_dfg_'+dfg_data_rate+'_l2pre_arb','mms_edp_dce_xyz_dsl_?']
  endif else begin
    if undefined(gsm) then gse=1
    mms_fpi_comp_kitamura,trange,probe=probe,/no_ele,lmn=lmn,va=na,vn=vn,gsm=gsm,gse=gse
    tplot,['mms_dfg_'+dfg_data_rate+'_l2pre_'+coord+'_btot','mms_dis_bulkVpara','mms_dfg_'+dfg_data_rate+'_l2pre_lmn_l','mms_dis_bulkVperpl','mms_dis_bulkl','mms_dfg_'+dfg_data_rate+'_l2pre_lmn_m','mms_dis_bulkVperpm','mms_dis_bulkm','mms_dfg_'+dfg_data_rate+'_l2pre_lmn_n','mms_dis_bulkVperpn','mms_dis_bulkn']
;    tplot,['mms1_des_brst_energySpectr_omni','mms1_dis_brst_energySpectr_omni','mms_dfg_'+dfg_data_rate+'_l2pre_'+coord+'_btot','mms_dis_bulkVpara','mms_dfg_'+dfg_data_rate+'_l2pre_lmn_l','mms_dis_bulkVperpl','mms_dis_bulkl','mms_dfg_'+dfg_data_rate+'_l2pre_lmn_m','mms_dis_bulkVperpm','mms_dis_bulkm','mms_dfg_'+dfg_data_rate+'_l2pre_lmn_n','mms_dis_bulkVperpn','mms_dis_bulkn']
  endelse
  if not undefined(lmn_orig) then print,'lmn_orig=[['+strcompress(lmn_orig[0,0])+','+strcompress(lmn_orig[1,0])+','+strcompress(lmn_orig[2,0])+'],['+strcompress(lmn_orig[0,1])+','+strcompress(lmn_orig[1,1])+','+strcompress(lmn_orig[2,1])+'],['+strcompress(lmn_orig[0,2])+','+strcompress(lmn_orig[1,2])+','+strcompress(lmn_orig[2,2])+']]'
  if not undefined(almn) then print,'almn=[['+strcompress(lmn[0,0])+','+strcompress(lmn[1,0])+','+strcompress(lmn[2,0])+'],['+strcompress(lmn[0,1])+','+strcompress(lmn[1,1])+','+strcompress(lmn[2,1])+'],['+strcompress(lmn[0,2])+','+strcompress(lmn[1,2])+','+strcompress(lmn[2,2])+']]'

END
