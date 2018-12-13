;+
;
;PROCEDURE:       SPEDAS2SSW
;
;PURPOSE:         Compiles duplicated routines stored in SPEDAS or SSW.
;
;INPUTS:          Path to the SPEDAS libs.
;                 If necessary, specifies the path to the SSW libs.
;
;KEYWORDS:
;
;       SSW:      If set, the SSW routines are compiled.
;
;    SPEDAS:      If set, the SPEDAS routines are compiled.
;
;CREATED BY:      Takuya Hara on 2017-06-16.
;
;LAST MODIFICATION:
; $LastChangedBy: hara $
; $LastChangedDate: 2017-06-18 02:05:27 -0700 (Sun, 18 Jun 2017) $
; $LastChangedRevision: 704 $
;-
PRO SPEDAS2SSW, path2spd, path2ssw, ssw=ssw, spedas=spd, verbose=verbose
  IF KEYWORD_SET(ssw) THEN spedas = 0
  IF KEYWORD_SET(spd) THEN spedas = 1 
  IF SIZE(spedas, /type) EQ 0 THEN spedas = 1
  IF SIZE(path2spd, /type) EQ 0 THEN path_spd = './' ELSE path_spd = path2spd

  slash = PATH_SEP()
  sep   = PATH_SEP(/search_path)
  dirs = ['.', STRSPLIT(!path, sep, /extract)]

  files = dirs + slash + '*.pro'
  f = FILE_SEARCH(files)
  rt_names = FILE_BASENAME(f)
  rt_dirs  = FILE_DIRNAME(f)

  uniq_rt_names = rt_names[UNIQ(rt_names, SORT(rt_names))]
  index = VALUE_LOCATE(uniq_rt_names, rt_names)
  h = HISTOGRAM(index, binsize=1, min=MIN(index), max=MAX(index), reverse_indices=ri)

  wm = WHERE(h GT 1, nm)
  IF nm EQ 0 THEN BEGIN
     dprint, 'No duplicated routines found.', dlevel=2, verbose=verbose
     RETURN
  ENDIF 
  dup_name = uniq_rt_names[wm]

  path_spd = FILE_SEARCH(path_spd, /fully_qualify_path, count=npath)
  IF npath EQ 0 THEN BEGIN
     dprint, dlevel=2, verbose=verbose, 'No PATH to IDL libs found.'
     RETURN
  ENDIF

  spd_ldir = STRLEN(path_spd)
  IF SIZE(path2ssw, /type) NE 0 THEN BEGIN
     path_ssw = path2ssw
     path_ssw = FILE_SEARCH(path_ssw, /fully_qualify_path, count=npath)
     IF npath EQ 0 THEN BEGIN
        dprint, dlevel=2, verbose=verbose, 'No PATH to SSW libs found.'
        RETURN
     ENDIF
     ssw_ldir = STRLEN(path_ssw)
  ENDIF 
  
  quiet = !quiet
  FOR i=0, nm-1 DO BEGIN
     dup_libs = f[ri[ri[wm[i]]:ri[wm[i]+1]-1]]
     w = WHERE(STRMATCH(STRMID(dup_libs, 0, spd_ldir), path_spd) EQ 1, nw, comp=v, ncomp=nv)
     IF nw GT 0 THEN w = w[0]
     IF nv GT 0 THEN v = v[0]
     IF SIZE(path_ssw, /type) NE 0 THEN BEGIN
        v = WHERE(STRMATCH(STRMID(dup_libs, 0, ssw_ldir), path_ssw) EQ 1, nv)
        IF nv GT 0 THEN v = v[0]
     ENDIF

     IF (nw GT 0) AND (nv GT 0) THEN BEGIN
        IF (spedas) THEN append_array, compile_libs, dup_libs[w] $
        ELSE append_array, compile_libs, dup_libs[v]
        append_array, compile_name, (STRSPLIT(dup_name[i], '.', /extract))[0]
     ENDIF 
  ENDFOR 
  
  IF SIZE(compile_libs, /type) NE 0 THEN BEGIN
     !quiet = 1
     FOR i=0, N_ELEMENTS(compile_libs)-1 DO BEGIN
        CD, FILE_DIRNAME(compile_libs[i]), current=opath
        status = EXECUTE("RESOLVE_ROUTINE, compile_name[i], /either, _extra={quiet: 1}")
        append_array, cstat, status
        CD, opath
     ENDFOR 
     !quiet = quiet
     w = WHERE(cstat EQ 1, nw)
     IF nw GT 1 THEN BEGIN
        lgth = STRLEN(compile_name[w])
        IF SIZE(verbose, /type) EQ 0 THEN vb = 2 ELSE vb = verbose
        dprint, dlevel=2, verbose=vb, '  Compiled the following duplicated routines:'
        IF vb GE 2 THEN $
           FOR i=0, nw-1 DO $
              print, '% Compiled Module: ' + STRUPCASE(compile_name[w[i]]) +  $
                     '.' + STRJOIN(REPLICATE(' ', MAX(lgth) - lgth[i] + 1)) + $
                     'at ' + FILE_DIRNAME(compile_libs[w[i]], /mark_dir)
     ENDIF
  ENDIF
  RETURN
END
