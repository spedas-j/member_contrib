;+
; PROCEDURE:
;         mms_pos_fgm_all_kitamura
;
; PURPOSE:
;         Plot relative positions of MMS
;
; KEYWORDS:
;         trange:       time range of interest [starttime, endtime] with the format
;                       ['YYYY-MM-DD','YYYY-MM-DD'] or to specify more or less than a day
;                       ['YYYY-MM-DD/hh:mm:ss','YYYY-MM-DD/hh:mm:ss']
;         probe_orig:   the probe at the origin of relative position and the standard of
;                       the field aligned coordinate. if no probe is specified the default
;                       is probe '0' (averaged position of all probes). if probe is '0',
;                       the field aligned coordinate is defined using the average of the
;                       magnetic field observed by all probes (0.5 sec averaged)
;         smmoth_p:     the period of magnetic field smoothing (in seconds) to calculate
;                       magnetic field aligned coordinates (default value is 20 sec)
;         no_load:      set this flag to skip load dfg data
;         dfg_l2pre:    set this flag to use DFG l2pre data. if not set, FGM l2 data
;                       is used
;         no_update:    set this flag to preserve the original data. if not set and newer
;                       data is found the existing data will be overwritten
;         delete:       set this flag to delete all data before run
;         plot_fgm:     set this flag to plot FGM(DFG) data (GSE or GSM coordinate)
;         fac:          set this flag to plot FGM(DFG) data in the fac coordinate
;         gsm:          set this flag to plot FGM(DFG) data in the GSM coordinate
;         gradB:        set this flag to calculate gradient of FGM(DFG) data
;
; EXAMPLE:
;
;     To plot relative positions from the averaged position of all probes and FGM(DFG) data 
;     MMS>  mms_pos_fgm_all_kitamura,['2015-09-01/12:00:00','2015-09-01/15:00:00'],probe_orig='0',smooth_p=20.d,/plot_fgm
;     MMS>  mms_pos_fgm_all_kitamura,['2015-09-01/12:00:00','2015-09-01/15:00:00'],probe_orig='0',smooth_p=20.d,/plot_fgm,/no_update
;
; NOTES:
;     1) See the notes in mms_load_data for rules on the use of MMS data
;-

pro mms_pos_fgm_all_kitamura,trange,probe_orig=probe_orig,smooth_p=smooth_p,no_load=no_load,dfg_l2pre=dfg_l2pre,no_update=no_update,delete=delete,plot_fgm=plot_fgm,fac=fac,gsm=gsm,gradB=gradB

  mms_init
