;+
; PROCEDURE:
;         mms_curlometer
;
; PURPOSE:
;         Calculate current denisty using curlometer technique 
;
; KEYWORDS:
;         trange:       time range of interest [starttime, endtime] with the format
;                       ['YYYY-MM-DD','YYYY-MM-DD'] or to specify more or less than a day
;                       ['YYYY-MM-DD/hh:mm:ss','YYYY-MM-DD/hh:mm:ss']
;         ref_probe:    a probe used as a reference - value for MMS SC # (default value is '1')
;         data_rate:    fgm data rate for the calculation
;         gsm:          set this flag to calculate current in the GSM coordinate
;         plot:         set this flag to plot
;         lmn:          set this flag to calculate current in the LMN coordinate (Shue et al. [1998] model).
;                       specific LMN coodinate can also be used if 3 x 3 matrix for coordnate transformation
;                       are used as the input. the original coordinate system is the GSE or GSM coodinate depending on
;                       the gsm flag.
;         l2pre:        set this flag to use dfg l2pre data forcibly. if not set, l2 data
;                       are used, if available (team member only)
;
; EXAMPLE:
;     MMS>  mms_curlometer,trange=['2015-11-18/02:12:00','2015-11-18/02:13:30'],ref_probe='1',data_rate='srvy',/gsm,/plot
;
; NOTES:
;     See the notes in mms_load_data for rules on the use of MMS data
;-

PRO mms_curlometer,trange=trange,ref_probe=ref_probe,data_rate=fgm_data_rate,gsm=gsm,plot=plot,lmn=lmn,l2pre=l2pre

  if not undefined(gsm) then coord='gsm' else coord='gse'
  if undefined(ref_probe) then ref_probe='1'
  if undefined(fgm_data_rate) then fgm_data_rate='srvy'
  
