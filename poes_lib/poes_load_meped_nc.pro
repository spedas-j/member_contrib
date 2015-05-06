;+
; PROCEDURE POES_LOAD_MEPED_NC
;
; DESCRIPTION:
;  This procedure loads NOAA/POES SEM-2 data in the NetCDF format
;  and create tplot variables of the MEPED data.
;  Before use of the data, users must refer to the documentations
;  of the instrument avaiable at:
;
;  http://ngdc.noaa.gov/stp/satellite/poes/docs/NGDC/External_Users_Manual_POES_MetOp_SEM-2_processing_V1.pdf
;  http://ngdc.noaa.gov/stp/satellite/poes/docs/NGDC/MEPED%20telescope%20processing%20ATBD_V1.pdf
; 
;  This is because the data are often dominated by unexpected signals
;  (especially proton contamitions to electron channels).
;
;  Although the instrument is not designed to measure 4 electron chennels
;  for each of the two different look directions, the E4 channel is added
;  since the P6 channel can be used as an additional electron channel.
;  The E4 channel provides the electron flux measured by the P6 channel
;  considering the instrument response to electrons.
;
;  Note that the complete MEPED database in the NetCDF format is available from 2013-01-01.
;
; KEYWORD:
;  probe: Spacecraft ID of the POES satellites (m01, m02, n15, n16, n17, n18, n19)
;
; EXAMPLE:
;  poes_load_meped_nc,probe='m02'
;
; SEE ALSO:
;  read_netcdf.pro
;
; HISTORY: 
;   First created by Satoshi Kurita, April 2015 
; 
; AUTHOR: 
;   Satoshi Kurita, STEL/Nagoya University (kurita@stelab.nagoya-u.ac.jp) 
;-

pro poes_load_meped_nc,probe=sc

source = file_retrieve(/struct)
source.local_data_dir=root_data_dir()+'poes_nc/'
source.remote_data_dir = 'http://satdat.ngdc.noaa.gov/sem/poes/data/processed/ngdc/uncorrected/full/'

if not(keyword_set(sc)) then sc='n18'

relpath=''

if sc eq 'm01' or sc eq 'm02' then $
prefix='metop'+strmid(sc,1,2)+'/poes_'+sc+'_' else $
prefix='noaa'+strmid(sc,1,2)+'/poes_'+sc+'_'

ending='_proc.nc'

relpathname=file_dailynames(relpath,prefix,ending,/yeardir,trange=trange)
file=file_retrieve(relpathname,_extra=source)

for ii=0,n_elements(file)-1 do begin
    
	dprint,'Loading file: ',file[ii]
	fname=file[ii]
	d=read_netcdf(fname)
	if(size(d,/type) eq 8) then begin

		append_array,year,d.year
		append_array,doy,d.day
		append_array,msec,d.msec

		append_array,l_igrf,d.l_igrf
		append_array,mlt,d.mlt
		append_array,lat,d.lat
		append_array,lon,d.lon
		append_array,flat,d.geod_lat_foot
		append_array,flon,d.geod_lon_foot

		append_array,p1_0,d.mep_pro_tel0_flux_p1
		append_array,p2_0,d.mep_pro_tel0_flux_p2
		append_array,p3_0,d.mep_pro_tel0_flux_p3
		append_array,p4_0,d.mep_pro_tel0_flux_p4
		append_array,p5_0,d.mep_pro_tel0_flux_p5
		append_array,p6_0,d.mep_pro_tel0_flux_p6

		append_array,p1_90,d.mep_pro_tel90_flux_p1
		append_array,p2_90,d.mep_pro_tel90_flux_p2
		append_array,p3_90,d.mep_pro_tel90_flux_p3
		append_array,p4_90,d.mep_pro_tel90_flux_p4
		append_array,p5_90,d.mep_pro_tel90_flux_p5
		append_array,p6_90,d.mep_pro_tel90_flux_p6

		append_array,e1_0,d.mep_ele_tel0_flux_e1
		append_array,e2_0,d.mep_ele_tel0_flux_e2
		append_array,e3_0,d.mep_ele_tel0_flux_e3
		append_array,e4_0,d.mep_ele_tel0_flux_e4

		append_array,e1_90,d.mep_ele_tel90_flux_e1
		append_array,e2_90,d.mep_ele_tel90_flux_e2
		append_array,e3_90,d.mep_ele_tel90_flux_e3
		append_array,e4_90,d.mep_ele_tel90_flux_e4

	endif
endfor

