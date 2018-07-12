;+
; PROCEDURE:
;         mms_data_time_takada
;
; PURPOSE:
;         To get a set of existence time ranges of fast or burst data.
;
; KEYWORDS:
;         trange:           input array ( 1dim, necessary, /string )
;                           time range of interest [starttime, endtime] with the format
;                           ['YYYY-MM-DD','YYYY-MM-DD'] or to specify more or less than a day
;                           ['YYYY-MM-DD/hh:mm:ss','YYYY-MM-DD/hh:mm:ss']
;                       
;         data_time_range: output array ( 2dims, optional, /string )
;                          a set of time ranges of burst data
;                          1dim --- composed of 2 elements, each element means "start time" and "end time" in every exixstence time range
;                          2dim --- the number of existence time ranges
;                          
;         error_level:     output number ( optional, /integer )
;                          if you want to know whether some errors happend or not.
;                          => successful run  : set errorlevel=0
;                          => something wrong : set errorlevel=1
;                          
;         startclip:       input keyword ( optional, /keyword )
;                          if you want to clip the first time in data_time_range using the "start time", you should input this keyword ( /startclip )
;                          Notice : This keyword is effective only if "start time" is the time after the first existence time in the run. See EXAMPLE No.2 !
;                          
;         endclip:         input keyword ( optional, /keyword )
;                          if you want to clip the last time in data_time_range using the "end time", you should input this keyword ( /endclip )
;                          Notice : This keyword is effective only if "end time" is the time before the last existence time in the run. See EXAMPLE No.2 !
;                          
;         datatype:        input keyword ( optional, /string )
;                          if you want to choose burst or fast data, you should input this keyword ( 'fast' or 'burst' )
;                          by default, datatype='burst'
;                          
;                          
;
; EXAMPLE:
;
;
;     No.1
;     
;       MMS>   mms_data_time_takada, ['2015-09-02/16:45:00', '2015-09-03/18:00:00'], output_data, datatype='burst'
;       MMS>   print, '  start time          end time '
;       MMS>   print, output_data
;     
;     
;       ~reslut~
;       
;         start time          end time 
;       2015-09-02/16:41:24 2015-09-02/17:38:34
;       2015-09-02/17:50:04 2015-09-02/17:58:24
;       2015-09-02/18:10:00 2015-09-02/18:10:40
;       2015-09-03/13:16:14 2015-09-03/13:20:04
;       2015-09-03/13:47:54 2015-09-03/13:53:44
;       2015-09-03/14:03:24 2015-09-03/14:24:54
;       2015-09-03/14:28:54 2015-09-03/14:43:04
;       2015-09-03/14:50:44 2015-09-03/15:49:44
;       2015-09-03/16:09:34 2015-09-03/16:15:34
;       2015-09-03/16:37:34 2015-09-03/16:56:14
;       2015-09-03/17:05:24 2015-09-03/17:33:14
;       2015-09-03/17:38:44 2015-09-03/17:40:24
;       2015-09-03/17:49:54 2015-09-03/17:52:24
;       2015-09-03/17:57:24 2015-09-03/17:59:34
;     
;     
;     
;     
;     No.2
;     
;       MMS>   mms_data_time_takada, ['2015-09-02/16:45:00', '2015-09-03/18:00:00'], output_data, datatype='burst', /startclip, /endclip
;       MMS>   print, '  start time          end time '
;       MMS>   print, output_data
;
;
;       ~reslut~ 
;     
;         start time          end time
;       2015-09-02/16:45:00 2015-09-02/17:38:34
;       2015-09-02/17:50:04 2015-09-02/17:58:24
;       2015-09-02/18:10:00 2015-09-02/18:10:40
;       2015-09-03/13:16:14 2015-09-03/13:20:04
;       2015-09-03/13:47:54 2015-09-03/13:53:44
;       2015-09-03/14:03:24 2015-09-03/14:24:54
;       2015-09-03/14:28:54 2015-09-03/14:43:04
;       2015-09-03/14:50:44 2015-09-03/15:49:44
;       2015-09-03/16:09:34 2015-09-03/16:15:34
;       2015-09-03/16:37:34 2015-09-03/16:56:14
;       2015-09-03/17:05:24 2015-09-03/17:33:14
;       2015-09-03/17:38:44 2015-09-03/17:40:24
;       2015-09-03/17:49:54 2015-09-03/17:52:24
;       2015-09-03/17:57:24 2015-09-03/17:59:34
;
;       Notice that only "start time" of the first time range has changed (clipped) !
;       /endclip does not work in this situation because '2015-09-03/17:59:34' is before trange[1] ('2015-09-03/18:00:00')
;     
;
;-








pro mms_data_time_takada, trange, data_time_range, error_level, datatype=datatype, startclip=startclip, endclip=endclip ;Variables are optional except trange

  if undefined(trange) then begin
    message, 'Error, '+ $
      'please input string variable "trange" ! '
    goto, error_end
  endif else begin
    n=size(trange)
    if n[0] ne 1 or n[1] ne 2 then begin
      message, 'Error, '+ $
         'please input string variable "trange" to be the string array having 1 dimension and 2 elements !', $
         /continue 
       print, 'your input "trange" : '
       print, trange
      goto, error_end
    endif
    if time_double(trange[0]) ge time_double(trange[1]) then begin
      message, 'Error, '+ $
         'please input trange as trange[0] is the time before trange[1] !', $
          /continue
        print, 'your input "trange" : '
        print, trange
        goto, error_end
    endif