; INOUT: SC position in km, magnetic field in nT
; OUTPUT: three components of electric current, |curl(B)|, |div(B)| in nA/(m^2)

  if not undefined(trange) then begin
    trange=time_double(trange)
    if undefined(l2pre) then begin
      inst='FGM'
      for p=1,4 do if strlen(tnames('mms'+strcompress(string(p),/remove_all)+'_fgm_b_'+coord+'_'+fgm_data_rate+'_l2_bvec')) eq 0 then mms_load_fgm,trange=trange,instrument='fgm',probes=strcompress(string(p),/remove_all),data_rate=fgm_data_rate,level='l2',/no_attitude_data
    endif else begin
      inst='DFG'
      for p=1,4 do if strlen(tnames('mms'+strcompress(string(p),/remove_all)+'_dfg_b_'+coord+'_'+fgm_data_rate+'_l2pre_bvec')) eq 0 then mms_load_fgm,trange=trange,instrument='dfg',probes=strcompress(string(p),/remove_all),data_rate=fgm_data_rate,level='l2pre',/no_attitude_data
    endelse
    for p=1,4 do if strlen(tnames('mms'+strcompress(string(p),/remove_all)+'_mec_r_'+coord)) eq 0 then mms_load_mec,trange=[trange[0]-60.0,trange[1]+60.0],probes=strcompress(string(p),/remove_all),varformat=['mms'+probe+'_mec_r_eci','mms'+probe+'_mec_r_gse','mms'+probe+'_mec_r_gsm','mms'+probe+'_mec_L_vec']
  endif else begin
    copy_data,'mms'+ref_probe+'_fgm_b_'+coord+'_'+fgm_data_rate+'_l2_btot','time_for_curlometer'
  endelse
  
  if undefined(l2pre) then begin
    if not undefined(trange) then time_clip,'mms'+ref_probe+'_fgm_b_'+coord+'_'+fgm_data_rate+'_l2_btot',time_double(trange[0]),time_double(trange[1]),newname='time_for_curlometer'
    for p=1,4 do tinterpol_mxn,'mms'+strcompress(string(p),/remove_all)+'_fgm_b_'+coord+'_'+fgm_data_rate+'_l2_bvec','time_for_curlometer',newname='mms'+strcompress(string(p),/remove_all)+'_b_for_curlometer'
  endif else begin
    if not undefined(trange) then time_clip,'mms'+ref_probe+'_dfg_b_'+coord+'_'+fgm_data_rate+'_l2pre_btot',time_double(trange[0]),time_double(trange[1]),newname='time_for_curlometer'
    for p=1,4 do tinterpol_mxn,'mms'+strcompress(string(p),/remove_all)+'_dfg_b_'+coord+'_'+fgm_data_rate+'_l2pre_bvec','time_for_curlometer',newname='mms'+strcompress(string(p),/remove_all)+'_b_for_curlometer'
  endelse
  for p=1,4 do tinterpol_mxn,'mms'+strcompress(string(p),/remove_all)+'_mec_r_'+coord,'time_for_curlometer',newname='mms'+strcompress(string(p),/remove_all)+'_pos_for_curlometer'

  get_data,'mms'+ref_probe+'_b_for_curlometer',data=b
  get_data,'mms'+ref_probe+'_pos_for_curlometer',data=pos
  time=b.x
  dnum=n_elements(time)
  all_pos=dblarr(4,dnum,3)
  all_b=dblarr(4,dnum,3)
  for i=0l,dnum-1 do begin
    for j=0,2 do begin
      all_pos[0,i,j]=pos.y[i,j]
      all_b[0,i,j]=b.y[i,j]
    endfor
  endfor
  undefine,b,pos
  
  sc_names0=['1','2','3','4']
  sc_names=sc_names0[where(sc_names0 ne ref_probe)]

  for p=0,2 do begin
    get_data,'mms'+sc_names[p]+'_b_for_curlometer',data=b
    get_data,'mms'+sc_names[p]+'_pos_for_curlometer',data=pos
    for i=0l,dnum-1 do begin
      for j=0,2 do begin
        all_pos[p+1,i,j]=pos.y[i,j]
        all_b[p+1,i,j]=b.y[i,j]
      endfor
    endfor
    undefine,b,pos
  endfor

  mu0=4.d*!dpi*1.e-7
  drx=dblarr(3)
  dry=dblarr(3)
  drz=dblarr(3)
  dbx=dblarr(3)
  dby=dblarr(3)
  dbz=dblarr(3)
  drcdrx=dblarr(3)
  drcdry=dblarr(3)
  drcdrz=dblarr(3)
  ji=dblarr(dnum,3)
  rotb=dblarr(dnum)
  divb=dblarr(dnum)
  jpara=dblarr(dnum)
  jperp=dblarr(dnum)

  for i=0l,dnum-1 do begin
    
    drx[0]=all_pos[1,i,0]-all_pos[0,i,0]
    dry[0]=all_pos[1,i,1]-all_pos[0,i,1]
    drz[0]=all_pos[1,i,2]-all_pos[0,i,2]
    drx[1]=all_pos[2,i,0]-all_pos[0,i,0]
    dry[1]=all_pos[2,i,1]-all_pos[0,i,1]
    drz[1]=all_pos[2,i,2]-all_pos[0,i,2]
    drx[2]=all_pos[3,i,0]-all_pos[0,i,0]
    dry[2]=all_pos[3,i,1]-all_pos[0,i,1]
    drz[2]=all_pos[3,i,2]-all_pos[0,i,2]

    dbx[0]=all_b[1,i,0]-all_b[0,i,0]
    dby[0]=all_b[1,i,1]-all_b[0,i,1]
    dbz[0]=all_b[1,i,2]-all_b[0,i,2]
    dbx[1]=all_b[2,i,0]-all_b[0,i,0]
    dby[1]=all_b[2,i,1]-all_b[0,i,1]
    dbz[1]=all_b[2,i,2]-all_b[0,i,2]
    dbx[2]=all_b[3,i,0]-all_b[0,i,0]
    dby[2]=all_b[3,i,1]-all_b[0,i,1]
    dbz[2]=all_b[3,i,2]-all_b[0,i,2]

    drcdrx[0]=dry[1]*drz[2]-dry[2]*drz[1]
    drcdry[0]=drz[1]*drx[2]-drz[2]*drx[1]
    drcdrz[0]=drx[1]*dry[2]-drx[2]*dry[1]
    drcdrx[1]=dry[2]*drz[0]-dry[0]*drz[2]
    drcdry[1]=drz[2]*drx[0]-drz[0]*drx[2]
    drcdrz[1]=drx[2]*dry[0]-drx[0]*dry[2]
    drcdrx[2]=dry[0]*drz[1]-dry[1]*drz[0]
    drcdry[2]=drz[0]*drx[1]-drz[1]*drx[0]
    drcdrz[2]=drx[0]*dry[1]-drx[1]*dry[0]

    mat=[[drcdrx[0],drcdry[0],drcdrz[0]],[drcdrx[1],drcdry[1],drcdrz[1]],[drcdrx[2],drcdry[2],drcdrz[2]]]

    mat2=invert(mat,/double)

    rhs=[dbx[1]*drx[2]+dby[1]*dry[2]+dbz[1]*drz[2]-(dbx[2]*drx[1]+dby[2]*dry[1]+dbz[2]*drz[1]), $
         dbx[2]*drx[0]+dby[2]*dry[0]+dbz[2]*drz[0]-(dbx[0]*drx[2]+dby[0]*dry[2]+dbz[0]*drz[2]), $
         dbx[0]*drx[1]+dby[0]*dry[1]+dbz[0]*drz[1]-(dbx[1]*drx[0]+dby[1]*dry[0]+dbz[1]*drz[0])]

    for j=0,2 do ji[i,j]=mat2[0,j]*rhs[0]+mat2[1,j]*rhs[1]+mat2[2,j]*rhs[2]

    for j=0,2 do ji[i,j]=ji[i,j]/mu0/1.e3
    
    rotb[i]=sqrt(ji[i,0]^2+ji[i,1]^2+ji[i,2]^2)
    B_avg=[average(all_b[*,i,0]),average(all_b[*,i,1]),average(all_b[*,i,2])]
    n_para=B_avg/norm(B_avg,/double)
    jpara[i]=sqrt((ji[i,0]*n_para[0])^2+(ji[i,1]*n_para[1])^2+(ji[i,2]*n_para[2])^2)
    jperp[i]=sqrt(rotb[i]^2-jpara[i]^2)

    lhs=drx[0]*drcdrx[0]+dry[0]*drcdry[0]+drz[0]*drcdrz[0]
    lhs2=0.d
    rhs2=0.d
    for j=0,2 do begin
      rhs2=rhs2+dbx[j]*drcdrx[j]+dby[j]*drcdry[j]+dbz[j]*drcdrz[j]
      lhs2=lhs2+drx[j]*drcdrx[j]+dry[j]*drcdry[j]+drz[j]*drcdrz[j]
    endfor
