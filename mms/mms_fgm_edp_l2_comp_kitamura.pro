;+
; PROCEDURE:
;         mms_fgm_edp_l2_comp_kitamura
;
; PURPOSE:
;         Plot magnetic and electric field data obtained by FGM and EDP
;
; KEYWORDS:
;         trange:       time range of interest [starttime, endtime] with the format
;                       ['YYYY-MM-DD','YYYY-MM-DD'] or to specify more or less than a day
;                       ['YYYY-MM-DD/hh:mm:ss','YYYY-MM-DD/hh:mm:ss']
;         probes:       probes - value for MMS SC # (default value is ['1','2','3','4'])
;         no_E:         set this flag to skip the use of EDP data
;         no_B:         set this flag to skip the use of FGM data
;         edp_brst:     set this flag to load EDP burst data. if not set, EDP fast survey
;                       data are used
;         fgm_brst:     set this flag to load FGM burst data. if not set, FGM survey data
;                       are used
;         lmn:          input 3 x 3 matrix for coordnate transformation to plot data in the
;                       lmn coordinate. the original coordinate system is the GSE or GSM
;                       coodinate depending on the gsm flag.
;         na:           input normal vector for a new lmn coodinate
;         almn:         set this flag to rotate the lmn coodinate using na as n component
;         out_lmn:      to output new lmn coodinate
;         vn:           n component of the velocity of the coodinate system (use with ion_plot)
;         gsm:          set this flag to plot data in the GSM coordinate
;         no_update:    set this flag to preserve the original FGM and EDP data. if not set and
;                       newer data is found the existing data will be overwritten
;         label_gsm:    set this flag to use the GSM coordinate as the labels
;         ion_plot:     set this flag to plot with FPI-DIS data
;         ion_fast:     set this flag to plot with FPI-DIS fast survey data (use with ion_plot)
;         delete:       set this flag to delete all tplot variables at the beginning
;         no_load:      set this flag to skip loading FGM and EDP data
;
; EXAMPLE:
;
;     To plot data from fluxgate magnetometers (FGM) and axial and spin-plain double probes (EDP)
;     MMS>  mms_fgm_edp_l2_comp_kitamura,['2015-11-18/02:09','2015-11-18/02:15'],/delete,/gsm,/fgm_brst
;     MMS>  mms_fgm_edp_l2_comp_kitamura,['2015-11-18/02:09','2015-11-18/02:15'],probes=['2','3'],/delete,/gsm,/ion_plot
;     MMS>  mms_fgm_edp_l2_comp_kitamura,['2015-11-18/02:09','2015-11-18/02:15'],probes='3',lmn=[[0.2272,0.1985,0.9534],[-0.0503,-0.9753,0.2150],[0.9725,-0.0968,-0.2116]],na=[0.9733,-0.1570,-0.1673],vn=-17.7d,out_lmn=out_lmn,/no_E,/gsm,/fgm_brst,/almn,/ion_plot
;     
; NOTES:
;     See the notes in mms_load_data for rules on the use of MMS data
;-