;  mstart=time_double(time_string(trange[0],format=0,precision=-3))
  timespan,trange[0],(time_double(trange[1])-time_double(trange[0]))/3600.d,/hours
  probes=['1','2','3','4']
  
  if undefined(smooth_p) then smooth_p=0.d
  if not undefined(delete) then store_data,'*',/delete
  if undefined(probe_orig) then probe_orig='0'
  if undefined(gsm) then coord='gse' else coord='gsm'
  if undefined(no_load) then begin
    if not undefined(dfg_l2pre) then begin
      mms_load_fgm,trange=trange,instrument='dfg',probes=probes,data_rate='srvy',level='l2pre',no_update=no_update
      name_level='dfg_b_'+coord+'_srvy_l2pre_bvec'
      name_level2='dfg_b_'+coord+'_srvy_l2pre_btot'
      inst='DFG'
    endif else begin
      mms_load_fgm,trange=trange,instrument='fgm',probes=probes,data_rate='srvy',level='l2',no_update=no_update
      name_level='fgm_b_'+coord+'_srvy_l2_bvec'
      name_level2='fgm_b_'+coord+'_srvy_l2_btot'
      inst='FGM'
    endelse
  endif else begin
    if undefined(dfg_l2pre) then begin
      name_level='dfg_b_'+coord+'_srvy_l2pre_bvec'
      name_level2='dfg_b_'+coord+'_srvy_l2pre_btot'
      inst='DFG'
    endif else begin
      name_level='fgm_b_'+coord+'_srvy_l2_bvec'
      name_level2='fgm_b_'+coord+'_srvy_l2_btot'
      inst='FGM'
    endelse
  endelse

  if not undefined(gradB) then begin
    for p=1,4 do avg_data,'mms'+strcompress(string(p),/remove_all)+'_'+name_level2,0.125d,trange=trange
    if smooth_p gt 0.d then for p=1,4 do tsmooth_in_time,'mms'+strcompress(string(p),/remove_all)+'_'+name_level2+'_avg',smooth_p,newname='mms'+strcompress(string(p),/remove_all)+'_'+name_level2+'_smoothed'
    if smooth_p gt 0.d then suf_gB='_smoothed' else suf_gB='_avg'
  endif

  if fix(probe_orig) eq 0 then begin
    probe=''
    for p=1,4 do avg_data,'mms'+strcompress(string(p),/remove_all)+'_'+name_level,0.125d,trange=trange
    calc,'"mms_'+name_level+'_avg"=("mms1_'+name_level+'_avg"+"mms2_'+name_level+'_avg"+"mms3_'+name_level+'_avg"+"mms4_'+name_level+'_avg")/4.d'
    if smooth_p gt 0.d then tsmooth_in_time,'mms_'+name_level+'_avg',smooth_p,newname='mms_'+name_level+'_smoothed'
    if smooth_p gt 0.d then suf='_smoothed' else suf='_avg'
  endif else begin
    probe=strcompress(string(probe_orig),/remove_all)
    if smooth_p gt 0.d then tsmooth_in_time,'mms'+strcompress(string(probe_orig),/remove_all)+'_'+name_level,smooth_p,newname='mms_'+name_level+'_smoothed'
    copy_data,'mms'+probe+'_'+name_level,'mms_'+name_level
    suf=''
  endelse

  if undefined(no_load) then mms_load_mec,trange=trange,probes=probes,no_update=no_update,varformat=['mms'+probes+'_mec_r_eci','mms'+probes+'_mec_r_gse','mms'+probes+'_mec_r_gsm','mms'+probes+'_mec_L_vec']

  for p=1,4 do tinterpol_mxn,'mms'+strcompress(string(p),/remove_all)+'_mec_r_'+coord,'mms_'+name_level+suf,/overwrite

  get_data,'mms1_mec_r_'+coord,data=pos1
  get_data,'mms2_mec_r_'+coord,data=pos2
  get_data,'mms3_mec_r_'+coord,data=pos3
  get_data,'mms4_mec_r_'+coord,data=pos4
  case fix(probe_orig) of
    0: origin=(pos1.y+pos2.y+pos3.y+pos4.y)/4.d
    1: origin=pos1.y
    2: origin=pos2.y
    3: origin=pos3.y
    4: origin=pos4.y
  endcase
  origin_r=sqrt(origin[*,0]^2.d + origin[*,1]^2.d + origin[*,2]^2.d)
  store_data,'mms_mec_r_'+coord,data={x:pos1.x,y:[[origin[*,0]],[origin[*,1]],[origin[*,2]],[origin_r]]}
  store_data,'mms1_relpos_'+coord,data={x:pos1.x,y:pos1.y[*,0:2]-origin[*,0:2]}
  store_data,'mms2_relpos_'+coord,data={x:pos2.x,y:pos2.y[*,0:2]-origin[*,0:2]}
  store_data,'mms3_relpos_'+coord,data={x:pos3.x,y:pos3.y[*,0:2]-origin[*,0:2]}
  store_data,'mms4_relpos_'+coord,data={x:pos4.x,y:pos4.y[*,0:2]-origin[*,0:2]}
  store_data,'mms_relpos_'+coord+'_x',data={x:pos1.x,y:[[pos1.y[*,0]-origin[*,0]],[pos2.y[*,0]-origin[*,0]],[pos3.y[*,0]-origin[*,0]],[pos4.y[*,0]-origin[*,0]]]}
  store_data,'mms_relpos_'+coord+'_y',data={x:pos1.x,y:[[pos1.y[*,1]-origin[*,1]],[pos2.y[*,1]-origin[*,1]],[pos3.y[*,1]-origin[*,1]],[pos4.y[*,1]-origin[*,1]]]}
  store_data,'mms_relpos_'+coord+'_z',data={x:pos1.x,y:[[pos1.y[*,2]-origin[*,2]],[pos2.y[*,2]-origin[*,2]],[pos3.y[*,2]-origin[*,2]],[pos4.y[*,2]-origin[*,2]]]}
  store_data,'mms_relpos_'+coord+'_r',data={x:pos1.x,y:[[sqrt((pos1.y[*,0]-origin[*,0])^2.d +(pos1.y[*,1]-origin[*,1])^2.d +(pos1.y[*,2]-origin[*,2])^2.d)], $
                                                        [sqrt((pos2.y[*,0]-origin[*,0])^2.d +(pos2.y[*,1]-origin[*,1])^2.d +(pos2.y[*,2]-origin[*,2])^2.d)], $
                                                        [sqrt((pos3.y[*,0]-origin[*,0])^2.d +(pos3.y[*,1]-origin[*,1])^2.d +(pos3.y[*,2]-origin[*,2])^2.d)], $
                                                        [sqrt((pos4.y[*,0]-origin[*,0])^2.d +(pos4.y[*,1]-origin[*,1])^2.d +(pos4.y[*,2]-origin[*,2])^2.d)]]}
  options,'mms1_relpos_'+coord,constant=0.0,colors=[2,4,6],ytitle='mms1_ql!CRelative!CPosition!C'+strupcase(coord),ysubtitle='[km]',labels=['x','y','z'],labflag=-1
  options,'mms2_relpos_'+coord,constant=0.0,colors=[2,4,6],ytitle='mms2_ql!CRelative!CPosition!C'+strupcase(coord),ysubtitle='[km]',labels=['x','y','z'],labflag=-1
  options,'mms3_relpos_'+coord,constant=0.0,colors=[2,4,6],ytitle='mms3_ql!CRelative!CPosition!C'+strupcase(coord),ysubtitle='[km]',labels=['x','y','z'],labflag=-1
  options,'mms4_relpos_'+coord,constant=0.0,colors=[2,4,6],ytitle='mms4_ql!CRelative!CPosition!C'+strupcase(coord),ysubtitle='[km]',labels=['x','y','z'],labflag=-1
  options,'mms_relpos_'+coord+'_x',constant=0.0,colors=[0,6,4,2],ytitle='Relative!CPosition!C'+strupcase(coord)+' X',ysubtitle='[km]',labels=['mms1','mms2','mms3','mms4'],labflag=-1
  options,'mms_relpos_'+coord+'_y',constant=0.0,colors=[0,6,4,2],ytitle='Relative!CPosition!C'+strupcase(coord)+' Y',ysubtitle='[km]',labels=['mms1','mms2','mms3','mms4'],labflag=-1
  options,'mms_relpos_'+coord+'_z',constant=0.0,colors=[0,6,4,2],ytitle='Relative!CPosition!C'+strupcase(coord)+' Z',ysubtitle='[km]',labels=['mms1','mms2','mms3','mms4'],labflag=-1
  options,'mms_relpos_'+coord+'_r',constant=0.0,colors=[0,6,4,2],ytitle='Distance!Cfrom!COrigin',ysubtitle='[km]',labels=['mms1','mms2','mms3','mms4'],labflag=-1
  undefine,pos1,pos2,pos3,pos4

  if not undefined(gradB) then begin
    get_data,'mms1_'+name_level2+suf_gB,data=btot1
    get_data,'mms2_'+name_level2+suf_gB,data=btot2
    get_data,'mms3_'+name_level2+suf_gB,data=btot3
    get_data,'mms4_'+name_level2+suf_gB,data=btot4
    for p=1,4 do tinterpol_mxn,'mms'+strcompress(string(p),/remove_all)+'_mec_r_'+coord,'mms'+strcompress(string(p),/remove_all)+'_'+name_level2+suf_gB,newname='mms'+strcompress(string(p),/remove_all)+'_mec_r_'+coord+'_intpl'
    get_data,'mms1_mec_r_'+coord+'_intpl',data=pos1
    get_data,'mms2_mec_r_'+coord+'_intpl',data=pos2
    get_data,'mms3_mec_r_'+coord+'_intpl',data=pos3
    get_data,'mms4_mec_r_'+coord+'_intpl',data=pos4
    if fix(probe_orig) ne 0 then begin
      for p=1,4 do avg_data,'mms'+strcompress(string(p),/remove_all)+'_'+name_level,0.125d,trange=trange
      calc,'"mms_'+name_level+'_avg"=("mms1_'+name_level+'_avg"+"mms2_'+name_level+'_avg"+"mms3_'+name_level+'_avg"+"mms4_'+name_level+'_avg")/4.d'
      if smooth_p gt 0.d then tsmooth_in_time,'mms_'+name_level+'_avg',smooth_p,newname='mms_'+name_level+'_smoothed'
      if smooth_p gt 0.d then get_data,'mms_'+name_level+'_smoothed',data=bvec_avg else get_data,'mms_'+name_level+'_avg',data=bvec_avg
    endif else begin
      get_data,'mms_'+name_level+suf,data=bvec_avg
    endelse
    grad_B=dblarr(n_elements(btot1.x),3)
    grad_B_para=dblarr(n_elements(btot1.x))
    for i=0,n_elements(btot1.x)-1 do begin
      mat=[[pos2.y[i,0]-pos1.y[i,0],pos2.y[i,1]-pos1.y[i,1],pos2.y[i,2]-pos1.y[i,2]],[pos3.y[i,0]-pos1.y[i,0],pos3.y[i,1]-pos1.y[i,1],pos3.y[i,2]-pos1.y[i,2]],[pos4.y[i,0]-pos1.y[i,0],pos4.y[i,1]-pos1.y[i,1],pos4.y[i,2]-pos1.y[i,2]]]
      gB=invert(mat)##[[btot2.y[i]-btot1.y[i]],[btot3.y[i]-btot1.y[i]],[btot4.y[i]-btot1.y[i]]]
      for j=0,2 do grad_B[i,j]=gb[j]*1000.d
      grad_B_para[i]=grad_B[i,0]*bvec_avg.y[i,0]/norm(reform(bvec_avg.y[i,*]),/double)+grad_B[i,1]*bvec_avg.y[i,1]/norm(reform(bvec_avg.y[i,*]),/double)+grad_B[i,2]*bvec_avg.y[i,2]/norm(reform(bvec_avg.y[i,*]),/double)
    endfor
    store_data,'mms_gradB_'+coord,data={x:btot1.x,y:grad_B}
    options,'mms_gradB_'+coord,constant=0.0,colors=[2,4,6],ytitle='mms_gradB!C'+strupcase(coord),ysubtitle='[pT/km]',labels=['x','y','z'],labflag=-1
    store_data,'mms_gradB_para',data={x:btot1.x,y:grad_B_para}
    options,'mms_gradB_para',constant=0.0,colors=1,ytitle='mms_gradB!CParallel',ysubtitle='[pT/km]'
  endif

  if not undefined(fac) then begin
    for p=1,4 do begin
      if fix(probe_orig) ne 0 then begin
        tinterpol_mxn,'mms'+strcompress(string(p),/remove_all)+'_'+name_level,'mms'+strcompress(string(p),/remove_all)+'_'+name_level,newname='mms'+strcompress(string(p),/remove_all)+'_fgm_srvy_'+coord+'_bvec_intpl'
        get_data,'mms'+strcompress(string(p),/remove_all)+'_fgm_srvy_'+coord+'_bvec_intpl',data=B
      endif else begin
        get_data,'mms'+strcompress(string(p),/remove_all)+'_'+name_level,data=B
      endelse
      tinterpol_mxn,'mms_'+name_level+suf,'mms'+strcompress(string(p),/remove_all)+'_'+name_level,newname='mms_fgm_srvy_'+coord+'_bvec_smoothed_intpl'
      get_data,'mms_fgm_srvy_'+coord+'_bvec_smoothed_intpl',data=smoothed_B
      B_fac=dblarr(n_elements(B.x),3)
      B_hpfilt=dblarr(n_elements(B.x),3)
      rpos_fac=dblarr(n_elements(B.x),3)
      if smooth_p gt 0.d then begin
        tsmooth_in_time,'mms'+strcompress(string(p),/remove_all)+'_'+name_level,smooth_p
        tinterpol_mxn,'mms'+strcompress(string(p),/remove_all)+'_'+name_level+'_smoothed','mms'+strcompress(string(p),/remove_all)+'_'+name_level,/overwrite
        get_data,'mms'+strcompress(string(p),/remove_all)+'_'+name_level+'_smoothed',data=smoothed_Bs
      endif
      tinterpol_mxn,'mms_mec_r_'+coord,'mms'+strcompress(string(p),/remove_all)+'_'+name_level,newname='mms_mec_r_'+coord+'_intpl'
      get_data,'mms_mec_r_'+coord+'_intpl',data=pos
      tinterpol_mxn,'mms'+strcompress(string(p),/remove_all)+'_relpos_'+coord,'mms'+strcompress(string(p),/remove_all)+'_'+name_level,newname='mms'+strcompress(string(p),/remove_all)+'_relpos_'+coord+'_intpl'
      get_data,'mms'+strcompress(string(p),/remove_all)+'_relpos_'+coord+'_intpl',data=rpos
      for j=0l,n_elements(smoothed_Bs.x)-1 do begin
        pos_m=norm(reform(pos.y[j,*]),/double)
        n_pos=reform([[pos.y[j,0]/pos_m],[pos.y[j,1]/pos_m],[pos.y[j,2]/pos_m]])
        smB_m=norm(reform(smoothed_B.y[j,*]),/double)
        fac_nz=[smoothed_B.y[j,0]/smB_m,smoothed_B.y[j,1]/smB_m,smoothed_B.y[j,2]/smB_m]
        fac_ny=crossp(fac_nz,[1.d,0.d,0.d])/norm(reform(crossp(fac_nz,[1.d,0.d,0.d])),/double)
        fac_nx=crossp(fac_ny,fac_nz)
        B_fac[j,0]=B.y[j,*]#fac_nx
        B_fac[j,1]=B.y[j,*]#fac_ny
        B_fac[j,2]=B.y[j,*]#fac_nz
        if smooth_p gt 0.d then begin
          B_hpfilt[j,0]=(B.y[j,*]-smoothed_Bs.y[j,*])#fac_nx
          B_hpfilt[j,1]=(B.y[j,*]-smoothed_Bs.y[j,*])#fac_ny
          B_hpfilt[j,2]=(B.y[j,*]-smoothed_Bs.y[j,*])#fac_nz
        endif 
        rpos_fac[j,0]=rpos.y[j,*]#fac_nx
        rpos_fac[j,1]=rpos.y[j,*]#fac_ny
        rpos_fac[j,2]=rpos.y[j,*]#fac_nz
      endfor
      store_data,'mms'+strcompress(string(p),/remove_all)+'_fgm_srvy_fac',data={x:B.x,y:B_fac}
      store_data,'mms'+strcompress(string(p),/remove_all)+'_fgm_srvy_fac_hpfilt',data={x:B.x,y:B_hpfilt}
      store_data,'mms'+strcompress(string(p),/remove_all)+'_relpos_fac',data={x:rpos.x,y:rpos_fac}
      split_vec,'mms'+strcompress(string(p),/remove_all)+'_relpos_fac'
      split_vec,'mms'+strcompress(string(p),/remove_all)+'_fgm_srvy_fac'
      split_vec,'mms'+strcompress(string(p),/remove_all)+'_fgm_srvy_fac_hpfilt'
    endfor
    options,'mms*_fgm_srvy_fac',constant=0.0
    options,'mms*_fgm_srvy_fac_hpfilt',constant=0.0,colors=[2,4,6],labels=['fac_dBx','fac_dBy','fac_dBz'],labflag=-1

    store_data,'mms_relpos_fac_x',data=['mms1_relpos_fac_x','mms2_relpos_fac_x','mms3_relpos_fac_x','mms4_relpos_fac_x']
    store_data,'mms_relpos_fac_y',data=['mms1_relpos_fac_y','mms2_relpos_fac_y','mms3_relpos_fac_y','mms4_relpos_fac_y']
    store_data,'mms_relpos_fac_z',data=['mms1_relpos_fac_z','mms2_relpos_fac_z','mms3_relpos_fac_z','mms4_relpos_fac_z']

    options,'mms1_relpos_fac',constant=0.0,colors=[2,4,6],ytitle='mms1_ql!CRelative!CPosition!CFAC',ysubtitle='[km]',labels=['x','y','z'],labflag=-1
    options,'mms2_relpos_fac',constant=0.0,colors=[2,4,6],ytitle='mms2_ql!CRelative!CPosition!CFAC',ysubtitle='[km]',labels=['x','y','z'],labflag=-1
    options,'mms3_relpos_fac',constant=0.0,colors=[2,4,6],ytitle='mms3_ql!CRelative!CPosition!CFAC',ysubtitle='[km]',labels=['x','y','z'],labflag=-1
    options,'mms4_relpos_fac',constant=0.0,colors=[2,4,6],ytitle='mms4_ql!CRelative!CPosition!CFAC',ysubtitle='[km]',labels=['x','y','z'],labflag=-1
    options,'mms_relpos_fac_x',constant=0.0,colors=[0,6,4,2],ytitle='Relative!CPosition!CFAC X',ysubtitle='[km]',labels=['mms1','mms2','mms3','mms4'],labflag=-1
    options,'mms_relpos_fac_y',constant=0.0,colors=[0,6,4,2],ytitle='Relative!CPosition!CFAC Y',ysubtitle='[km]',labels=['mms1','mms2','mms3','mms4'],labflag=-1
    options,'mms_relpos_fac_z',constant=0.0,colors=[0,6,4,2],ytitle='Relative!CPosition!CFAC Z',ysubtitle='[km]',labels=['mms1','mms2','mms3','mms4'],labflag=-1
  endif

  tkm2re,'mms_mec_r_'+coord
  split_vec,'mms_mec_r_'+coord+'_re'
  options,'mms_mec_r_'+coord+'_re_0',ytitle='MMS'+probe+' '+strupcase(coord)+'X [RE]',format='(f7.3)'
  options,'mms_mec_r_'+coord+'_re_1',ytitle='MMS'+probe+' '+strupcase(coord)+'Y [RE]',format='(f7.3)'
  options,'mms_mec_r_'+coord+'_re_2',ytitle='MMS'+probe+' '+strupcase(coord)+'Z [RE]',format='(f7.3)'
  options,'mms_mec_r_'+coord+'_re_3',ytitle='MMS'+probe+' R [RE]',format='(f7.3)'
  
  tplot_options, var_label=['mms_mec_r_'+coord+'_re_3','mms_mec_r_'+coord+'_re_2','mms_mec_r_'+coord+'_re_1','mms_mec_r_'+coord+'_re_0']

  loadct2,43
  time_stamp,/off
  tplot_options,'xmargin',[20,10]

  if undefined(plot_fgm) then begin
