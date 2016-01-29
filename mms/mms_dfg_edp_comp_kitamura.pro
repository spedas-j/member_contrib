PRO mms_dfg_edp_comp_kitamura,trange,probe=probe,dce_2d=dce_2d,no_E=no_E,no_B=no_B,edp_brst=edp_brst,dfg_brst=dfg_brst,lmn=lmn,na=na,gsm=gsm,no_update=no_update,label_gsm=label_gsm,delete=delete

; MMS> mms_dfg_edp_comp_kitamura,['2015-11-18/02:09','2015-11-18/02:15'],/gsm,/dfg_brst

  if not undefined(delete) then store_data, '*', /delete

  trange=time_double(trange)
  
  loadct2,43
  time_stamp,/off
  
  timespan,trange[0],trange[1]-trange[0],/seconds

  if undefined(gsm) then coord='gse' else coord='gsm'
  
  if undefined(probe) then probe=['1','2','3','4'] else probe=strcompress(string(probe),/remove_all)
  
  if undefined(dfg_brst) then dfg_data_rate='srvy' else dfg_data_rate='brst'
  if undefined(no_B) then begin
    for i=0,n_elements(probe)-1 do begin
      if strlen(tnames('mms'+probe[i]+'_pos_gse')) gt 0 then copy_data,'mms'+probe[i]+'_pos_gse','mms'+probe[i]+'_pos_gse_temp'
      if strlen(tnames('mms'+probe[i]+'_pos_gsm')) gt 0 then copy_data,'mms'+probe[i]+'_pos_gsm','mms'+probe[i]+'_pos_gsm_temp'
      mms_load_fgm,trange=trange,instrument='dfg',probes=probe[i],data_rate=dfg_data_rate,level='l2pre',no_update=no_update,/no_attitude_data
      if strlen(tnames('mms'+probe[i]+'_pos_gse_temp')) gt 0 then copy_data,'mms'+probe[i]+'_pos_gse_temp','mms'+probe[i]+'_pos_gse'
      if strlen(tnames('mms'+probe[i]+'_pos_gsm_temp')) gt 0 then copy_data,'mms'+probe[i]+'_pos_gsm_temp','mms'+probe[i]+'_pos_gsm'
      if strlen(tnames('mms'+probe[i]+'_pos_gse_temp')) gt 0 then store_data,'mms'+probe[i]+'_pos_gs?_temp',/delete
    endfor  
  endif
  
  if n_elements(probe) eq 4 then begin
    for p=1,4 do split_vec,'mms'+strcompress(string(p),/remove_all)+'_dfg_'+dfg_data_rate+'_l2pre_gse_bvec'
    store_data,'mms_dfg_'+dfg_data_rate+'_l2pre_gse_btot',data=['mms1_dfg_'+dfg_data_rate+'_l2pre_gse_btot','mms2_dfg_'+dfg_data_rate+'_l2pre_gse_btot','mms3_dfg_'+dfg_data_rate+'_l2pre_gse_btot','mms4_dfg_'+dfg_data_rate+'_l2pre_gse_btot']
    store_data,'mms_dfg_'+dfg_data_rate+'_l2pre_gse_bvec_x',data=['mms1_dfg_'+dfg_data_rate+'_l2pre_gse_bvec_x','mms2_dfg_'+dfg_data_rate+'_l2pre_gse_bvec_x','mms3_dfg_'+dfg_data_rate+'_l2pre_gse_bvec_x','mms4_dfg_'+dfg_data_rate+'_l2pre_gse_bvec_x']
    store_data,'mms_dfg_'+dfg_data_rate+'_l2pre_gse_bvec_y',data=['mms1_dfg_'+dfg_data_rate+'_l2pre_gse_bvec_y','mms2_dfg_'+dfg_data_rate+'_l2pre_gse_bvec_y','mms3_dfg_'+dfg_data_rate+'_l2pre_gse_bvec_y','mms4_dfg_'+dfg_data_rate+'_l2pre_gse_bvec_y']
    store_data,'mms_dfg_'+dfg_data_rate+'_l2pre_gse_bvec_z',data=['mms1_dfg_'+dfg_data_rate+'_l2pre_gse_bvec_z','mms2_dfg_'+dfg_data_rate+'_l2pre_gse_bvec_z','mms3_dfg_'+dfg_data_rate+'_l2pre_gse_bvec_z','mms4_dfg_'+dfg_data_rate+'_l2pre_gse_bvec_z']
    options,'mms_dfg_'+dfg_data_rate+'_l2pre_gse_btot',colors=[0,2,4,6],ytitle='MMS!CDFG!CB_total',ysubtitle='[nT]',labels=['mms1','mms2','mms3','mms4'],labflag=-1
    options,'mms_dfg_'+dfg_data_rate+'_l2pre_gse_bvec_x',constant=0.0,colors=[0,2,4,6],ytitle='MMS!CDFG!CGSE X',ysubtitle='[nT]',labels=['mms1','mms2','mms3','mms4'],labflag=-1
    options,'mms_dfg_'+dfg_data_rate+'_l2pre_gse_bvec_y',constant=0.0,colors=[0,2,4,6],ytitle='MMS!CDFG!CGSE Y',ysubtitle='[nT]',labels=['mms1','mms2','mms3','mms4'],labflag=-1
    options,'mms_dfg_'+dfg_data_rate+'_l2pre_gse_bvec_z',constant=0.0,colors=[0,2,4,6],ytitle='MMS!CDFG!CGSE Z',ysubtitle='[nT]',labels=['mms1','mms2','mms3','mms4'],labflag=-1
    for p=1,4 do split_vec,'mms'+strcompress(string(p),/remove_all)+'_dfg_'+dfg_data_rate+'_l2pre_gsm_bvec'
    store_data,'mms_dfg_'+dfg_data_rate+'_l2pre_gsm_btot',data=['mms1_dfg_'+dfg_data_rate+'_l2pre_gsm_btot','mms2_dfg_'+dfg_data_rate+'_l2pre_gsm_btot','mms3_dfg_'+dfg_data_rate+'_l2pre_gsm_btot','mms4_dfg_'+dfg_data_rate+'_l2pre_gsm_btot']
    store_data,'mms_dfg_'+dfg_data_rate+'_l2pre_gsm_bvec_x',data=['mms1_dfg_'+dfg_data_rate+'_l2pre_gsm_bvec_x','mms2_dfg_'+dfg_data_rate+'_l2pre_gsm_bvec_x','mms3_dfg_'+dfg_data_rate+'_l2pre_gsm_bvec_x','mms4_dfg_'+dfg_data_rate+'_l2pre_gsm_bvec_x']
    store_data,'mms_dfg_'+dfg_data_rate+'_l2pre_gsm_bvec_y',data=['mms1_dfg_'+dfg_data_rate+'_l2pre_gsm_bvec_y','mms2_dfg_'+dfg_data_rate+'_l2pre_gsm_bvec_y','mms3_dfg_'+dfg_data_rate+'_l2pre_gsm_bvec_y','mms4_dfg_'+dfg_data_rate+'_l2pre_gsm_bvec_y']
    store_data,'mms_dfg_'+dfg_data_rate+'_l2pre_gsm_bvec_z',data=['mms1_dfg_'+dfg_data_rate+'_l2pre_gsm_bvec_z','mms2_dfg_'+dfg_data_rate+'_l2pre_gsm_bvec_z','mms3_dfg_'+dfg_data_rate+'_l2pre_gsm_bvec_z','mms4_dfg_'+dfg_data_rate+'_l2pre_gsm_bvec_z']
    options,'mms_dfg_'+dfg_data_rate+'_l2pre_gsm_btot',colors=[0,2,4,6],ytitle='MMS!CDFG!CB_total',ysubtitle='[nT]',labels=['mms1','mms2','mms3','mms4'],labflag=-1
    options,'mms_dfg_'+dfg_data_rate+'_l2pre_gsm_bvec_x',constant=0.0,colors=[0,2,4,6],ytitle='MMS!CDFG!CGSM X',ysubtitle='[nT]',labels=['mms1','mms2','mms3','mms4'],labflag=-1
    options,'mms_dfg_'+dfg_data_rate+'_l2pre_gsm_bvec_y',constant=0.0,colors=[0,2,4,6],ytitle='MMS!CDFG!CGSM Y',ysubtitle='[nT]',labels=['mms1','mms2','mms3','mms4'],labflag=-1
    options,'mms_dfg_'+dfg_data_rate+'_l2pre_gsm_bvec_z',constant=0.0,colors=[0,2,4,6],ytitle='MMS!CDFG!CGSM Z',ysubtitle='[nT]',labels=['mms1','mms2','mms3','mms4'],labflag=-1
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
      options,'mms_dfg_'+dfg_data_rate+'_l2pre_lmn_l',constant=0.0,colors=[0,2,4,6],ytitle='MMS!CDFG!Clmn-l',ysubtitle='[nT]',labels=['mms1','mms2','mms3','mms4'],labflag=-1
      options,'mms_dfg_'+dfg_data_rate+'_l2pre_lmn_m',constant=0.0,colors=[0,2,4,6],ytitle='MMS!CDFG!Clmn-m',ysubtitle='[nT]',labels=['mms1','mms2','mms3','mms4'],labflag=-1
      options,'mms_dfg_'+dfg_data_rate+'_l2pre_lmn_n',constant=0.0,colors=[0,2,4,6],ytitle='MMS!CDFG!Clmn-n',ysubtitle='[nT]',labels=['mms1','mms2','mms3','mms4'],labflag=-1
    endif
    
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
      options,'mms_dfg_'+dfg_data_rate+'_l2pre_arb',constant=0.0,colors=[0,2,4,6],ytitle='MMS!CDFG!CArbitrary',ysubtitle='[nT]',labels=['mms1','mms2','mms3','mms4'],labflag=-1
    endif
    
  endif
   
  if undefined(edp_brst) then edp_data_rate='fast' else edp_data_rate='brst'
  if undefined(no_E) then begin
    if undefined(dce_2d) then efield_datatype='dce' else efield_datatype='dce2d'
    mms_load_edp,trange=trange,probes=probes,data_rate=edp_data_rate,level='ql',datatype=efield_datatype,no_update=no_update
    
    if n_elements(probe) eq 4 then begin
      for p=1,4 do split_vec,'mms'+strcompress(string(p),/remove_all)+'_edp_'+edp_data_rate+'_dce_dsl'
      store_data,'mms_edp_'+edp_data_rate+'_dce_dsl_x',data=['mms1_edp_'+edp_data_rate+'_dce_dsl_x','mms2_edp_'+edp_data_rate+'_dce_dsl_x','mms3_edp_'+edp_data_rate+'_dce_dsl_x','mms4_edp_'+edp_data_rate+'_dce_dsl_x']
      store_data,'mms_edp_'+edp_data_rate+'_dce_dsl_y',data=['mms1_edp_'+edp_data_rate+'_dce_dsl_y','mms2_edp_'+edp_data_rate+'_dce_dsl_y','mms3_edp_'+edp_data_rate+'_dce_dsl_y','mms4_edp_'+edp_data_rate+'_dce_dsl_y']
      store_data,'mms_edp_'+edp_data_rate+'_dce_dsl_z',data=['mms1_edp_'+edp_data_rate+'_dce_dsl_z','mms2_edp_'+edp_data_rate+'_dce_dsl_z','mms3_edp_'+edp_data_rate+'_dce_dsl_z','mms4_edp_'+edp_data_rate+'_dce_dsl_z']
      options,'mms_edp_'+edp_data_rate+'_dce_dsl_x',constant=0.0,colors=[0,2,4,6],ytitle='MMS!CEDP!Cdsl-x',ysubtitle='[mV/m]',labels=['mms1','mms2','mms3','mms4'],labflag=-1
      options,'mms_edp_'+edp_data_rate+'_dce_dsl_y',constant=0.0,colors=[0,2,4,6],ytitle='MMS!CEDP!Cdsl-y',ysubtitle='[mV/m]',labels=['mms1','mms2','mms3','mms4'],labflag=-1
      options,'mms_edp_'+edp_data_rate+'_dce_dsl_z',constant=0.0,colors=[0,2,4,6],ytitle='MMS!CEDP!Cdsl-z',ysubtitle='[mV/m]',labels=['mms1','mms2','mms3','mms4'],labflag=-1
    endif

  endif

  if not undefined(label_gsm) then label_coord='gsm' else label_coord=coord

  tkm2re,'mms'+probe[0]+'_pos_'+label_coord
  split_vec,'mms'+probe[0]+'_pos_'+label_coord+'_re'
  options,'mms'+probe[0]+'_pos_'+label_coord+'_re_0',ytitle=strupcase(label_coord)+'X [R!DE!N]',format='(f8.4)'
  options,'mms'+probe[0]+'_pos_'+label_coord+'_re_1',ytitle=strupcase(label_coord)+'Y [R!DE!N]',format='(f8.4)'
  options,'mms'+probe[0]+'_pos_'+label_coord+'_re_2',ytitle=strupcase(label_coord)+'Z [R!DE!N]',format='(f8.4)'
  tplot_options,var_label=['mms'+probe[0]+'_pos_'+label_coord+'_re_2','mms'+probe[0]+'_pos_'+label_coord+'_re_1','mms'+probe[0]+'_pos_'+label_coord+'_re_0']

  tplot_options,'xmargin',[20,10]
  tplot,['mms_dfg_'+dfg_data_rate+'_l2pre_'+coord+'_btot','mms_dfg_'+dfg_data_rate+'_l2pre_'+coord+'_bvec_?','mms_dfg_'+dfg_data_rate+'_l2pre_lmn_?','mms_dfg_'+dfg_data_rate+'_l2pre_arb','mms_edp_'+edp_data_rate+'_dce_dsl_?']

END
