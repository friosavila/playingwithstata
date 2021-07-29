clear
set obs 1000
gen x1=rnormal()
gen x2=rnormal()
gen x3=rnormal()
gen x4=rnormal()

gen z1=exp(0.5*x1)
gen z2=10+x2/(1+exp(x1))
gen z3=(0.6+x1*x3/25)^3
gen z4=(20+x2+x4)^2

foreach i in z1 z2 z3 z4 {
    qui:sum `i'
	replace `i'=(`i'-r(mean))/r(sd)
}

gen freg=210+27.4*z1+13.7*(z2+z3+z4)
gen fps =0.75*(-z1+0.5*z2-0.25*z3-0.1*z4)
gen id = _n

gen pz = logistic(fps)
gen d  = pz>runiform()
gen v  = rnormal(freg*d,1)
gen y0 = freg  +v
gen y1 = 2*freg+v
expand 2
bysort id:gen t=_n
replace y0=y0+rnormal()
replace y1=y1+rnormal()
gen y=y0 if t==1
replace y=y1 if t==2

gen te = y1-y0
gen td=d*(t==2)

sum te if d==1 & t==2
reghdfe y i.t#c.(z1 z2 z3 z4) td, abs(i t)
reg y d##t,
ss
drdid y z1 z2 z3 z4 td, ivar(i) time(t) tr(d) all