PRO mms_fgm_edp_l2_comp_kitamura,trange,probes=probes,no_E=no_E,no_B=no_B,edp_brst=edp_brst,fgm_brst=fgm_brst,$
                                 lmn=lmn,na=na,almn=almn,out_lmn=out_lmn,vn=vn,gsm=gsm,no_update=no_update,$
                                 label_gsm=label_gsm,ion_plot=ion_plot,ion_fast=ion_fast,delete=delete,no_load=no_load

  if not undefined(delete) then store_data,'*', /delete

  trange=time_double(trange)
  
  loadct2,43
  time_stamp,/off
  
  timespan,trange[0],trange[1]-trange[0],/seconds

  if undefined(gsm) then coord='gse' else coord='gsm'
  if undefined(probes) then probes=['1','2','3','4'] else if probes[0] eq '*' then probes=['1','2','3','4'] else probes=strcompress(string(probes),/remove_all)
  
  if undefined(fgm_brst) then fgm_data_rate='srvy' else fgm_data_rate='brst'
  if undefined(no_B) or undefined(no_load) then begin
    for i=0,n_elements(probes)-1 do begin
      if strlen(tnames('mms'+probes[i]+'_fgm_r_gse_srvy_l2')) eq 0 and fgm_data_rate eq 'brst' then mms_load_fgm,trange=trange,instrument='fgm',probes=probes[i],data_rate='srvy',level='l2',no_update=no_update,/time_clip,/no_attitude_data
      mms_load_fgm,trange=trange,instrument='fgm',probes=probes[i],data_rate=fgm_data_rate,level='l2',no_update=no_update,/time_clip,/no_attitude_data
      get_data,'mms'+probes[i]+'_fgm_b_'+coord+'_'+fgm_data_rate+'_l2',data=b
      store_data,'mms'+probes[i]+'_fgm_b_'+coord+'_'+fgm_data_rate+'_l2_mod',data={x:b.x,y:[[b.y[*,3]],[b.y[*,0]],[b.y[*,1]],[b.y[*,2]]]}
      options,'mms'+probes[i]+'_fgm_b_'+coord+'_'+fgm_data_rate+'_l2_mod',constant=0.0,colors=[0,2,4,6],labels=['|B|','B!DX!N','B!DY!N','B!DZ!N'],ytitle='MMS'+probes[i]+'!CFGM_L2!C'+strupcase(coord),ysubtitle='[nT]',labflag=-1,datagap=0.26d
      if strlen(tnames('mms'+probes[i]+'_fgm_r_gse_brst_l2')) eq 0 and not undefined(ion_plot) then mms_load_fgm,trange=trange,instrument='fgm',probes=probes[i],data_rate='brst',level='l2',no_update=no_update,/time_clip,/no_attitude_data
    endfor  
  endif
  
  if undefined(no_load) then mms_load_mec,trange=trange,probes=probes,no_update=no_update,varformat=['mms'+probes+'_mec_r_eci','mms'+probes+'_mec_r_gse','mms'+probes+'_mec_r_gsm','mms'+probes+'_mec_L_vec']
  
  if n_elements(probes) gt 1 then begin
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
    for i=0,n_elements(probes)-1 do begin
      get_data,'mms'+probes[i]+'_fgm_b_'+coord+'_'+fgm_data_rate+'_l2_bvec',data=B
      B_a=dblarr(n_elements(B.x))
      for j=0l,n_elements(B.x)-1 do B_a[j]=B.y[j,0]*na[0]+B.y[j,1]*na[1]+B.y[j,2]*na[2]
      store_data,'mms'+probes[i]+'_fgm_b_'+fgm_data_rate+'_l2_arb',data={x:B.x,y:B_a}
    endfor

    if n_elements(probes) gt 1 then begin
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
    for i=0,n_elements(probes)-1 do begin
      get_data,'mms'+probes[i]+'_fgm_b_'+coord+'_'+fgm_data_rate+'_l2_bvec',data=B
      B_lmn=dblarr(n_elements(B.x),3)
      for j=0l,n_elements(B.x)-1 do begin
        B_lmn[j,0]=B.y[j,0]*lmn[0,0]+B.y[j,1]*lmn[1,0]+B.y[j,2]*lmn[2,0]
        B_lmn[j,1]=B.y[j,0]*lmn[0,1]+B.y[j,1]*lmn[1,1]+B.y[j,2]*lmn[2,1]
        B_lmn[j,2]=B.y[j,0]*lmn[0,2]+B.y[j,1]*lmn[1,2]+B.y[j,2]*lmn[2,2]
      endfor
      store_data,'mms'+probes[i]+'_fgm_b_'+fgm_data_rate+'_l2_lmn',data={x:B.x,y:B_lmn}
      options,'mms'+probes[i]+'_fgm_b_'+fgm_data_rate+'_l2_lmn',constant=0.0,colors=[2,4,6],ytitle='MMS'+probes[i]+'!CFGM!CLMN',ysubtitle='[nT]',labels=['B!DL!N','B!DM!N','B!DN!N'],labflag=-1,datagap=0.26d
    endfor
    
    if n_elements(probes) gt 1 then begin
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
    if undefined(no_load) then mms_load_edp,trange=trange,probes=probes,data_rate=edp_data_rate,level='l2',datatype=efield_datatype,no_update=no_update,/time_clip
    if coord eq 'gsm' then for i=0,n_elements(probes)-1 do mms_cotrans,'mms'+probes[i]+'_edp_dce_gse_'+edp_data_rate+'_l2','mms'+probes[i]+'_edp_dce_gsm_'+edp_data_rate+'_l2',in_coord='gse',out_coord='gsm'
    for i=0,n_elements(probes)-1 do options,'mms'+probes[i]+'_edp_dce_'+coord+'_'+edp_data_rate+'_l2',constant=0.0,colors=[2,4,6],ytitle='MMS'+probes[i]+'!CEDP!C'+strupcase(coord),ysubtitle='[mV/m]',labels=['E!DX!N','E!DY!N','E!DZ!N'],labflag=-1,datagap=0.26d
    
    if n_elements(probes) gt 1 then begin
      for p=1,4 do split_vec,'mms'+strcompress(string(p),/remove_all)+'_edp_dce_'+coord+'_'+edp_data_rate+'_l2'
      store_data,'mms_edp_dce_'+coord+'_'+edp_data_rate+'_l2_x',data=['mms1_edp_dce_'+coord+'_'+edp_data_rate+'_l2_x','mms2_edp_dce_'+coord+'_'+edp_data_rate+'_l2_x','mms3_edp_dce_'+coord+'_'+edp_data_rate+'_l2_x','mms4_edp_dce_'+coord+'_'+edp_data_rate+'_l2_x']
      store_data,'mms_edp_dce_'+coord+'_'+edp_data_rate+'_l2_y',data=['mms1_edp_dce_'+coord+'_'+edp_data_rate+'_l2_y','mms2_edp_dce_'+coord+'_'+edp_data_rate+'_l2_y','mms3_edp_dce_'+coord+'_'+edp_data_rate+'_l2_y','mms4_edp_dce_'+coord+'_'+edp_data_rate+'_l2_y']
      store_data,'mms_edp_dce_'+coord+'_'+edp_data_rate+'_l2_z',data=['mms1_edp_dce_'+coord+'_'+edp_data_rate+'_l2_z','mms2_edp_dce_'+coord+'_'+edp_data_rate+'_l2_z','mms3_edp_dce_'+coord+'_'+edp_data_rate+'_l2_z','mms4_edp_dce_'+coord+'_'+edp_data_rate+'_l2_z']
      options,'mms_edp_dce_'+coord+'_'+edp_data_rate+'_l2_x',constant=0.0,colors=[0,6,4,2],ytitle='MMS!CEDP!C'+strupcase(coord)+' X',ysubtitle='[mV/m]',labels=['mms1','mms2','mms3','mms4'],labflag=-1,datagap=0.26d
      options,'mms_edp_dce_'+coord+'_'+edp_data_rate+'_l2_y',constant=0.0,colors=[0,6,4,2],ytitle='MMS!CEDP!C'+strupcase(coord)+' Y',ysubtitle='[mV/m]',labels=['mms1','mms2','mms3','mms4'],labflag=-1,datagap=0.26d
      options,'mms_edp_dce_'+coord+'_'+edp_data_rate+'_l2_z',constant=0.0,colors=[0,6,4,2],ytitle='MMS!CEDP!C'+strupcase(coord)+' Z',ysubtitle='[mV/m]',labels=['mms1','mms2','mms3','mms4'],labflag=-1,datagap=0.26d
    endif

    if n_elements(lmn) eq 9 then begin
      for i=0,n_elements(probes)-1 do begin
        get_data,'mms'+probes[i]+'_edp_dce_'+coord+'_'+edp_data_rate+'_l2',data=E
        E_lmn=dblarr(n_elements(E.x),3)
        for j=0l,n_elements(E.x)-1 do begin
          E_lmn[j,0]=E.y[j,0]*lmn[0,0]+E.y[j,1]*lmn[1,0]+E.y[j,2]*lmn[2,0]
          E_lmn[j,1]=E.y[j,0]*lmn[0,1]+E.y[j,1]*lmn[1,1]+E.y[j,2]*lmn[2,1]
          E_lmn[j,2]=E.y[j,0]*lmn[0,2]+E.y[j,1]*lmn[1,2]+E.y[j,2]*lmn[2,2]
        endfor
        store_data,'mms'+probes[i]+'_edp_dce_'+edp_data_rate+'_l2_lmn',data={x:E.x,y:E_lmn}
        options,'mms'+probes[i]+'_edp_dce_'+edp_data_rate+'_l2_lmn',constant=0.0,colors=[2,4,6],ytitle='MMS'+probes[i]+'!CEDP!Clmn',ysubtitle='[mV/m]',labels=['E!DL!N','E!DM!N','E!DN!N'],labflag=-1,datagap=0.26d
      endfor

      if n_elements(probes) gt 1 then begin
        for p=1,4 do split_vec,'mms'+strcompress(string(p),/remove_all)+'_edp_dce_'+edp_data_rate+'_l2_lmn',suffix=['_l','_m','_n']
        store_data,'mms_edp_dce_'+edp_data_rate+'_l2_lmn_l',data=['mms1_edp_dce_'+edp_data_rate+'_l2_lmn_l','mms2_edp_dce_'+edp_data_rate+'_l2_lmn_l','mms3_edp_dce_'+edp_data_rate+'_l2_lmn_l','mms4_edp_dce_'+edp_data_rate+'_l2_lmn_l']
        store_data,'mms_edp_dce_'+edp_data_rate+'_l2_lmn_m',data=['mms1_edp_dce_'+edp_data_rate+'_l2_lmn_m','mms2_edp_dce_'+edp_data_rate+'_l2_lmn_m','mms3_edp_dce_'+edp_data_rate+'_l2_lmn_m','mms4_edp_dce_'+edp_data_rate+'_l2_lmn_m']
        store_data,'mms_edp_dce_'+edp_data_rate+'_l2_lmn_n',data=['mms1_edp_dce_'+edp_data_rate+'_l2_lmn_n','mms2_edp_dce_'+edp_data_rate+'_l2_lmn_n','mms3_edp_dce_'+edp_data_rate+'_l2_lmn_n','mms4_edp_dce_'+edp_data_rate+'_l2_lmn_n']
        options,'mms_edp_dce_'+edp_data_rate+'_l2_lmn_l',constant=0.0,colors=[0,6,4,2],ytitle='MMS!CEDP!Clmn-l',ysubtitle='[mV/m]',labels=['mms1','mms2','mms3','mms4'],labflag=-1,datagap=0.26d
        options,'mms_edp_dce_'+edp_data_rate+'_l2_lmn_m',constant=0.0,colors=[0,6,4,2],ytitle='MMS!CEDP!Clmn-m',ysubtitle='[mV/m]',labels=['mms1','mms2','mms3','mms4'],labflag=-1,datagap=0.26d
        options,'mms_edp_dce_'+edp_data_rate+'_l2_lmn_n',constant=0.0,colors=[0,6,4,2],ytitle='MMS!CEDP!Clmn-n',ysubtitle='[mV/m]',labels=['mms1','mms2','mms3','mms4'],labflag=-1,datagap=0.26d
      endif

    endif

  endif

  if not undefined(label_gsm) then label_coord='gsm' else label_coord=coord

  tkm2re,'mms'+probes[0]+'_mec_r_'+label_coord
  split_vec,'mms'+probes[0]+'_mec_r_'+label_coord+'_re'
  options,'mms'+probes[0]+'_mec_r_'+label_coord+'_re_x',ytitle=strupcase(label_coord)+'X [R!DE!N]',format='(f8.4)'
  options,'mms'+probes[0]+'_mec_r_'+label_coord+'_re_y',ytitle=strupcase(label_coord)+'Y [R!DE!N]',format='(f8.4)'
  options,'mms'+probes[0]+'_mec_r_'+label_coord+'_re_z',ytitle=strupcase(label_coord)+'Z [R!DE!N]',format='(f8.4)'
  tplot_options,var_label=['mms'+probes[0]+'_mec_r_'+label_coord+'_re_z','mms'+probes[0]+'_mec_r_'+label_coord+'_re_y','mms'+probes[0]+'_mec_r_'+label_coord+'_re_x']

  tplot_options,'xmargin',[20,10]

  if undefined(ion_plot) then begin
    if n_elements(probes) gt 1 then begin
      tplot,['mms_fgm_b_'+coord+'_'+fgm_data_rate+'_l2_btot','mms_fgm_b_'+coord+'_'+fgm_data_rate+'_l2_bvec_?','mms_fgm_b_'+fgm_data_rate+'_l2_lmn_?','mms_fgm_b_'+fgm_data_rate+'_l2_arb','mms_edp_dce_'+coord+'_'+edp_data_rate+'_l2_?','mms_edp_dce_'+edp_data_rate+'_l2_lmn_?']
    endif else begin
      tplot,['mms'+probes+'_fgm_b_'+coord+'_'+fgm_data_rate+'_l2_btot','mms'+probes+'_fgm_b_'+coord+'_'+fgm_data_rate+'_l2_bvec_?','mms'+probes+'_fgm_b_'+fgm_data_rate+'_l2_lmn_?','mms'+probes+'_fgm_b_'+fgm_data_rate+'_l2_arb','mms'+probes+'_edp_dce_'+coord+'_'+edp_data_rate+'_l2_?','mms'+probes+'_edp_dce_'+edp_data_rate+'_l2_lmn_?']
    endelse
  endif else begin
    if undefined(gsm) then gse=1
    mms_fpi_l2_comp_kitamura,trange,probes=probes,/no_ele,/no_load_mec,/no_load_fgm,no_load_fpi=no_load,lmn=lmn,va=na,vn=vn,gsm=gsm,gse=gse,fast=ion_fast
    if n_elements(probes) gt 1 then begin
      if undefined(lmn) then begin
        tplot,['mms_fgm_b_'+coord+'_'+fgm_data_rate+'_l2_btot','mms_dis_bulkvpara','mms_fgm_b_'+coord+'_'+fgm_data_rate+'_l2_bvec_x','mms_dis_bulkvperpX','mms_dis_bulkX','mms_fgm_b_'+coord+'_'+fgm_data_rate+'_l2_bvec_y','mms_dis_bulkvperpY','mms_dis_bulkY','mms_fgm_b_'+coord+'_'+fgm_data_rate+'_l2_bvec_z','mms_dis_bulkvperpZ','mms_dis_bulkZ']
      endif else begin
        tplot,['mms_fgm_b_'+coord+'_'+fgm_data_rate+'_l2_btot','mms_dis_bulkvpara','mms_fgm_b_'+fgm_data_rate+'_l2_lmn_l','mms_dis_bulkvperpl','mms_dis_bulkl','mms_fgm_b_'+fgm_data_rate+'_l2_lmn_m','mms_dis_bulkvperpm','mms_dis_bulkm','mms_fgm_b_'+fgm_data_rate+'_l2_lmn_n','mms_dis_bulkvperpn','mms_dis_bulkn']
      endelse
    endif else begin
      if undefined(lmn) then begin
        tplot,['mms'+probes+'_fgm_b_'+coord+'_'+fgm_data_rate+'_l2_mod','mms'+probes+'_edp_dce_'+coord+'_'+edp_data_rate+'_l2','mms'+probes+'_dis_bulkvpara','mms'+probes+'_dis_bulkvperp_'+coord,'mms'+probes+'_dis_bulkv_'+coord]
      endif else begin
        tplot,['mms'+probes+'_fgm_b_'+coord+'_'+fgm_data_rate+'_l2_btot','mms'+probes+'_edp_dce_'+edp_data_rate+'_l2_lmn','mms'+probes+'_dis_bulkvpara','mms'+probes+'_fgm_b_'+fgm_data_rate+'_l2_lmn','mms'+probes+'_dis_bulkvperp_lmn','mms'+probes+'_dis_bulkv_lmn']
      endelse
    endelse
  endelse
  if not undefined(lmn_orig) then print,'lmn_orig=[['+strcompress(lmn_orig[0,0])+','+strcompress(lmn_orig[1,0])+','+strcompress(lmn_orig[2,0])+'],['+strcompress(lmn_orig[0,1])+','+strcompress(lmn_orig[1,1])+','+strcompress(lmn_orig[2,1])+'],['+strcompress(lmn_orig[0,2])+','+strcompress(lmn_orig[1,2])+','+strcompress(lmn_orig[2,2])+']]'
  if not undefined(almn) then print,'almn=[['+strcompress(lmn[0,0])+','+strcompress(lmn[1,0])+','+strcompress(lmn[2,0])+'],['+strcompress(lmn[0,1])+','+strcompress(lmn[1,1])+','+strcompress(lmn[2,1])+'],['+strcompress(lmn[0,2])+','+strcompress(lmn[1,2])+','+strcompress(lmn[2,2])+']]'
  if not undefined(lmn) then out_lmn=lmn

END
