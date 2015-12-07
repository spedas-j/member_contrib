;+
; PROCEDURE POES_LOAD_MEPED_TED_AVG
;
; DESCRIPTION:
;  This procedure loads NOAA/POES SEM-2 data in the CDF format
;  and create tplot variables of the MEPED/TED data.
;  Before use of the data, users must refer to the documentations
;  of the instrument avaiable at:
;
;  http://ngdc.noaa.gov/stp/satellite/poes/docs/NGDC/External_Users_Manual_POES_MetOp_SEM-2_processing_V1.pdf
;  http://ngdc.noaa.gov/stp/satellite/poes/docs/NGDC/MEPED%20telescope%20processing%20ATBD_V1.pdf
;
; KEYWORD:
;  probe: Spacecraft ID of the POES satellites (m01, m02, n15, n16, n17, n18, n19)
;
; EXAMPLE:
;  poes_load_meped_ted,probe='m02'
;
; HISTORY:
;   First created by Yoshi Miyoshi, Dec. 5, 2015
;
; AUTHOR:
;   Yoshi Miyoshi, ISEE/Nagoya University (miyoshi@stelab.nagoya-u.ac.jp)
;-

pro poes_load_meped_ted_avg,probe=sc

  source = file_retrieve(/struct)
  source.local_data_dir=root_data_dir()+'poes_cdf/'
  source.remote_data_dir = 'http://satdat.ngdc.noaa.gov/sem/poes/data/avg/cdf/'

  if not(keyword_set(sc)) then sc='n17'

  relpath=''
  if sc eq 'm01' or sc eq 'm02' then $
    prefix='metop'+strmid(sc,1,2)+'/poes_'+sc+'_' else $
    prefix='noaa'+strmid(sc,1,2)+'/poes_'+sc+'_'

  ending='.cdf'

  relpathname=file_dailynames(relpath,prefix,ending,/yeardir,trange=trange)
  file=file_retrieve(relpathname,_extra=source)

  for ii=0,n_elements(file)-1 do begin

    dprint,'Loading file: ',file[ii]
    fname=file[ii]
    d=read_cdf(fname)
    cdf_epoch,d.epoch[0,*],yr, mo, dy, hr, mn, sec, milli, /BREAK
    timestring=strcompress(string(yr[0,*])+'-'+string(mo[0,*])+'-'+string(dy[0,*])+'/'+string(hr[0,*])+':'+string(mn[0,*])+':'+string(sec[0,*])+'.'+string(milli[0,*]),/remove_all)
    dblt=time_double(timestring)
    
    if(size(d,/type) eq 8) then begin

      append_array,tepoch,transpose(dblt)

      append_array,l_igrf,transpose(d.LVALUE)
      append_array,mlt,transpose(d.MAGLTIME/360.*24.)
      append_array,lat,transpose(d.GEOGLL[0,*])
      append_array,lon,transpose(d.GEOGLL[1,*])
      append_array,flat,transpose(d.FOFLLL[0,*])
      append_array,flon,transpose(d.FOFLLL[1,*])

      append_array,mep0pitch,transpose(d.MEP0PITCH[0,*])
      append_array,mep90pitch,transpose(d.MEP90PITCH[0,*])
      append_array,ted,transpose(d.TED[0,*])
      append_array,echar,transpose(d.ECHAR[0,*])
      append_array,pchar,transpose(d.PCHAR[0,*])
      append_array,econt,transpose(d.ECONT[0,*])

      append_array,p1_0,transpose(d.MEP0P[0,*])
      append_array,p2_0,transpose(d.MEP0P[1,*])
      append_array,p3_0,transpose(d.MEP0p[2,*])
      append_array,p4_0,transpose(d.MEP0P[3,*])
      append_array,p5_0,transpose(d.MEP0P[4,*])
      append_array,p6_0,transpose(d.MEP0P[5,*])

      append_array,p1_90,transpose(d.MEP90P[0,*])
      append_array,p2_90,transpose(d.MEP90P[1,*])
      append_array,p3_90,transpose(d.MEP90p[2,*])
      append_array,p4_90,transpose(d.MEP90P[3,*])
      append_array,p5_90,transpose(d.MEP90P[4,*])
      append_array,p6_90,transpose(d.MEP90P[5,*])

      append_array,omniP0,transpose(d.MEPOMNI[0,*])
      append_array,omniP1,transpose(d.MEPOMNI[1,*])
      append_array,omniP2,transpose(d.MEPOMNI[2,*])
      append_array,omniP3,transpose(d.MEPOMNI[3,*])

      append_array,e1_0,transpose(d.MEP0E[0,*])
      append_array,e2_0,transpose(d.MEP0E[1,*])
      append_array,e3_0,transpose(d.MEP0E[2,*])
      E4_tmp=d.MEP0P[5,*]
      E4_tmp[where(d.MEP0P[4,*] gt 3.)] = -999.
      append_array,e4_0,transpose(E4_tmp)

      append_array,e1_90,transpose(d.MEP90E[0,*])
      append_array,e2_90,transpose(d.MEP90E[1,*])
      append_array,e3_90,transpose(d.MEP90E[2,*])
      E4_tmp=d.MEP90P[5,*]
      E4_tmp[where(d.MEP90P[4,*] gt 3.)] = -999.
      append_array,e4_90,transpose(E4_tmp)

    endif
  endfor

  gatt=cdf_var_atts(file[0])
  print_str_maxlet, ' '
  print, '**********************************************************************'
  print_str_maxlet,gatt.text,70
  print, '**********************************************************************'