;    tplot,['mms?_'+name_level,'mms?_fgm_srvy_fac_hpfilt','mms?_relpos_fac','mms?_relpos_'+coord,'mms_relpos_'+coord+'_?']
;    tplot,['mms?_'+name_level,'mms?_fgm_srvy_fac_hpfilt','mms_fgm_srvy_fac_hpfilt_?','mms?_relpos_fac','mms?_relpos_'+coord,'mms_relpos_'+coord+'_?']
;    tplot,['mms?_fgm_srvy_fac_hpfilt','mms_fgm_srvy_fac_hpfilt_?','mms_relpos_fac_?']
    if not undefined(gradB) then begin
      store_data,'mms_'+name_level2+suf_gB,data=['mms1_'+name_level2+suf_gB,'mms2_'+name_level2+suf_gB,'mms3_'+name_level2+suf_gB,'mms4_'+name_level2+suf_gB]
      options,'mms_'+name_level2+suf_gB,colors=[0,6,4,2],ytitle='MMS!C!C'+inst+'!C!CBtotal',ysubtitle='[nT]',labels=['mms1','mms2','mms3','mms4'],labflag=-1
      tplot,['mms_'+name_level2+suf_gB,'mms?_relpos_'+coord,'mms_relpos_'+coord+'_?','mms_gradB_'+coord,'mms_gradB_para']
    endif else begin
      tplot,['mms?_'+name_level,'mms?_relpos_'+coord,'mms_relpos_'+coord+'_?']
    endelse
  endif else begin
    if undefined(fac) then begin
      split_vec,'mms?_'+name_level
      store_data,'mms_'+name_level+'_x',data=['mms1_'+name_level+'_x','mms2_'+name_level+'_x','mms3_'+name_level+'_x','mms4_'+name_level+'_x']
      store_data,'mms_'+name_level+'_y',data=['mms1_'+name_level+'_y','mms2_'+name_level+'_y','mms3_'+name_level+'_y','mms4_'+name_level+'_y']
      store_data,'mms_'+name_level+'_z',data=['mms1_'+name_level+'_z','mms2_'+name_level+'_z','mms3_'+name_level+'_z','mms4_'+name_level+'_z']
      store_data,'mms_'+name_level2,data=['mms1_'+name_level2,'mms2_'+name_level2,'mms3_'+name_level2,'mms4_'+name_level2]
      options,'mms_'+name_level+'_x',constant=0.0,colors=[0,6,4,2],ytitle='MMS!C'+inst+'!C'+strupcase(coord)+' X',ysubtitle='[nT]',labels=['mms1','mms2','mms3','mms4'],labflag=-1
      options,'mms_'+name_level+'_y',constant=0.0,colors=[0,6,4,2],ytitle='MMS!C'+inst+'!C'+strupcase(coord)+' Y',ysubtitle='[nT]',labels=['mms1','mms2','mms3','mms4'],labflag=-1
      options,'mms_'+name_level+'_z',constant=0.0,colors=[0,6,4,2],ytitle='MMS!C'+inst+'!C'+strupcase(coord)+' Z',ysubtitle='[nT]',labels=['mms1','mms2','mms3','mms4'],labflag=-1
      options,'mms_'+name_level2,colors=[0,6,4,2],ytitle='MMS!C'+inst+'!CBtotal',ysubtitle='[nT]',labels=['mms1','mms2','mms3','mms4'],labflag=-1
      tplot,['mms_'+name_level2,'mms_'+name_level+'_?','mms_relpos_'+coord+'_?']
    endif else begin
      store_data,'mms_fgm_srvy_fac_x',data=['mms1_fgm_srvy_fac_x','mms2_fgm_srvy_fac_x','mms3_fgm_srvy_fac_x','mms4_fgm_srvy_fac_x']
      store_data,'mms_fgm_srvy_fac_y',data=['mms1_fgm_srvy_fac_y','mms2_fgm_srvy_fac_y','mms3_fgm_srvy_fac_y','mms4_fgm_srvy_fac_y']
      store_data,'mms_fgm_srvy_fac_z',data=['mms1_fgm_srvy_fac_z','mms2_fgm_srvy_fac_z','mms3_fgm_srvy_fac_z','mms4_fgm_srvy_fac_z']
      options,'mms_fgm_srvy_fac_x',constant=0.0,colors=[0,6,4,2],ytitle='MMS!C'+inst+'!CFAC X',ysubtitle='[nT]',labels=['mms1','mms2','mms3','mms4'],labflag=-1
      options,'mms_fgm_srvy_fac_y',constant=0.0,colors=[0,6,4,2],ytitle='MMS!C'+inst+'!CFAC Y',ysubtitle='[nT]',labels=['mms1','mms2','mms3','mms4'],labflag=-1
      options,'mms_fgm_srvy_fac_z',constant=0.0,colors=[0,6,4,2],ytitle='MMS!C'+inst+'!CFAC Z',ysubtitle='[nT]',labels=['mms1','mms2','mms3','mms4'],labflag=-1
      store_data,'mms_fgm_srvy_fac_hpfilt_x',data=['mms1_fgm_srvy_fac_hpfilt_x','mms2_fgm_srvy_fac_hpfilt_x','mms3_fgm_srvy_fac_hpfilt_x','mms4_fgm_srvy_fac_hpfilt_x']
      store_data,'mms_fgm_srvy_fac_hpfilt_y',data=['mms1_fgm_srvy_fac_hpfilt_y','mms2_fgm_srvy_fac_hpfilt_y','mms3_fgm_srvy_fac_hpfilt_y','mms4_fgm_srvy_fac_hpfilt_y']
      store_data,'mms_fgm_srvy_fac_hpfilt_z',data=['mms1_fgm_srvy_fac_hpfilt_z','mms2_fgm_srvy_fac_hpfilt_z','mms3_fgm_srvy_fac_hpfilt_z','mms4_fgm_srvy_fac_hpfilt_z']
      options,'mms_fgm_srvy_fac_hpfilt_x',constant=0.0,colors=[0,6,4,2],ytitle='MMS!C'+inst+'!CFAC X',ysubtitle='[nT]',labels=['mms1','mms2','mms3','mms4'],labflag=-1
      options,'mms_fgm_srvy_fac_hpfilt_y',constant=0.0,colors=[0,6,4,2],ytitle='MMS!C'+inst+'!CFAC Y',ysubtitle='[nT]',labels=['mms1','mms2','mms3','mms4'],labflag=-1
      options,'mms_fgm_srvy_fac_hpfilt_z',constant=0.0,colors=[0,6,4,2],ytitle='MMS!C'+inst+'!CFAC Z',ysubtitle='[nT]',labels=['mms1','mms2','mms3','mms4'],labflag=-1
      store_data,'mms_'+name_level2,data=['mms1_'+name_level2,'mms2_'+name_level2,'mms3_'+name_level2,'mms4_'+name_level2]
      options,'mms_'+name_level2,colors=[0,6,4,2],ytitle='MMS!C'+inst+'!CBtotal',ysubtitle='[nT]',labels=['mms1','mms2','mms3','mms4'],labflag=-1
      tplot,['mms_'+name_level2,'mms_fgm_srvy_fac_hpfilt_?','mms_relpos_fac_?']
    endelse
  endelse
  
end