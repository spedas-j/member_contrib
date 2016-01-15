;+
;EXAMPLE:
; MMS>  make_ascii_mms_dfg_kitamura,'1',['2015-09-01/08:00:00','2015-09-02/00:00:00'],/load_dfg,/delete
; MMS>  make_ascii_mms_dfg_kitamura,'1',['2015-09-01/08:00:00','2015-09-02/00:00:00'],/brst,/load_dfg,/delete
;-

pro make_ascii_mms_dfg_kitamura,probe,trange,brst=brst,load_dfg=load_dfg,outdir=outdir,delete=delete,no_update=no_update

  mms_init
  trange=time_double(trange)
  if not undefined(delete) then store_data,'*',/delete
  if undefined(brst) then data_rate='srvy' else data_rate='brst'
  
  if not undefined(load_dfg) then begin
    mms_load_fgm,trange=trange,instrument='dfg',probes=probe,data_rate=data_rate,level='l2pre',no_update=no_update
  endif
  
  get_data,'mms'+probe+'_dfg_'+data_rate+'_l2pre_gse_btot',data=Btot
  get_data,'mms'+probe+'_dfg_'+data_rate+'_l2pre_gse_bvec',data=Bvec_gse
  get_data,'mms'+probe+'_dfg_'+data_rate+'_l2pre_gsm_bvec',data=Bvec_gsm
  tinterpol_mxn,'mms'+probe+'_pos_gse','mms'+probe+'_dfg_'+data_rate+'_l2pre_gse_btot',newname='mms'+probe+'_pos_gse_intpl'
  get_data,'mms'+probe+'_pos_gse_intpl',data=pos_gse
  del_data,'mms'+probe+'_pos_gse_intpl'
  tinterpol_mxn,'mms'+probe+'_pos_gsm','mms'+probe+'_dfg_'+data_rate+'_l2pre_gse_btot',newname='mms'+probe+'_pos_gsm_intpl'
  get_data,'mms'+probe+'_pos_gsm_intpl',data=pos_gsm
  del_data,'mms'+probe+'_pos_gsm_intpl'
  
  if not undefined(outdir) then if ~file_test(outdir) then file_mkdir,outdir
  fileout='mms'+probe+'_dfg_'+data_rate+'_'+time_string(trange[0],format=2,precision=-1)+'-'+time_string(trange[1],format=2,precision=-1)
  
  store_data,fileout,data={x:pos_gse.x,y:[[pos_gsm.y],[Bvec_gsm.y],[pos_gse.y],[Bvec_gse.y],[Btot.y]]}
  tplot_ascii,fileout,dir=outdir,trange=trange
  store_data,fileout,/delete
  undefine,pos_gse,pos_gsm,Bvec_gse,Bvec_gsm,Btot

end