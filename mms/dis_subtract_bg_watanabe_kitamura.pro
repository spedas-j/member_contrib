pro dis_subtract_bg_watanabe_kitamura,probe=probe,data_rate=data_rate,coord=coord

  if undefined(probe) then probe='1'
  if undefined(data_rate) then data_rate='fast'
  if undefined(coord) then coord='gse'

  mp=1.673e-27
  q=1.602e-19

  get_data,'mms'+probe+'_dis_numberdensity_'+data_rate,data=ni,dlimit=dl_ni
  get_data,'mms'+probe+'_dis_numberdensity_bg_'+data_rate,data=ni_bg
  ni_bgsubt=ni
  ni_bgsubt.y=ni.y-ni_bg.y
  store_data,'mms'+probe+'_dis_numberdensity_bg_corr_'+data_rate,data=ni_bgsubt,dlimit=dl_ni
  
  get_data,'mms'+probe+'_dis_bulkv_'+coord+'_'+data_rate,data=vi,dlimit=dl_vi
  vi_orig=vi
  for i=0,2 do vi.y[*,i]=vi.y[*,i]*ni.y/ni_bgsubt.y
  store_data,'mms'+probe+'_dis_bulkv_bg_corr_'+coord+'_'+data_rate,data=vi,dlimit=dl_vi

  if coord eq 'dbcs' or coord eq 'gse' then begin
    get_data,'mms'+probe+'_dis_prestensor_'+coord+'_'+data_rate,data=ptens,dlimit=dl_ptens
    store_data,'mms'+probe+'_dis_prestensor_diag_'+coord+'_'+data_rate,data={x:ptens.x,y:[[ptens.y[*,0,0]],[ptens.y[*,1,1]],[ptens.y[*,2,2]]]}
    get_data,'mms'+probe+'_dis_pres_bg_'+data_rate,data=p_bg
    for i=0,2 do ptens.y[*,i,i]=ptens.y[*,i,i]-p_bg.y
    for i=0,2 do for j=0,2 do ptens.y[*,i,j]=ptens.y[*,i,j]-mp*1.e+21*(ni.y*vi_orig.y[*,i]*vi_orig.y[*,j]-ni_bgsubt.y*vi.y[*,i]*vi.y[*,j])
    store_data,'mms'+probe+'_dis_prestensor_bg_corr_'+coord+'_'+data_rate,data=ptens,dlimit=dl_ptens
    store_data,'mms'+probe+'_dis_prestensor_diag_bg_corr_'+coord+'_'+data_rate,data={x:ptens.x,y:[[ptens.y[*,0,0]],[ptens.y[*,1,1]],[ptens.y[*,2,2]]]}

    get_data,'mms'+probe+'_dis_temptensor_'+coord+'_'+data_rate,data=ttens,dlimit=dl_ttens
    store_data,'mms'+probe+'_dis_temptensor_diag_'+coord+'_'+data_rate,data={x:ttens.x,y:[[ttens.y[*,0,0]],[ttens.y[*,1,1]],[ttens.y[*,2,2]]]}
    for i=0,2 do for j=0,2 do ttens.y[*,i,j]=ptens.y[*,i,j]*1e-9/(ni_bgsubt.y*1e+6*q)
    store_data,'mms'+probe+'_dis_temptensor_bg_corr_'+coord+'_'+data_rate,data=ttens,dlimit=dl_ttens
    store_data,'mms'+probe+'_dis_temptensor_diag_bg_corr_'+coord+'_'+data_rate,data={x:ttens.x,y:[[ttens.y[*,0,0]],[ttens.y[*,1,1]],[ttens.y[*,2,2]]]}
  endif

  get_data,'mms'+probe+'_dis_spectr_bg_'+data_rate,data=spec_bg
  type=['omni','px','mx','py','my','pz','mz']
  for j=0,n_elements(type)-1 do begin
    get_data,'mms'+probe+'_dis_energyspectr_'+type[j]+'_'+data_rate,data=spec_data,limit=spec_l,dlimit=spec_dl
    for i=0,n_elements(spec_data.y[0,*])-1 do spec_data.y[*,i]=spec_data.y[*,i]-spec_bg.y
    store_data,'mms'+probe+'_dis_energyspectr_'+type[j]+'_bg_corr_'+data_rate,data=spec_data,limit=spec_l,dlimit=spec_dl
  endfor
  
end
