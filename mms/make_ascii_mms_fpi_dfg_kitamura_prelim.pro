;+
;EXAMPLE:
; MMS>  make_ascii_mms_fpi_dfg_kitamura_prelim,['2015-09-01/08:00:00','2015-09-02/00:00:00'],probes=['1','2','3','4']
; MMS>  make_ascii_mms_fpi_dfg_kitamura_prelim,['2015-09-01/08:00:00','2015-09-02/00:00:00'],probes=['1','2','3','4'],/brst
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

pro make_ascii_mms_fpi_dfg_kitamura_prelim,trange,probes=probes,brst=brst,fpi_ql=fpi_ql,no_load_dfg=no_load_dfg,no_load_fpi=no_load_fpi,$
                                    no_load_state=no_load_state,fpi_suffix=fpi_suffix,outdir=outdir,delete=delete,$
                                    no_update=no_update

  mms_init
  trange=time_double(trange)
  if not undefined(delete) then store_data,'*',/delete
  if undefined(brst) then data_rate='fast' else data_rate='brst'
  if undefined(brst) then dfg_data_rate='srvy' else dfg_data_rate='brst'
  if undefined(brst) then inval=4.5d else inval=0.03d
  if undefined(fpi_ql) then fpi_level='l1b' else fpi_level='ql'
  if undefined(fpi_suffix) then fpi_suffix=''
  if undefined(probes) or probes eq '*' then probes=['1','2','3','4']
  probes=strcompress(probes,/remove_all)

  for i=0,n_elements(probes)-1 do begin
    
    if undefined(no_load_dfg) then mms_load_fgm,trange=[trange[0]-600.d,trange[1]+600.d],instrument='dfg',probes=probes[i],data_rate=dfg_data_rate,level='l2pre',no_update=no_update
    if undefined(no_load_fpi) then begin
      if undefined(fpi_ql) then begin
        mms_load_fpi,trange=trange,probes=probes[i],level=fpi_level,data_rate=data_rate,datatype=['des-moms','dis-moms'],suffix=fpi_suffix,no_update=no_update
      endif else begin
        mms_load_fpi,trange=trange,probes=probes[i],level=fpi_level,data_rate=data_rate,datatype=['des','dis'],suffix=fpi_suffix,no_update=no_update
      endelse
    endif
    if undefined(no_load_state) then mms_load_state,trange=[trange[0]-600.d,trange[1]+600.d],probes=probes[i],datatypes=['spinras','spindec'],no_download=no_update

    trange_clip,'mms'+probes[i]+'_des_numberDensity'+fpi_suffix,trange[0],trange[1],newname='mms'+probes[i]+'_des_numberDensity_clip'
    get_data,'mms'+probes[i]+'_des_numberDensity_clip',data=e_density,dlimit=dl
    store_data,'mms'+probes[i]+'_des_numberDensity_clip',/delete
    e_density.x=e_density.x+inval*0.5d
    store_data,'mms'+probes[i]+'_des_shifted_time',data={x:e_density.x,y:e_density.x}

    join_vec,'mms'+probes[i]+'_des_bulk'+['X','Y','Z']+fpi_suffix,'mms'+probes[i]+'_des_bulkV_DSC'
    get_data,'mms'+probes[i]+'_des_bulkV_DSC',data=vdsc
    vdsc.x=vdsc.x+inval*0.5d
    store_data,'mms'+probes[i]+'_des_bulkV_DSC',data={x:vdsc.x,y:vdsc.y}
    ;This part should be improved in future.
    mms_cotrans,'mms'+probes[i]+'_des_bulkV',in_coord='dmpa',in_suffix='_DSC',out_coord='gse',out_suffix='_gse',/ignore_dlimits
    mms_cotrans,'mms'+probes[i]+'_des_bulkV',in_coord='gse',in_suffix='_gse',out_coord='gsm',out_suffix='_gsm',/ignore_dlimits

    trange_clip,'mms'+probes[i]+'_des_bulkV_gsm'+fpi_suffix,trange[0],trange[1],newname='mms'+probes[i]+'_des_bulkV_clip'
    get_data,'mms'+probes[i]+'_des_bulkV_clip',data=ve
    del_data,'mms'+probes[i]+'_des_bulkV_clip'

    get_data,'mms'+probes[i]+'_des_TempXX'+fpi_suffix,data=texx
    get_data,'mms'+probes[i]+'_des_TempYY'+fpi_suffix,data=teyy
    get_data,'mms'+probes[i]+'_des_TempZZ'+fpi_suffix,data=tezz
    get_data,'mms'+probes[i]+'_des_TempXY'+fpi_suffix,data=texy
    get_data,'mms'+probes[i]+'_des_TempXZ'+fpi_suffix,data=texz
    get_data,'mms'+probes[i]+'_des_TempYZ'+fpi_suffix,data=teyz

    store_data,'mms'+probes[i]+'te_tensor',data={x:texx.x,y:[[texx.y],[teyy.y],[tezz.y],[texy.y],[texz.y],[teyz.y]]}
    ;This part should be improved in future.
    diag_t,'mms'+probes[i]+'te_tensor'
    get_data,'T_diag',data=t_diag
    store_data,'mms'+probes[i]+'_fpi_DEStempPerp',data={x:t_diag.x,y:(t_diag.y[*,1]+t_diag.y[*,2])/2.d}
    store_data,'mms'+probes[i]+'_fpi_DEStempPara',data={x:t_diag.x,y:t_diag.y[*,0]}

    trange_clip,'mms'+probes[i]+'_fpi_DEStempPara',trange[0],trange[1],newname='mms'+probes[i]+'_fpi_DEStempPara_clip'
    get_data,'mms'+probes[i]+'_fpi_DEStempPara_clip',data=Te_para
    del_data,'mms'+probes[i]+'_fpi_DEStempPara_clip'
    trange_clip,'mms'+probes[i]+'_fpi_DEStempPerp',trange[0],trange[1],newname='mms'+probes[i]+'_fpi_DEStempPerp_clip'
    get_data,'mms'+probes[i]+'_fpi_DEStempPerp_clip',data=Te_perp
    del_data,'mms'+probes[i]+'_fpi_DEStempPerp_clip'

    box_ave_mms, variable1='mms'+probes[i]+'_des_shifted_time', variable2='mms'+probes[i]+'_dfg_'+dfg_data_rate+'_l2pre_gsm', var2ave='mms'+probes[i]+'_dfg_'+dfg_data_rate+'_l2pre_gsm_ele',inval=inval
    get_data,'mms'+probes[i]+'_dfg_'+dfg_data_rate+'_l2pre_gsm_ele',data=Bvec

    tinterpol_mxn,'mms'+probes[i]+'_pos_gsm','mms'+probes[i]+'_dfg_'+dfg_data_rate+'_l2pre_gsm_ele',newname='mms'+probes[i]+'_pos_gsm_ele'
    get_data,'mms'+probes[i]+'_pos_gsm_ele',data=pos_gsm
    del_data,'mms'+probes[i]+'_pos_gsm_ele'

    fpiver='v'+strmid(dl.cdf.gatt.logical_file_id,4,5,/reverse_offset)
    fileout='mms'+probes[i]+'_des_'+data_rate+'_'+fpi_level+'_'+fpiver+'_'+time_string(trange[0],format=2,precision=-1)+'-'+time_string(trange[1],format=2,precision=-1)

    store_data,fileout,data={x:e_density.x,y:[[pos_gsm.y[*,0:2]],[Bvec.y],[e_density.y],[ve.y],[Te_para.y],[Te_perp.y]]}
    tplot_ascii,fileout,dir=outdir
    store_data,fileout,/delete
    undefine,pos_gsm,e_density,ve,vdsc,Te_para,Te_perp


    if undefined(brst) then inval=4.5d else inval=0.15d

    trange_clip,'mms'+probes[i]+'_dis_numberDensity'+fpi_suffix,trange[0],trange[1],newname='mms'+probes[i]+'_dis_numberDensity_clip'
    get_data,'mms'+probes[i]+'_dis_numberDensity_clip',data=i_density,dlimit=dl
    store_data,'mms'+probes[i]+'_dis_numberDensity_clip',/delete
    i_density.x=i_density.x+inval*0.5d
    store_data,'mms'+probes[i]+'_dis_shifted_time',data={x:i_density.x,y:i_density.x}

    join_vec,'mms'+probes[i]+'_dis_bulk'+['X','Y','Z']+fpi_suffix,'mms'+probes[i]+'_dis_bulkV_DSC'
    get_data,'mms'+probes[i]+'_dis_bulkV_DSC',data=vdsc
    vdsc.x=vdsc.x+inval*0.5d
    store_data,'mms'+probes[i]+'_dis_bulkV_DSC',data={x:vdsc.x,y:vdsc.y}
    ;This part should be improved in future.
    mms_cotrans,'mms'+probes[i]+'_dis_bulkV',in_coord='dmpa',in_suffix='_DSC',out_coord='gse',out_suffix='_gse',/ignore_dlimits
    mms_cotrans,'mms'+probes[i]+'_dis_bulkV',in_coord='gse',in_suffix='_gse',out_coord='gsm',out_suffix='_gsm',/ignore_dlimits

    trange_clip,'mms'+probes[i]+'_dis_bulkV_gsm'+fpi_suffix,trange[0],trange[1],newname='mms'+probes[i]+'_dis_bulkV_clip'
    get_data,'mms'+probes[i]+'_dis_bulkV_clip',data=vi
    del_data,'mms'+probes[i]+'_dis_bulkV_clip'
    
    get_data,'mms'+probes[i]+'_dis_TempXX'+fpi_suffix,data=tixx
    get_data,'mms'+probes[i]+'_dis_TempYY'+fpi_suffix,data=tiyy
    get_data,'mms'+probes[i]+'_dis_TempZZ'+fpi_suffix,data=tizz
    get_data,'mms'+probes[i]+'_dis_TempXY'+fpi_suffix,data=tixy
    get_data,'mms'+probes[i]+'_dis_TempXZ'+fpi_suffix,data=tixz
    get_data,'mms'+probes[i]+'_dis_TempYZ'+fpi_suffix,data=tiyz

    store_data,'mms'+probes[i]+'ti_tensor',data={x:tixx.x,y:[[tixx.y],[tiyy.y],[tizz.y],[tixy.y],[tixz.y],[tiyz.y]]}
    ;This part should be improved in future.
    diag_t,'mms'+probes[i]+'ti_tensor'
    get_data,'T_diag',data=t_diag
    store_data,'mms'+probes[i]+'_fpi_DIStempPerp',data={x:t_diag.x,y:(t_diag.y[*,1]+t_diag.y[*,2])/2.d}
    store_data,'mms'+probes[i]+'_fpi_DIStempPara',data={x:t_diag.x,y:t_diag.y[*,0]}

    trange_clip,'mms'+probes[i]+'_fpi_DIStempPara',trange[0],trange[1],newname='mms'+probes[i]+'_fpi_DIStempPara_clip'
    get_data,'mms'+probes[i]+'_fpi_DIStempPara_clip',data=Ti_para
    del_data,'mms'+probes[i]+'_fpi_DIStempPara_clip'
    trange_clip,'mms'+probes[i]+'_fpi_DIStempPerp',trange[0],trange[1],newname='mms'+probes[i]+'_fpi_DIStempPerp_clip'
    get_data,'mms'+probes[i]+'_fpi_DIStempPerp_clip',data=Ti_perp
    del_data,'mms'+probes[i]+'_fpi_DIStempPerp_clip'

    if not undefined(brst) then begin
      box_ave_mms, variable1='mms'+probes[i]+'_dis_shifted_time', variable2='mms'+probes[i]+'_dfg_'+dfg_data_rate+'_l2pre_gsm', var2ave='mms'+probes[i]+'_dfg_'+dfg_data_rate+'_l2pre_gsm_ion',inval=inval
      get_data,'mms'+probes[i]+'_dfg_'+dfg_data_rate+'_l2pre_gsm_ion',data=Bvec
    endif

    tinterpol_mxn,'mms'+probes[i]+'_pos_gsm','mms'+probes[i]+'_dfg_'+dfg_data_rate+'_l2pre_gsm_ion',newname='mms'+probes[i]+'_pos_gsm_ion'
    get_data,'mms'+probes[i]+'_pos_gsm_ion',data=pos_gsm
    del_data,'mms'+probes[i]+'_pos_gsm_ion'

    fpiver='v'+strmid(dl.cdf.gatt.logical_file_id,4,5,/reverse_offset)
    fileout='mms'+probes[i]+'_dis_'+data_rate+'_'+fpi_level+'_'+fpiver+'_'+time_string(trange[0],format=2,precision=-1)+'-'+time_string(trange[1],format=2,precision=-1)

    store_data,fileout,data={x:i_density.x,y:[[pos_gsm.y[*,0:2]],[Bvec.y],[i_density.y],[vi.y],[Ti_para.y],[Ti_perp.y]]}
    tplot_ascii,fileout,dir=outdir
    store_data,fileout,/delete
    undefine,pos_gsm,i_density,vi,vdsc,Ti_para,Ti_perp
    undefine,Bvec
    
  endfor

end