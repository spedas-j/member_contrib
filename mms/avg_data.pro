PRO avg_data,name,res,newname=newname,append=append,trange=trange,day=day

get_data,name,data=d,dlim=dlim,lim=lim
if not keyword_set(d) then begin
	   message,/info,'data not defined!'
	      return
      endif

      if not keyword_set(append) then append = '_avg'
      if not keyword_set(newname) then newname = name+append
      if not keyword_set(res) then res = 60.D   ; 1 minute resolution as default
      res = double(res)

      time = d.x

      if keyword_set(day) then trange=(round(average(time,/nan)/86400d -day/2.)+[0,day])*86400d

      if not keyword_set(trange) then trange= (floor(minmax(time)/res)+[0,1]) * res

      dn = time_average( d.x, d.y, newtime=newtime, trange=trange, res=res )

      store_data, newname, data={x:newtime, y:dn},dlim=dlim,lim=lim

      return
END