Gfinal_E1=100./1.24   ; cm2-s-str  
Gfinal_E2=100./1.44   ; cm2-s-str
Gfinal_E3=100./0.75   ; cm2-s-str
Gfinal_E4=100./0.55   ; cm2-s-str
Gfinal_P1=100./42.95  ; cm2-s-str-keV
Gfinal_P2=100./135.28 ; cm2-s-str-keV
Gfinal_P3=100./401.09 ; cm2-s-str-keV
Gfinal_P4=100./1128.67 ; cm2-s-str-keV
Gfinal_P5=100./2202.93 ; cm2-s-str-keV
Gfinal_P6=100./0.41 ; cm2-s-str

if(size(d,/type) eq 8) then begin
 yr_int='!C!C[cm!U-2!N s!U-1!N str!U-1!N]'
 yr_diff='!C!C[cm!U-2!N s!U-1!N str!U-1!N keV!U-1!N]'
 yr_ted='!C!C[ergs cm!U-2!N s!U-1!N]'

 store_data,sc+'_lat',data={x:tepoch,y:lat},$
   dlim={ytitle:sc+'_Lat',labels:'LAT'}
 store_data,sc+'_lon',data={x:tepoch,y:lon},$
   dlim={ytitle:sc+'_Long',labels:'LON'}
 store_data,sc+'_flat',data={x:tepoch,y:flat},$
   dlim={ytitle:sc+'_FLAT',labels:'FLAT'}
 store_data,sc+'_flon',data={x:tepoch,y:flon},$
   dlim={ytitle:sc+'_FLONG',labels:'FLONG'}
 store_data,sc+'_l_igrf',data={x:tepoch,y:l_igrf},$
  dlim={ytitle:sc+'_L',labels:'L'}
 store_data,sc+'_mlt',data={x:tepoch,y:mlt},$
   dlim={ytitle:sc+'_MLT',labels:'MLT'}
 
 store_data,sc+'mep0pitch',data={x:tepoch,y:mep0pitch},$
   dlim={spec:0,ytitle:'PA of MEPED 00deg [deg]'}
 store_data,sc+'mep90pitch',data={x:tepoch,y:mep90pitch},$
   dlim={spec:0,ytitle:'PA of MEPED 90deg [deg]'}
 store_data,sc+'ted',data={x:tepoch,y:ted},$
  dlim={spec:0,ylog:1,ytitle:'TED'+yr_ted}
 store_data,sc+'echar',data={x:tepoch,y:echar},$
    dlim={spec:0,ytitle:'Echar [eV]'}
 store_data,sc+'pchar',data={x:tepoch,y:pchar},$
    dlim={spec:0,ytitle:'Pchar [eV]'}
 store_data,sc+'econt',data={x:tepoch,y:econt},$
   dlim={spec:0,ytitle:'Ele/Etotal'}

 store_data,sc+'_mep_P1_90',data={x:tepoch,y:p1_90*Gfinal_P1},$
   dlim={spec:0,ylog:1,ytitle:'P1 90 deg'+yr_diff,labels:'30-80 keV'}
 store_data,sc+'_mep_P2_90',data={x:tepoch,y:p2_90*Gfinal_P2},$
   dlim={spec:0,ylog:1,ytitle:'P2 90 deg'+yr_diff,labels:'80-250 keV'}
 store_data,sc+'_mep_P3_90',data={x:tepoch,y:p3_90*Gfinal_P3},$
   dlim={spec:0,ylog:1,ytitle:'P3 90 deg'+yr_diff,labels:'250-800 keV'}
 store_data,sc+'_mep_P4_90',data={x:tepoch,y:p4_90*Gfinal_P4},$
   dlim={spec:0,ylog:1,ytitle:'P4 90 deg'+yr_diff,labels:'800-2500 keV'}
 store_data,sc+'_mep_P5_90',data={x:tepoch,y:p5_90*Gfinal_P5},$
   dlim={spec:0,ylog:1,ytitle:'P5 90 deg'+yr_diff,labels:'2500-6900 keV'}
 store_data,sc+'_mep_P6_90',data={x:tepoch,y:p6_90*Gfinal_P6},$
   dlim={spec:0,ylog:1,ytitle:'P6 90 deg'+yr_int,labels:'>6900 keV'}

 store_data,sc+'_mep_P1_0',data={x:tepoch,y:p1_0*Gfinal_P1},$
   dlim={spec:0,ylog:1,ytitle:'P1 0 deg'+yr_diff,labels:'30-80 keV'}
 store_data,sc+'_mep_P2_0',data={x:tepoch,y:p2_0*Gfinal_P2},$
   dlim={spec:0,ylog:1,ytitle:'P2 0 deg'+yr_diff,labels:'80-250 keV'}
 store_data,sc+'_mep_P3_0',data={x:tepoch,y:p3_0*Gfinal_P3},$
   dlim={spec:0,ylog:1,ytitle:'P3 0 deg'+yr_diff,labels:'250-800 keV'}
 store_data,sc+'_mep_P4_0',data={x:tepoch,y:p4_0*Gfinal_P4},$
   dlim={spec:0,ylog:1,ytitle:'P4 0 deg'+yr_diff,labels:'800-2500 keV'}
 store_data,sc+'_mep_P5_0',data={x:tepoch,y:p5_0*Gfinal_P5},$
   dlim={spec:0,ylog:1,ytitle:'P5 0 deg'+yr_diff,labels:'2500-6900 keV'}
 store_data,sc+'_mep_P6_0',data={x:tepoch,y:p6_0*Gfinal_P6},$
   dlim={spec:0,ylog:1,ytitle:'P6 0 deg'+yr_int,labels:'>6900 keV'}
   
 store_data,sc+'_mep_E1_0',data={x:tepoch,y:e1_0*Gfinal_E1},$
   dlim={spec:0,ylog:1,ytitle:'E1 90 deg'+yr_int,labels:'40 keV'}
 store_data,sc+'_mep_E2_0',data={xtplo:tepoch,y:e2_0*Gfinal_E2},$
   dlim={spec:0,ylog:1,ytitle:'E2 0 deg'+yr_int,labels:'130 keV'}
 store_data,sc+'_mep_E3_0',data={x:tepoch,y:e3_0*Gfinal_E3},$
   dlim={spec:0,ylog:1,ytitle:'E3 0 deg'+yr_int,labels:'287 keV'}
 store_data,sc+'_mep_E4_0',data={x:tepoch,y:E4_0*Gfinal_E4},$
   dlim={spec:0,ylog:1,ytitle:'E4 0 deg'+yr_int,labels:'612 keV'}


 store_data,sc+'_mep_E1_90',data={x:tepoch,y:e1_90*Gfinal_E1},$
  dlim={spec:0,ylog:1,ytitle:'E1 90 deg'+yr_int,labels:'40 keV'}
 store_data,sc+'_mep_E2_90',data={x:tepoch,y:e2_90*Gfinal_E2},$
  dlim={spec:0,ylog:1,ytitle:'E2 90 deg'+yr_int,labels:'130 keV'}
 store_data,sc+'_mep_E3_90',data={x:tepoch,y:e3_90*Gfinal_E3},$
  dlim={spec:0,ylog:1,ytitle:'E3 90 deg'+yr_int,labels:'287 keV'}
 store_data,sc+'_mep_E4_90',data={x:tepoch,y:E4_90*Gfinal_E4},$
   dlim={spec:0,ylog:1,ytitle:'E4 90 deg'+yr_int,labels:'612 keV'}


  store_data,sc+'_mep_omniP0',data={x:tepoch,y:omniP0},$
    dlim={spec:0,ylog:1,ytitle:'Omni P0',labels:'>16 MeV'}
  store_data,sc+'_mep_omniP1',data={x:tepoch,y:omniP1},$
    dlim={spec:0,ylog:1,ytitle:'Omni P1',labels:'>36 MeV'}
  store_data,sc+'_mep_omniP2',data={x:tepoch,y:omniP2},$
    dlim={spec:0,ylog:1,ytitle:'Omni P2',labels:'>70 MeV'}
  store_data,sc+'_mep_omniP3',data={x:tepoch,y:omniP3},$
    dlim={spec:0,ylog:1,ytitle:'Omni P3',labels:'>140 MeV'}


options,sc+'_mep_*',labflag=1

endif


end