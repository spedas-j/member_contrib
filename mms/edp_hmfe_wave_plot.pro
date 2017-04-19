PRO edp_hmfe_wave_plot,trange,probe=probe,delete=delete

  if not undefined(delete) then store_data,'*',/delete
  mms_load_edp,trange=trange,probes=probe,data_rate='brst',level='l2',datatype='hmfe',/time_clip
  get_data,'mms'+probe+'_edp_hmfe_dsl_brst_l2',data=d
  dnum=n_elements(d.x)
  i=0l
  while d.x[i+1]-d.x[i] lt 1.d/32768.d do i=i+1
  print,i
  if (i+1l mod 32768) ne 0 then store_data,'mms'+probe+'_edp_hmfe_dsl_brst_l2',data={x:d.x[i+1:dnum-1],y:d.y[i+1:dnum-1,*]}
  tdpwrspc,'mms'+probe+'_edp_hmfe_dsl_brst_l2',nboxpoints=32768l,nshiftpoints=32768l
  options,'mms'+probe+'_edp_hmfe_dsl_brst_l2_?_dpwrspc',ylog=0,datagap=1.1d
;  options,'mms'+probe+'_edp_hmfe_dsl_brst_l2_?_dpwrspc',ylog=0,datagap=1.1d,constant=[sqrt(80.7d),sqrt(80.7d*1.1d)]
  options,'mms'+probe+'_edp_hmfe_dsl_brst_l2_x_dpwrspc',ytitle='MMS'+probe+'!CEx',ysubtitle='[Hz]',ztitle='(mV/m)!U2!N/Hz'
  options,'mms'+probe+'_edp_hmfe_dsl_brst_l2_y_dpwrspc',ytitle='MMS'+probe+'!CEy',ysubtitle='[Hz]',ztitle='(mV/m)!U2!N/Hz'
  options,'mms'+probe+'_edp_hmfe_dsl_brst_l2_z_dpwrspc',ytitle='MMS'+probe+'!CEz',ysubtitle='[Hz]',ztitle='(mV/m)!U2!N/Hz'
;  window,xsize=1280,ysize=1024
;  time_stamp,/off
  tplot_options,'xmargin',[15,10]
  tplot,['mms'+probe+'_edp_hmfe_dsl_brst_l2_x_dpwrspc','mms'+probe+'_edp_hmfe_dsl_brst_l2_y_dpwrspc','mms'+probe+'_edp_hmfe_dsl_brst_l2_z_dpwrspc']
  
END

;dis_density_wave_check,['2015-09-01/13:20:00','2015-09-01/15:20:00'],probe='3'
;makepng,'mms3_chen_event4_20150901_152000'
;dis_density_wave_check,['2015-09-03/22:10:00','2015-09-03/22:50:00'],probe='3'
;makepng,'mms3_chen_event5_20150903_221000'
;dis_density_wave_check,['2015-09-11/19:00:00','2015-09-11/19:35:00'],probe='3'
;makepng,'mms3_chen_event6_20150911_190000'
;dis_density_wave_check,['2016-01-01/07:29:00','2016-01-01/07:42:00'],probe='3'
;makepng,'mms3_nakamura_event_20160101_072900'
;dis_density_wave_check,['2016-01-01/07:29:00','2016-01-01/07:42:00'],probe='1'
;makepng,'mms1_nakamura_event_20160101_072900'
;dis_density_wave_check,['2016-01-01/07:29:00','2016-01-01/07:42:00'],probe='4'
;makepng,'mms4_nakamura_event_20160101_072900'
;
;dis_density_wave_check,['2015-10-07/12:00:00','2015-10-07/14:00:00'],probe='1'
;makepng,'mms1_swbad_event1_20151007_120000'
;dis_density_wave_check,['2015-11-03/08:15:00','2015-11-03/09:15:00'],probe='1'
;makepng,'mms1_swgood_event1_20151103_081500'