;   divb[i]=abs(rhs2)/abs(lhs2)/mu0/1.e3
    divb[i]=abs(rhs2)/abs(lhs)/mu0/1.e3

  endfor

  store_data,'Current_'+coord,data={x:time,y:ji}
  options,'Current_'+coord,constant=0.0,ytitle='Current!CDensity!C'+strupcase(coord),ysubtitle='[nA/m!U2!N]',colors=[2,4,6],labels=['J!DX!N','J!DY!N','J!DZ!N'],labflag=-1,datagap=0.13d
  store_data,'Current_magnitude',data={x:time,y:[[rotb],[jpara],[jperp]]}
  options,'Current_magnitude',ytitle='Current!CDensity!CMagnitude',ysubtitle='[nA/m!U2!N]',colors=[0,4,6],labels=['|J|','|J_para|','|J_perp|'],labflag=-1,datagap=0.13d
  ylim,'Current_magnitude',10.d,2000.d,1
  store_data,'divB_over_rotB',data={x:time,y:divb/rotb}
  options,'divB_over_rotB',ytitle='divB/|rotB|',colors=1,panel_size=0.75,datagap=0.13d
  ylim,'divB_over_rotB',0.03d,10.d,1

  if not undefined(lmn) then begin
    ji_lmn=dblarr(n_elements(time),3)
    b_lmn=dblarr(n_elements(time),3)
    bt=dblarr(n_elements(time))
    if n_elements(lmn) eq 9 then begin
      for i=0l,n_elements(time)-1 do begin
        ji_lmn[i,0]=ji[i,0]*lmn[0,0]+ji[i,1]*lmn[1,0]+ji[i,2]*lmn[2,0]
        ji_lmn[i,1]=ji[i,0]*lmn[0,1]+ji[i,1]*lmn[1,1]+ji[i,2]*lmn[2,1]
        ji_lmn[i,2]=ji[i,0]*lmn[0,2]+ji[i,1]*lmn[1,2]+ji[i,2]*lmn[2,2]
      endfor
      
