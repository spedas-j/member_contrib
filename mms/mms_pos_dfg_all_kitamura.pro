;+
; PROCEDURE:
;         mms_pos_dfg_all_kitamura
;
; PURPOSE:
;         Plot relative positions of MMS
;
; KEYWORDS:
;         trange:       time range of interest [starttime, endtime] with the format
;                       ['YYYY-MM-DD','YYYY-MM-DD'] or to specify more or less than a day
;                       ['YYYY-MM-DD/hh:mm:ss','YYYY-MM-DD/hh:mm:ss']
;         probe:        the probe at the origin of relative position and the standard of
;                       the field aligned coordinate. if no probe is specified the default
;                       is probe '0' (averaged position of all probes). if probe is '0',
;                       the field aligned coordinate is defined using the average of the
;                       magnetic field observed by all probes (0.5 sec averaged)
;         smmoth_p:     the period of magnetic field smoothing (in seconds) to calculate
;                       magnetic field aligned coordinates (default value is 40 sec)
;         no_load:      set this flag to skip load dfg data
;         dfg_ql:       set this flag to use dfg ql data forcibly. if not set, l2pre data
;                       is used, if available
;         no_update:    set this flag to preserve the original data. if not set and newer
;                       data is found the existing data will be overwritten
;         delete:       set this flag to delete all data before run
;         plot_dfg:     set this flag to plot DFG data (GSE coordinate)
;         fac:          set this flag to plot DFG data in the fac coordinate
;
; EXAMPLE:
;
;     To plot relative positions from the averaged position of all probes and DFG data 
;     MMS>  mms_pos_dfg_all_kitamura,['2015-09-01/12:00:00','2015-09-01/15:00:00'],probe_orig='0',smooth_p=40.d,/plot_dfg
;     MMS>  mms_pos_dfg_all_kitamura,['2015-09-01/12:00:00','2015-09-01/15:00:00'],probe_orig='0',smooth_p=40.d,/plot_dfg,/no_update
;
; NOTES:
;     1) See the notes in mms_load_data for rules on the use of MMS data
;     2) Large memory space is necessary to use ql data (not recommended)
;-

pro mms_pos_dfg_all_kitamura,trange,probe_orig=probe_orig,smooth_p=smooth_p,no_load=no_load,dfg_ql=dfg_ql,no_update=no_update,delete=delete,plot_dfg=plot_dfg,fac=fac

  mms_init
