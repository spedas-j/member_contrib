;+
; PROCEDURE:
;         mms_fgm_scm_edp_l2_comp_kitamura
;
; PURPOSE:
;         Plot magnetic and electric field data obtained by FGM, SCM, and EDP
;
; KEYWORDS:
;         trange:       time range of interest [starttime, endtime] with the format
;                       ['YYYY-MM-DD','YYYY-MM-DD'] or to specify more or less than a day
;                       ['YYYY-MM-DD/hh:mm:ss','YYYY-MM-DD/hh:mm:ss']
;         probes:       probes - value for MMS SC # (default value is ['1','2','3','4'])
;         no_E:         set this flag to skip the use of EDP data
;         no_B:         set this flag to skip the use of FGM data
;         edp_brst:     set this flag to load EDP burst data. if not set, EDP fast survey
;                       data are used
;         fgm_brst:     set this flag to load FGM burst data. if not set, FGM survey data
;                       are used
;         gsm:          set this flag to plot data in the GSM coordinate
;         no_update:    set this flag to preserve the original FGM and EDP data. if not set and
;                       newer data is found the existing data will be overwritten
;         label_gsm:    set this flag to use the GSM coordinate as the labels
;         delete:       set this flag to delete all tplot variables at the beginning
;         no_load:      set this flag to skip loading FGM and EDP data
;
; EXAMPLE:
;
;     To plot data from fluxgate magnetometers (FGM) and axial and spin-plain double probes (EDP)
;     MMS>  mms_fgm_scm_edp_l2_comp_kitamura,['2016-11-23/07:49:30','2016-11-23/07:49:40'],/gsm,/wave,/fac,/label_gsm
;     MMS>  mms_fgm_scm_edp_l2_comp_kitamura,['2016-10-27/12:18:30','2016-10-27/12:19:30'],/gsm,/wave,/fac,/mag,/delete,/no_E,freq_range=[30.d,300.d]
;     
; NOTES:
;     See the notes in mms_load_data for rules on the use of MMS data
;-

