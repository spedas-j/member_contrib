;+
; PROCEDURE:
;         mms_fpi_comp_kitamura
;
; PURPOSE:
;         Plot FPI level-2 data
;
; KEYWORDS:
;         trange:       time range of interest [starttime, endtime] with the format
;                       ['YYYY-MM-DD','YYYY-MM-DD'] or to specify more or less than a day
;                       ['YYYY-MM-DD/hh:mm:ss','YYYY-MM-DD/hh:mm:ss']
;         probes:       probes - value for MMS SC # (default value is ['1','2','3','4'])
;         no_ele:       set this flag to skip the use of electron data (FPI-DES)
;         no_ion:       set this flag to skip the use of ion data (FPI-DIS)
;         lmn:          input 3 x 3 matrix for coordnate transformation to plot data in the
;                       lmn coordinate. the original coordinate system is the GSE, GSM, or
;                       DSC(dbcs) coodinate depending on the gse or gsm flag.
;         va:           vector of arbitrary direction
;         vn:           n component of the velocity of the coodinate system
;         gsm:          set this flag to plot data in the GSM coordinate
;         gse:          set this flag to plot data in the GSE coordinate
;         no_load_mec:  set this flag to skip loading MEC data
;         no_load_fpi:  set this flag to skip loading FPI data
;         no_load_fgm:  set this flag to skip loading FGM data
;         no_update:    set this flag to preserve the original data. if not set and
;                       newer data is found, the existing data will be overwritten
;         label_gsm:    set this flag to use the GSM coordinate as the labels
;         delete:       set this flag to delete all tplot variables at the beginning
;         fast:         set this flag to use FPI fast survey data. if not set, FPI burst
;                       data is used, if available
;
; EXAMPLE:
;
;     To plot FPI data
;     MMS>  mms_fpi_l2_comp_kitamura,['2015-11-18/02:09','2015-11-18/02:15'],/label_gsm
;     MMS>  mms_fpi_l2_comp_kitamura,['2015-11-18/02:09','2015-11-18/02:15'],probes=['2','3'],/label_gsm
;     MMS>  mms_fpi_l2_comp_kitamura,['2015-11-18/02:09','2015-11-18/02:15'],probes='3',lmn=[[0.197390,0.201321,0.959430],[-0.116952,-0.966861,0.226942],[0.973324,-0.157004,-0.167304]],na=[0.9733,-0.1570,-0.1673],vn=-17.7d,/gsm,/no_ele
;
; NOTES:
;     See the notes in mms_load_data for rules on the use of MMS data
;-