if(size(d,/type) eq 8) then begin
	
	doy_to_month_date,year,doy,mon,day

	yyyy=string(year,format='(i4)')
	mm=string(mon,format='(i2)')
	dd=string(day,format='(i2)')

	tepoch=time_double(yyyy+'-'+mm+'-'+dd+'/00:00:00')+msec/1e3

	;Spacecraft position

	store_data,sc+'_l_igrf',data={x:tepoch,y:l_igrf}
	store_data,sc+'_mlt',data={x:tepoch,y:mlt}
	store_data,sc+'_lat',data={x:tepoch,y:lat}
	store_data,sc+'_lon',data={x:tepoch,y:lon}
	store_data,sc+'_flat',data={x:tepoch,y:flat}
	store_data,sc+'_flon',data={x:tepoch,y:flon}

    ;Create tplot vars of SEM-2/MEPED data
    ;The labels are based on the document provided by NOAA.

	yr='!C!C[cm!U-2!N s!U-1!N str!U-1!N keV!U-1!N]'
	store_data,sc+'_mep_P1_0',data={x:tepoch,y:p1_0},$
		dlim={spec:0,ylog:1,ytitle:'P1 0 deg'+yr,labels:'39 keV'}
	store_data,sc+'_mep_P2_0',data={x:tepoch,y:p2_0},$
		dlim={spec:0,ylog:1,ytitle:'P2 0 deg'+yr,labels:'115 keV'}
	store_data,sc+'_mep_P3_0',data={x:tepoch,y:p3_0},$
		dlim={spec:0,ylog:1,ytitle:'P3 0 deg'+yr,labels:'332 keV'}
	store_data,sc+'_mep_P4_0',data={x:tepoch,y:p4_0},$
		dlim={spec:0,ylog:1,ytitle:'P4 0 deg'+yr,labels:'1105 keV'}
	store_data,sc+'_mep_P5_0',data={x:tepoch,y:p5_0},$
		dlim={spec:0,ylog:1,ytitle:'P5 0 deg'+yr,labels:'2723 keV'}

	store_data,sc+'_mep_P1_90',data={x:tepoch,y:p1_90},$
		dlim={spec:0,ylog:1,ytitle:'P1 90 deg'+yr,labels:'39 keV'}
	store_data,sc+'_mep_P2_90',data={x:tepoch,y:p2_90},$
		dlim={spec:0,ylog:1,ytitle:'P2 90 deg'+yr,labels:'115 keV'}
	store_data,sc+'_mep_P3_90',data={x:tepoch,y:p3_90},$
		dlim={spec:0,ylog:1,ytitle:'P3 90 deg'+yr,labels:'332 keV'}
	store_data,sc+'_mep_P4_90',data={x:tepoch,y:p4_90},$
		dlim={spec:0,ylog:1,ytitle:'P4 90 deg'+yr,labels:'1105 keV'}
	store_data,sc+'_mep_P5_90',data={x:tepoch,y:p5_90},$
		dlim={spec:0,ylog:1,ytitle:'P5 90 deg'+yr,labels:'2723 keV'}

	yr='!C!C[cm!U-2!N s!U-1!N str!U-1!N]'
	store_data,sc+'_mep_E1_0',data={x:tepoch,y:e1_0},$
		dlim={spec:0,ylog:1,ytitle:'E1 0 deg'+yr,labels:'40 keV'}
	store_data,sc+'_mep_E2_0',data={x:tepoch,y:e2_0},$
		dlim={spec:0,ylog:1,ytitle:'E2 0 deg'+yr,labels:'130 keV'}
	store_data,sc+'_mep_E3_0',data={x:tepoch,y:e3_0},$
		dlim={spec:0,ylog:1,ytitle:'E3 0 deg'+yr,labels:'287 keV'}
	store_data,sc+'_mep_E4_0',data={x:tepoch,y:e4_0},$
		dlim={spec:0,ylog:1,ytitle:'E4 0 deg'+yr,labels:'612 keV'}
	store_data,sc+'_mep_P6_0',data={x:tepoch,y:p6_0},$
		dlim={spec:0,ylog:1,ytitle:'P6 0 deg'+yr,labels:'6423 keV'}

	store_data,sc+'_mep_E1_90',data={x:tepoch,y:e1_90},$
		dlim={spec:0,ylog:1,ytitle:'E1 90 deg'+yr,labels:'40 keV'}
	store_data,sc+'_mep_E2_90',data={x:tepoch,y:e2_90},$
		dlim={spec:0,ylog:1,ytitle:'E2 90 deg'+yr,labels:'130 keV'}
	store_data,sc+'_mep_E3_90',data={x:tepoch,y:e3_90},$
		dlim={spec:0,ylog:1,ytitle:'E3 90 deg'+yr,labels:'287 keV'}
	store_data,sc+'_mep_E4_90',data={x:tepoch,y:e4_90},$
		dlim={spec:0,ylog:1,ytitle:'E4 90 deg'+yr,labels:'612 keV'}
	store_data,sc+'_mep_P6_90',data={x:tepoch,y:p6_90},$
		dlim={spec:0,ylog:1,ytitle:'P6 90 deg'+yr,labels:'6423 keV'}

	options,sc+'_mep_*',labflag=1

endif

end