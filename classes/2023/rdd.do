*** clear RDD
clear
set seed 1
set obs 200
gen e=rnormal()
gen z=runiform()+e
sum z
replace z=(z-r(mean))/r(sd)
gen t = z>0

gen y = 1 + 0.5*z + e + rnormal() + (z>0)
color_style bay

two line t z, sort title("Sharp RDD") ylabel(0 "Not Treated" 1 "Treated")
two scatter y z, sort title("Sharp RDD") pstyle(p1) || lfit y z, lw(1) pstyle(p2) ///
	|| lfit y z if z<0, lw(0.5) || lfit y z if z>0, lw(0.5) , legend(order(3 "Not Treated" 4 "Treated"))


reg y t z 
predict yh1
local b1:display %3.2f _b[t]
reg y t c.z##c.z  
predict yh2
local b2:display %3.2f _b[t]
reg y t c.z##c.z##c.z
predict yh3
local b3:display %3.2f _b[t]
sort z
two (scatter y z, sort title("Sharp RDD") pstyle(p1) color(%20)) ///
	(line yh1 z if z<0, pstyle(p2)) (line yh1 z if z>0, pstyle(p2)) ///
	(line yh2 z if z<0, pstyle(p3)) (line yh2 z if z>0, pstyle(p3)) ///
	(line yh3 z if z<0, pstyle(p4)) (line yh3 z if z>0, pstyle(p4)) , ///
	legend(order(1 "Linear ATT: `b1'" 2 "Quadratic ATT: `b2'" 3 "Cubic ATT: `b3'"))
	
qui:reg y t c.z#t 
predict yh11
local b1:display %3.2f _b[t]
qui:reg y t (c.z##c.z)#t  
predict yh21
local b2:display %3.2f _b[t]
qui:reg y t (c.z##c.z##c.z)#t
predict yh31
local b3:display %3.2f _b[t]


two (scatter y z, sort title("Sharp RDD") pstyle(p1) color(%20)) ///
	(line yh11 z if z<0, pstyle(p2)) (line yh11 z if z>0, pstyle(p2)) ///
	(line yh21 z if z<0, pstyle(p3)) (line yh21 z if z>0, pstyle(p3)) ///
	(line yh31 z if z<0, pstyle(p4)) (line yh31 z if z>0, pstyle(p4)) , ///
	legend(order(2 "Linear ATT: `b1'" 3 "Quadratic ATT: `b2'" 4 "Cubic ATT: `b3'"))	
	
	
clear
set seed 11
set obs 200
gen e=rnormal()
gen z=runiform()+e
sum z
replace z=(z-r(mean))/r(sd)

gen t = (rnormal(-1)*0.5 + (z>0) +e ) >0

gen y = 1 + e + rnormal() + (t>0)	
sort z

gen q20=0
forvalues i = -3(.25)3 {
	local j = `j'+1
	replace q20 = q20+1 if z>`i'
}

bysort q20 :egen mt = mean(t)
bysort q20 :egen mz = mean(z)
bysort mt mz:gen ww=_N
two scatter mt mz [w=ww] || ///
	lfit t z if z<0, lw(1) || ///
	lfit t z if z>0 , lw(1) legend(off) ///
	ytitle("Share treated")
	