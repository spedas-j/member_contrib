;+
;EXAMPLE:
; MMS>  make_ascii_mms_fpi_fgm_l2_hase_kitamura,['2015-09-01/08:00:00','2015-09-02/00:00:00'],probes=['1','2','3','4']
; MMS>  make_ascii_mms_fpi_fgm_l2_hase_kitamura,['2015-09-01/08:00:00','2015-09-02/00:00:00'],probes=['1','2','3','4'],/brst
; 
; NOTES:
;     1) See the notes in mms_load_data for rules on the use of MMS data
;     2) The time is shifted to mark the middle of the fpi data interval
;     3) Information of version of the first fpi cdf files is shown in the file name,
;        if multiple fpi cdf files are loaded
;     4) The coordinate transformation of velocities and calculation of temperatures 
;        will be updated in future
; 
; OUTPUT FORMAT:
; time position-GSMX[km] -GSMY[km] -GSMZ[km] dfg-GSMX[nT] -GSMY[nT] -GSMZ[nT] dfg_Btotal[nT] density[/cm^-3] velocity-GSMX[km/s] -GSMY[km/s] -GSMZ[km/s] temperature-parallel[eV] -perpendicular[eV]
;-

pro make_ascii_mms_fpi_fgm_l2_hase_kitamura,trange,probes=probes,brst=brst,no_load_fgm=no_load_fgm,no_load_fpi=no_load_fpi,$
                                    no_load_mec=no_load_mec,fpi_suffix=fpi_suffix,outdir=outdir,delete=delete,$
                                    no_update=no_update

  mms_init
  trange=time_double(trange)
  if not undefined(delete) then store_data,'*',/delete
  if undefined(brst) then data_rate='fast' else data_rate='brst'
  if undefined(brst) then fgm_data_rate='srvy' else fgm_data_rate='brst'
  if undefined(fpi_suffix) then fpi_suffix=''
  if undefined(probes) then probes=['1','2','3','4']
  if probes[0] eq '*' then probes=['1','2','3','4']
  probes=strcompress(probes,/remove_all)

  for i=0,n_elements(probes)-1 do begin
    
    if undefined(no_load_fgm) then mms_load_fgm,trange=[trange[0]-600.d,trange[1]+600.d],instrument='fgm',probes=probes[i],data_rate=fgm_data_rate,level='l2',no_update=no_update
    if undefined(no_load_fpi) then mms_load_fpi,trange=trange,probes=probes[i],level='l2',data_rate=data_rate,datatype=['des-moms','dis-moms'],suffix=fpi_suffix,no_update=no_update,/center_measurement
    if undefined(no_load_mec) then mms_load_mec,trange=[trange[0]-600.d,trange[1]+600.d],probes=probes[i],no_update=no_update
    if undefined(brst) then inval=4.5d else inval=0.03d
    
    trange_clip,'mms'+probes[i]+'_des_numberdensity_dbcs_'+data_rate+fpi_suffix,trange[0],trange[1],newname='mms'+probes[i]+'_des_numberDensity_clip'
    get_data,'mms'+probes[i]+'_des_numberDensity_clip',data=e_density,dlimit=dl
    store_data,'mms'+probes[i]+'_des_numberDensity_clip',/delete
    store_data,'mms'+probes[i]+'_des_shifted_time',data={x:e_density.x,y:e_density.x}

    join_vec,'mms'+probes[i]+'_des_bulk'+['x','y','z']+'_dbcs_'+data_rate,'mms'+probes[i]+'_des_bulkv_dbcs'
    ;This part should be improved in future.
    mms_cotrans,'mms'+probes[i]+'_des_bulkv',in_coord='dmpa',in_suffix='_dbcs',out_coord='gsm',out_suffix='_gsm',/ignore_dlimits

    trange_clip,'mms'+probes[i]+'_des_bulkv_gsm'+fpi_suffix,trange[0],trange[1],newname='mms'+probes[i]+'_des_bulkv_clip'
    get_data,'mms'+probes[i]+'_des_bulkv_clip',data=ve
    store_data,'mms'+probes[i]+'_des_bulkv_clip',/delete


    ;This part should be improved in future.
    if data_rate eq 'fast' then begin
      get_data,'mms'+probes[i]+'_des_tempxx_dbcs_'+data_rate+fpi_suffix,data=texx
      get_data,'mms'+probes[i]+'_des_tempyy_dbcs_'+data_rate+fpi_suffix,data=teyy
      get_data,'mms'+probes[i]+'_des_tempzz_dbcs_'+data_rate+fpi_suffix,data=tezz
      get_data,'mms'+probes[i]+'_des_tempxy_dbcs_'+data_rate+fpi_suffix,data=texy
      get_data,'mms'+probes[i]+'_des_tempxz_dbcs_'+data_rate+fpi_suffix,data=texz
      get_data,'mms'+probes[i]+'_des_tempyz_dbcs_'+data_rate+fpi_suffix,data=teyz

      store_data,'mms'+probes[i]+'te_tensor',data={x:texx.x,y:[[texx.y],[teyy.y],[tezz.y],[texy.y],[texz.y],[teyz.y]]}
      ;This part should be improved in future.
      diag_t,'mms'+probes[i]+'te_tensor'
      get_data,'T_diag',data=t_diag
      store_data,'mms'+probes[i]+'_fpi_DEStempPerp',data={x:t_diag.x,y:(t_diag.y[*,1]+t_diag.y[*,2])/2.d}
      store_data,'mms'+probes[i]+'_fpi_DEStempPara',data={x:t_diag.x,y:t_diag.y[*,0]}
    endif else begin
      get_data,'mms'+probes[i]+'_des_tempperp_'+data_rate,data=teperp
      store_data,'mms'+probes[i]+'_fpi_DEStempPerp',data={x:teperp.x,y:teperp.y}
      get_data,'mms'+probes[i]+'_des_temppara_'+data_rate,data=tepara
      store_data,'mms'+probes[i]+'_fpi_DEStempPara',data={x:tepara.x,y:tepara.y}
    endelse
    trange_clip,'mms'+probes[i]+'_fpi_DEStempPara',trange[0],trange[1],newname='mms'+probes[i]+'_fpi_DEStempPara_clip'
    get_data,'mms'+probes[i]+'_fpi_DEStempPara_clip',data=Te_para
    store_data,'mms'+probes[i]+'_fpi_DEStempPara_clip',/delete
    trange_clip,'mms'+probes[i]+'_fpi_DEStempPerp',trange[0],trange[1],newname='mms'+probes[i]+'_fpi_DEStempPerp_clip'
    get_data,'mms'+probes[i]+'_fpi_DEStempPerp_clip',data=Te_perp
    store_data,'mms'+probes[i]+'_fpi_DEStempPerp_clip',/delete      

    box_ave_mms,variable1='mms'+probes[i]+'_des_shifted_time',variable2='mms'+probes[i]+'_fgm_b_gsm_'+fgm_data_rate+'_l2',var2ave='mms'+probes[i]+'_fgm_b_gsm_'+fgm_data_rate+'_l2_ele',inval=inval
    get_data,'mms'+probes[i]+'_fgm_b_gsm_'+fgm_data_rate+'_l2_ele',data=Bvec

    tinterpol_mxn,'mms'+probe[i]+'_mec_r_gsm','mms'+probes[i]+'_fgm_b_gsm_'+fgm_data_rate+'_l2_ele',newname='mms'+probe[i]+'_mec_r_gsm_intpl_ele'
    get_data,'mms'+probe[i]+'_mec_r_gsm_intpl_ele',data=pos_gsm
    store_data,'mms'+probe[i]+'_mec_r_gsm_intpl_ele',/delete

    fpiver='v'+strmid(dl.cdf.gatt.logical_file_id,4,5,/reverse_offset)
    fileout='mms'+probes[i]+'_des_'+data_rate+'_l2_'+fpiver+'_'+time_string(trange[0],format=2,precision=-1)+'-'+time_string(trange[1],format=2,precision=-1)

    store_data,fileout,data={x:e_density.x,y:[[pos_gsm.y],[Bvec.y],[e_density.y],[ve.y],[Te_para.y],[Te_perp.y]]}
    tplot_ascii,fileout,dir=outdir
    store_data,fileout,/delete
    undefine,pos_gsm,e_density,ve,vdbcs,Te_para,Te_perp


    if undefined(brst) then inval=4.5d else inval=0.15d

    trange_clip,'mms'+probes[i]+'_dis_numberdensity_dbcs_'+data_rate+fpi_suffix,trange[0],trange[1],newname='mms'+probes[i]+'_dis_numberDensity_clip'
    get_data,'mms'+probes[i]+'_dis_numberDensity_clip',data=i_density,dlimit=dl
    store_data,'mms'+probes[i]+'_dis_numberDensity_clip',/delete
    store_data,'mms'+probes[i]+'_dis_shifted_time',data={x:i_density.x,y:i_density.x}

    join_vec,'mms'+probes[i]+'_dis_bulk'+['x','y','z']+'_dbcs_'+data_rate,'mms'+probes[i]+'_dis_bulkv_dbcs'
    ;This part should be improved in future.
    mms_cotrans,'mms'+probes[i]+'_dis_bulkv',in_coord='dmpa',in_suffix='_dbcs',out_coord='gsm',out_suffix='_gsm',/ignore_dlimits

    trange_clip,'mms'+probes[i]+'_dis_bulkv_gsm'+fpi_suffix,trange[0],trange[1],newname='mms'+probes[i]+'_dis_bulkv_clip'
    get_data,'mms'+probes[i]+'_dis_bulkv_clip',data=vi
    store_data,'mms'+probes[i]+'_dis_bulkv_clip',/delete
    
    get_data,'mms'+probes[i]+'_dis_tempperp_'+data_rate,data=tiperp
    store_data,'mms'+probes[i]+'_fpi_DIStempPerp',data={x:tiperp.x,y:tiperp.y}
    get_data,'mms'+probes[i]+'_dis_temppara_'+data_rate,data=tipara
    store_data,'mms'+probes[i]+'_fpi_DIStempPara',data={x:tipara.x,y:tipara.y}

    trange_clip,'mms'+probes[i]+'_fpi_DIStempPara',trange[0],trange[1],newname='mms'+probes[i]+'_fpi_DIStempPara_clip'
    get_data,'mms'+probes[i]+'_fpi_DIStempPara_clip',data=Ti_para
    store_data,'mms'+probes[i]+'_fpi_DIStempPara_clip',/delete
    trange_clip,'mms'+probes[i]+'_fpi_DIStempPerp',trange[0],trange[1],newname='mms'+probes[i]+'_fpi_DIStempPerp_clip'
    get_data,'mms'+probes[i]+'_fpi_DIStempPerp_clip',data=Ti_perp
    store_data,'mms'+probes[i]+'_fpi_DIStempPerp_clip',/delete

    if not undefined(brst) then begin
      box_ave_mms,variable1='mms'+probes[i]+'_dis_shifted_time',variable2='mms'+probes[i]+'_fgm_b_gsm_'+fgm_data_rate+'_l2',var2ave='mms'+probes[i]+'_fgm_b_gsm_'+fgm_data_rate+'_l2_ion',inval=inval
    endif else begin
      copy_data,'mms'+probes[i]+'_fgm_b_gsm_'+fgm_data_rate+'_l2_ele','mms'+probes[i]+'_fgm_b_gsm_'+fgm_data_rate+'_l2_ion'
    endelse
    get_data,'mms'+probes[i]+'_fgm_b_gsm_'+fgm_data_rate+'_l2_ion',data=Bvec

    tinterpol_mxn,'mms'+probe[i]+'_mec_r_gsm','mms'+probes[i]+'_fgm_b_gsm_'+fgm_data_rate+'_l2_ion',newname='mms'+probe[i]+'_mec_r_gsm_intpl_ion'
    get_data,'mms'+probe[i]+'_mec_r_gsm_intpl_ion',data=pos_gsm
    store_data,'mms'+probe[i]+'_mec_r_gsm_intpl_ion',/delete

    fpiver='v'+strmid(dl.cdf.gatt.logical_file_id,4,5,/reverse_offset)
    fileout='mms'+probes[i]+'_dis_'+data_rate+'_l2_'+fpiver+'_'+time_string(trange[0],format=2,precision=-1)+'-'+time_string(trange[1],format=2,precision=-1)

    store_data,fileout,data={x:i_density.x,y:[[pos_gsm.y],[Bvec.y],[i_density.y],[vi.y],[Ti_para.y],[Ti_perp.y]]}
    tplot_ascii,fileout,dir=outdir
    store_data,fileout,/delete
    undefine,pos_gsm,i_density,vi,vdbcs,Ti_para,Ti_perp
    undefine,Bvec
    
  endfor

end