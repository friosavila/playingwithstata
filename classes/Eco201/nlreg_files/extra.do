
mata
y = st_data(.,"lfp")
x = st_data(.,"educ age female one")
b = 0\0\0\0
 end


mata:
for(i=1;i<=10;i++) {
yh = logistic(x*b)
err = y:-yh
se = sqrt(yh:*(1:-yh))
wsx =  yh:*(1:-yh):*x:/se
werr=  err:/se
g = -cross(wsx,werr)
h = cross(wsx,wsx)
b = b:-invsym(h)*g;b'
}
mata:b,diagonal(cross(werr,werr)/1643*invsym(h)):^.5
 end
 