PRO mms_fgm_scm_edp_l2_comp_kitamura,trange,probes=probes,no_E=no_E,no_scm=no_scm,fgm_brst=fgm_brst,$
                                     gsm=gsm,mag=mag,no_update=no_update,label_gsm=label_gsm,delete=delete,$
                                     no_load=no_load,wave=wave,fac=fac,freq_range=freq_range,xyz=xyz,envelope=envelope

  if not undefined(delete) then store_data,'*', /delete
  if undefined(wave) then wave='' else wave='_wave'

  trange=time_double(trange)
  
  loadct2,43
  time_stamp,/off
  
  timespan,trange[0],trange[1]-trange[0],/seconds
  if undefined(freq_range) then freq_range=25.d

  if undefined(gsm) then coord='gse' else coord='gsm'
  if undefined(probes) then probes=['1','2','3','4'] else if probes[0] eq '*' then probes=['1','2','3','4'] else probes=strcompress(string(probes),/remove_all)
  
  if undefined(fgm_brst) then fgm_data_rate='srvy' else fgm_data_rate='brst'
  if undefined(no_load) then begin
    for i=0,n_elements(probes)-1 do begin
      if strlen(tnames('mms'+probes[i]+'_fgm_r_gse_srvy_l2')) eq 0 and fgm_data_rate eq 'brst' then mms_load_fgm,trange=trange,instrument='fgm',probes=probes[i],data_rate='srvy',level='l2',no_update=no_update,/time_clip,/no_attitude_data
      mms_load_fgm,trange=trange,instrument='fgm',probes=probes[i],data_rate=fgm_data_rate,level='l2',no_update=no_update,/time_clip,/no_attitude_data
      get_data,'mms'+probes[i]+'_fgm_b_'+coord+'_'+fgm_data_rate+'_l2',data=b
      store_data,'mms'+probes[i]+'_fgm_b_'+coord+'_'+fgm_data_rate+'_l2_mod',data={x:b.x,y:[[b.y[*,3]],[b.y[*,0]],[b.y[*,1]],[b.y[*,2]]]}
      options,'mms'+probes[i]+'_fgm_b_'+coord+'_'+fgm_data_rate+'_l2_mod',constant=0.0,colors=[0,2,4,6],labels=['|B|','B!DX!N','B!DY!N','B!DZ!N'],ytitle='MMS'+probes[i]+'!CFGM_L2!C'+strupcase(coord),ysubtitle='[nT]',labflag=-1,datagap=0.26d
      if strlen(tnames('mms'+probes[i]+'_fgm_r_gse_brst_l2')) eq 0 and not undefined(ion_plot) then mms_load_fgm,trange=trange,instrument='fgm',probes=probes[i],data_rate='brst',level='l2',no_update=no_update,/time_clip,/no_attitude_data
    endfor
  endif

  if n_elements(probes) eq 1 then begin
    copy_data,'mms'+probes+'_fgm_b_gse_'+fgm_data_rate+'_l2_bvec','mms_fgm_b_gse_'+fgm_data_rate+'_l2_bvec'
  endif else begin
    get_data,'mms'+probes[0]+'_fgm_b_gse_'+fgm_data_rate+'_l2_bvec',data=b
    for i=1,n_elements(probes)-1 do begin
      tinterpol_mxn,'mms'+probes[i]+'_fgm_b_gse_'+fgm_data_rate+'_l2_bvec','mms'+probes[0]+'_fgm_b_gse_'+fgm_data_rate+'_l2_bvec',newname='mms'+probes[i]+'_fgm_b_gse_'+fgm_data_rate+'_l2_bvec_intpl'
      get_data,'mms'+probes[i]+'_fgm_b_gse_'+fgm_data_rate+'_l2_bvec_intpl',data=bint
      store_data,'mms'+probes[i]+'_fgm_b_gse_'+fgm_data_rate+'_l2_bvec_intpl',/delete
      b.y=b.y+bint.y
    endfor
    b.y=b.y/double(n_elements(probes))
    store_data,'mms_fgm_b_gse_'+fgm_data_rate+'_l2_bvec',data=b
    undefine,b,bint
  endelse

  if n_elements(probes) eq 1 then begin
    copy_data,'mms'+probes+'_fgm_b_gsm_'+fgm_data_rate+'_l2_bvec','mms_fgm_b_gsm_'+fgm_data_rate+'_l2_bvec'
  endif else begin
    get_data,'mms'+probes[0]+'_fgm_b_gsm_'+fgm_data_rate+'_l2_bvec',data=b
    for i=1,n_elements(probes)-1 do begin
      tinterpol_mxn,'mms'+probes[i]+'_fgm_b_gsm_'+fgm_data_rate+'_l2_bvec','mms'+probes[0]+'_fgm_b_gsm_'+fgm_data_rate+'_l2_bvec',newname='mms'+probes[i]+'_fgm_b_gsm_'+fgm_data_rate+'_l2_bvec_intpl'
      get_data,'mms'+probes[i]+'_fgm_b_gsm_'+fgm_data_rate+'_l2_bvec_intpl',data=bint
      store_data,'mms'+probes[i]+'_fgm_b_gsm_'+fgm_data_rate+'_l2_bvec_intpl',/delete
      b.y=b.y+bint.y
    endfor
    b.y=b.y/double(n_elements(probes))
    store_data,'mms_fgm_b_gsm_'+fgm_data_rate+'_l2_bvec',data=b
    undefine,b,bint
  endelse
  
  if undefined(no_load) then mms_load_mec,trange=trange,probes=probes,no_update=no_update,varformat=['mms'+probes+'_mec_r_eci','mms'+probes+'_mec_r_gse','mms'+probes+'_mec_r_gsm','mms'+probes+'_mec_L_vec','mms'+probes+'_mec_l_dipole','mms'+probes+'_mec_mlt','mms'+probes+'_mec_mlat']

  if n_elements(probes) eq 1 then begin
    copy_data,'mms'+probes+'_mec_r_gse','mms_mec_r_gse'
  endif else begin
    get_data,'mms'+probes[0]+'_mec_r_gse',data=r
    for i=1,n_elements(probes)-1 do begin
      tinterpol_mxn,'mms'+probes[i]+'_mec_r_gse','mms'+probes[0]+'_mec_r_gse',newname='mms'+probes[i]+'_mec_r_gse_intpl'
      get_data,'mms'+probes[i]+'_mec_r_gse_intpl',data=rint
      store_data,'mms'+probes[i]+'_mec_r_gse_intpl',/delete
      r.y=r.y+rint.y
    endfor
    r.y=r.y/double(n_elements(probes))
    store_data,'mms_mec_r_gse',data=r
    undefine,r,rint
  endelse

  if n_elements(probes) eq 1 then begin
    copy_data,'mms'+probes+'_mec_r_gsm','mms_mec_r_gsm'
  endif else begin
    get_data,'mms'+probes[0]+'_mec_r_gsm',data=r
    for i=1,n_elements(probes)-1 do begin
      tinterpol_mxn,'mms'+probes[i]+'_mec_r_gsm','mms'+probes[0]+'_mec_r_gsm',newname='mms'+probes[i]+'_mec_r_gsm_intpl'
      get_data,'mms'+probes[i]+'_mec_r_gsm_intpl',data=rint
      store_data,'mms'+probes[i]+'_mec_r_gsm_intpl',/delete
      r.y=r.y+rint.y
    endfor
    r.y=r.y/double(n_elements(probes))
    store_data,'mms_mec_r_gsm',data=r
    undefine,r,rint
  endelse
  
  if n_elements(probes) gt 1 then begin
    for p=1,4 do split_vec,'mms'+strcompress(string(p),/remove_all)+'_fgm_b_gse_'+fgm_data_rate+'_l2_bvec'
    store_data,'mms_fgm_b_gse_'+fgm_data_rate+'_l2_btot',data=['mms1_fgm_b_gse_'+fgm_data_rate+'_l2_btot','mms2_fgm_b_gse_'+fgm_data_rate+'_l2_btot','mms3_fgm_b_gse_'+fgm_data_rate+'_l2_btot','mms4_fgm_b_gse_'+fgm_data_rate+'_l2_btot']
    store_data,'mms_fgm_b_gse_'+fgm_data_rate+'_l2_bvec_x',data=['mms1_fgm_b_gse_'+fgm_data_rate+'_l2_bvec_x','mms2_fgm_b_gse_'+fgm_data_rate+'_l2_bvec_x','mms3_fgm_b_gse_'+fgm_data_rate+'_l2_bvec_x','mms4_fgm_b_gse_'+fgm_data_rate+'_l2_bvec_x']
    store_data,'mms_fgm_b_gse_'+fgm_data_rate+'_l2_bvec_y',data=['mms1_fgm_b_gse_'+fgm_data_rate+'_l2_bvec_y','mms2_fgm_b_gse_'+fgm_data_rate+'_l2_bvec_y','mms3_fgm_b_gse_'+fgm_data_rate+'_l2_bvec_y','mms4_fgm_b_gse_'+fgm_data_rate+'_l2_bvec_y']
    store_data,'mms_fgm_b_gse_'+fgm_data_rate+'_l2_bvec_z',data=['mms1_fgm_b_gse_'+fgm_data_rate+'_l2_bvec_z','mms2_fgm_b_gse_'+fgm_data_rate+'_l2_bvec_z','mms3_fgm_b_gse_'+fgm_data_rate+'_l2_bvec_z','mms4_fgm_b_gse_'+fgm_data_rate+'_l2_bvec_z']
    options,'mms_fgm_b_gse_'+fgm_data_rate+'_l2_btot',colors=[0,6,4,2],ytitle='MMS!CFGM!CB_total',ysubtitle='[nT]',labels=['mms1','mms2','mms3','mms4'],labflag=-1
    options,'mms_fgm_b_gse_'+fgm_data_rate+'_l2_bvec_x',constant=0.0,colors=[0,6,4,2],ytitle='MMS!CFGM!CGSE X',ysubtitle='[nT]',labels=['mms1','mms2','mms3','mms4'],labflag=-1
    options,'mms_fgm_b_gse_'+fgm_data_rate+'_l2_bvec_y',constant=0.0,colors=[0,6,4,2],ytitle='MMS!CFGM!CGSE Y',ysubtitle='[nT]',labels=['mms1','mms2','mms3','mms4'],labflag=-1
    options,'mms_fgm_b_gse_'+fgm_data_rate+'_l2_bvec_z',constant=0.0,colors=[0,6,4,2],ytitle='MMS!CFGM!CGSE Z',ysubtitle='[nT]',labels=['mms1','mms2','mms3','mms4'],labflag=-1
    for p=1,4 do split_vec,'mms'+strcompress(string(p),/remove_all)+'_fgm_b_gsm_'+fgm_data_rate+'_l2_bvec'
    store_data,'mms_fgm_b_gsm_'+fgm_data_rate+'_l2_btot',data=['mms1_fgm_b_gsm_'+fgm_data_rate+'_l2_btot','mms2_fgm_b_gsm_'+fgm_data_rate+'_l2_btot','mms3_fgm_b_gsm_'+fgm_data_rate+'_l2_btot','mms4_fgm_b_gsm_'+fgm_data_rate+'_l2_btot']
    store_data,'mms_fgm_b_gsm_'+fgm_data_rate+'_l2_bvec_x',data=['mms1_fgm_b_gsm_'+fgm_data_rate+'_l2_bvec_x','mms2_fgm_b_gsm_'+fgm_data_rate+'_l2_bvec_x','mms3_fgm_b_gsm_'+fgm_data_rate+'_l2_bvec_x','mms4_fgm_b_gsm_'+fgm_data_rate+'_l2_bvec_x']
    store_data,'mms_fgm_b_gsm_'+fgm_data_rate+'_l2_bvec_y',data=['mms1_fgm_b_gsm_'+fgm_data_rate+'_l2_bvec_y','mms2_fgm_b_gsm_'+fgm_data_rate+'_l2_bvec_y','mms3_fgm_b_gsm_'+fgm_data_rate+'_l2_bvec_y','mms4_fgm_b_gsm_'+fgm_data_rate+'_l2_bvec_y']
    store_data,'mms_fgm_b_gsm_'+fgm_data_rate+'_l2_bvec_z',data=['mms1_fgm_b_gsm_'+fgm_data_rate+'_l2_bvec_z','mms2_fgm_b_gsm_'+fgm_data_rate+'_l2_bvec_z','mms3_fgm_b_gsm_'+fgm_data_rate+'_l2_bvec_z','mms4_fgm_b_gsm_'+fgm_data_rate+'_l2_bvec_z']
    options,'mms_fgm_b_gsm_'+fgm_data_rate+'_l2_btot',colors=[0,6,4,2],ytitle='MMS!CFGM!CB_total',ysubtitle='[nT]',labels=['mms1','mms2','mms3','mms4'],labflag=-1
    options,'mms_fgm_b_gsm_'+fgm_data_rate+'_l2_bvec_x',constant=0.0,colors=[0,6,4,2],ytitle='MMS!CFGM!CGSM X',ysubtitle='[nT]',labels=['mms1','mms2','mms3','mms4'],labflag=-1
    options,'mms_fgm_b_gsm_'+fgm_data_rate+'_l2_bvec_y',constant=0.0,colors=[0,6,4,2],ytitle='MMS!CFGM!CGSM Y',ysubtitle='[nT]',labels=['mms1','mms2','mms3','mms4'],labflag=-1
    options,'mms_fgm_b_gsm_'+fgm_data_rate+'_l2_bvec_z',constant=0.0,colors=[0,6,4,2],ytitle='MMS!CFGM!CGSM Z',ysubtitle='[nT]',labels=['mms1','mms2','mms3','mms4'],labflag=-1
  endif

  coord_fgm=coord
  if not undefined(fac) then coord='fac'
  
  if undefined(no_E) then begin
    if undefined(no_load) then mms_load_edp,trange=trange,probes=probes,data_rate='brst',level='l2',datatype=efield_datatype,no_update=no_update,/time_clip
    if coord eq 'gsm' then for i=0,n_elements(probes)-1 do mms_cotrans,'mms'+probes[i]+'_edp_dce_gse_brst_l2','mms'+probes[i]+'_edp_dce_gsm_brst_l2',in_coord='gse',out_coord='gsm'
    for i=0,n_elements(probes)-1 do begin
      if not undefined(fac) then cotrans_fac,trange,'mms'+probes[i]+'_edp_dce_gse_brst_l2','mms_fgm_b_gse_srvy_l2_bvec','mms_mec_r_gse',newname='mms'+probes[i]+'_edp_dce_fac_brst_l2'
      options,'mms'+probes[i]+'_edp_dce_'+coord+'_brst_l2',constant=0.0,colors=[2,4,6],ytitle='MMS'+probes[i]+'!CEDP!C'+strupcase(coord),ysubtitle='[mV/m]',labels=['E!DX!N','E!DY!N','E!DZ!N'],labflag=-1,datagap=0.001d
      if n_elements(freq_range) eq 1 then begin
        thigh_pass_filter,'mms'+probes[i]+'_edp_dce_'+coord+'_brst_l2',1.d/freq_range,newname='mms'+probes[i]+'_edp_dce_'+coord+'_brst_l2_wave'
      endif else begin
        thigh_pass_filter,'mms'+probes[i]+'_edp_dce_'+coord+'_brst_l2',1.d/freq_range[0],newname='mms'+probes[i]+'_edp_dce_'+coord+'_brst_l2_0'
        thigh_pass_filter,'mms'+probes[i]+'_edp_dce_'+coord+'_brst_l2',1.d/freq_range[1],newname='mms'+probes[i]+'_edp_dce_'+coord+'_brst_l2_1'
        dif_data,'mms'+probes[i]+'_edp_dce_'+coord+'_brst_l2_0','mms'+probes[i]+'_edp_dce_'+coord+'_brst_l2_1',newname='mms'+probes[i]+'_edp_dce_'+coord+'_brst_l2_wave'
        store_data,['mms'+probes[i]+'_edp_dce_'+coord+'_brst_l2_0','mms'+probes[i]+'_edp_dce_'+coord+'_brst_l2_1'],/delete
      endelse
      options,'mms'+probes[i]+'_edp_dce_'+coord+'_brst_l2'+wave,constant=0.0,colors=[2,4,6],ytitle='MMS'+probes[i]+'!CEDP!C'+strupcase(coord),ysubtitle='[mV/m]',labels=['E!DX!N','E!DY!N','E!DZ!N'],labflag=-1,datagap=0.26d
    endfor
    
    if n_elements(probes) gt 1 then begin
      for p=1,4 do split_vec,'mms'+strcompress(string(p),/remove_all)+'_edp_dce_'+coord+'_brst_l2'+wave
      if not undefined(fac) and not undefined(envelope) then begin
        for i=0,n_elements(probes)-1 do begin
          get_data,'mms'+probes[i]+'_edp_dce_fac_brst_l2'+wave,data=edp
          store_data,'mms'+probes[i]+'_edp_dce_fac_brst_l2'+wave+'_envelope',data={x:edp.x,y:sqrt(edp.y[*,0]*edp.y[*,0]+edp.y[*,1]*edp.y[*,1])}
        endfor  
        store_data,'mms_edp_dce_fac_brst_l2'+wave+'_envelope',data=['mms1_edp_dce_fac_brst_l2'+wave+'_envelope','mms2_edp_dce_fac_brst_l2'+wave+'_envelope','mms3_edp_dce_fac_brst_l2'+wave+'_envelope','mms4_edp_dce_fac_brst_l2'+wave+'_envelope']
        options,'mms_edp_dce_fac_brst_l2'+wave+'_envelope',constant=0.0,panel_size=0.75d,colors=[0,6,4,2],ytitle='MMS!CEDP!Cenvelope',ysubtitle='[mV/m]',labels=['mms1','mms2','mms3','mms4'],labflag=-1,datagap=0.26d
      endif
      store_data,'mms_edp_dce_'+coord+'_brst_l2'+wave+'_x',data=['mms1_edp_dce_'+coord+'_brst_l2'+wave+'_x','mms2_edp_dce_'+coord+'_brst_l2'+wave+'_x','mms3_edp_dce_'+coord+'_brst_l2'+wave+'_x','mms4_edp_dce_'+coord+'_brst_l2'+wave+'_x']
      store_data,'mms_edp_dce_'+coord+'_brst_l2'+wave+'_y',data=['mms1_edp_dce_'+coord+'_brst_l2'+wave+'_y','mms2_edp_dce_'+coord+'_brst_l2'+wave+'_y','mms3_edp_dce_'+coord+'_brst_l2'+wave+'_y','mms4_edp_dce_'+coord+'_brst_l2'+wave+'_y']
      store_data,'mms_edp_dce_'+coord+'_brst_l2'+wave+'_z',data=['mms1_edp_dce_'+coord+'_brst_l2'+wave+'_z','mms2_edp_dce_'+coord+'_brst_l2'+wave+'_z','mms3_edp_dce_'+coord+'_brst_l2'+wave+'_z','mms4_edp_dce_'+coord+'_brst_l2'+wave+'_z']
      options,'mms_edp_dce_'+coord+'_brst_l2'+wave+'_x',constant=0.0,colors=[0,6,4,2],ytitle='MMS!CEDP!C'+strupcase(coord)+' X',ysubtitle='[mV/m]',labels=['mms1','mms2','mms3','mms4'],labflag=-1,datagap=0.26d
      options,'mms_edp_dce_'+coord+'_brst_l2'+wave+'_y',constant=0.0,colors=[0,6,4,2],ytitle='MMS!CEDP!C'+strupcase(coord)+' Y',ysubtitle='[mV/m]',labels=['mms1','mms2','mms3','mms4'],labflag=-1,datagap=0.26d
      options,'mms_edp_dce_'+coord+'_brst_l2'+wave+'_z',constant=0.0,colors=[0,6,4,2],ytitle='MMS!CEDP!C'+strupcase(coord)+' Z',ysubtitle='[mV/m]',labels=['mms1','mms2','mms3','mms4'],labflag=-1,datagap=0.26d
    endif
  endif

  if undefined(no_scm) then begin
    if undefined(no_load) then mms_load_scm,trange=trange,probes=probes,data_rate='brst',level='l2',datatype='scb',no_update=no_update,/time_clip
    if coord eq 'gsm' then for i=0,n_elements(probes)-1 do mms_cotrans,'mms'+probes[i]+'_scm_acb_gse_scb_brst_l2','mms'+probes[i]+'_scm_acb_gsm_scb_brst_l2',in_coord='gse',out_coord='gsm'
    for i=0,n_elements(probes)-1 do begin
      if not undefined(fac) then cotrans_fac,trange,'mms'+probes[i]+'_scm_acb_gse_scb_brst_l2','mms_fgm_b_gse_srvy_l2_bvec','mms_mec_r_gse',newname='mms'+probes[i]+'_scm_acb_fac_scb_brst_l2'
      options,'mms'+probes[i]+'_scm_acb_'+coord+'_scb_brst_l2',constant=0.0,colors=[2,4,6],ytitle='MMS'+probes[i]+'!CECM!C'+strupcase(coord),ysubtitle='[nT]',labels=['B!DX!N','B!DY!N','B!DZ!N'],labflag=-1,datagap=0.001d
      if n_elements(freq_range) eq 1 then begin
        thigh_pass_filter,'mms'+probes[i]+'_scm_acb_'+coord+'_scb_brst_l2',1.d/freq_range,newname='mms'+probes[i]+'_scm_acb_'+coord+'_scb_brst_l2_wave'
      endif else begin
        thigh_pass_filter,'mms'+probes[i]+'_scm_acb_'+coord+'_scb_brst_l2',1.d/freq_range[0],newname='mms'+probes[i]+'_scm_acb_'+coord+'_scb_brst_l2_0'
        thigh_pass_filter,'mms'+probes[i]+'_scm_acb_'+coord+'_scb_brst_l2',1.d/freq_range[1],newname='mms'+probes[i]+'_scm_acb_'+coord+'_scb_brst_l2_1'
        dif_data,'mms'+probes[i]+'_scm_acb_'+coord+'_scb_brst_l2_0','mms'+probes[i]+'_scm_acb_'+coord+'_scb_brst_l2_1',newname='mms'+probes[i]+'_scm_acb_'+coord+'_scb_brst_l2_wave'
        store_data,['mms'+probes[i]+'_scm_acb_'+coord+'_scb_brst_l2_0','mms'+probes[i]+'_scm_acb_'+coord+'_scb_brst_l2_1'],/delete
      endelse
      options,'mms'+probes[i]+'_scm_acb_'+coord+'_scb_brst_l2_wave',ytitle='MMS'+probes[i]+'!CSCM_L2!Cwave!C'+strupcase(coord),ysubtitle='[nT]',constant=0.0,colors=[2,4,6],labels=['B!DX!N','B!DY!N','B!DZ!N'],datagap=0.001d
    endfor

    if n_elements(probes) gt 1 then begin
      for p=1,4 do split_vec,'mms'+strcompress(string(p),/remove_all)+'_scm_acb_'+coord+'_scb_brst_l2'+wave
      if not undefined(fac) and not undefined(envelope) then begin
        for i=0,n_elements(probes)-1 do begin
          get_data,'mms'+probes[i]+'_scm_acb_fac_scb_brst_l2'+wave,data=edp
          store_data,'mms'+probes[i]+'_scm_acb_fac_scb_brst_l2'+wave+'_envelope',data={x:edp.x,y:sqrt(edp.y[*,0]*edp.y[*,0]+edp.y[*,1]*edp.y[*,1])}
        endfor
        store_data,'mms_scm_acb_fac_scb_brst_l2'+wave+'_envelope',data=['mms1_scm_acb_fac_scb_brst_l2'+wave+'_envelope','mms2_scm_acb_fac_scb_brst_l2'+wave+'_envelope','mms3_scm_acb_fac_scb_brst_l2'+wave+'_envelope','mms4_scm_acb_fac_scb_brst_l2'+wave+'_envelope']
        options,'mms_scm_acb_fac_scb_brst_l2'+wave+'_envelope',constant=0.0,panel_size=0.75d,colors=[0,6,4,2],ytitle='MMS!CSCM!Cenvelope',ysubtitle='[nT]',labels=['mms1','mms2','mms3','mms4'],labflag=-1,datagap=0.26d
      endif
      store_data,'mms_scm_acb_'+coord+'_scb_brst_l2'+wave+'_x',data=['mms1_scm_acb_'+coord+'_scb_brst_l2'+wave+'_x','mms2_scm_acb_'+coord+'_scb_brst_l2'+wave+'_x','mms3_scm_acb_'+coord+'_scb_brst_l2'+wave+'_x','mms4_scm_acb_'+coord+'_scb_brst_l2'+wave+'_x']
      store_data,'mms_scm_acb_'+coord+'_scb_brst_l2'+wave+'_y',data=['mms1_scm_acb_'+coord+'_scb_brst_l2'+wave+'_y','mms2_scm_acb_'+coord+'_scb_brst_l2'+wave+'_y','mms3_scm_acb_'+coord+'_scb_brst_l2'+wave+'_y','mms4_scm_acb_'+coord+'_scb_brst_l2'+wave+'_y']
      store_data,'mms_scm_acb_'+coord+'_scb_brst_l2'+wave+'_z',data=['mms1_scm_acb_'+coord+'_scb_brst_l2'+wave+'_z','mms2_scm_acb_'+coord+'_scb_brst_l2'+wave+'_z','mms3_scm_acb_'+coord+'_scb_brst_l2'+wave+'_z','mms4_scm_acb_'+coord+'_scb_brst_l2'+wave+'_z']
      options,'mms_scm_acb_'+coord+'_scb_brst_l2'+wave+'_x',constant=0.0,colors=[0,6,4,2],ytitle='MMS!CSCM!C'+strupcase(coord)+' X',ysubtitle='[nT]',labels=['mms1','mms2','mms3','mms4'],labflag=-1,datagap=0.26d
      options,'mms_scm_acb_'+coord+'_scb_brst_l2'+wave+'_y',constant=0.0,colors=[0,6,4,2],ytitle='MMS!CSCM!C'+strupcase(coord)+' Y',ysubtitle='[nT]',labels=['mms1','mms2','mms3','mms4'],labflag=-1,datagap=0.26d
      options,'mms_scm_acb_'+coord+'_scb_brst_l2'+wave+'_z',constant=0.0,colors=[0,6,4,2],ytitle='MMS!CSCM!C'+strupcase(coord)+' Z',ysubtitle='[nT]',labels=['mms1','mms2','mms3','mms4'],labflag=-1,datagap=0.26d
    endif
  endif

  if not undefined(fac) then begin
    tinterpol_mxn,'mms_mec_r_gse','mms_fgm_b_gse_srvy_l2_bvec',newname='mms_mec_r_gse_intpl'
    cotrans_fac,trange,'mms_mec_r_gse_intpl','mms_fgm_b_gse_srvy_l2_bvec','mms_mec_r_gse',newname='mms_mec_r_fac_intpl'
    for i=0,n_elements(probes)-1 do begin
      tinterpol_mxn,'mms'+probes[i]+'_mec_r_gse','mms_fgm_b_gse_srvy_l2_bvec',newname='mms'+probes[i]+'_mec_r_gse_intpl'
      cotrans_fac,trange,'mms'+probes[i]+'_mec_r_gse_intpl','mms_fgm_b_gse_srvy_l2_bvec','mms_mec_r_gse',newname='mms'+probes[i]+'_mec_r_fac_orig'
      dif_data,'mms'+probes[i]+'_mec_r_fac_orig','mms_mec_r_fac_intpl',newname='mms'+probes[i]+'_mec_r_fac'
      store_data,['mms'+probes[i]+'_mec_r_gse_intpl','mms'+probes[i]+'_mec_r_fac_orig'],/delete
      if undefined(no_scm) then begin
        tinterpol_mxn,'mms'+probes[i]+'_mec_r_fac','mms'+probes[0]+'_scm_acb_'+coord+'_scb_brst_l2',/overwrite
      endif else begin
        tinterpol_mxn,'mms'+probes[i]+'_mec_r_fac','mms'+probes[0]+'_edp_dce_'+coord+'_brst_l2',/overwrite
      endelse  
      split_vec,'mms'+probes[i]+'_mec_r_fac'
    endfor
    store_data,'mms_mec_r_fac_x',data=['mms1_mec_r_fac_x','mms2_mec_r_fac_x','mms3_mec_r_fac_x','mms4_mec_r_fac_x']
    store_data,'mms_mec_r_fac_y',data=['mms1_mec_r_fac_y','mms2_mec_r_fac_y','mms3_mec_r_fac_y','mms4_mec_r_fac_y']
    store_data,'mms_mec_r_fac_z',data=['mms1_mec_r_fac_z','mms2_mec_r_fac_z','mms3_mec_r_fac_z','mms4_mec_r_fac_z']
    options,'mms_mec_r_fac_x',constant=0.0,colors=[0,6,4,2],ytitle='MMS!CPOS!CFAC X',ysubtitle='[km]',labels=['mms1','mms2','mms3','mms4'],labflag=-1,datagap=0.01d
    options,'mms_mec_r_fac_y',constant=0.0,colors=[0,6,4,2],ytitle='MMS!CPOS!CFAC Y',ysubtitle='[km]',labels=['mms1','mms2','mms3','mms4'],labflag=-1,datagap=0.01d
    options,'mms_mec_r_fac_z',constant=0.0,colors=[0,6,4,2],ytitle='MMS!CPOS!CFAC Z',ysubtitle='[km]',labels=['mms1','mms2','mms3','mms4'],labflag=-1,datagap=0.01d
    if strlen(tnames('mms1_mec_r_fac')) gt 1 then get_data,'mms1_mec_r_fac',data=r_fac1
    if strlen(tnames('mms2_mec_r_fac')) gt 1 then get_data,'mms2_mec_r_fac',data=r_fac2
    if strlen(tnames('mms3_mec_r_fac')) gt 1 then get_data,'mms3_mec_r_fac',data=r_fac3
    if strlen(tnames('mms4_mec_r_fac')) gt 1 then get_data,'mms4_mec_r_fac',data=r_fac4
    if not undefined(r_fac1) and not undefined(r_fac2) then store_data,'mms1_mms2_perp_distance',data={x:r_fac1.x,y:sqrt((r_fac1.y[*,0]-r_fac2.y[*,0])*(r_fac1.y[*,0]-r_fac2.y[*,0])+(r_fac1.y[*,1]-r_fac2.y[*,1])*(r_fac1.y[*,1]-r_fac2.y[*,1]))}
    if not undefined(r_fac1) and not undefined(r_fac3) then store_data,'mms1_mms3_perp_distance',data={x:r_fac1.x,y:sqrt((r_fac1.y[*,0]-r_fac3.y[*,0])*(r_fac1.y[*,0]-r_fac3.y[*,0])+(r_fac1.y[*,1]-r_fac3.y[*,1])*(r_fac1.y[*,1]-r_fac3.y[*,1]))}
    if not undefined(r_fac1) and not undefined(r_fac4) then store_data,'mms1_mms4_perp_distance',data={x:r_fac1.x,y:sqrt((r_fac1.y[*,0]-r_fac4.y[*,0])*(r_fac1.y[*,0]-r_fac4.y[*,0])+(r_fac1.y[*,1]-r_fac4.y[*,1])*(r_fac1.y[*,1]-r_fac4.y[*,1]))}
    if not undefined(r_fac2) and not undefined(r_fac3) then store_data,'mms2_mms3_perp_distance',data={x:r_fac2.x,y:sqrt((r_fac2.y[*,0]-r_fac3.y[*,0])*(r_fac2.y[*,0]-r_fac3.y[*,0])+(r_fac2.y[*,1]-r_fac3.y[*,1])*(r_fac2.y[*,1]-r_fac3.y[*,1]))}
    if not undefined(r_fac2) and not undefined(r_fac4) then store_data,'mms2_mms4_perp_distance',data={x:r_fac2.x,y:sqrt((r_fac2.y[*,0]-r_fac4.y[*,0])*(r_fac2.y[*,0]-r_fac4.y[*,0])+(r_fac2.y[*,1]-r_fac4.y[*,1])*(r_fac2.y[*,1]-r_fac4.y[*,1]))}
    if not undefined(r_fac3) and not undefined(r_fac4) then store_data,'mms3_mms4_perp_distance',data={x:r_fac3.x,y:sqrt((r_fac3.y[*,0]-r_fac4.y[*,0])*(r_fac3.y[*,0]-r_fac4.y[*,0])+(r_fac3.y[*,1]-r_fac4.y[*,1])*(r_fac3.y[*,1]-r_fac4.y[*,1]))}
    store_data,'mms_perp_distance',data=['mms1_mms2_perp_distance','mms1_mms3_perp_distance','mms1_mms4_perp_distance','mms2_mms3_perp_distance','mms2_mms4_perp_distance','mms3_mms4_perp_distance']
    options,'mms_perp_distance',colors=[0,1,2,3,4,6],ytitle='MMS!CDistance!CPerp',ysubtitle='[km]',labels=['mms1-2','mms1-3','mms1-4','mms2-3','mms2-4','mms3-4'],labflag=-1,datagap=0.01d
    undefine,r_fac1,r_fac2,r_fac3,r_fac4
  endif

  if not undefined(label_gsm) then label_coord='gsm' else label_coord=coord_fgm

  if undefined(mag) then begin
    if strlen(tnames('mms_mec_r_'+label_coord)) gt 0 then begin
      tkm2re,'mms_mec_r_'+label_coord
      split_vec,'mms_mec_r_'+label_coord+'_re'
      options,'mms_mec_r_'+label_coord+'_re_x',ytitle=strupcase(label_coord)+'X [R!DE!N]',format='(f8.4)'
      options,'mms_mec_r_'+label_coord+'_re_y',ytitle=strupcase(label_coord)+'Y [R!DE!N]',format='(f8.4)'
      options,'mms_mec_r_'+label_coord+'_re_z',ytitle=strupcase(label_coord)+'Z [R!DE!N]',format='(f8.4)'
      tplot_options,var_label=['mms_mec_r_'+label_coord+'_re_z','mms_mec_r_'+label_coord+'_re_y','mms_mec_r_'+label_coord+'_re_x']
    endif
  endif else begin
    options,'mms'+probes[0]+'_mec_mlat',ytitle='MLAT [deg]',format='(f7.3)'
    options,'mms'+probes[0]+'_mec_mlt',ytitle='MLT [hour]',format='(f7.3)'
    options,'mms'+probes[0]+'_mec_l_dipole',ytitle='Dipole L [R!DE!N]',format='(f7.3)'
    tplot_options,var_label=['mms'+probes[0]+'_mec_l_dipole','mms'+probes[0]+'_mec_mlt','mms'+probes[0]+'_mec_mlat']
  endelse

  tplot_options,'xmargin',[20,10]

  if n_elements(probes) eq 1 then begin
    tplot,['mms_fgm_b_'+coord_fgm+'_'+fgm_data_rate+'_l2_btot','mms'+probes+'_fgm_b_'+coord_fgm+'_'+fgm_data_rate+'_l2','mms'+probes+'_edp_dce_'+coord+'_brst_l2'+wave,'mms'+probes+'_scm_acb_'+coord+'_scb_brst_l2'+wave]
  endif else begin
    options,'mms_fgm_b_'+coord_fgm+'_'+fgm_data_rate+'_l2_btot',panel_size=0.75d
    options,'mms_fgm_b_'+coord_fgm+'_'+fgm_data_rate+'_l2_bvec_?',panel_size=0.5d
    options,'mms_mec_r_fac_?',panel_size=0.5d
    options,'mms_perp_distance',panel_size=0.5d
    if not undefined(xyz) then begin
      tplot,['mms_fgm_b_'+coord_fgm+'_'+fgm_data_rate+'_l2_btot','mms_fgm_b_'+coord_fgm+'_'+fgm_data_rate+'_l2_bvec_?','mms_edp_dce_fac_brst_l2'+wave+'_envelope','mms_edp_dce_'+coord+'_brst_l2'+wave+'_?','mms_scm_acb_fac_scb_brst_l2'+wave+'_envelope','mms_scm_acb_'+coord+'_scb_brst_l2'+wave+'_?','mms_mec_r_fac_?','mms_perp_distance']
    endif else begin
      tplot,['mms_fgm_b_'+coord_fgm+'_'+fgm_data_rate+'_l2_btot','mms_fgm_b_'+coord_fgm+'_'+fgm_data_rate+'_l2_bvec_?','mms_edp_dce_fac_brst_l2'+wave+'_envelope','mms_edp_dce_'+coord+'_brst_l2'+wave+'_?','mms_scm_acb_fac_scb_brst_l2'+wave+'_envelope','mms_scm_acb_'+coord+'_scb_brst_l2'+wave+'_?','mms_mec_r_fac_z','mms_perp_distance']
    endelse
  endelse

END
