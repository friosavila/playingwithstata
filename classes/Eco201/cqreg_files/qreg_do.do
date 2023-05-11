**** QREG
cd "I:\My Drive\Class\Class 2023-I\figures\"
frause wage2, clear
sort wage
gen cdf=(2*_n-1)/(2*_N)
scatter cdf wage, xtitle(Wages Quantile) ytitle(Percentile)
graph export qreg1, as(png) name("Graph")

*** SE Bootstrap
frause wage2, clear
bootstrap q10=r(r1) q25=r(r2) q50=r(r3) q75=r(r4) q90=r(r5), reps(1000): _pctile wage  , p(10 25 50 75 90)

sort wage
gen w1 = _n
gen w0 = _n-1
by wage:gen p=0.5*(w1[_N]+w0[1])/935
kdensity wage, at(wage) gen(fwage)
replace se = sqrt(p*(1-p)/935)/fwage
tabstat wage se if inlist(wage,500,668,905,1160,1444), by(wage)

*** Square vs ABs
replace l2 = (wage-1000)^2 
gen l1 = abs(wage-1000)
scatter l1 l2 wage

** Penalty.
gen l_sqr=.
gen l_abs=.

gen loss=.
forvalues i = 1/935 {
	 qui {
		replace loss = (wage - wage[`i'])^2
		sum loss,  
		replace l_sqr=r(mean) in `i'
		replace loss = abs(wage - wage[`i'])
		sum loss, meanonly
		replace l_abs=r(mean) in `i'
	}
}

sum l_sqr 
replace l_sqr =l_sqr /r(mean)
sum l_abs 
replace l_abs =l_abs /r(mean)
line l_sqr l_abs wage if wage<2000, sort

dydx l_sqr wage, gen(dydx1)
dydx l_abs wage, gen(dydx2)

line l_sqr l_abs wage if abs(wage-1000)<500, sort name(m1, replace) ///
	legend(order(1 "Square Loss" 2 "Abs loss") pos(6) cols(2))
line dydx1 dydx2 wage if abs(wage-1000)<500, sort name(m2, replace) ///
	legend(order(1 "Square Loss" 2 "Abs loss") pos(6) cols(2))	
graph combine m1 m2, xsize(10) ysize(5) iscale(1.2) imargin(0 0 0 0)