;      for p=1,4 do begin
;        get_data,'mms'+strcompress(string(p),/remove_all)+'_b_for_curlometer',data=b
;        for i=0l,n_elements(time)-1 do begin
;          b_lmn[i,0]=b.y[i,0]*lmn[0,0]+b.y[i,1]*lmn[1,0]+b.y[i,2]*lmn[2,0]
;          b_lmn[i,1]=b.y[i,0]*lmn[0,1]+b.y[i,1]*lmn[1,1]+b.y[i,2]*lmn[2,1]
;          b_lmn[i,2]=b.y[i,0]*lmn[0,2]+b.y[i,1]*lmn[1,2]+b.y[i,2]*lmn[2,2]
;          bt[i]=norm(reform(b.y[i,*]),/double)
;        endfor
;        store_data,'mms'+strcompress(string(p),/remove_all)+'_b_for_curlometer_lmn',data={x:b.x,y:b_lmn}
;        store_data,'mms'+strcompress(string(p),/remove_all)+'_b_for_curlometer_tlmn',data={x:b.x,y:[[bt],[b_lmn[*,0]],[b_lmn[*,1]],[b_lmn[*,2]]}
;        options,'mms'+strcompress(string(p),/remove_all)+'_b_for_curlometer_lmn',constant=0.0,ytitle='MMS'+strcompress(string(p),/remove_all)+'!CFGM_'+fgm_data_rate+'!CLMN',ysubtitle='[nT]',colors=[2,4,6],labels=['B!DL!N','B!DM!N','B!DN!N'],labflag=-1,datagap=0.13d
;        options,'mms'+strcompress(string(p),/remove_all)+'_b_for_curlometer_tlmn',constant=0.0,ytitle='MMS'+strcompress(string(p),/remove_all)+'!CFGM_'+fgm_data_rate+'!CLMN',ysubtitle='[nT]',colors=[0,2,4,6],labels=['|B|','B!DL!N','B!DM!N','B!DN!N'],labflag=-1,datagap=0.13d
;      endfor

      get_data,'mms'+ref_probe+'_b_for_curlometer',data=b
      for i=0l,n_elements(time)-1 do begin
        b_lmn[i,0]=b.y[i,0]*lmn[0,0]+b.y[i,1]*lmn[1,0]+b.y[i,2]*lmn[2,0]
        b_lmn[i,1]=b.y[i,0]*lmn[0,1]+b.y[i,1]*lmn[1,1]+b.y[i,2]*lmn[2,1]
        b_lmn[i,2]=b.y[i,0]*lmn[0,2]+b.y[i,1]*lmn[1,2]+b.y[i,2]*lmn[2,2]
        bt[i]=norm(reform(b.y[i,*]),/double)
      endfor
      store_data,'mms'+ref_probe+'_b_for_curlometer_lmn',data={x:b.x,y:b_lmn}
      store_data,'mms'+ref_probe+'_b_for_curlometer_tlmn',data={x:b.x,y:[[bt],[b_lmn[*,0]],[b_lmn[*,1]],[b_lmn[*,2]]]}
      options,'mms'+ref_probe+'_b_for_curlometer_lmn',constant=0.0,ytitle='MMS'+ref_probe+'!C'+inst+'_'+fgm_data_rate+'!CLMN',ysubtitle='[nT]',colors=[2,4,6],labels=['B!DL!N','B!DM!N','B!DN!N'],labflag=-1,datagap=0.13d
      options,'mms'+ref_probe+'_b_for_curlometer_tlmn',constant=0.0,ytitle='MMS'+ref_probe+'!C'+inst+'_'+fgm_data_rate+'!CLMN',ysubtitle='[nT]',colors=[0,2,4,6],labels=['|B|','B!DL!N','B!DM!N','B!DN!N'],labflag=-1,datagap=0.13d
      undefine,b

    endif else begin
      calc,"'mms_avg_pos'=('mms1_pos_for_curlometer'+'mms2_pos_for_curlometer'+'mms3_pos_for_curlometer'+'mms4_pos_for_curlometer')/4.d"
      if coord eq 'gse' then begin
        cotrans,'mms_avg_pos','mms_avg_pos_gsm',/gse2gsm
        cotrans,ji,ji_gsm,time,/gse2gsm
;        for p=1,4 do cotrans,'mms'+strcompress(string(p),/remove_all)+'_b_for_curlometer','mms'+strcompress(string(p),/remove_all)+'_b_for_curlometer_gsm',/gse2gsm
        cotrans,'mms'+ref_probe+'_b_for_curlometer','mms'+ref_probe+'_b_for_curlometer_gsm',/gse2gsm
      endif else begin
;        for p=1,4 do copy_data,'mms'+strcompress(string(p),/remove_all)+'_b_for_curlometer','mms'+strcompress(string(p),/remove_all)+'_b_for_curlometer_gsm'
        copy_data,'mms'+ref_probe+'_b_for_curlometer','mms'+ref_probe+'_b_for_curlometer_gsm'
        copy_data,'mms_avg_pos','mms_avg_pos_gsm'
        ji_gsm=ji
      endelse
      store_data,'mms_avg_pos',/delete
      get_data,'mms_avg_pos_gsm',data=pos
      gsm2lmn,[[pos.x],[pos.y[*,0]],[pos.y[*,1]],[pos.y[*,2]]],ji_gsm,ji_lmn
      
;      for p=1,4 do begin
;        get_data,'mms'+strcompress(string(p),/remove_all)+'_b_for_curlometer_gsm',data=b
;        for i=0l,n_elements(time)-1 do bt[i]=norm(reform(b.y[i,*]),/double)
;        gsm2lmn,[[pos.x],[pos.y[*,0]],[pos.y[*,1]],[pos.y[*,2]]],b.y,b_lmn
;        store_data,'mms'+strcompress(string(p),/remove_all)+'_b_for_curlometer_lmn',data={x:b.x,y:b_lmn}
;        store_data,'mms'+strcompress(string(p),/remove_all)+'_b_for_curlometer_tlmn',data={x:b.x,y:[[bt],[b_lmn[*,0]],[b_lmn[*,1]],[b_lmn[*,2]]]}
;        options,'mms'+strcompress(string(p),/remove_all)+'_b_for_curlometer_lmn',constant=0.0,ytitle='MMS'+strcompress(string(p),/remove_all)+'!CFGM_'+fgm_data_rate+'!CLMN',ysubtitle='[nT]',colors=[2,4,6],labels=['B!DL!N','B!DM!N','B!DN!N'],labflag=-1,datagap=0.13d
;        options,'mms'+strcompress(string(p),/remove_all)+'_b_for_curlometer_tlmn',constant=0.0,ytitle='MMS'+strcompress(string(p),/remove_all)+'!CFGM_'+fgm_data_rate+'!CLMN',ysubtitle='[nT]',colors=[0,2,4,6],labels=['|B|','B!DL!N','B!DM!N','B!DN!N'],labflag=-1,datagap=0.13d
;      endfor
      
      get_data,'mms'+ref_probe+'_b_for_curlometer_gsm',data=b
      for i=0l,n_elements(time)-1 do bt[i]=norm(reform(b.y[i,*]),/double)
      gsm2lmn,[[pos.x],[pos.y[*,0]],[pos.y[*,1]],[pos.y[*,2]]],b.y,b_lmn
      store_data,'mms'+ref_probe+'_b_for_curlometer_lmn',data={x:b.x,y:b_lmn}
      store_data,'mms'+ref_probe+'_b_for_curlometer_tlmn',data={x:b.x,y:[[bt],[b_lmn[*,0]],[b_lmn[*,1]],[b_lmn[*,2]]]}
      options,'mms'+ref_probe+'_b_for_curlometer_lmn',constant=0.0,ytitle='MMS'+ref_probe+'!C'+inst+'_'+fgm_data_rate+'!CLMN',ysubtitle='[nT]',colors=[2,4,6],labels=['B!DL!N','B!DM!N','B!DN!N'],labflag=-1,datagap=0.13d
      options,'mms'+ref_probe+'_b_for_curlometer_tlmn',constant=0.0,ytitle='MMS'+ref_probe+'!C'+inst+'_'+fgm_data_rate+'!CLMN',ysubtitle='[nT]',colors=[0,2,4,6],labels=['|B|','B!DL!N','B!DM!N','B!DN!N'],labflag=-1,datagap=0.13d
      
      undefine,pos,ji,ji_gsm,b
    endelse
    store_data,'Current_lmn',data={x:time,y:ji_lmn}
    options,'Current_lmn',constant=0.0,ytitle='Current!CDensity!CLMN',ysubtitle='[nA/m!U2!N]',colors=[2,4,6],labels=['J!DL!N','J!DM!N','J!DN!N'],labflag=-1,datagap=0.13d
  endif

  if not undefined(plot) then begin
    tkm2re,'mms'+ref_probe+'_mec_r_'+coord
    split_vec,'mms'+ref_probe+'_mec_r_'+coord+'_re'
    options,'mms'+ref_probe+'_mec_r_'+coord+'_re_x',ytitle='MMS'+ref_probe+' '+strupcase(coord)+'X [R!DE!N]',format='(f8.4)'
    options,'mms'+ref_probe+'_mec_r_'+coord+'_re_y',ytitle='MMS'+ref_probe+' '+strupcase(coord)+'Y [R!DE!N]',format='(f8.4)'
    options,'mms'+ref_probe+'_mec_r_'+coord+'_re_z',ytitle='MMS'+ref_probe+' '+strupcase(coord)+'Z [R!DE!N]',format='(f8.4)'
    tplot_options,var_label=['mms'+ref_probe+'_mec_r_'+coord+'_re_z','mms'+ref_probe+'_mec_r_'+coord+'_re_y','mms'+ref_probe+'_mec_r_'+coord+'_re_x']
    tplot_options,'xmargin',[15,10]
    options,'mms'+ref_probe+'_b_for_curlometer',labflag=-1
    if undefined(lmn) then begin
      tplot,['mms'+ref_probe+'_b_for_curlometer','Current_'+coord,'Current_magnitude','divB_over_rotB']
    endif else begin
      tplot,['mms'+ref_probe+'_b_for_curlometer_tlmn','Current_lmn','Current_magnitude','divB_over_rotB']
    endelse
  endif
  
end