;     print, 'your input "trange" : [ ', string(trange),' ]', format='(A,A,X,A,A)'
  endelse
  
  
  if undefined(datatype) then datatype = 'burst'
  datatype = strlowcase(datatype)
  

  
  
  case datatype of
    'fast': begin
      get_trange=[time_string(time_double(trange[0])-3600*24*7),time_string(time_double(trange[1])+3600*24*7)]
      mms_load_fast_segments, trange=get_trange, start_times=d1, end_times=d2
    end
    'burst': begin
      get_trange=[time_string(time_double(trange[0])-3600*24),time_string(time_double(trange[1])+3600*24)]
      mms_load_brst_segments, trange=get_trange, start_times=d1, end_times=d2
    end
    else : begin
      message,'Error, datatype : '+datatype+' is not allowed !', $
        /continue
      goto, error_end
    end
  endcase
  
  
  if n_elements(d1) le 0 or n_elements(d2) le 0 then begin
    
    message, 'Error : '+ $
      'no '+datatype+' intervals within the requested time range ! ', $
       /continue
    goto, error_end
    
  endif  
  
  
  
  n1max = n_elements(d1)
  n2max = n_elements(d2)
  
  if n1max ne n2max then begin
    
    message, 'Error, '+'n1max /= n2max !', /continue
    print, 'n1max = ',n1max
    print, 'n2max = ',n2max
    goto, error_end
    
  endif
  
  nmax = n1max

  counter1=make_array(1,nmax,/string)
  counter1[0:nmax-1]='true'  
  counter2=make_array(1,nmax,/string)
  counter2[0:nmax-1]='true'

  
  for i=1,nmax-1 do begin
    
    if d2[i-1] eq d1[i] then begin
     
       counter1[i] = 'false'
       counter2[i-1] = 'false'
             
    endif
    
  endfor
  
  
  combine_number1 = where(counter1 eq 'true', count , complement=not_conbine_number1 )
  new_d1_size = count
  new_d1 = d1[combine_number1]
  combine_number2 = where(counter2 eq 'true', count , complement=not_conbine_number2 )
  new_d2_size = count
  new_d2 = d2[combine_number2]
  
  
  if new_d1_size ne new_d2_size then begin

    message, 'Error,'+'new_d1_size /= new_d2_size !', /continue
    print, 'new_d1_size = ',new_d1_size
    print, 'new_d2_size = ',new_d2_size
    goto, error_end

  endif
  
  
  
  
  while time_double(trange[0]) ge new_d2[0] do begin

    if n_elements(new_d1) le 1 or n_elements(new_d2) le 1 then begin

      message, 'Error, '+ $
        'no '+datatype+' intervals within the requested time range ! ', $
        /continue
      goto, error_end

    endif

    a=make_array(1,n_elements(new_d1),/double)
    a[0:n_elements(new_d1)-1-1] = new_d1[1:n_elements(new_d1)-1]
    new_d1=make_array(1,n_elements(new_d1)-1,/double)
    new_d1[0:n_elements(new_d1)-1]=a[0:n_elements(new_d1)-1]

    a=make_array(1,n_elements(new_d2),/double)
    a[0:n_elements(new_d2)-1-1] = new_d2[1:n_elements(new_d2)-1]
    new_d2=make_array(1,n_elements(new_d2)-1,/double)
    new_d2[0:n_elements(new_d2)-1]=a[0:n_elements(new_d2)-1]


  endwhile


  while time_double(trange[1]) le new_d1[n_elements(new_d1)-1] do begin

    if n_elements(new_d1) le 1 or n_elements(new_d2) le 1 then begin

      message, 'Error, '+ $
        'no '+datatype+' intervals within the requested time range ! ', $
        /continue
      goto, error_end

    endif

    a=make_array(1,n_elements(new_d1),/double)
    a[0:n_elements(new_d1)-1-1] = new_d1[0:n_elements(new_d1)-1-1]
    new_d1=make_array(1,n_elements(new_d1)-1,/double)
    new_d1[0:n_elements(new_d1)-1]=a[0:n_elements(new_d1)-1]

    a=make_array(1,n_elements(new_d2),/double)
    a[0:n_elements(new_d2)-1-1] = new_d2[0:n_elements(new_d2)-1-1]
    new_d2=make_array(1,n_elements(new_d2)-1,/double)
    new_d2[0:n_elements(new_d2)-1]=a[0:n_elements(new_d2)-1]

  endwhile



  ;^ to prevent mms_load_brst(fast)'s overshoot




  new_d1_size=n_elements(new_d1)
  new_d2_size=n_elements(new_d2)

  if new_d2_size ne new_d2_size then begin

    message, 'Error,'+'new_d1_size /= new_d2_size !', /continue
    print, 'new_d1_size = ',new_d1_size
    print, 'new_d2_size = ',new_d2_size
    goto, error_end

  endif
  
  
  data_time_range_size = new_d1_size

  
  data_time_range = make_array(2,data_time_range_size,/string)
  
  data_time_range[0,0:data_time_range_size-1] = time_string(new_d1[0:new_d1_size-1])
  data_time_range[1,0:data_time_range_size-1] = time_string(new_d2[0:new_d2_size-1])
  
  
  
  if ~undefined(startclip) then begin
    data_time_range[0,0] = time_string( max([time_double(trange[0]),time_double(data_time_range[0,0]) ]) )
  endif
  if ~undefined(endclip) then begin
    data_time_range[1,data_time_range_size-1] = time_string( min([ time_double(trange[1]),time_double(data_time_range[1,data_time_range_size-1]) ]) )
  endif






  
  error_level=0
  
  goto, success_end



  
error_end :


  error_level=1


success_end :


print ;dummy print

end