;+
; PROCEDURE:
;         mms_fpi_comp_kitamura
;
; PURPOSE:
;         Plot fpi data
;
; KEYWORDS:
;         trange:       time range of interest [starttime, endtime] with the format
;                       ['YYYY-MM-DD','YYYY-MM-DD'] or to specify more or less than a day
;                       ['YYYY-MM-DD/hh:mm:ss','YYYY-MM-DD/hh:mm:ss']
;         probes:       probes - value for MMS SC # (default value is ['1','2','3','4'])
;         no_ele:       set this flag to skip the use of electron data (FPI-DES)
;         no_ion:       set this flag to skip the use of ion data (FPI-DES)
;         lmn:          input 3 x 3 matrix for coordnate transformation to plot data in the
;                       lmn coordinate. the original coordinate system is the GSE, GSM, or
;                       DSC(dbcs) coodinate depending on the gse or gsm flag.
;         va:           vector of arbitrary direction
;         vn:           n component of the velocity of the coodinate system
;         gsm:          set this flag to plot data in the GSM coordinate
;         gse:          set this flag to plot data in the GSE coordinate
;         no_update:    set this flag to preserve the original data. if not set and
;                       newer data is found, the existing data will be overwritten
;         label_gsm:    set this flag to use the GSM coordinate as the labels
;         delete:       set this flag to delete all tplot variables at the beginning
;         fast:         set this flag to use FPI fast survey data. if not set, FPI burst
;                       data is used, if available
;         no_load_mec:  set this flag to skip loading MEC data
;
; EXAMPLE:
;
;     To plot fpi data
;     MMS>  mms_fpi_comp_kitamura,['2015-11-18/02:09','2015-11-18/02:15'],/label_gsm
;     MMS>  mms_fpi_comp_kitamura,['2015-11-18/02:09','2015-11-18/02:15'],probes='1',/label_gsm
;     MMS>  mms_fpi_comp_kitamura,['2015-11-18/02:09','2015-11-18/02:15'],probes='3',lmn=[[0.197390,0.201321,0.959430],[-0.116952,-0.966861,0.226942],[0.973324,-0.157004,-0.167304]],na=[0.9733,-0.1570,-0.1673],vn=-17.7d,/gsm,/no_ele
;
; NOTES:
;     See the notes in mms_load_data for rules on the use of MMS data
;-

