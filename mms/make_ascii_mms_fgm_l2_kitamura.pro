;+
;EXAMPLE:
; MMS>  make_ascii_mms_fgm_kitamura,['2015-09-01/08:00:00','2015-09-02/00:00:00'],probes=['1','2','3','4'],/load_fgm,/delete
; MMS>  make_ascii_mms_fgm_kitamura,['2015-09-01/08:00:00','2015-09-02/00:00:00'],probes=['1','2','3','4'],/brst,/load_fgm,/delete
;
; NOTES:
;     1) See the notes in mms_load_data for rules on the use of MMS data
;     2) Information of version of the first FGM cdf files is shown in the file name,
;        if multiple cdf files are loaded
; 
; OUTPUT FORMAT:
; time position-GSMX[km] -GSMY[km] -GSMZ[km] fgm-GSMX[nT] -GSMY[nT] -GSMZ[nT] position-GSEX[km] -GSEY[km] -GSEZ[km] fgm-GSEX[nT] -GSEY[nT] -GSEZ[nT] fgm_Btotal[nT]
;-

pro make_ascii_mms_fgm_l2_kitamura,trange,probes=probes,brst=brst,no_load_fgm=no_load_fgm,no_load_state=no_load_state,outdir=outdir,delete=delete,no_update=no_update

  mms_init
  trange=time_double(trange)
  if not undefined(delete) then store_data,'*',/delete
  if undefined(brst) then data_rate='srvy' else data_rate='brst'
  if undefined(probes) then probes=['1','2','3','4']
  if probes[0] eq '*' then probes=['1','2','3','4']
  probes=strcompress(probes,/remove_all)

  for i=0,n_elements(probes)-1 do begin
    
    if undefined(no_load_fgm) then begin
      mms_load_fgm,trange=trange,instrument='fgm',probes=probes[i],data_rate=data_rate,level='l2',no_update=no_update,/no_attitude_data
    endif
    if undefined(no_load_state) then mms_load_mec,trange=[trange[0]-600.d,trange[1]+600.d],probes=probes[i],no_update=no_update

    get_data,'mms'+probes[i]+'_fgm_b_gse_'+data_rate+'_l2_btot',data=Btot,dlimit=dl
    get_data,'mms'+probes[i]+'_fgm_b_gse_'+data_rate+'_l2_bvec',data=Bvec_gse
    get_data,'mms'+probes[i]+'_fgm_b_gsm_'+data_rate+'_l2_bvec',data=Bvec_gsm
    tinterpol_mxn,'mms'+probe[i]+'_mec_r_gse','mms'+probes[i]+'_fgm_b_gse_'+data_rate+'_l2_btot',newname='mms'+probe[i]+'_mec_r_gse_intpl'
    get_data,'mms'+probe[i]+'_mec_r_gse_intpl',data=pos_gse
    del_data,'mms'+probe[i]+'_mec_r_gse_intpl'
    tinterpol_mxn,'mms'+probe[i]+'_mec_r_gsm','mms'+probes[i]+'_fgm_b_gse_'+data_rate+'_l2_btot',newname='mms'+probe[i]+'_mec_r_gsm_intpl'
    get_data,'mms'+probe[i]+'_mec_r_gsm_intpl',data=pos_gsm
    del_data,'mms'+probe[i]+'_mec_r_gsm_intpl'

    if not undefined(outdir) then if ~file_test(outdir) then file_mkdir,outdir
    fgm_dv='v'+dl.cdf.gatt.data_version
    fileout='mms'+probes[i]+'_fgm_'+data_rate+'_'+fgm_dv+'_'+time_string(trange[0],format=2,precision=-1)+'-'+time_string(trange[1],format=2,precision=-1)

    store_data,fileout,data={x:pos_gse.x,y:[[pos_gsm.y],[Bvec_gsm.y],[pos_gse.y],[Bvec_gse.y],[Btot.y]]}
    tplot_ascii,fileout,dir=outdir,trange=trange
    store_data,fileout,/delete
    undefine,pos_gse,pos_gsm,Bvec_gse,Bvec_gsm,Btot
    
  endfor

end