PRO mms_fpi_l2_comp_kitamura,trange,probes=probes,no_ele=no_ele,no_ion=no_ion,lmn=lmn,va=va,vn=vn,gsm=gsm,gse=gse,no_load_mec=no_load_mec,$
                             no_load_fpi=no_load_fpi,no_load_fgm=no_load_fgm,no_update=no_update,label_gsm=label_gsm,delete=delete,fast=fast

  if not undefined(delete) then store_data,'*',/delete

  trange=time_double(trange)
  
  mms_init
  loadct2,43
  time_stamp,/off
  
  timespan,trange[0],trange[1]-trange[0],/seconds

  if not undefined(gse) then coord='gse' else if undefined(gsm) then coord='DSC' else coord='gsm'
  
  if undefined(probes) then probes=['1','2','3','4'] else if probes[0] eq '*' then probes=['1','2','3','4'] else probes=strcompress(string(probes),/remove_all)

  if undefined(no_load_fgm) then begin
    for i=0,n_elements(probes)-1 do begin
      if undefined(fast) then mms_load_fgm,trange=trange,instrument='fgm',probes=probes[i],data_rate='brst',level='l2',no_update=no_update,versions=fgm_versions
      mms_load_fgm,trange=trange,instrument='fgm',probes=probes[i],data_rate='srvy',level='l2',no_update=no_update,versions=fgm_versions
    endfor
  endif

  if undefined(no_load_mec) then mms_load_mec,trange=[trange[0]-600.d,trange[1]+600.d],probes=probes,no_update=no_update,varformat=['mms'+probes+'_mec_r_eci','mms'+probes+'_mec_r_gse','mms'+probes+'_mec_r_gsm','mms'+probes+'_mec_L_vec']

  if undefined(fast) then begin
    fpi_data_rate='brst'
    fgm_data_rate='brst'
    dgap_e=0.032d
    dgap_i=0.16d
    inval_e=0.03d
    inval_i=0.15d
  endif else begin
    fpi_data_rate='fast'
    fgm_data_rate='srvy'
    dgap_e=4.6d
    dgap_i=4.6d
    inval_e=4.5d
    inval_i=4.5d
  endelse

  if undefined(no_ele) then begin
    for i=0,n_elements(probes)-1 do begin
      if undefined(no_load_fpi) then mms_load_fpi,trange=trange,probes=probes[i],level='l2',data_rate=fpi_data_rate,datatype='des-moms',no_update=no_update,versions=des_versions,/center_measurement
      if des_versions[0,0] le 2 then begin
        copy_data,'mms'+probes[i]+'_des_numberdensity_dbcs_'+fpi_data_rate,'mms'+probes[i]+'_des_numberDensity'
        join_vec,'mms'+probes[i]+'_des_bulk'+['x','y','z']+'_dbcs_'+fpi_data_rate,'mms'+probes[i]+'_des_bulkv_DSC'
        options,'mms'+probes[i]+'_des_bulkv_DSC',constant=0.0,ytitle='mms'+probes[i]+'_des!CBulkV!CDSC',ysubtitle='[km/s]',colors=[2,4,6],labels=['V!DX!N','V!DY!N','V!DZ!N'],labflag=-1,datagap=dgap_e
        mms_cotrans,'mms'+probes[i]+'_des_bulkv',in_coord='dmpa',in_suffix='_DSC',out_coord='gse',out_suffix='_gse',/ignore_dlimits
      endif else begin
        copy_data,'mms'+probes[i]+'_des_numberdensity_'+fpi_data_rate,'mms'+probes[i]+'_des_numberDensity'
        copy_data,'mms'+probes[i]+'_des_bulkv_gse_'+fpi_data_rate,'mms'+probes[i]+'_des_bulkv_gse'
      endelse
      options,'mms'+probes[i]+'_des_bulkv_gse',constant=0.0,ytitle='mms'+probes[i]+'_des!CBulkV!CGSE',ysubtitle='[km/s]',colors=[2,4,6],labels=['V!DX!N','V!DY!N','V!DZ!N'],labflag=-1,datagap=dgap_e
      mms_cotrans,'mms'+probes[i]+'_des_bulkv',in_coord='gse',in_suffix='_gse',out_coord='gsm',out_suffix='_gsm',/ignore_dlimits
      options,'mms'+probes[i]+'_des_bulkv_gsm',constant=0.0,ytitle='mms'+probes[i]+'_des!CBulkV!CGSM',ysubtitle='[km/s]',colors=[2,4,6],labels=['V!DX!N','V!DY!N','V!DZ!N'],labflag=-1,datagap=dgap_e
      split_vec,'mms'+probes[i]+'_des_bulkv_'+coord

      if not undefined(lmn) and n_elements(lmn) eq 9 then begin
        get_data,'mms'+probes[i]+'_des_bulkv_'+coord,data=v
        v_lmn=dblarr(n_elements(v.x),3)
        for j=0l,n_elements(v.x)-1 do begin
          v_lmn[j,0]=v.y[j,0]*lmn[0,0]+v.y[j,1]*lmn[1,0]+v.y[j,2]*lmn[2,0]
          v_lmn[j,1]=v.y[j,0]*lmn[0,1]+v.y[j,1]*lmn[1,1]+v.y[j,2]*lmn[2,1]
          v_lmn[j,2]=v.y[j,0]*lmn[0,2]+v.y[j,1]*lmn[1,2]+v.y[j,2]*lmn[2,2]
        endfor
        store_data,'mms'+probes[i]+'_des_bulkv_lmn',data={x:v.x,y:v_lmn}
        options,'mms'+probes[i]+'_des_bulkv_lmn',constant=0.0,ytitle='mms'+probes[i]+'_des!CBulkV!CLMN',ysubtitle='[km/s]',colors=[2,4,6],labels=['V!DL!N','V!DM!N','V!DN!N'],labflag=-1,datagap=dgap_e
        split_vec,'mms'+probes[i]+'_des_bulkv_lmn',suffix=['_l','_m','_n']
      endif
      
      if not undefined(va) and n_elements(va) eq 3 then begin
        if undefined(vn) then vn=0.d
        get_data,'mms'+probes[i]+'_des_bulkv_'+coord,data=v
        nva=va/sqrt(va[0]*va[0]+va[1]*va[1]+va[2]*va[2])
        v_arb=dblarr(n_elements(v.x))
        for j=0l,n_elements(v.x)-1 do begin
          v_arb[j]=v.y[j,0]*nva[0]+v.y[j,1]*nva[1]+v.y[j,2]*nva[2]-vn
        endfor
        store_data,'mms'+probes[i]+'_des_bulkv_arb',data={x:v.x,y:v_arb}
      endif

      copy_data,'mms'+probes[i]+'_des_bulkv_'+coord,'bulkVe'
      if coord ne 'DSC' then fgm_coord=coord else fgm_coord='dmpa'
      box_ave_mms,variable1='bulkVe',variable2='mms'+probes[i]+'_fgm_b_'+fgm_coord+'_'+fgm_data_rate+'_l2_bvec',var2ave='mms'+probes[i]+'_fgm_b_'+fgm_data_rate+'_l2_bvec_des',inval=inval_e
      get_data,'bulkVe',data=v_des
      get_data,'mms'+probes[i]+'_fgm_b_'+fgm_data_rate+'_l2_bvec_des',data=b_des
      vpara_t=total(v_des.y*b_des.y,2)/sqrt(total(b_des.y^2,2))
      vperp_t= sqrt(total(v_des.y^2,2)-vpara_t^2)
      store_data,'mms'+probes[i]+'_des_bulkvperp_mag',data={x:v_des.x,y:vperp_t}
      store_data,'mms'+probes[i]+'_des_bulkvpara',data={x:v_des.x,y:vpara_t}
      options,'mms'+probes[i]+'_des_bulkvpara',constant=0.0,ytitle='mms'+probes[i]+'_des!CBulkVpara',ysubtitle='[km/s]',colors=6,datagap=dgap_e

      vperpx=v_des.y[*,0]-dotp(v_des.y,b_des.y)*b_des.y[*,0]/(b_des.y[*,0]^2+b_des.y[*,1]^2+b_des.y[*,2]^2)
      vperpy=v_des.y[*,1]-dotp(v_des.y,b_des.y)*b_des.y[*,1]/(b_des.y[*,0]^2+b_des.y[*,1]^2+b_des.y[*,2]^2)
      vperpz=v_des.y[*,2]-dotp(v_des.y,b_des.y)*b_des.y[*,2]/(b_des.y[*,0]^2+b_des.y[*,1]^2+b_des.y[*,2]^2)
      vperp=dblarr(n_elements(vperpx),3)
      vperp[*,0]=vperpx
      vperp[*,1]=vperpy
      vperp[*,2]=vperpz
      store_data,'mms'+probes[i]+'_des_bulkvperp_'+coord,data={x:v_des.x,y:vperp}
      options,'mms'+probes[i]+'_des_bulkvperp_'+coord,constant=0.0,ytitle='mms'+probes[i]+'_des!CBulkV!C'+strupcase(coord),ysubtitle='[km/s]',colors=[2,4,6],labels=['V!DX!N','V!DY!N','V!DZ!N'],labflag=-1,datagap=dgap_e
      store_data,'mms'+probes[i]+'_des_bulkvperp_'+coord+'_x',data={x:v_des.x,y:vperpx}
      store_data,'mms'+probes[i]+'_des_bulkvperp_'+coord+'_y',data={x:v_des.x,y:vperpy}
      store_data,'mms'+probes[i]+'_des_bulkvperp_'+coord+'_z',data={x:v_des.x,y:vperpz}

      if not undefined(lmn) and n_elements(lmn) eq 9 then begin
        vperp_lmn=dblarr(n_elements(v_des.x),3)
        for j=0l,n_elements(v_des.x)-1 do begin
          vperp_lmn[j,0]=vperp[j,0]*lmn[0,0]+vperp[j,1]*lmn[1,0]+vperp[j,2]*lmn[2,0]
          vperp_lmn[j,1]=vperp[j,0]*lmn[0,1]+vperp[j,1]*lmn[1,1]+vperp[j,2]*lmn[2,1]
          vperp_lmn[j,2]=vperp[j,0]*lmn[0,2]+vperp[j,1]*lmn[1,2]+vperp[j,2]*lmn[2,2]
        endfor
        store_data,'mms'+probes[i]+'_des_bulkvperp_lmn',data={x:v_des.x,y:vperp_lmn}
        options,'mms'+probes[i]+'_des_bulkvperp_lmn',constant=0.0,ytitle='mms'+probes[i]+'_des!CBulkVperp!CLMN',ysubtitle='[km/s]',colors=[2,4,6],labels=['V!DL!N','V!DM!N','V!DN!N'],labflag=-1,datagap=dgap_e
        split_vec,'mms'+probes[i]+'_des_bulkvperp_lmn',suffix=['_l','_m','_n']
      endif

      if not undefined(va) and n_elements(va) eq 3 then begin
        get_data,'mms'+probes[i]+'_des_bulkvperp_'+coord,data=vperp
        vperp_arb=dblarr(n_elements(vperp.x))
        for j=0l,n_elements(vperp.x)-1 do begin
          vperp_arb[j]=vperp.y[j,0]*nva[0]+vperp.y[j,1]*nva[1]+vperp.y[j,2]*nva[2]-vn
        endfor
        store_data,'mms'+probes[i]+'_des_bulkvperp_arb',data={x:v.x,y:vperp_arb}
      endif
      
      if des_versions[0,0] le 2 and fpi_data_rate eq 'fast' then begin
        get_data,'mms'+probes[i]+'_des_tempxx_dbcs_'+fpi_data_rate,data=txx
        get_data,'mms'+probes[i]+'_des_tempyy_dbcs_'+fpi_data_rate,data=tyy
        get_data,'mms'+probes[i]+'_des_tempzz_dbcs_'+fpi_data_rate,data=tzz
        get_data,'mms'+probes[i]+'_des_tempxy_dbcs_'+fpi_data_rate,data=txy
        get_data,'mms'+probes[i]+'_des_tempxz_dbcs_'+fpi_data_rate,data=txz
        get_data,'mms'+probes[i]+'_des_tempyz_dbcs_'+fpi_data_rate,data=tyz
        store_data,'mms'+probes[i]+'te_tensor',data={x:txx.x,y:[[txx.y],[tyy.y],[tzz.y],[txy.y],[txz.y],[tyz.y]]}
        diag_t,'mms'+probes[i]+'te_tensor'
        copy_data,'T_diag','mms'+probes[i]+'_fpi_DES_T_diag'
        copy_data,'Saxis','mms'+probes[i]+'_fpi_DES_T_Saxis'
        get_data,'T_diag',data=t_diag
        store_data,'mms'+probes[i]+'_fpi_DEStempPerp',data={x:t_diag.x,y:(t_diag.y[*,1]+t_diag.y[*,2])/2.d}
        store_data,'mms'+probes[i]+'_fpi_DEStempPara',data={x:t_diag.x,y:t_diag.y[*,0]}
      endif else begin
        copy_data,'mms'+probes[i]+'_des_tempperp_'+fpi_data_rate,'mms'+probes[i]+'_fpi_DEStempPerp'
        copy_data,'mms'+probes[i]+'_des_temppara_'+fpi_data_rate,'mms'+probes[i]+'_fpi_DEStempPara'
      endelse

    endfor

    if n_elements(probes) gt 1 then begin
      store_data,'mms_des_numberDensity',data=['mms1_des_numberDensity','mms2_des_numberDensity','mms3_des_numberDensity','mms4_des_numberDensity']
      store_data,'mms_des_bulkX',data=['mms1_des_bulkv_'+coord+'_x','mms2_des_bulkv_'+coord+'_x','mms3_des_bulkv_'+coord+'_x','mms4_des_bulkv_'+coord+'_x']
      store_data,'mms_des_bulkY',data=['mms1_des_bulkv_'+coord+'_y','mms2_des_bulkv_'+coord+'_y','mms3_des_bulkv_'+coord+'_y','mms4_des_bulkv_'+coord+'_y']
      store_data,'mms_des_bulkZ',data=['mms1_des_bulkv_'+coord+'_z','mms2_des_bulkv_'+coord+'_z','mms3_des_bulkv_'+coord+'_z','mms4_des_bulkv_'+coord+'_z']
      store_data,'mms_des_bulkvperpX',data=['mms1_des_bulkvperp_'+coord+'_x','mms2_des_bulkvperp_'+coord+'_x','mms3_des_bulkvperp_'+coord+'_x','mms4_des_bulkvperp_'+coord+'_x']
      store_data,'mms_des_bulkvperpY',data=['mms1_des_bulkvperp_'+coord+'_y','mms2_des_bulkvperp_'+coord+'_y','mms3_des_bulkvperp_'+coord+'_y','mms4_des_bulkvperp_'+coord+'_y']
      store_data,'mms_des_bulkvperpZ',data=['mms1_des_bulkvperp_'+coord+'_z','mms2_des_bulkvperp_'+coord+'_z','mms3_des_bulkvperp_'+coord+'_z','mms4_des_bulkvperp_'+coord+'_z']
      store_data,'mms_des_bulkvperp_mag',data=['mms1_des_bulkvperp_mag','mms2_des_bulkvperp_mag','mms3_des_bulkvperp_mag','mms4_des_bulkvperp_mag']
      store_data,'mms_des_bulkvpara',data=['mms1_des_bulkvpara','mms2_des_bulkvpara','mms3_des_bulkvpara','mms4_des_bulkvpara']
      
      if not undefined(lmn) and n_elements(lmn) eq 9 then begin
        store_data,'mms_des_bulkl',data=['mms1_des_bulkv_lmn_l','mms2_des_bulkv_lmn_l','mms3_des_bulkv_lmn_l','mms4_des_bulkv_lmn_l']
        store_data,'mms_des_bulkm',data=['mms1_des_bulkv_lmn_m','mms2_des_bulkv_lmn_m','mms3_des_bulkv_lmn_m','mms4_des_bulkv_lmn_m']
        store_data,'mms_des_bulkn',data=['mms1_des_bulkv_lmn_n','mms2_des_bulkv_lmn_n','mms3_des_bulkv_lmn_n','mms4_des_bulkv_lmn_n']
        options,'mms_des_bulkl',constant=0.0,colors=[0,6,4,2],ytitle='MMS!CDES!CBulkV!Clmn l',ysubtitle='[km/s]',labels=['mms1','mms2','mms3','mms4'],labflag=-1,datagap=dgap_e
        options,'mms_des_bulkm',constant=0.0,colors=[0,6,4,2],ytitle='MMS!CDES!CBulkV!Clmn m',ysubtitle='[km/s]',labels=['mms1','mms2','mms3','mms4'],labflag=-1,datagap=dgap_e
        options,'mms_des_bulkn',constant=0.0,colors=[0,6,4,2],ytitle='MMS!CDES!CBulkV!Clmn n',ysubtitle='[km/s]',labels=['mms1','mms2','mms3','mms4'],labflag=-1,datagap=dgap_e
        store_data,'mms_des_bulkvperpl',data=['mms1_des_bulkvperp_lmn_l','mms2_des_bulkvperp_lmn_l','mms3_des_bulkvperp_lmn_l','mms4_des_bulkvperp_lmn_l']
        store_data,'mms_des_bulkvperpm',data=['mms1_des_bulkvperp_lmn_m','mms2_des_bulkvperp_lmn_m','mms3_des_bulkvperp_lmn_m','mms4_des_bulkvperp_lmn_m']
        store_data,'mms_des_bulkvperpn',data=['mms1_des_bulkvperp_lmn_n','mms2_des_bulkvperp_lmn_n','mms3_des_bulkvperp_lmn_n','mms4_des_bulkvperp_lmn_n']
        options,'mms_des_bulkvperpl',constant=0.0,colors=[0,6,4,2],ytitle='MMS!CDES!CBulkVperp!Clmn l',ysubtitle='[km/s]',labels=['mms1','mms2','mms3','mms4'],labflag=-1,datagap=dgap_e
        options,'mms_des_bulkvperpm',constant=0.0,colors=[0,6,4,2],ytitle='MMS!CDES!CBulkVperp!Clmn m',ysubtitle='[km/s]',labels=['mms1','mms2','mms3','mms4'],labflag=-1,datagap=dgap_e
        options,'mms_des_bulkvperpn',constant=0.0,colors=[0,6,4,2],ytitle='MMS!CDES!CBulkVperp!Clmn n',ysubtitle='[km/s]',labels=['mms1','mms2','mms3','mms4'],labflag=-1,datagap=dgap_e
      endif
      if not undefined(va) and n_elements(va) eq 3 then begin
        store_data,'mms_des_bulkva',data=['mms1_des_bulkv_arb','mms2_des_bulkv_arb','mms3_des_bulkv_arb','mms4_des_bulkv_arb']
        options,'mms_des_bulkva',constant=0.0,colors=[0,6,4,2],ytitle='MMS!CDES!CBulkV!CArbitrary',ysubtitle='[km/s]',labels=['mms1','mms2','mms3','mms4'],labflag=-1,datagap=dgap_e
        store_data,'mms_des_bulkvperpa',data=['mms1_des_bulkvperp_arb','mms2_des_bulkvperp_arb','mms3_des_bulkvperp_arb','mms4_des_bulkvperp_arb']
        options,'mms_des_bulkvperpa',constant=0.0,colors=[0,6,4,2],ytitle='MMS!CDES!CBulkVperp!CArbitrary',ysubtitle='[km/s]',labels=['mms1','mms2','mms3','mms4'],labflag=-1,datagap=dgap_e
      endif
      store_data,'mms_des_Tperp',data=['mms1_fpi_DEStempPerp','mms2_fpi_DEStempPerp','mms3_fpi_DEStempPerp','mms4_fpi_DEStempPerp']
      store_data,'mms_des_Tpara',data=['mms1_fpi_DEStempPara','mms2_fpi_DEStempPara','mms3_fpi_DEStempPara','mms4_fpi_DEStempPara']

      options,'mms_des_numberDensity',colors=[0,6,4,2],ytitle='MMS!CDES!CNumber!CDensity',ysubtitle='[/cm!U3!N]',labels=['mms1','mms2','mms3','mms4'],labflag=-1,ylog=1,datagap=dgap_e,ytickformat='mms_exponent2'
      ylim,'mms_des_numberDensity',0.03d,300.d,1
      options,'mms_des_bulkX',constant=0.0,colors=[0,6,4,2],ytitle='MMS!CDES!CBulkV!C'+strupcase(coord)+' X',ysubtitle='[km/s]',labels=['mms1','mms2','mms3','mms4'],labflag=-1,datagap=dgap_e
      options,'mms_des_bulkY',constant=0.0,colors=[0,6,4,2],ytitle='MMS!CDES!CBulkV!C'+strupcase(coord)+' Y',ysubtitle='[km/s]',labels=['mms1','mms2','mms3','mms4'],labflag=-1,datagap=dgap_e
      options,'mms_des_bulkZ',constant=0.0,colors=[0,6,4,2],ytitle='MMS!CDES!CBulkV!C'+strupcase(coord)+' Z',ysubtitle='[km/s]',labels=['mms1','mms2','mms3','mms4'],labflag=-1,datagap=dgap_e
      options,'mms_des_bulkvperpX',constant=0.0,colors=[0,6,4,2],ytitle='MMS!CDES!CBulkVperp!C'+strupcase(coord)+' X',ysubtitle='[km/s]',labels=['mms1','mms2','mms3','mms4'],labflag=-1,datagap=dgap_e
      options,'mms_des_bulkvperpY',constant=0.0,colors=[0,6,4,2],ytitle='MMS!CDES!CBulkVperp!C'+strupcase(coord)+' Y',ysubtitle='[km/s]',labels=['mms1','mms2','mms3','mms4'],labflag=-1,datagap=dgap_e
      options,'mms_des_bulkvperpZ',constant=0.0,colors=[0,6,4,2],ytitle='MMS!CDES!CBulkVperp!C'+strupcase(coord)+' Z',ysubtitle='[km/s]',labels=['mms1','mms2','mms3','mms4'],labflag=-1,datagap=dgap_e
      options,'mms_des_bulkvperp_mag',colors=[0,6,4,2],ytitle='MMS!CDES!CBulkVperpV!CMagnitude',ysubtitle='[km/s]',labels=['mms1','mms2','mms3','mms4'],labflag=-1,datagap=dgap_e
      options,'mms_des_bulkvpara',constant=0.0,colors=[0,6,4,2],ytitle='MMS!CDES!CBulkVpara',ysubtitle='[km/s]',labels=['mms1','mms2','mms3','mms4'],labflag=-1,datagap=dgap_e
      options,'mms_des_Tperp',colors=[0,6,4,2],ytitle='MMS!CDES!CTperp',ysubtitle='[eV]',labels=['mms1','mms2','mms3','mms4'],labflag=-1,ylog=1,datagap=dgap_e,ytickformat='mms_exponent2'
      options,'mms_des_Tpara',colors=[0,6,4,2],ytitle='MMS!CDES!CTpara',ysubtitle='[eV]',labels=['mms1','mms2','mms3','mms4'],labflag=-1,ylog=1,datagap=dgap_e,ytickformat='mms_exponent2'
      ylim,'mms_des_T*',5.d,30000.d,1
    endif
  endif

  if undefined(no_ion) then begin
    for i=0,n_elements(probes)-1 do begin
      if undefined(no_load_fpi) then mms_load_fpi,trange=trange,probes=probes[i],level='l2',data_rate=fpi_data_rate,datatype='dis-moms',no_update=no_update,versions=dis_versions,/center_measurement

      if dis_versions[0,0] le 2 then begin
        copy_data,'mms'+probes[i]+'_dis_numberdensity_dbcs_'+fpi_data_rate,'mms'+probes[i]+'_dis_numberDensity'
        join_vec,'mms'+probes[i]+'_dis_bulk'+['x','y','z']+'_dbcs_'+fpi_data_rate,'mms'+probes[i]+'_dis_bulkv_DSC'
        options,'mms'+probes[i]+'_dis_bulkv_DSC',constant=0.0,ytitle='mms'+probes[i]+'_dis!CBulkV!CDSC',ysubtitle='[km/s]',colors=[2,4,6],labels=['V!DX!N','V!DY!N','V!DZ!N'],labflag=-1,datagap=dgap_i
        mms_cotrans,'mms'+probes[i]+'_dis_bulkv',in_coord='dmpa',in_suffix='_DSC',out_coord='gse',out_suffix='_gse',/ignore_dlimits
      endif else begin
        copy_data,'mms'+probes[i]+'_dis_numberdensity_'+fpi_data_rate,'mms'+probes[i]+'_dis_numberDensity'
        copy_data,'mms'+probes[i]+'_dis_bulkv_gse_'+fpi_data_rate,'mms'+probes[i]+'_dis_bulkv_gse'
      endelse
      options,'mms'+probes[i]+'_dis_bulkv_gse',constant=0.0,ytitle='mms'+probes[i]+'_dis!CBulkV!CGSE',ysubtitle='[km/s]',colors=[2,4,6],labels=['V!DX!N','V!DY!N','V!DZ!N'],labflag=-1,datagap=dgap_i
      mms_cotrans,'mms'+probes[i]+'_dis_bulkv',in_coord='gse',in_suffix='_gse',out_coord='gsm',out_suffix='_gsm',/ignore_dlimits
      options,'mms'+probes[i]+'_dis_bulkv_gsm',constant=0.0,ytitle='mms'+probes[i]+'_dis!CBulkV!CGSM',ysubtitle='[km/s]',colors=[2,4,6],labels=['V!DX!N','V!DY!N','V!DZ!N'],labflag=-1,datagap=dgap_i
      split_vec,'mms'+probes[i]+'_dis_bulkv_'+coord

      if not undefined(lmn) and n_elements(lmn) eq 9 then begin
        get_data,'mms'+probes[i]+'_dis_bulkv_'+coord,data=v
        v_lmn=dblarr(n_elements(v.x),3)
        for j=0l,n_elements(v.x)-1 do begin
          v_lmn[j,0]=v.y[j,0]*lmn[0,0]+v.y[j,1]*lmn[1,0]+v.y[j,2]*lmn[2,0]
          v_lmn[j,1]=v.y[j,0]*lmn[0,1]+v.y[j,1]*lmn[1,1]+v.y[j,2]*lmn[2,1]
          v_lmn[j,2]=v.y[j,0]*lmn[0,2]+v.y[j,1]*lmn[1,2]+v.y[j,2]*lmn[2,2]
        endfor
        store_data,'mms'+probes[i]+'_dis_bulkv_lmn',data={x:v.x,y:v_lmn}
        options,'mms'+probes[i]+'_dis_bulkv_lmn',constant=0.0,ytitle='mms'+probes[i]+'_dis!CBulkV!CLMN',ysubtitle='[km/s]',colors=[2,4,6],labels=['V!DL!N','V!DM!N','V!DN!N'],labflag=-1,datagap=dgap_i
        split_vec,'mms'+probes[i]+'_dis_bulkv_lmn',suffix=['_l','_m','_n']
      endif

      if not undefined(va) and n_elements(va) eq 3 then begin
        if undefined(vn) then vn=0.d
        get_data,'mms'+probes[i]+'_dis_bulkv_'+coord,data=v
        nva=va/sqrt(va[0]*va[0]+va[1]*va[1]+va[2]*va[2])
        v_arb=dblarr(n_elements(v.x))
        for j=0l,n_elements(v.x)-1 do begin
          v_arb[j]=v.y[j,0]*nva[0]+v.y[j,1]*nva[1]+v.y[j,2]*nva[2]-vn
        endfor
        store_data,'mms'+probes[i]+'_dis_bulkv_arb',data={x:v.x,y:v_arb}
      endif
      
      copy_data,'mms'+probes[i]+'_dis_bulkv_'+coord,'bulkVi'
      if coord ne 'DSC' then fgm_coord=coord else fgm_coord='dmpa'
      box_ave_mms,variable1='bulkVi',variable2='mms'+probes[i]+'_fgm_b_'+fgm_coord+'_'+fgm_data_rate+'_l2_bvec',var2ave='mms'+probes[i]+'_fgm_b_'+fgm_data_rate+'_l2_bvec_dis',inval=inval_i
      get_data,'bulkVi',data=v_dis
      get_data,'mms'+probes[i]+'_fgm_b_'+fgm_data_rate+'_l2_bvec_dis',data=b_dis
      vpara_t=total(v_dis.y*b_dis.y,2)/sqrt(total(b_dis.y^2,2))
      vperp_t= sqrt(total(v_dis.y^2,2)-vpara_t^2)
      store_data,'mms'+probes[i]+'_dis_bulkvperp_mag',data={x:v_dis.x,y:vperp_t}
      store_data,'mms'+probes[i]+'_dis_bulkvpara',data={x:v_dis.x,y:vpara_t}
      options,'mms'+probes[i]+'_dis_bulkvpara',constant=0.0,ytitle='mms'+probes[i]+'_dis!CBulkVpara',ysubtitle='[km/s]',colors=6,datagap=dgap_i

      vperpx=v_dis.y[*,0]-dotp(v_dis.y,b_dis.y)*b_dis.y[*,0]/(b_dis.y[*,0]^2+b_dis.y[*,1]^2+b_dis.y[*,2]^2)
      vperpy=v_dis.y[*,1]-dotp(v_dis.y,b_dis.y)*b_dis.y[*,1]/(b_dis.y[*,0]^2+b_dis.y[*,1]^2+b_dis.y[*,2]^2)
      vperpz=v_dis.y[*,2]-dotp(v_dis.y,b_dis.y)*b_dis.y[*,2]/(b_dis.y[*,0]^2+b_dis.y[*,1]^2+b_dis.y[*,2]^2)
      vperp=dblarr(n_elements(vperpx),3)
      vperp[*,0]=vperpx
      vperp[*,1]=vperpy
      vperp[*,2]=vperpz
      store_data,'mms'+probes[i]+'_dis_bulkvperp_'+coord,data={x:v_dis.x,y:vperp}
      options,'mms'+probes[i]+'_dis_bulkvperp_'+coord,constant=0.0,ytitle='mms'+probes[i]+'_dis!CBulkVperp!C'+strupcase(coord),ysubtitle='[km/s]',colors=[2,4,6],labels=['V!DX!N','V!DY!N','V!DZ!N'],labflag=-1,datagap=dgap_i
      store_data,'mms'+probes[i]+'_dis_bulkvperp_'+coord+'_x',data={x:v_dis.x,y:vperpx}
      store_data,'mms'+probes[i]+'_dis_bulkvperp_'+coord+'_y',data={x:v_dis.x,y:vperpy}
      store_data,'mms'+probes[i]+'_dis_bulkvperp_'+coord+'_z',data={x:v_dis.x,y:vperpz}

      if not undefined(lmn) and n_elements(lmn) eq 9 then begin
        vperp_lmn=dblarr(n_elements(v_dis.x),3)
        for j=0l,n_elements(v_dis.x)-1 do begin
          vperp_lmn[j,0]=vperp[j,0]*lmn[0,0]+vperp[j,1]*lmn[1,0]+vperp[j,2]*lmn[2,0]
          vperp_lmn[j,1]=vperp[j,0]*lmn[0,1]+vperp[j,1]*lmn[1,1]+vperp[j,2]*lmn[2,1]
          vperp_lmn[j,2]=vperp[j,0]*lmn[0,2]+vperp[j,1]*lmn[1,2]+vperp[j,2]*lmn[2,2]
        endfor
        store_data,'mms'+probes[i]+'_dis_bulkvperp_lmn',data={x:v_dis.x,y:vperp_lmn}
        options,'mms'+probes[i]+'_dis_bulkvperp_lmn',constant=0.0,ytitle='mms'+probes[i]+'_dis!CBulkVperp!CLMN',ysubtitle='[km/s]',colors=[2,4,6],labels=['V!DL!N','V!DM!N','V!DN!N'],labflag=-1,datagap=dgap_i
        split_vec,'mms'+probes[i]+'_dis_bulkvperp_lmn',suffix=['_l','_m','_n']
      endif
      
      if not undefined(va) and n_elements(va) eq 3 then begin
        get_data,'mms'+probes[i]+'_dis_bulkvperp_'+coord,data=vperp
        vperp_arb=dblarr(n_elements(vperp.x))
        for j=0l,n_elements(vperp.x)-1 do begin
          vperp_arb[j]=vperp.y[j,0]*nva[0]+vperp.y[j,1]*nva[1]+vperp.y[j,2]*nva[2]-vn
        endfor
        store_data,'mms'+probes[i]+'_dis_bulkvperp_arb',data={x:v.x,y:vperp_arb}
      endif
      
      copy_data,'mms'+probes[i]+'_dis_tempperp_'+fpi_data_rate,'mms'+probes[i]+'_fpi_DIStempPerp'
      copy_data,'mms'+probes[i]+'_dis_temppara_'+fpi_data_rate,'mms'+probes[i]+'_fpi_DIStempPara'

    endfor

    if n_elements(probes) gt 1 then begin
      store_data,'mms_dis_numberDensity',data=['mms1_dis_numberDensity','mms2_dis_numberDensity','mms3_dis_numberDensity','mms4_dis_numberDensity']
      store_data,'mms_dis_bulkX',data=['mms1_dis_bulkv_'+coord+'_x','mms2_dis_bulkv_'+coord+'_x','mms3_dis_bulkv_'+coord+'_x','mms4_dis_bulkv_'+coord+'_x']
      store_data,'mms_dis_bulkY',data=['mms1_dis_bulkv_'+coord+'_y','mms2_dis_bulkv_'+coord+'_y','mms3_dis_bulkv_'+coord+'_y','mms4_dis_bulkv_'+coord+'_y']
      store_data,'mms_dis_bulkZ',data=['mms1_dis_bulkv_'+coord+'_z','mms2_dis_bulkv_'+coord+'_z','mms3_dis_bulkv_'+coord+'_z','mms4_dis_bulkv_'+coord+'_z']
      store_data,'mms_dis_bulkvperpX',data=['mms1_dis_bulkvperp_'+coord+'_x','mms2_dis_bulkvperp_'+coord+'_x','mms3_dis_bulkvperp_'+coord+'_x','mms4_dis_bulkvperp_'+coord+'_x']
      store_data,'mms_dis_bulkvperpY',data=['mms1_dis_bulkvperp_'+coord+'_y','mms2_dis_bulkvperp_'+coord+'_y','mms3_dis_bulkvperp_'+coord+'_y','mms4_dis_bulkvperp_'+coord+'_y']
      store_data,'mms_dis_bulkvperpZ',data=['mms1_dis_bulkvperp_'+coord+'_z','mms2_dis_bulkvperp_'+coord+'_z','mms3_dis_bulkvperp_'+coord+'_z','mms4_dis_bulkvperp_'+coord+'_z']
      store_data,'mms_dis_bulkvperp_mag',data=['mms1_dis_bulkvperp_mag','mms2_dis_bulkvperp_mag','mms3_dis_bulkvperp_mag','mms4_dis_bulkvperp_mag']
      store_data,'mms_dis_bulkvpara',data=['mms1_dis_bulkvpara','mms2_dis_bulkvpara','mms3_dis_bulkvpara','mms4_dis_bulkvpara']
      if not undefined(lmn) and n_elements(lmn) eq 9 then begin
        store_data,'mms_dis_bulkl',data=['mms1_dis_bulkv_lmn_l','mms2_dis_bulkv_lmn_l','mms3_dis_bulkv_lmn_l','mms4_dis_bulkv_lmn_l']
        store_data,'mms_dis_bulkm',data=['mms1_dis_bulkv_lmn_m','mms2_dis_bulkv_lmn_m','mms3_dis_bulkv_lmn_m','mms4_dis_bulkv_lmn_m']
        store_data,'mms_dis_bulkn',data=['mms1_dis_bulkv_lmn_n','mms2_dis_bulkv_lmn_n','mms3_dis_bulkv_lmn_n','mms4_dis_bulkv_lmn_n']
        options,'mms_dis_bulkl',constant=0.0,colors=[0,6,4,2],ytitle='MMS!CDIS!CBulkV!Clmn l',ysubtitle='[km/s]',labels=['mms1','mms2','mms3','mms4'],labflag=-1,datagap=dgap_i
        options,'mms_dis_bulkm',constant=0.0,colors=[0,6,4,2],ytitle='MMS!CDIS!CBulkV!Clmn m',ysubtitle='[km/s]',labels=['mms1','mms2','mms3','mms4'],labflag=-1,datagap=dgap_i
        options,'mms_dis_bulkn',constant=0.0,colors=[0,6,4,2],ytitle='MMS!CDIS!CBulkV!Clmn n',ysubtitle='[km/s]',labels=['mms1','mms2','mms3','mms4'],labflag=-1,datagap=dgap_i
        store_data,'mms_dis_bulkvperpl',data=['mms1_dis_bulkvperp_lmn_l','mms2_dis_bulkvperp_lmn_l','mms3_dis_bulkvperp_lmn_l','mms4_dis_bulkvperp_lmn_l']
        store_data,'mms_dis_bulkvperpm',data=['mms1_dis_bulkvperp_lmn_m','mms2_dis_bulkvperp_lmn_m','mms3_dis_bulkvperp_lmn_m','mms4_dis_bulkvperp_lmn_m']
        store_data,'mms_dis_bulkvperpn',data=['mms1_dis_bulkvperp_lmn_n','mms2_dis_bulkvperp_lmn_n','mms3_dis_bulkvperp_lmn_n','mms4_dis_bulkvperp_lmn_n']
        options,'mms_dis_bulkvperpl',constant=0.0,colors=[0,6,4,2],ytitle='MMS!CDIS!CBulkVperp!Clmn l',ysubtitle='[km/s]',labels=['mms1','mms2','mms3','mms4'],labflag=-1,datagap=dgap_i
        options,'mms_dis_bulkvperpm',constant=0.0,colors=[0,6,4,2],ytitle='MMS!CDIS!CBulkVperp!Clmn m',ysubtitle='[km/s]',labels=['mms1','mms2','mms3','mms4'],labflag=-1,datagap=dgap_i
        options,'mms_dis_bulkvperpn',constant=0.0,colors=[0,6,4,2],ytitle='MMS!CDIS!CBulkVperp!Clmn n',ysubtitle='[km/s]',labels=['mms1','mms2','mms3','mms4'],labflag=-1,datagap=dgap_i
      endif
      if not undefined(va) and n_elements(va) eq 3 then begin
        store_data,'mms_dis_bulkva',data=['mms1_dis_bulkv_arb','mms2_dis_bulkv_arb','mms3_dis_bulkv_arb','mms4_dis_bulkv_arb']
        options,'mms_dis_bulkva',constant=0.0,colors=[0,6,4,2],ytitle='MMS!CDIS!CBulkV!CArbitrary',ysubtitle='[km/s]',labels=['mms1','mms2','mms3','mms4'],labflag=-1,datagap=dgap_i
        store_data,'mms_dis_bulkvperpa',data=['mms1_dis_bulkvperp_arb','mms2_dis_bulkvperp_arb','mms3_dis_bulkvperp_arb','mms4_dis_bulkvperp_arb']
        options,'mms_dis_bulkvperpa',constant=0.0,colors=[0,6,4,2],ytitle='MMS!CDIS!CBulkVperp!CArbitrary',ysubtitle='[km/s]',labels=['mms1','mms2','mms3','mms4'],labflag=-1,datagap=dgap_i
      endif
      store_data,'mms_dis_Tperp',data=['mms1_fpi_DIStempPerp','mms2_fpi_DIStempPerp','mms3_fpi_DIStempPerp','mms4_fpi_DIStempPerp']
      store_data,'mms_dis_Tpara',data=['mms1_fpi_DIStempPara','mms2_fpi_DIStempPara','mms3_fpi_DIStempPara','mms4_fpi_DIStempPara']

      options,'mms_dis_numberDensity',colors=[0,6,4,2],ytitle='MMS!CDIS!CNumber!CDensity',ysubtitle='[/cm!U3!N]',labels=['mms1','mms2','mms3','mms4'],labflag=-1,ylog=1,datagap=dgap_i,ytickformat='mms_exponent2'
      ylim,'mms_dis_numberDensity',0.03d,300.d,1
      options,'mms_dis_bulkX',constant=0.0,colors=[0,6,4,2],ytitle='MMS!CDIS!CBulkV!C'+strupcase(coord)+' X',ysubtitle='[km/s]',labels=['mms1','mms2','mms3','mms4'],labflag=-1,datagap=dgap_i
      options,'mms_dis_bulkY',constant=0.0,colors=[0,6,4,2],ytitle='MMS!CDIS!CBulkV!C'+strupcase(coord)+' Y',ysubtitle='[km/s]',labels=['mms1','mms2','mms3','mms4'],labflag=-1,datagap=dgap_i
      options,'mms_dis_bulkZ',constant=0.0,colors=[0,6,4,2],ytitle='MMS!CDIS!CBulkV!C'+strupcase(coord)+' Z',ysubtitle='[km/s]',labels=['mms1','mms2','mms3','mms4'],labflag=-1,datagap=dgap_i
      options,'mms_dis_bulkvperpX',constant=0.0,colors=[0,6,4,2],ytitle='MMS!CDIS!CBulkVperp!C'+strupcase(coord)+' X',ysubtitle='[km/s]',labels=['mms1','mms2','mms3','mms4'],labflag=-1,datagap=dgap_i
      options,'mms_dis_bulkvperpY',constant=0.0,colors=[0,6,4,2],ytitle='MMS!CDIS!CBulkVperp!C'+strupcase(coord)+' Y',ysubtitle='[km/s]',labels=['mms1','mms2','mms3','mms4'],labflag=-1,datagap=dgap_i
      options,'mms_dis_bulkvperpZ',constant=0.0,colors=[0,6,4,2],ytitle='MMS!CDIS!CBulkVperp!C'+strupcase(coord)+' Z',ysubtitle='[km/s]',labels=['mms1','mms2','mms3','mms4'],labflag=-1,datagap=dgap_i
      options,'mms_dis_bulkvperp_mag',colors=[0,6,4,2],ytitle='MMS!CDIS!CBulkVperpV!CMagnitude',ysubtitle='[km/s]',labels=['mms1','mms2','mms3','mms4'],labflag=-1,datagap=dgap_i
      options,'mms_dis_bulkvpara',constant=0.0,colors=[0,6,4,2],ytitle='MMS!CDIS!CBulkVpara',ysubtitle='[km/s]',labels=['mms1','mms2','mms3','mms4'],labflag=-1,datagap=dgap_i
      options,'mms_dis_Tperp',colors=[0,6,4,2],ytitle='MMS!CDIS!CTperp',ysubtitle='[eV]',labels=['mms1','mms2','mms3','mms4'],labflag=-1,ylog=1,datagap=dgap_i,ytickformat='mms_exponent2'
      options,'mms_dis_Tpara',colors=[0,6,4,2],ytitle='MMS!CDIS!CTpara',ysubtitle='[eV]',labels=['mms1','mms2','mms3','mms4'],labflag=-1,ylog=1,datagap=dgap_i,ytickformat='mms_exponent2'
      ylim,'mms_dis_T*',5.d,30000.d,1
    endif
  endif

  if not undefined(label_gsm) or not undefined(gsm) then label_coord='gsm' else label_coord='gse'

  if strlen(tnames('mms'+probes[0]+'_mec_r_'+label_coord)) gt 0 then begin
    tkm2re,'mms'+probes[0]+'_mec_r_'+label_coord
    split_vec,'mms'+probes[0]+'_mec_r_'+label_coord+'_re'
    options,'mms'+probes[0]+'_mec_r_'+label_coord+'_re_x',ytitle=strupcase(label_coord)+'X [R!DE!N]',format='(f8.4)'
    options,'mms'+probes[0]+'_mec_r_'+label_coord+'_re_y',ytitle=strupcase(label_coord)+'Y [R!DE!N]',format='(f8.4)'
    options,'mms'+probes[0]+'_mec_r_'+label_coord+'_re_z',ytitle=strupcase(label_coord)+'Z [R!DE!N]',format='(f8.4)'
    tplot_options,var_label=['mms'+probes[0]+'_mec_r_'+label_coord+'_re_z','mms'+probes[0]+'_mec_r_'+label_coord+'_re_y','mms'+probes[0]+'_mec_r_'+label_coord+'_re_x']
  endif else begin
    tkm2re,'mms'+probes[0]+'_fgm_r_'+label_coord+'_srvy_l2'
    split_vec,'mms'+probes[0]+'_fgm_r_'+label_coord+'_srvy_l2_re'
    options,'mms'+probes[0]+'_fgm_r_'+label_coord+'_srvy_l2_re_0',ytitle=strupcase(label_coord)+'X [R!DE!N]',format='(f8.4)'
    options,'mms'+probes[0]+'_fgm_r_'+label_coord+'_srvy_l2_re_1',ytitle=strupcase(label_coord)+'Y [R!DE!N]',format='(f8.4)'
    options,'mms'+probes[0]+'_fgm_r_'+label_coord+'_srvy_l2_re_2',ytitle=strupcase(label_coord)+'Z [R!DE!N]',format='(f8.4)'
    tplot_options,var_label=['mms'+probes[0]+'_fgm_r_'+label_coord+'_srvy_l2_re_2','mms'+probes[0]+'_fgm_r_'+label_coord+'_srvy_l2_re_1','mms'+probes[0]+'_fgm_r_'+label_coord+'_srvy_l2_re_0']
  endelse

  tplot_options,'xmargin',[20,10]
;  tplot,['mms_des_numberDensity','mms_des_bulk*','mms_des_T*','mms_dis_numberDensity','mms_dis_bulk*','mms_dis_T*']
;  tplot,['mms_des_numberDensity','mms_des_bulkv*','mms_des_T*','mms_dis_numberDensity','mms_dis_bulkv*','mms_dis_T*']
;  tplot,['mms_des_numberDensity','mms_des_bulk*','mms_dis_numberDensity','mms_dis_bulk*']
  tplot,['mms_des_numberDensity','mms_des_bulkv*l','mms_des_bulkv*m','mms_des_bulkv*n','mms_des_bulkv*a','mms_dis_numberDensity','mms_dis_bulkv*l','mms_dis_bulkv*m','mms_dis_bulkv*n','mms_dis_bulkv*a']


END
