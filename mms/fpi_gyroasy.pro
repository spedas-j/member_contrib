PRO fpi_gyroasy,tname,range=range,tavg=tavg

  if undefined(range) then range=1.25d

  get_data,tname,data=d,lim=l
  dnum=n_elements(d.y[0,*])
  
  for i=0,n_elements(d.x)-1 do begin
    avg=total(d.y[i,0:dnum-1])/double(dnum-1)
    for j=0,dnum-1 do begin
      if d.y[i,j] gt 0.d then d.y[i,j]=d.y[i,j]/avg else d.y[i,j]=1e-31
    endfor
  endfor
  
  store_data,tname+'_ratio',data={x:d.x,y:d.y,v:d.v},lim=l
  options,tname+'_ratio',spec=1,datagap=1.1d*(d.x[1]-d.x[0]),color_table=0,yticks=4,zticks=1
  ylim,tname+'_ratio',0.d,360.d
  zlim,tname+'_ratio',1/range,range,1

  if not undefined(tavg) then tsmooth_in_time,tname+'_ratio',tavg,newname=tname+'_ratio_avg'

END