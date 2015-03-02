; themis_ifoot 
; This script calcuates the footprint positions of THEMIS probes and 
; saves them in tplot variables named th?_state_pos_ifoot_geo_lat,lon,alt. 
; Tsyganenko 1996 model and IGRF model are used for the field-line tracing. 
; You can give a "parmod" array with the keyword "parmod". 
; Parmod (used for the original fortran code of Tsyganenko 1996 model) 
; is a four-element array in a form of:
; parmod = [ Pdyn, Dst, IMF-By, IMF-Bz ], 
; where Pdyn is the solar wind dynamic pressure [nPa], Dst, IMF-By, and IMF-Bz 
; should be given in nT. 
; --------------------------------------------------------------------------------------
; A subordinative routine called by the main routine, themis_ifoot.
FUNCTION calc_tsy_params, model

  ;Error check
  argc= N_PARAMS()
  IF argc NE 1 THEN model='t96'

  list=['t96']
  idx=WHERE( list EQ STRLOWCASE(model), cnt)
  IF cnt LT 1 THEN BEGIN
    PRINT,'tsy_params.pro: Invalid model name!'
    RETURN,''
  ENDIF ELSE IF cnt GT 1 THEN BEGIN
    PRINT,'tsy_params.pro: Multiple model names are specified!'
    PRINT,'T96 is used now'
    model='t96'
  ENDIF


  ;kyoto_dst_load
  omni_hro_load

  ;tdegap,'kyoto_dst',/overwrite
  ;tdeflag,'kyoto_dst','linear',/overwrite

  tdegap, 'OMNI_HRO_1min_SYM_H', /overwrite, /nowarning
  tdeflag, 'OMNI_HRO_1min_SYM_H', 'linear', /overwrite, /nowarning

  tdegap,'OMNI_HRO_1min_BY_GSM',/overwrite, /nowarning
  tdeflag,'OMNI_HRO_1min_BY_GSM','linear',/overwrite, /nowarning

  tdegap,'OMNI_HRO_1min_BZ_GSM',/overwrite, /nowarning
  tdeflag,'OMNI_HRO_1min_BZ_GSM','linear',/overwrite, /nowarning

  tdegap,'OMNI_HRO_1min_proton_density',/overwrite, /nowarning
  tdeflag,'OMNI_HRO_1min_proton_density','linear',/overwrite, /nowarning

  tdegap,'OMNI_HRO_1min_flow_speed',/overwrite, /nowarning
  tdeflag,'OMNI_HRO_1min_flow_speed','linear',/overwrite, /nowarning

  store_data,'omni_imf',data=['OMNI_HRO_1min_BY_GSM','OMNI_HRO_1min_BZ_GSM']

  ;get_tsy_params generates parameters for t96,t01, & t04s models
  get_tsy_params,'OMNI_HRO_1min_SYM_H','omni_imf',$
    'OMNI_HRO_1min_proton_density','OMNI_HRO_1min_flow_speed',model,/speed,/imf_yz

  par = model + '_par'

  RETURN, par

END


; --------------------------------------------------------------------------------------
pro themis_ifoot, $
  probe=probe, $
  parmod=parmod, $
  autocalc_parmod=autocalc_parmod

  thm_init
  sd_init

  ;Check if any valid probe name is given
  sc_list = [ 'a', 'b', 'c', 'd', 'e' ]
  probe = thm_check_valid_name( strlowcase(probe) , sc_list, $
    /ignore_case, /include_all, /no_warning )
  if strlen(probe[0]) lt 1 then begin & print, 'No valid probe name is given!' & return & endif

  ;Load orbit data in GSM for THEMIS probes
  thm_load_state, probe=probe, coord='gsm', suffix='_gsm'

  ;Generate tplot variables containing the footprint positions for each THEMIS probe
  for n=0, n_elements(probe)-1 do begin

    sc = probe[n]
    prefix = 'th'+sc+'_state_pos'
    vn_orbgsm = prefix + '_gsm'
    if strlen(tnames(vn_orbgsm)) lt 1 then continue ;Skip unless orbit data is loaded

    ; km --> Re
    tkm2re, vn_orbgsm, /replace

    ;Remove the pre-existing variables for footprint positions
    del_data,tnames( vn_orbgsm+'_ifoot*' )

    if ~keyword_set(autocalc_parmod) then begin  ;;;The given or nominal parmod is used

      if is_string(parmod) then begin  ;;; a tplot variable name is given

        if strlen(tnames(parmod[0])) gt 6 then tsy_par = parmod[0] else begin
          print, 'Parmod given is not a valid tplot variable!'
          return
        endelse

      endif else begin ;;;Otherwise parmod is given by an numerical array or not given at all!

        if n_elements(parmod) eq 4 then begin ;;; fixed parmod values are given by a user
          sw_pdyn = double( parmod[0] )
          dst = double( parmod[1] )
          imfby = double( parmod[2] )
          imfbz = double( parmod[3] )
        endif else begin  ;;;nothing is given, so use the nominal values
          sw_pdyn = double( 1.0 )
          dst = double( 0.0 )
          imfby = double( 0.0 )
          imfbz = double( 0.0 )
        endelse

        tsy_par = [ sw_pdyn, dst, imfby, imfbz, 0.D, 0.D, 0.D, 0.D, 0.D, 0.D ]
        print, 'Used parameter set [Pdyn, Dst, IMF-By, IMF-Bz]: ', $
          tsy_par[0], tsy_par[1], tsy_par[2], tsy_par[3] 
        
      endelse

    endif else begin ;;; autocalc_parmod keyword has been set, then calculate it!

      istp_init
      tsy_par = calc_tsy_params( 't96' )
      if strlen(tnames(tsy_par)) lt 6 then begin
        print, 'Parmod could not be calculated by some unknown reason. '
        print, 'Program stopped.'
        return
      endif
      
      print, 'Parmod has been automatically calculated from OMNI 1min data.'
      
    endelse
    
    
    vn_ifootgeo = prefix + '_ifoot_geo'
    ttrace2iono,vn_orbgsm, in_coord='gsm', out_coord='geo', $
      internal_model='igrf', external_model='t96', $
      par=tsy_par, $
      newname=vn_ifootgeo
    if tnames(vn_ifootgeo) eq '' then begin
      print, 'Failed to calculate the footprint position for some unknown reason.'
      return
    endif
    
    options, vn_ifootgeo, 'labels', ['x_geo', 'y_geo', 'z_geo' ]
    
    ;cartesian --> spherical coordinates
    xyz_to_polar, vn_ifootgeo, /ph_0_360 
    vn_removed = tnames( [vn_ifootgeo+'_lat',vn_ifootgeo+'_lon'] ) 
    if strlen(vn_removed[0]) gt 6 then store_data, delete=vn_removed
    store_data, vn_ifootgeo+'_th', newname=vn_ifootgeo+'_lat'
    store_data, vn_ifootgeo+'_phi', newname=vn_ifootgeo+'_lon'
    tkm2re, vn_ifootgeo+'_mag', /km, /replace
    calc, '"'+vn_ifootgeo+'_alt" = "'+vn_ifootgeo+'_mag" - 6371.2' 
    options, vn_ifootgeo+'_alt', 'ysubtitle', '[km]' 
    
  endfor


  return
end