;  mstart=time_double(time_string(trange[0],format=0,precision=-3))
  timespan,trange[0],(time_double(trange[1])-time_double(trange[0]))/3600.d,/hours
  
  if undefined(smooth_p) then smooth_p=40.d
  if not undefined(delete) then store_data,'*',/delete
  if undefined(probe_orig) then probe_orig='0'
  if undefined(no_load) then begin
    if undefined(dfg_ql) then mms_load_fgm,trange=trange,instrument='dfg',probes=['1','2','3','4'],data_rate='srvy',level='l2pre',no_update=no_update,/no_attitude_data
    if strlen(tnames('mms1_dfg_srvy_l2pre_gse')) eq 0 then begin
      mms_load_fgm,trange=trange,instrument='dfg',probes=['1','2','3','4'],data_rate='srvy',level='ql',no_update=no_update;,/no_attitude_data
      name_ql='_ql'
      name_level='srvy_gse_bvec'
      name_level2='srvy_gse_btot'
    endif else begin
      name_ql=''
      name_level='srvy_l2pre_gse_bvec'
      name_level2='srvy_l2pre_gse_btot'
    endelse
  endif else begin
    if undefined(dfg_ql) then begin
      name_ql=''
      name_level='srvy_l2pre_gse_bvec'      
      name_level2='srvy_l2pre_gse_btot'
    endif else begin
      name_ql='_ql'
      name_level='srvy_gse_bvec'
      name_level2='srvy_gse_btot'
    endelse
  endelse

  get_data,'mms1'+name_ql+'_pos_gse',data=pos1
  get_data,'mms2'+name_ql+'_pos_gse',data=pos2
  get_data,'mms3'+name_ql+'_pos_gse',data=pos3
  get_data,'mms4'+name_ql+'_pos_gse',data=pos4
  case fix(probe_orig) of
    0: origin=(pos1.y+pos2.y+pos3.y+pos4.y)/4.d
    1: origin=pos1.y
    2: origin=pos2.y
    3: origin=pos3.y
    4: origin=pos4.y
  endcase
  origin_r=sqrt(origin[*,0]^2.d + origin[*,1]^2.d + origin[*,2]^2.d)
  store_data,'mms'+name_ql+'_pos_gse',data={x:pos1.x,y:[[origin[*,0]],[origin[*,1]],[origin[*,2]],[origin_r]]}

  store_data,'mms1'+name_ql+'_relpos_gse',data={x:pos1.x,y:pos1.y[*,0:2]-origin[*,0:2]}
  store_data,'mms2'+name_ql+'_relpos_gse',data={x:pos2.x,y:pos2.y[*,0:2]-origin[*,0:2]}
  store_data,'mms3'+name_ql+'_relpos_gse',data={x:pos3.x,y:pos3.y[*,0:2]-origin[*,0:2]}
  store_data,'mms4'+name_ql+'_relpos_gse',data={x:pos4.x,y:pos4.y[*,0:2]-origin[*,0:2]}
  store_data,'mms'+name_ql+'_relpos_gse_x',data={x:pos1.x,y:[[pos1.y[*,0]-origin[*,0]],[pos2.y[*,0]-origin[*,0]],[pos3.y[*,0]-origin[*,0]],[pos4.y[*,0]-origin[*,0]]]}
  store_data,'mms'+name_ql+'_relpos_gse_y',data={x:pos1.x,y:[[pos1.y[*,1]-origin[*,1]],[pos2.y[*,1]-origin[*,1]],[pos3.y[*,1]-origin[*,1]],[pos4.y[*,1]-origin[*,1]]]}
  store_data,'mms'+name_ql+'_relpos_gse_z',data={x:pos1.x,y:[[pos1.y[*,2]-origin[*,2]],[pos2.y[*,2]-origin[*,2]],[pos3.y[*,2]-origin[*,2]],[pos4.y[*,2]-origin[*,2]]]}
  store_data,'mms'+name_ql+'_relpos_gse_r',data={x:pos1.x,y:[[sqrt((pos1.y[*,0]-origin[*,0])^2.d +(pos1.y[*,1]-origin[*,1])^2.d +(pos1.y[*,2]-origin[*,2])^2.d)], $
                                                     [sqrt((pos2.y[*,0]-origin[*,0])^2.d +(pos2.y[*,1]-origin[*,1])^2.d +(pos2.y[*,2]-origin[*,2])^2.d)], $
                                                     [sqrt((pos3.y[*,0]-origin[*,0])^2.d +(pos3.y[*,1]-origin[*,1])^2.d +(pos3.y[*,2]-origin[*,2])^2.d)], $
                                                     [sqrt((pos4.y[*,0]-origin[*,0])^2.d +(pos4.y[*,1]-origin[*,1])^2.d +(pos4.y[*,2]-origin[*,2])^2.d)]]}
  options,'mms1'+name_ql+'_relpos_gse',constant=0.0,colors=[2,4,6],ytitle='mms1_ql!CRelative!CPosition!CGSE',ysubtitle='[km]',labels=['x','y','z'],labflag=-1
  options,'mms2'+name_ql+'_relpos_gse',constant=0.0,colors=[2,4,6],ytitle='mms2_ql!CRelative!CPosition!CGSE',ysubtitle='[km]',labels=['x','y','z'],labflag=-1
  options,'mms3'+name_ql+'_relpos_gse',constant=0.0,colors=[2,4,6],ytitle='mms3_ql!CRelative!CPosition!CGSE',ysubtitle='[km]',labels=['x','y','z'],labflag=-1
  options,'mms4'+name_ql+'_relpos_gse',constant=0.0,colors=[2,4,6],ytitle='mms4_ql!CRelative!CPosition!CGSE',ysubtitle='[km]',labels=['x','y','z'],labflag=-1
  options,'mms'+name_ql+'_relpos_gse_x',constant=0.0,colors=[0,2,4,6],ytitle='Relative!CPosition!CGSE X',ysubtitle='[km]',labels=['mms1','mms2','mms3','mms4'],labflag=-1
  options,'mms'+name_ql+'_relpos_gse_y',constant=0.0,colors=[0,2,4,6],ytitle='Relative!CPosition!CGSE Y',ysubtitle='[km]',labels=['mms1','mms2','mms3','mms4'],labflag=-1
  options,'mms'+name_ql+'_relpos_gse_z',constant=0.0,colors=[0,2,4,6],ytitle='Relative!CPosition!CGSE Z',ysubtitle='[km]',labels=['mms1','mms2','mms3','mms4'],labflag=-1
  options,'mms'+name_ql+'_relpos_gse_r',constant=0.0,colors=[0,2,4,6],ytitle='Distance!Cfrom!COrigin',ysubtitle='[km]',labels=['mms1','mms2','mms3','mms4'],labflag=-1

  if fix(probe_orig) eq 0 then begin
    probe=''
    avg_data,'mms1_dfg_'+name_level,0.5d,trange=trange
    avg_data,'mms2_dfg_'+name_level,0.5d,trange=trange
    avg_data,'mms3_dfg_'+name_level,0.5d,trange=trange
    avg_data,'mms4_dfg_'+name_level,0.5d,trange=trange
    if name_level eq 'srvy_l2pre_gse_bvec' then begin
      calc,'"mms_dfg_srvy_l2pre_gse_bvec_avg"=("mms1_dfg_srvy_l2pre_gse_bvec_avg"+"mms2_dfg_srvy_l2pre_gse_bvec_avg"+"mms3_dfg_srvy_l2pre_gse_bvec_avg"+"mms4_dfg_srvy_l2pre_gse_bvec_avg")/4.d'
    endif else begin
      calc,'"mms_dfg_srvy_gse_bvec_avg"=("mms1_dfg_srvy_gse_bvec_avg"+"mms2_dfg_srvy_gse_bvec_avg"+"mms3_dfg_srvy_gse_bvec_avg"+"mms4_dfg_srvy_gse_bvec_avg")/4.d'
    endelse
    tsmooth_in_time,'mms_dfg_'+name_level+'_avg',smooth_p,newname='mms_dfg_srvy_gse_bvec_smoothed'
  endif else begin
    probe=strcompress(string(probe_orig),/rem)
    tsmooth_in_time,'mms'+probe+'_dfg_'+name_level,smooth_p,newname='mms_dfg_srvy_gse_bvec_smoothed'
    copy_data,'mms'+probe+'_dfg_'+name_level,'mms_dfg_'+name_level
  endelse

  for p=1,4 do begin
      tinterpol_mxn,'mms'+strcompress(string(p),/rem)+'_dfg_'+name_level,'mms'+strcompress(string(p),/rem)+'_dfg_'+name_level,newname='mms'+strcompress(string(p),/rem)+'_dfg_srvy_gse_bvec_intpl'
      get_data,'mms'+strcompress(string(p),/rem)+'_dfg_'+name_level,data=B
      tinterpol_mxn,'mms_dfg_srvy_gse_bvec_smoothed','mms'+strcompress(string(p),/rem)+'_dfg_'+name_level,newname='mms_dfg_srvy_gse_bvec_smoothed_intpl'
      get_data,'mms_dfg_srvy_gse_bvec_smoothed_intpl',data=smoothed_B
      B_fac=dblarr(n_elements(B.x),3)
      B_hpfilt=dblarr(n_elements(B.x),3)
      rpos_fac=dblarr(n_elements(B.x),3)
      tsmooth_in_time,'mms'+strcompress(string(p),/rem)+'_dfg_'+name_level,smooth_p
      tinterpol_mxn,'mms'+strcompress(string(p),/rem)+'_dfg_'+name_level+'_smoothed','mms'+strcompress(string(p),/rem)+'_dfg_'+name_level,/overwrite
      get_data,'mms'+strcompress(string(p),/rem)+'_dfg_'+name_level+'_smoothed',data=smoothed_Bs
      tinterpol_mxn,'mms'+name_ql+'_pos_gse','mms'+strcompress(string(p),/rem)+'_dfg_'+name_level,newname='mms'+name_ql+'_pos_gse_intpl'
      get_data,'mms'+name_ql+'_pos_gse_intpl',data=pos
      tinterpol_mxn,'mms'+strcompress(string(p),/rem)+name_ql+'_relpos_gse','mms'+strcompress(string(p),/rem)+'_dfg_'+name_level,newname='mms'+strcompress(string(p),/rem)+name_ql+'_relpos_gse_intpl'
      get_data,'mms'+strcompress(string(p),/rem)+name_ql+'_relpos_gse_intpl',data=rpos
      for j=0l,n_elements(smoothed_Bs.x)-1 do begin
        pos_m=norm(pos.y[j,*])
        n_pos=[[pos.y[j,0]/pos_m],[pos.y[j,1]/pos_m],[pos.y[j,2]/pos_m]]
        smB_m=norm(smoothed_B.y[j,*],/double)
        fac_nz=[smoothed_B.y[j,0]/smB_m,smoothed_B.y[j,1]/smB_m,smoothed_B.y[j,2]/smB_m]
        fac_ny=crossp(fac_nz,n_pos)/norm(crossp(fac_nz,n_pos),/double)
        fac_nx=crossp(fac_ny,fac_nz)
        B_fac[j,0]=B.y[j,*]#fac_nx
        B_fac[j,1]=B.y[j,*]#fac_ny
        B_fac[j,2]=B.y[j,*]#fac_nz
        B_hpfilt[j,0]=(B.y[j,*]-smoothed_Bs.y[j,*])#fac_nx
        B_hpfilt[j,1]=(B.y[j,*]-smoothed_Bs.y[j,*])#fac_ny
        B_hpfilt[j,2]=(B.y[j,*]-smoothed_Bs.y[j,*])#fac_nz
        rpos_fac[j,0]=rpos.y[j,*]#fac_nx
        rpos_fac[j,1]=rpos.y[j,*]#fac_ny
        rpos_fac[j,2]=rpos.y[j,*]#fac_nz
      endfor
      store_data,'mms'+strcompress(string(p),/rem)+'_dfg_srvy_fac',data={x:B.x,y:B_fac}
      store_data,'mms'+strcompress(string(p),/rem)+'_dfg_srvy_fac_hpfilt',data={x:B.x,y:B_hpfilt}
      store_data,'mms'+strcompress(string(p),/rem)+name_ql+'_relpos_fac',data={x:rpos.x,y:rpos_fac}
      split_vec,'mms'+strcompress(string(p),/rem)+name_ql+'_relpos_fac'
      split_vec,'mms'+strcompress(string(p),/rem)+'_dfg_srvy_fac_hpfilt'
  endfor
  options,'mms*_dfg_srvy_fac',constant=0.0
  options,'mms*_dfg_srvy_fac_hpfilt',constant=0.0,colors=[2,4,6],labels=['fac_dBx','fac_dBy','fac_dBz'],labflag=-1

  store_data,'mms'+name_ql+'_relpos_fac_x',data=['mms1'+name_ql+'_relpos_fac_x','mms2'+name_ql+'_relpos_fac_x','mms3'+name_ql+'_relpos_fac_x','mms4'+name_ql+'_relpos_fac_x']
  store_data,'mms'+name_ql+'_relpos_fac_y',data=['mms1'+name_ql+'_relpos_fac_y','mms2'+name_ql+'_relpos_fac_y','mms3'+name_ql+'_relpos_fac_y','mms4'+name_ql+'_relpos_fac_y']
  store_data,'mms'+name_ql+'_relpos_fac_z',data=['mms1'+name_ql+'_relpos_fac_z','mms2'+name_ql+'_relpos_fac_z','mms3'+name_ql+'_relpos_fac_z','mms4'+name_ql+'_relpos_fac_z']

  options,'mms1'+name_ql+'_relpos_fac',constant=0.0,colors=[2,4,6],ytitle='mms1_ql!CRelative!CPosition!CFAC',ysubtitle='[km]',labels=['x','y','z'],labflag=-1
  options,'mms2'+name_ql+'_relpos_fac',constant=0.0,colors=[2,4,6],ytitle='mms2_ql!CRelative!CPosition!CFAC',ysubtitle='[km]',labels=['x','y','z'],labflag=-1
  options,'mms3'+name_ql+'_relpos_fac',constant=0.0,colors=[2,4,6],ytitle='mms3_ql!CRelative!CPosition!CFAC',ysubtitle='[km]',labels=['x','y','z'],labflag=-1
  options,'mms4'+name_ql+'_relpos_fac',constant=0.0,colors=[2,4,6],ytitle='mms4_ql!CRelative!CPosition!CFAC',ysubtitle='[km]',labels=['x','y','z'],labflag=-1
  options,'mms'+name_ql+'_relpos_fac_x',constant=0.0,colors=[0,2,4,6],ytitle='Relative!CPosition!CFAC X',ysubtitle='[km]',labels=['mms1','mms2','mms3','mms4'],labflag=-1
  options,'mms'+name_ql+'_relpos_fac_y',constant=0.0,colors=[0,2,4,6],ytitle='Relative!CPosition!CFAC Y',ysubtitle='[km]',labels=['mms1','mms2','mms3','mms4'],labflag=-1
  options,'mms'+name_ql+'_relpos_fac_z',constant=0.0,colors=[0,2,4,6],ytitle='Relative!CPosition!CFAC Z',ysubtitle='[km]',labels=['mms1','mms2','mms3','mms4'],labflag=-1


  tkm2re,'mms'+name_ql+'_pos_gse'
  split_vec,'mms'+name_ql+'_pos_gse_re'
  options,'mms'+name_ql+'_pos_gse_re_0',ytitle='MMS'+probe+' GSEX [RE]',format='(f7.3)'
  options,'mms'+name_ql+'_pos_gse_re_1',ytitle='MMS'+probe+' GSEY [RE]',format='(f7.3)'
  options,'mms'+name_ql+'_pos_gse_re_2',ytitle='MMS'+probe+' GSEZ [RE]',format='(f7.3)'
  options,'mms'+name_ql+'_pos_gse_re_3',ytitle='MMS'+probe+' R [RE]',format='(f7.3)'
  
  tplot_options, var_label=['mms'+name_ql+'_pos_gse_re_3','mms'+name_ql+'_pos_gse_re_2','mms'+name_ql+'_pos_gse_re_1','mms'+name_ql+'_pos_gse_re_0']

  loadct2,43
  time_stamp,/off
  tplot_options,'xmargin',[20,10]

  if undefined(plot_dfg) then begin