PRO mms_fpi_comp_kitamura,trange,probes=probes,no_ele=no_ele,no_ion=no_ion,lmn=lmn,va=va,vn=vn,gsm=gsm,$
                          gse=gse,no_load_mec=no_load_mec,no_load_fpi=no_load_fpi,no_load_dfg=no_load_dfg,$
                          no_update=no_update,label_gsm=label_gsm,delete=delete,fast=fast,time_clip=time_clip

  if not undefined(delete) then store_data,'*',/delete

  trange=time_double(trange)
  
  mms_init
  loadct2,43
  time_stamp,/off
  
  timespan,trange[0],trange[1]-trange[0],/seconds

  if not undefined(gse) then coord='gse' else if undefined(gsm) then coord='DSC' else coord='gsm'
  
  if undefined(probes) then probes=['1','2','3','4'] else if probes[0] eq '*' then probes=['1','2','3','4'] else probes=strcompress(string(probes),/remove_all)

  if undefined(no_load_dfg) then begin

    for i=0,n_elements(probes)-1 do begin
      if undefined(fast) then mms_load_fgm,trange=trange,instrument='dfg',probes=probes[i],data_rate='brst',level='l2pre',no_update=no_update,versions=fgm_versions
      mms_load_fgm,trange=trange,instrument='dfg',probes=probes[i],data_rate='srvy',level='l2pre',no_update=no_update,versions=fgm_versions
    endfor
  endif

  if undefined(no_load_mec) then mms_load_mec,trange=[trange[0]-600.d,trange[1]+600.d],probes=probes,no_update=no_update,varformat=['mms'+probes+'_mec_r_eci','mms'+probes+'_mec_r_gse','mms'+probes+'_mec_r_gsm','mms'+probes+'_mec_L_vec']

  if undefined(fast) then fpi_data_rate='brst' else fpi_data_rate='fast'

  if undefined(no_ele) then begin
    for i=0,n_elements(probes)-1 do begin
      if undefined(no_load_fpi) then mms_load_fpi,trange=trange,probes=probes[i],level='l2',data_rate=fpi_data_rate,datatype='des-moms',no_update=no_update,time_clip=time_clip
      if strlen(tnames('mms'+probes[i]+'_des_bulkx_dbcs_'+fpi_data_rate)) eq 0 then begin
        if undefined(no_load_fpi) then mms_load_fpi,trange=trange,probes=probes[i],level='l1b',data_rate=fpi_data_rate,datatype='des-moms',no_update=no_update,time_clip=time_clip
        join_vec,'mms'+probes[i]+'_des_bulk'+['X','Y','Z'],'mms'+probes[i]+'_des_bulkV_DSC'
      endif else begin
        join_vec,'mms'+probes[i]+'_des_bulk'+['x','y','z']+'_dbcs_'+fpi_data_rate,'mms'+probes[i]+'_des_bulkV_DSC'
        copy_data,'mms'+probes[i]+'_des_numberdensity_dbcs_'+fpi_data_rate,'mms'+probes[i]+'_des_numberDensity'
      endelse
      options,'mms'+probes[i]+'_des_bulkV_DSC',constant=0.0,ytitle='mms'+probes[i]+'_des!CBulkV!CDSC',ysubtitle='[km/s]',colors=[2,4,6],labels=['V!DX!N','V!DY!N','V!DZ!N'],labflag=-1,datagap=0.032d
      mms_cotrans,'mms'+probes[i]+'_des_bulkV',in_coord='dmpa',in_suffix='_DSC',out_coord='gse',out_suffix='_gse',/ignore_dlimits
      options,'mms'+probes[i]+'_des_bulkV_gse',constant=0.0,ytitle='mms'+probes[i]+'_des!CBulkV!CGSE',ysubtitle='[km/s]',colors=[2,4,6],labels=['V!DX!N','V!DY!N','V!DZ!N'],labflag=-1,datagap=0.032d
      mms_cotrans,'mms'+probes[i]+'_des_bulkV',in_coord='gse',in_suffix='_gse',out_coord='gsm',out_suffix='_gsm',/ignore_dlimits
      options,'mms'+probes[i]+'_des_bulkV_gsm',constant=0.0,ytitle='mms'+probes[i]+'_des!CBulkV!CGSM',ysubtitle='[km/s]',colors=[2,4,6],labels=['V!DX!N','V!DY!N','V!DZ!N'],labflag=-1,datagap=0.032d
      split_vec,'mms'+probes[i]+'_des_bulkV_'+coord

      if not undefined(lmn) and n_elements(lmn) eq 9 then begin
        get_data,'mms'+probes[i]+'_des_bulkV_'+coord,data=v
        v_lmn=dblarr(n_elements(v.x),3)
        for j=0l,n_elements(v.x)-1 do begin
          v_lmn[j,0]=v.y[j,0]*lmn[0,0]+v.y[j,1]*lmn[1,0]+v.y[j,2]*lmn[2,0]
          v_lmn[j,1]=v.y[j,0]*lmn[0,1]+v.y[j,1]*lmn[1,1]+v.y[j,2]*lmn[2,1]
          v_lmn[j,2]=v.y[j,0]*lmn[0,2]+v.y[j,1]*lmn[1,2]+v.y[j,2]*lmn[2,2]
        endfor
        store_data,'mms'+probes[i]+'_des_bulkV_lmn',data={x:v.x,y:v_lmn}
        split_vec,'mms'+probes[i]+'_des_bulkV_lmn',suffix=['_l','_m','_n']
      endif
      
      if not undefined(va) and n_elements(va) eq 3 then begin
        if undefined(vn) then vn=0.d
        get_data,'mms'+probes[i]+'_des_bulkV_'+coord,data=v
        nva=va/sqrt(va[0]*va[0]+va[1]*va[1]+va[2]*va[2])
        v_arb=dblarr(n_elements(v.x))
        for j=0l,n_elements(v.x)-1 do begin
          v_arb[j]=v.y[j,0]*nva[0]+v.y[j,1]*nva[1]+v.y[j,2]*nva[2]-vn
        endfor
        store_data,'mms'+probes[i]+'_des_bulkV_arb',data={x:v.x,y:v_arb}
      endif

      copy_data,'mms'+probes[i]+'_des_bulkV_'+coord,'bulkVe'
      if coord ne 'DSC' then dfg_coord=coord else dfg_coord='dmpa'
      box_ave_mms,variable1='bulkVe',variable2='mms'+probes[i]+'_dfg_brst_l2pre_'+dfg_coord+'_bvec',var2ave='mms'+probes[i]+'_dfg_brst_l2pre_bvec_des',inval=0.03d
      get_data,'bulkVe',data=v_des
      get_data,'mms'+probes[i]+'_dfg_brst_l2pre_bvec_des',data=b_des
      vpara_t=total(v_des.y*b_des.y,2)/sqrt(total(b_des.y^2,2))
      vperp_t= sqrt(total(v_des.y^2,2)-vpara_t^2)
      store_data,'mms'+probes[i]+'_des_bulkVperp_mag',data={x:v_des.x,y:vperp_t}
      store_data,'mms'+probes[i]+'_des_bulkVpara',data={x:v_des.x,y:vpara_t}

      vperpx=v_des.y[*,0]-dotp(v_des.y,b_des.y)*b_des.y[*,0]/(b_des.y[*,0]^2+b_des.y[*,1]^2+b_des.y[*,2]^2)
      vperpy=v_des.y[*,1]-dotp(v_des.y,b_des.y)*b_des.y[*,1]/(b_des.y[*,0]^2+b_des.y[*,1]^2+b_des.y[*,2]^2)
      vperpz=v_des.y[*,2]-dotp(v_des.y,b_des.y)*b_des.y[*,2]/(b_des.y[*,0]^2+b_des.y[*,1]^2+b_des.y[*,2]^2)
      vperp=dblarr(n_elements(vperpx),3)
      vperp[*,0]=vperpx
      vperp[*,1]=vperpy
      vperp[*,2]=vperpz
      store_data,'mms'+probes[i]+'_des_bulkVperp_'+coord,data={x:v_des.x,y:vperp}
      store_data,'mms'+probes[i]+'_des_bulkVperp_'+coord+'_x',data={x:v_des.x,y:vperpx}
      store_data,'mms'+probes[i]+'_des_bulkVperp_'+coord+'_y',data={x:v_des.x,y:vperpy}
      store_data,'mms'+probes[i]+'_des_bulkVperp_'+coord+'_z',data={x:v_des.x,y:vperpz}

      if not undefined(lmn) and n_elements(lmn) eq 9 then begin
        vperp_lmn=dblarr(n_elements(v_des.x),3)
        for j=0l,n_elements(v_des.x)-1 do begin
          vperp_lmn[j,0]=vperp[j,0]*lmn[0,0]+vperp[j,1]*lmn[1,0]+vperp[j,2]*lmn[2,0]
          vperp_lmn[j,1]=vperp[j,0]*lmn[0,1]+vperp[j,1]*lmn[1,1]+vperp[j,2]*lmn[2,1]
          vperp_lmn[j,2]=vperp[j,0]*lmn[0,2]+vperp[j,1]*lmn[1,2]+vperp[j,2]*lmn[2,2]
        endfor
        store_data,'mms'+probes[i]+'_des_bulkVperp_lmn',data={x:v_des.x,y:vperp_lmn}
        split_vec,'mms'+probes[i]+'_des_bulkVperp_lmn',suffix=['_l','_m','_n']
      endif

      if not undefined(va) and n_elements(va) eq 3 then begin
        get_data,'mms'+probes[i]+'_des_bulkVperp_'+coord,data=vperp
        vperp_arb=dblarr(n_elements(vperp.x))
        for j=0l,n_elements(vperp.x)-1 do begin
          vperp_arb[j]=vperp.y[j,0]*nva[0]+vperp.y[j,1]*nva[1]+vperp.y[j,2]*nva[2]-vn
        endfor
        store_data,'mms'+probes[i]+'_des_bulkVperp_arb',data={x:v.x,y:vperp_arb}
      endif
      
      if strlen(tnames('mms'+probes[i]+'_des_temppara_'+fpi_data_rate)) eq 0 then begin
        ;This part should be improved in future.
        get_data,'mms'+probes[i]+'_des_TempXX',data=txx
        get_data,'mms'+probes[i]+'_des_TempYY',data=tyy
        get_data,'mms'+probes[i]+'_des_TempZZ',data=tzz
        get_data,'mms'+probes[i]+'_des_TempXY',data=txy
        get_data,'mms'+probes[i]+'_des_TempXZ',data=txz
        get_data,'mms'+probes[i]+'_des_TempYZ',data=tyz

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

    if n_elements(probes) eq 4 then begin
      store_data,'mms_des_numberDensity',data=['mms1_des_numberDensity','mms2_des_numberDensity','mms3_des_numberDensity','mms4_des_numberDensity']
      store_data,'mms_des_bulkX',data=['mms1_des_bulkV_'+coord+'_x','mms2_des_bulkV_'+coord+'_x','mms3_des_bulkV_'+coord+'_x','mms4_des_bulkV_'+coord+'_x']
      store_data,'mms_des_bulkY',data=['mms1_des_bulkV_'+coord+'_y','mms2_des_bulkV_'+coord+'_y','mms3_des_bulkV_'+coord+'_y','mms4_des_bulkV_'+coord+'_y']
      store_data,'mms_des_bulkZ',data=['mms1_des_bulkV_'+coord+'_z','mms2_des_bulkV_'+coord+'_z','mms3_des_bulkV_'+coord+'_z','mms4_des_bulkV_'+coord+'_z']
      store_data,'mms_des_bulkVperpX',data=['mms1_des_bulkVperp_'+coord+'_x','mms2_des_bulkVperp_'+coord+'_x','mms3_des_bulkVperp_'+coord+'_x','mms4_des_bulkVperp_'+coord+'_x']
      store_data,'mms_des_bulkVperpY',data=['mms1_des_bulkVperp_'+coord+'_y','mms2_des_bulkVperp_'+coord+'_y','mms3_des_bulkVperp_'+coord+'_y','mms4_des_bulkVperp_'+coord+'_y']
      store_data,'mms_des_bulkVperpZ',data=['mms1_des_bulkVperp_'+coord+'_z','mms2_des_bulkVperp_'+coord+'_z','mms3_des_bulkVperp_'+coord+'_z','mms4_des_bulkVperp_'+coord+'_z']
      store_data,'mms_des_bulkVperp_mag',data=['mms1_des_bulkVperp_mag','mms2_des_bulkVperp_mag','mms3_des_bulkVperp_mag','mms4_des_bulkVperp_mag']
      store_data,'mms_des_bulkVpara',data=['mms1_des_bulkVpara','mms2_des_bulkVpara','mms3_des_bulkVpara','mms4_des_bulkVpara']
      
      if not undefined(lmn) and n_elements(lmn) eq 9 then begin
        store_data,'mms_des_bulkl',data=['mms1_des_bulkV_lmn_l','mms2_des_bulkV_lmn_l','mms3_des_bulkV_lmn_l','mms4_des_bulkV_lmn_l']
        store_data,'mms_des_bulkm',data=['mms1_des_bulkV_lmn_m','mms2_des_bulkV_lmn_m','mms3_des_bulkV_lmn_m','mms4_des_bulkV_lmn_m']
        store_data,'mms_des_bulkn',data=['mms1_des_bulkV_lmn_n','mms2_des_bulkV_lmn_n','mms3_des_bulkV_lmn_n','mms4_des_bulkV_lmn_n']
        options,'mms_des_bulkl',constant=0.0,colors=[0,6,4,2],ytitle='MMS!CDES!CBulkV!Clmn l',ysubtitle='[km/s]',labels=['mms1','mms2','mms3','mms4'],labflag=-1,datagap=0.032d
        options,'mms_des_bulkm',constant=0.0,colors=[0,6,4,2],ytitle='MMS!CDES!CBulkV!Clmn m',ysubtitle='[km/s]',labels=['mms1','mms2','mms3','mms4'],labflag=-1,datagap=0.032d
        options,'mms_des_bulkn',constant=0.0,colors=[0,6,4,2],ytitle='MMS!CDES!CBulkV!Clmn n',ysubtitle='[km/s]',labels=['mms1','mms2','mms3','mms4'],labflag=-1,datagap=0.032d
        store_data,'mms_des_bulkVperpl',data=['mms1_des_bulkVperp_lmn_l','mms2_des_bulkVperp_lmn_l','mms3_des_bulkVperp_lmn_l','mms4_des_bulkVperp_lmn_l']
        store_data,'mms_des_bulkVperpm',data=['mms1_des_bulkVperp_lmn_m','mms2_des_bulkVperp_lmn_m','mms3_des_bulkVperp_lmn_m','mms4_des_bulkVperp_lmn_m']
        store_data,'mms_des_bulkVperpn',data=['mms1_des_bulkVperp_lmn_n','mms2_des_bulkVperp_lmn_n','mms3_des_bulkVperp_lmn_n','mms4_des_bulkVperp_lmn_n']
        options,'mms_des_bulkVperpl',constant=0.0,colors=[0,6,4,2],ytitle='MMS!CDES!CbulkVperp!Clmn l',ysubtitle='[km/s]',labels=['mms1','mms2','mms3','mms4'],labflag=-1,datagap=0.032d
        options,'mms_des_bulkVperpm',constant=0.0,colors=[0,6,4,2],ytitle='MMS!CDES!CbulkVperp!Clmn m',ysubtitle='[km/s]',labels=['mms1','mms2','mms3','mms4'],labflag=-1,datagap=0.032d
        options,'mms_des_bulkVperpn',constant=0.0,colors=[0,6,4,2],ytitle='MMS!CDES!CbulkVperp!Clmn n',ysubtitle='[km/s]',labels=['mms1','mms2','mms3','mms4'],labflag=-1,datagap=0.032d
      endif
      if not undefined(va) and n_elements(va) eq 3 then begin
        store_data,'mms_des_bulkVa',data=['mms1_des_bulkV_arb','mms2_des_bulkV_arb','mms3_des_bulkV_arb','mms4_des_bulkV_arb']
        options,'mms_des_bulkVa',constant=0.0,colors=[0,6,4,2],ytitle='MMS!CDES!CbulkV!CArbitrary',ysubtitle='[km/s]',labels=['mms1','mms2','mms3','mms4'],labflag=-1,datagap=0.032d
        store_data,'mms_des_bulkVperpa',data=['mms1_des_bulkVperp_arb','mms2_des_bulkVperp_arb','mms3_des_bulkVperp_arb','mms4_des_bulkVperp_arb']
        options,'mms_des_bulkVperpa',constant=0.0,colors=[0,6,4,2],ytitle='MMS!CDES!CbulkVperp!CArbitrary',ysubtitle='[km/s]',labels=['mms1','mms2','mms3','mms4'],labflag=-1,datagap=0.032d
      endif
      store_data,'mms_des_Tperp',data=['mms1_fpi_DEStempPerp','mms2_fpi_DEStempPerp','mms3_fpi_DEStempPerp','mms4_fpi_DEStempPerp']
      store_data,'mms_des_Tpara',data=['mms1_fpi_DEStempPara','mms2_fpi_DEStempPara','mms3_fpi_DEStempPara','mms4_fpi_DEStempPara']

      options,'mms_des_numberDensity',colors=[0,6,4,2],ytitle='MMS!CDES!CNumber!CDensity',ysubtitle='[/cm!U3!N]',labels=['mms1','mms2','mms3','mms4'],labflag=-1,ylog=1,datagap=0.032d,ytickformat='mms_exponent2'
      ylim,'mms_des_numberDensity',0.03d,300.d,1
      options,'mms_des_bulkX',constant=0.0,colors=[0,6,4,2],ytitle='MMS!CDES!CBulkV!C'+strupcase(coord)+' X',ysubtitle='[km/s]',labels=['mms1','mms2','mms3','mms4'],labflag=-1,datagap=0.032d
      options,'mms_des_bulkY',constant=0.0,colors=[0,6,4,2],ytitle='MMS!CDES!CBulkV!C'+strupcase(coord)+' Y',ysubtitle='[km/s]',labels=['mms1','mms2','mms3','mms4'],labflag=-1,datagap=0.032d
      options,'mms_des_bulkZ',constant=0.0,colors=[0,6,4,2],ytitle='MMS!CDES!CBulkV!C'+strupcase(coord)+' Z',ysubtitle='[km/s]',labels=['mms1','mms2','mms3','mms4'],labflag=-1,datagap=0.032d
      options,'mms_des_bulkVperpX',constant=0.0,colors=[0,6,4,2],ytitle='MMS!CDES!CbulkVperp!C'+strupcase(coord)+' X',ysubtitle='[km/s]',labels=['mms1','mms2','mms3','mms4'],labflag=-1,datagap=0.032d
      options,'mms_des_bulkVperpY',constant=0.0,colors=[0,6,4,2],ytitle='MMS!CDES!CbulkVperp!C'+strupcase(coord)+' Y',ysubtitle='[km/s]',labels=['mms1','mms2','mms3','mms4'],labflag=-1,datagap=0.032d
      options,'mms_des_bulkVperpZ',constant=0.0,colors=[0,6,4,2],ytitle='MMS!CDES!CbulkVperp!C'+strupcase(coord)+' Z',ysubtitle='[km/s]',labels=['mms1','mms2','mms3','mms4'],labflag=-1,datagap=0.032d
      options,'mms_des_bulkVperp_mag',colors=[0,6,4,2],ytitle='MMS!CDES!CbulkVperpV!CMagnitude',ysubtitle='[km/s]',labels=['mms1','mms2','mms3','mms4'],labflag=-1,datagap=0.032d
      options,'mms_des_bulkVpara',constant=0.0,colors=[0,6,4,2],ytitle='MMS!CDES!CbulkVpara',ysubtitle='[km/s]',labels=['mms1','mms2','mms3','mms4'],labflag=-1,datagap=0.032d
      options,'mms_des_Tperp',colors=[0,6,4,2],ytitle='MMS!CDES!CTperp',ysubtitle='[eV]',labels=['mms1','mms2','mms3','mms4'],labflag=-1,ylog=1,datagap=0.032d,ytickformat='mms_exponent2'
      options,'mms_des_Tpara',colors=[0,6,4,2],ytitle='MMS!CDES!CTpara',ysubtitle='[eV]',labels=['mms1','mms2','mms3','mms4'],labflag=-1,ylog=1,datagap=0.032d,ytickformat='mms_exponent2'
      ylim,'mms_des_T*',5.d,30000.d,1
    endif
  endif

  if undefined(no_ion) then begin
    for i=0,n_elements(probes)-1 do begin
      if undefined(no_load_fpi) then mms_load_fpi,trange=trange,probes=probes[i],level='l2',data_rate=fpi_data_rate,datatype='dis-moms',no_update=no_update,time_clip=time_clip
      if strlen(tnames('mms'+probes[i]+'_dis_bulkx_dbcs_'+fpi_data_rate)) eq 0 then begin
        if undefined(no_load_fpi) then mms_load_fpi,trange=trange,probes=probes[i],level='l1b',data_rate=fpi_data_rate,datatype='dis-moms',no_update=no_update,time_clip=time_clip
        join_vec,'mms'+probes[i]+'_dis_bulk'+['X','Y','Z'],'mms'+probes[i]+'_dis_bulkV_DSC'
      endif else begin
        join_vec,'mms'+probes[i]+'_dis_bulk'+['x','y','z']+'_dbcs_'+fpi_data_rate,'mms'+probes[i]+'_dis_bulkV_DSC'
        copy_data,'mms'+probes[i]+'_dis_numberdensity_dbcs_'+fpi_data_rate,'mms'+probes[i]+'_dis_numberDensity'
      endelse
      options,'mms'+probes[i]+'_dis_bulkV_DSC',constant=0.0,ytitle='mms'+probes[i]+'_dis!CBulkV!CDSC',ysubtitle='[km/s]',colors=[2,4,6],labels=['V!DX!N','V!DY!N','V!DZ!N'],labflag=-1,datagap=0.16d
      mms_cotrans,'mms'+probes[i]+'_dis_bulkV',in_coord='dmpa',in_suffix='_DSC',out_coord='gse',out_suffix='_gse',/ignore_dlimits
      options,'mms'+probes[i]+'_dis_bulkV_gse',constant=0.0,ytitle='mms'+probes[i]+'_dis!CBulkV!CGSE',ysubtitle='[km/s]',colors=[2,4,6],labels=['V!DX!N','V!DY!N','V!DZ!N'],labflag=-1,datagap=0.16d
      mms_cotrans,'mms'+probes[i]+'_dis_bulkV',in_coord='gse',in_suffix='_gse',out_coord='gsm',out_suffix='_gsm',/ignore_dlimits
      options,'mms'+probes[i]+'_dis_bulkV_gsm',constant=0.0,ytitle='mms'+probes[i]+'_dis!CBulkV!CGSM',ysubtitle='[km/s]',colors=[2,4,6],labels=['V!DX!N','V!DY!N','V!DZ!N'],labflag=-1,datagap=0.16d
      split_vec,'mms'+probes[i]+'_dis_bulkV_'+coord

      if not undefined(lmn) and n_elements(lmn) eq 9 then begin
        get_data,'mms'+probes[i]+'_dis_bulkV_'+coord,data=v
        v_lmn=dblarr(n_elements(v.x),3)
        for j=0l,n_elements(v.x)-1 do begin
          v_lmn[j,0]=v.y[j,0]*lmn[0,0]+v.y[j,1]*lmn[1,0]+v.y[j,2]*lmn[2,0]
          v_lmn[j,1]=v.y[j,0]*lmn[0,1]+v.y[j,1]*lmn[1,1]+v.y[j,2]*lmn[2,1]
          v_lmn[j,2]=v.y[j,0]*lmn[0,2]+v.y[j,1]*lmn[1,2]+v.y[j,2]*lmn[2,2]
        endfor
        store_data,'mms'+probes[i]+'_dis_bulkV_lmn',data={x:v.x,y:v_lmn}
        split_vec,'mms'+probes[i]+'_dis_bulkV_lmn',suffix=['_l','_m','_n']
      endif

      if not undefined(va) and n_elements(va) eq 3 then begin
        if undefined(vn) then vn=0.d
        get_data,'mms'+probes[i]+'_dis_bulkV_'+coord,data=v
        nva=va/sqrt(va[0]*va[0]+va[1]*va[1]+va[2]*va[2])
        v_arb=dblarr(n_elements(v.x))
        for j=0l,n_elements(v.x)-1 do begin
          v_arb[j]=v.y[j,0]*nva[0]+v.y[j,1]*nva[1]+v.y[j,2]*nva[2]-vn
        endfor
        store_data,'mms'+probes[i]+'_dis_bulkV_arb',data={x:v.x,y:v_arb}
      endif
      
      copy_data,'mms'+probes[i]+'_dis_bulkV_'+coord,'bulkVi'
      if coord ne 'DSC' then dfg_coord=coord else dfg_coord='dmpa'
      box_ave_mms,variable1='bulkVi',variable2='mms'+probes[i]+'_dfg_brst_l2pre_'+dfg_coord+'_bvec',var2ave='mms'+probes[i]+'_dfg_brst_l2pre_bvec_dis',inval=0.15d
      get_data,'bulkVi',data=v_dis
      get_data,'mms'+probes[i]+'_dfg_brst_l2pre_bvec_dis',data=b_dis
      vpara_t=total(v_dis.y*b_dis.y,2)/sqrt(total(b_dis.y^2,2))
      vperp_t= sqrt(total(v_dis.y^2,2)-vpara_t^2)
      store_data,'mms'+probes[i]+'_dis_bulkVperp_mag',data={x:v_dis.x,y:vperp_t}
      store_data,'mms'+probes[i]+'_dis_bulkVpara',data={x:v_dis.x,y:vpara_t}

      vperpx=v_dis.y[*,0]-dotp(v_dis.y,b_dis.y)*b_dis.y[*,0]/(b_dis.y[*,0]^2+b_dis.y[*,1]^2+b_dis.y[*,2]^2)
      vperpy=v_dis.y[*,1]-dotp(v_dis.y,b_dis.y)*b_dis.y[*,1]/(b_dis.y[*,0]^2+b_dis.y[*,1]^2+b_dis.y[*,2]^2)
      vperpz=v_dis.y[*,2]-dotp(v_dis.y,b_dis.y)*b_dis.y[*,2]/(b_dis.y[*,0]^2+b_dis.y[*,1]^2+b_dis.y[*,2]^2)
      vperp=dblarr(n_elements(vperpx),3)
      vperp[*,0]=vperpx
      vperp[*,1]=vperpy
      vperp[*,2]=vperpz
      store_data,'mms'+probes[i]+'_dis_bulkVperp_'+coord,data={x:v_dis.x,y:vperp}
      store_data,'mms'+probes[i]+'_dis_bulkVperp_'+coord+'_x',data={x:v_dis.x,y:vperpx}
      store_data,'mms'+probes[i]+'_dis_bulkVperp_'+coord+'_y',data={x:v_dis.x,y:vperpy}
      store_data,'mms'+probes[i]+'_dis_bulkVperp_'+coord+'_z',data={x:v_dis.x,y:vperpz}

      if not undefined(lmn) and n_elements(lmn) eq 9 then begin
        vperp_lmn=dblarr(n_elements(v_dis.x),3)
        for j=0l,n_elements(v_dis.x)-1 do begin
          vperp_lmn[j,0]=vperp[j,0]*lmn[0,0]+vperp[j,1]*lmn[1,0]+vperp[j,2]*lmn[2,0]
          vperp_lmn[j,1]=vperp[j,0]*lmn[0,1]+vperp[j,1]*lmn[1,1]+vperp[j,2]*lmn[2,1]
          vperp_lmn[j,2]=vperp[j,0]*lmn[0,2]+vperp[j,1]*lmn[1,2]+vperp[j,2]*lmn[2,2]
        endfor
        store_data,'mms'+probes[i]+'_dis_bulkVperp_lmn',data={x:v_dis.x,y:vperp_lmn}
        split_vec,'mms'+probes[i]+'_dis_bulkVperp_lmn',suffix=['_l','_m','_n']
      endif
      
      if not undefined(va) and n_elements(va) eq 3 then begin
        get_data,'mms'+probes[i]+'_dis_bulkVperp_'+coord,data=vperp
        vperp_arb=dblarr(n_elements(vperp.x))
        for j=0l,n_elements(vperp.x)-1 do begin
          vperp_arb[j]=vperp.y[j,0]*nva[0]+vperp.y[j,1]*nva[1]+vperp.y[j,2]*nva[2]-vn
        endfor
        store_data,'mms'+probes[i]+'_dis_bulkVperp_arb',data={x:v.x,y:vperp_arb}
      endif
      
      if strlen(tnames('mms'+probes[i]+'_dis_temppara_'+fpi_data_rate)) eq 0 then begin
        ;This part should be improved in future.
        get_data,'mms'+probes[i]+'_dis_TempXX',data=txx
        get_data,'mms'+probes[i]+'_dis_TempYY',data=tyy
        get_data,'mms'+probes[i]+'_dis_TempZZ',data=tzz
        get_data,'mms'+probes[i]+'_dis_TempXY',data=txy
        get_data,'mms'+probes[i]+'_dis_TempXZ',data=txz
        get_data,'mms'+probes[i]+'_dis_TempYZ',data=tyz
  
        store_data,'mms'+probes[i]+'te_tensor',data={x:txx.x,y:[[txx.y],[tyy.y],[tzz.y],[txy.y],[txz.y],[tyz.y]]}
        diag_t,'mms'+probes[i]+'te_tensor'
        copy_data,'T_diag','mms'+probes[i]+'_fpi_DIS_T_diag'
        copy_data,'Saxis','mms'+probes[i]+'_fpi_DIS_T_Saxis'
        get_data,'T_diag',data=t_diag
        store_data,'mms'+probes[i]+'_fpi_DIStempPerp',data={x:t_diag.x,y:(t_diag.y[*,1]+t_diag.y[*,2])/2.d}
        store_data,'mms'+probes[i]+'_fpi_DIStempPara',data={x:t_diag.x,y:t_diag.y[*,0]}
      endif else begin
        copy_data,'mms'+probes[i]+'_dis_tempperp_'+fpi_data_rate,'mms'+probes[i]+'_fpi_DIStempPerp'
        copy_data,'mms'+probes[i]+'_dis_temppara_'+fpi_data_rate,'mms'+probes[i]+'_fpi_DIStempPara'
      endelse

    endfor

    if n_elements(probes) eq 4 then begin
      store_data,'mms_dis_numberDensity',data=['mms1_dis_numberDensity','mms2_dis_numberDensity','mms3_dis_numberDensity','mms4_dis_numberDensity']
      store_data,'mms_dis_bulkX',data=['mms1_dis_bulkV_'+coord+'_x','mms2_dis_bulkV_'+coord+'_x','mms3_dis_bulkV_'+coord+'_x','mms4_dis_bulkV_'+coord+'_x']
      store_data,'mms_dis_bulkY',data=['mms1_dis_bulkV_'+coord+'_y','mms2_dis_bulkV_'+coord+'_y','mms3_dis_bulkV_'+coord+'_y','mms4_dis_bulkV_'+coord+'_y']
      store_data,'mms_dis_bulkZ',data=['mms1_dis_bulkV_'+coord+'_z','mms2_dis_bulkV_'+coord+'_z','mms3_dis_bulkV_'+coord+'_z','mms4_dis_bulkV_'+coord+'_z']
      store_data,'mms_dis_bulkVperpX',data=['mms1_dis_bulkVperp_'+coord+'_x','mms2_dis_bulkVperp_'+coord+'_x','mms3_dis_bulkVperp_'+coord+'_x','mms4_dis_bulkVperp_'+coord+'_x']
      store_data,'mms_dis_bulkVperpY',data=['mms1_dis_bulkVperp_'+coord+'_y','mms2_dis_bulkVperp_'+coord+'_y','mms3_dis_bulkVperp_'+coord+'_y','mms4_dis_bulkVperp_'+coord+'_y']
      store_data,'mms_dis_bulkVperpZ',data=['mms1_dis_bulkVperp_'+coord+'_z','mms2_dis_bulkVperp_'+coord+'_z','mms3_dis_bulkVperp_'+coord+'_z','mms4_dis_bulkVperp_'+coord+'_z']
      store_data,'mms_dis_bulkVperp_mag',data=['mms1_dis_bulkVperp_mag','mms2_dis_bulkVperp_mag','mms3_dis_bulkVperp_mag','mms4_dis_bulkVperp_mag']
      store_data,'mms_dis_bulkVpara',data=['mms1_dis_bulkVpara','mms2_dis_bulkVpara','mms3_dis_bulkVpara','mms4_dis_bulkVpara']
      if not undefined(lmn) and n_elements(lmn) eq 9 then begin
        store_data,'mms_dis_bulkl',data=['mms1_dis_bulkV_lmn_l','mms2_dis_bulkV_lmn_l','mms3_dis_bulkV_lmn_l','mms4_dis_bulkV_lmn_l']
        store_data,'mms_dis_bulkm',data=['mms1_dis_bulkV_lmn_m','mms2_dis_bulkV_lmn_m','mms3_dis_bulkV_lmn_m','mms4_dis_bulkV_lmn_m']
        store_data,'mms_dis_bulkn',data=['mms1_dis_bulkV_lmn_n','mms2_dis_bulkV_lmn_n','mms3_dis_bulkV_lmn_n','mms4_dis_bulkV_lmn_n']
        options,'mms_dis_bulkl',constant=0.0,colors=[0,6,4,2],ytitle='MMS!CDIS!CBulkV!Clmn l',ysubtitle='[km/s]',labels=['mms1','mms2','mms3','mms4'],labflag=-1,datagap=0.16d
        options,'mms_dis_bulkm',constant=0.0,colors=[0,6,4,2],ytitle='MMS!CDIS!CBulkV!Clmn m',ysubtitle='[km/s]',labels=['mms1','mms2','mms3','mms4'],labflag=-1,datagap=0.16d
        options,'mms_dis_bulkn',constant=0.0,colors=[0,6,4,2],ytitle='MMS!CDIS!CBulkV!Clmn n',ysubtitle='[km/s]',labels=['mms1','mms2','mms3','mms4'],labflag=-1,datagap=0.16d
        store_data,'mms_dis_bulkVperpl',data=['mms1_dis_bulkVperp_lmn_l','mms2_dis_bulkVperp_lmn_l','mms3_dis_bulkVperp_lmn_l','mms4_dis_bulkVperp_lmn_l']
        store_data,'mms_dis_bulkVperpm',data=['mms1_dis_bulkVperp_lmn_m','mms2_dis_bulkVperp_lmn_m','mms3_dis_bulkVperp_lmn_m','mms4_dis_bulkVperp_lmn_m']
        store_data,'mms_dis_bulkVperpn',data=['mms1_dis_bulkVperp_lmn_n','mms2_dis_bulkVperp_lmn_n','mms3_dis_bulkVperp_lmn_n','mms4_dis_bulkVperp_lmn_n']
        options,'mms_dis_bulkVperpl',constant=0.0,colors=[0,6,4,2],ytitle='MMS!CDIS!CbulkVperp!Clmn l',ysubtitle='[km/s]',labels=['mms1','mms2','mms3','mms4'],labflag=-1,datagap=0.16d
        options,'mms_dis_bulkVperpm',constant=0.0,colors=[0,6,4,2],ytitle='MMS!CDIS!CbulkVperp!Clmn m',ysubtitle='[km/s]',labels=['mms1','mms2','mms3','mms4'],labflag=-1,datagap=0.16d
        options,'mms_dis_bulkVperpn',constant=0.0,colors=[0,6,4,2],ytitle='MMS!CDIS!CbulkVperp!Clmn n',ysubtitle='[km/s]',labels=['mms1','mms2','mms3','mms4'],labflag=-1,datagap=0.16d
      endif
      if not undefined(va) and n_elements(va) eq 3 then begin
        store_data,'mms_dis_bulkVa',data=['mms1_dis_bulkV_arb','mms2_dis_bulkV_arb','mms3_dis_bulkV_arb','mms4_dis_bulkV_arb']
        options,'mms_dis_bulkVa',constant=0.0,colors=[0,6,4,2],ytitle='MMS!CDIS!CbulkV!CArbitrary',ysubtitle='[km/s]',labels=['mms1','mms2','mms3','mms4'],labflag=-1,datagap=0.16d
        store_data,'mms_dis_bulkVperpa',data=['mms1_dis_bulkVperp_arb','mms2_dis_bulkVperp_arb','mms3_dis_bulkVperp_arb','mms4_dis_bulkVperp_arb']
        options,'mms_dis_bulkVperpa',constant=0.0,colors=[0,6,4,2],ytitle='MMS!CDIS!CbulkVperp!CArbitrary',ysubtitle='[km/s]',labels=['mms1','mms2','mms3','mms4'],labflag=-1,datagap=0.16d
      endif
      store_data,'mms_dis_Tperp',data=['mms1_fpi_DIStempPerp','mms2_fpi_DIStempPerp','mms3_fpi_DIStempPerp','mms4_fpi_DIStempPerp']
      store_data,'mms_dis_Tpara',data=['mms1_fpi_DIStempPara','mms2_fpi_DIStempPara','mms3_fpi_DIStempPara','mms4_fpi_DIStempPara']

      options,'mms_dis_numberDensity',colors=[0,6,4,2],ytitle='MMS!CDIS!CNumber!CDensity',ysubtitle='[/cm!U3!N]',labels=['mms1','mms2','mms3','mms4'],labflag=-1,ylog=1,datagap=0.16d,ytickformat='mms_exponent2'
      ylim,'mms_dis_numberDensity',0.03d,300.d,1
      options,'mms_dis_bulkX',constant=0.0,colors=[0,6,4,2],ytitle='MMS!CDIS!CBulkV!C'+strupcase(coord)+' X',ysubtitle='[km/s]',labels=['mms1','mms2','mms3','mms4'],labflag=-1,datagap=0.16d
      options,'mms_dis_bulkY',constant=0.0,colors=[0,6,4,2],ytitle='MMS!CDIS!CBulkV!C'+strupcase(coord)+' Y',ysubtitle='[km/s]',labels=['mms1','mms2','mms3','mms4'],labflag=-1,datagap=0.16d
      options,'mms_dis_bulkZ',constant=0.0,colors=[0,6,4,2],ytitle='MMS!CDIS!CBulkV!C'+strupcase(coord)+' Z',ysubtitle='[km/s]',labels=['mms1','mms2','mms3','mms4'],labflag=-1,datagap=0.16d
      options,'mms_dis_bulkVperpX',constant=0.0,colors=[0,6,4,2],ytitle='MMS!CDIS!CbulkVperp!C'+strupcase(coord)+' X',ysubtitle='[km/s]',labels=['mms1','mms2','mms3','mms4'],labflag=-1,datagap=0.16d
      options,'mms_dis_bulkVperpY',constant=0.0,colors=[0,6,4,2],ytitle='MMS!CDIS!CbulkVperp!C'+strupcase(coord)+' Y',ysubtitle='[km/s]',labels=['mms1','mms2','mms3','mms4'],labflag=-1,datagap=0.16d
      options,'mms_dis_bulkVperpZ',constant=0.0,colors=[0,6,4,2],ytitle='MMS!CDIS!CbulkVperp!C'+strupcase(coord)+' Z',ysubtitle='[km/s]',labels=['mms1','mms2','mms3','mms4'],labflag=-1,datagap=0.16d
      options,'mms_dis_bulkVperp_mag',colors=[0,6,4,2],ytitle='MMS!CDIS!CbulkVperpV!CMagnitude',ysubtitle='[km/s]',labels=['mms1','mms2','mms3','mms4'],labflag=-1,datagap=0.16d
      options,'mms_dis_bulkVpara',constant=0.0,colors=[0,6,4,2],ytitle='MMS!CDIS!CbulkVpara',ysubtitle='[km/s]',labels=['mms1','mms2','mms3','mms4'],labflag=-1,datagap=0.16d
      options,'mms_dis_Tperp',colors=[0,6,4,2],ytitle='MMS!CDIS!CTperp',ysubtitle='[eV]',labels=['mms1','mms2','mms3','mms4'],labflag=-1,ylog=1,datagap=0.16d,ytickformat='mms_exponent2'
      options,'mms_dis_Tpara',colors=[0,6,4,2],ytitle='MMS!CDIS!CTpara',ysubtitle='[eV]',labels=['mms1','mms2','mms3','mms4'],labflag=-1,ylog=1,datagap=0.16d,ytickformat='mms_exponent2'
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
    tkm2re,'mms'+probes[0]+'_pos_'+label_coord
    split_vec,'mms'+probes[0]+'_pos_'+label_coord+'_re'
    options,'mms'+probes[0]+'_pos_'+label_coord+'_re_0',ytitle=strupcase(label_coord)+'X [R!DE!N]',format='(f8.4)'
    options,'mms'+probes[0]+'_pos_'+label_coord+'_re_1',ytitle=strupcase(label_coord)+'Y [R!DE!N]',format='(f8.4)'
    options,'mms'+probes[0]+'_pos_'+label_coord+'_re_2',ytitle=strupcase(label_coord)+'Z [R!DE!N]',format='(f8.4)'
    tplot_options,var_label=['mms'+probes[0]+'_pos_'+label_coord+'_re_2','mms'+probes[0]+'_pos_'+label_coord+'_re_1','mms'+probes[0]+'_pos_'+label_coord+'_re_0']
  endelse

  tplot_options,'xmargin',[20,10]
;  tplot,['mms_des_numberDensity','mms_des_bulk*','mms_des_T*','mms_dis_numberDensity','mms_dis_bulk*','mms_dis_T*']
;  tplot,['mms_des_numberDensity','mms_des_bulkV*','mms_des_T*','mms_dis_numberDensity','mms_dis_bulkV*','mms_dis_T*']
;  tplot,['mms_des_numberDensity','mms_des_bulk*','mms_dis_numberDensity','mms_dis_bulk*']
  tplot,['mms_des_numberDensity','mms_des_bulkV*l','mms_des_bulkV*m','mms_des_bulkV*n','mms_des_bulkV*a','mms_dis_numberDensity','mms_dis_bulkV*l','mms_dis_bulkV*m','mms_dis_bulkV*n','mms_dis_bulkV*a']


END
