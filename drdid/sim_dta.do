clear
set obs 10000
gen x1=rnormal()
gen x2=rnormal()
gen x3=rnormal()
gen x4=rnormal()

gen t = rnormal()<0
gen i = rnormal()<0

gen te=runiform(0.2,0.4)*i*t +(x1+x2+x3+x4)*0.1*i*t
gen y = (x1+x2+x3+x4)*(1+0.1*i*t) +i*runiform(0,0.2)+ t + te +rnormal()*0.25

qui {
gen d =  i
gen post =  t

 
reg y x1 x2 x3 x4 if d==0 & post==0
predict y00
reg y x1 x2 x3 x4 if d==1 & post==0
predict y10
reg y x1 x2 x3 x4 if d==0 & post==1
predict y01
reg y x1 x2 x3 x4 if d==1 & post==1
predict y11

gen eff1 = (y11-y10)-(y01-y00) 
}
egen it=group(i t)
tabstat eff1, by(it)
reg y x1 x2 x3 x4 i##t

gen eff11 = (y-y10)-(y01-y00)
gen eff10 = (y11-y)-(y01-y00)
gen eff01 = (y11-y10)-(y-y00)
gen eff00 = (y11-y10)-(y01-y)

summ eff1 te if i==1 & t==1
drdid y x1 x2 x3 x4, tr(i) time(t) all


****
/*gmm (eq1:(y-{b00:_cons x1 x2 x3 x4})*(it==1)) ///
	(eq2:(y-{b01:_cons x1 x2 x3 x4})*(it==2)) ///
	(eq3:(y-{b10:_cons x1 x2 x3 x4})*(it==3)) ///
	(eq4:(y-{b11:_cons x1 x2 x3 x4})*(it==4)) ///
	(eq5:({att}-({b11:}-{b10:} -({b01:}-{b00:})))*(i==1)) ///
	, instruments(eq1:x1 x2 x3 x4) instruments(eq2:x1 x2 x3 x4) ///
	instruments(eq3:x1 x2 x3 x4) instruments(eq4:x1 x2 x3 x4) ///
	winitial(identity) onestep*/