;    tplot,['mms?_dfg_'+name_level,'mms?_dfg_srvy_fac_hpfilt','mms?'+name_ql+'_relpos_fac','mms?'+name_ql+'_relpos_gse','mms'+name_ql+'_relpos_gse_?']
;    tplot,['mms?_dfg_'+name_level,'mms?_dfg_srvy_fac_hpfilt','mms_dfg_srvy_fac_hpfilt_?','mms?'+name_ql+'_relpos_fac','mms?'+name_ql+'_relpos_gse','mms'+name_ql+'_relpos_gse_?']
;    tplot,['mms?_dfg_srvy_fac_hpfilt','mms_dfg_srvy_fac_hpfilt_?','mms'+name_ql+'_relpos_fac_?']
    tplot,['mms?_dfg_'+name_level,'mms?'+name_ql+'_relpos_gse','mms'+name_ql+'_relpos_gse_?']
  endif else begin
    if undefined(fac) then begin
      split_vec,'mms?_dfg_'+name_level
      store_data,'mms_dfg_'+name_level+'_x',data=['mms1_dfg_'+name_level+'_x','mms2_dfg_'+name_level+'_x','mms3_dfg_'+name_level+'_x','mms4_dfg_'+name_level+'_x']
      store_data,'mms_dfg_'+name_level+'_y',data=['mms1_dfg_'+name_level+'_y','mms2_dfg_'+name_level+'_y','mms3_dfg_'+name_level+'_y','mms4_dfg_'+name_level+'_y']
      store_data,'mms_dfg_'+name_level+'_z',data=['mms1_dfg_'+name_level+'_z','mms2_dfg_'+name_level+'_z','mms3_dfg_'+name_level+'_z','mms4_dfg_'+name_level+'_z']
      store_data,'mms_dfg_'+name_level2,data=['mms1_dfg_'+name_level2,'mms2_dfg_'+name_level2,'mms3_dfg_'+name_level2,'mms4_dfg_'+name_level2]
      options,'mms_dfg_'+name_level+'_x',constant=0.0,colors=[0,2,4,6],ytitle='MMS!CDFG!CGSE X',ysubtitle='[nT]',labels=['mms1','mms2','mms3','mms4'],labflag=-1
      options,'mms_dfg_'+name_level+'_y',constant=0.0,colors=[0,2,4,6],ytitle='MMS!CDFG!CGSE Y',ysubtitle='[nT]',labels=['mms1','mms2','mms3','mms4'],labflag=-1
      options,'mms_dfg_'+name_level+'_z',constant=0.0,colors=[0,2,4,6],ytitle='MMS!CDFG!CGSE Z',ysubtitle='[nT]',labels=['mms1','mms2','mms3','mms4'],labflag=-1
      options,'mms_dfg_'+name_level2,colors=[0,2,4,6],ytitle='MMS!CDFG!CBtotal',ysubtitle='[nT]',labels=['mms1','mms2','mms3','mms4'],labflag=-1
      tplot,['mms_dfg_'+name_level2,'mms_dfg_'+name_level+'_?','mms'+name_ql+'_relpos_gse_?']
    endif else begin
      store_data,'mms_dfg_srvy_fac_hpfilt_x',data=['mms1_dfg_srvy_fac_hpfilt_x','mms2_dfg_srvy_fac_hpfilt_x','mms3_dfg_srvy_fac_hpfilt_x','mms4_dfg_srvy_fac_hpfilt_x']
      store_data,'mms_dfg_srvy_fac_hpfilt_y',data=['mms1_dfg_srvy_fac_hpfilt_y','mms2_dfg_srvy_fac_hpfilt_y','mms3_dfg_srvy_fac_hpfilt_y','mms4_dfg_srvy_fac_hpfilt_y']
      store_data,'mms_dfg_srvy_fac_hpfilt_z',data=['mms1_dfg_srvy_fac_hpfilt_z','mms2_dfg_srvy_fac_hpfilt_z','mms3_dfg_srvy_fac_hpfilt_z','mms4_dfg_srvy_fac_hpfilt_z']
      options,'mms_dfg_srvy_fac_hpfilt_x',constant=0.0,colors=[0,2,4,6],ytitle='MMS!CDFG!CFAC X',ysubtitle='[nT]',labels=['mms1','mms2','mms3','mms4'],labflag=-1
      options,'mms_dfg_srvy_fac_hpfilt_y',constant=0.0,colors=[0,2,4,6],ytitle='MMS!CDFG!CFAC Y',ysubtitle='[nT]',labels=['mms1','mms2','mms3','mms4'],labflag=-1
      options,'mms_dfg_srvy_fac_hpfilt_z',constant=0.0,colors=[0,2,4,6],ytitle='MMS!CDFG!CFAC Z',ysubtitle='[nT]',labels=['mms1','mms2','mms3','mms4'],labflag=-1
      store_data,'mms_dfg_'+name_level2,data=['mms1_dfg_'+name_level2,'mms2_dfg_'+name_level2,'mms3_dfg_'+name_level2,'mms4_dfg_'+name_level2]
      options,'mms_dfg_'+name_level2,colors=[0,2,4,6],ytitle='MMS!CDFG!CBtotal',ysubtitle='[nT]',labels=['mms1','mms2','mms3','mms4'],labflag=-1
      tplot,['mms_dfg_'+name_level2,'mms_dfg_srvy_fac_hpfilt_?','mms'+name_ql+'_relpos_fac_?']
    endelse
  endelse
  
end