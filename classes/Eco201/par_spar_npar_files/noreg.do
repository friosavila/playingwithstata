frause oaxaca, clear
drop if lnwage==.
sum lnwage 
gen fwage = normalden(lnwage, r(mean) ,  r(sd))

two scatter fwage lnwage || histogram lnwage, color(%50)

histogram lnwage, width(0.15) pstyle(p1) color(*.70) name(m1, replace) subtitle(w = 0.15)
histogram lnwage, width(0.0725) pstyle(p1) color(*.70) name(m2, replace) subtitle(w = 0.0725)
histogram lnwage, width(0.30) pstyle(p1) color(*.70) name(m3, replace) subtitle(w = 0.3)
histogram lnwage, width(0.60) pstyle(p1) color(*.70) name(m4, replace) subtitle(w = 0.6)
cd "I:\My Drive\Class\Class 2023-I\figures"
graph combine m1 m2 m3 m4, imargin(0 0 0 0) ycommon
graph export hist_1.png

*****************************
* kdensity 

clear 
set obs 5
gen r=rnormal()

set obs 200
range x -4 4
gen f1 = normalden(x,`=r[1]',.5)
gen f2 = normalden(x,`=r[2]',.5)
gen f3 = normalden(x,`=r[3]',.5)
gen f4 = normalden(x,`=r[4]',.5)
gen f5 = normalden(x,`=r[5]',.5)


foreach i of varlist f* {
	replace `i' = `i'/(5)
}

gen f21=f2+f1
gen f31=f3+f21
gen f41=f4+f31
gen f51=f5+f41

*color_style tableau
kdensity r, bw(.5) at(x) kernel(gaussian) gen(ffx)


two line f5 f4 f3 f2 f1 x , legend(off) name(m1,replace) lw(1 1 1 1 1)
two area f51 f41 f31 f21 f1   x, legend(off) name(m2,replace)

graph combine m1 m2 , ycommon xsize(14) ysize(9)
graph export kden_2.png

************************************
** B vs V
clear
set obs 1000
gen r1 = runiform()<.5
gen r2 = rnormal(-1,0.5)*r1 + rnormal(1,1)*(1-r1 )
** true density
gen f = normalden(r2,-1,0.5)*0.5 + normalden(r2,1,1)*0.5

gen bw =.
gen err =.
forvalues i = 0.05 (0.025) 0.4 {
	local j = `j'+1
	kdensity r2, at(r2)	gen(f_`j') nodraw kernel(gaussian) bw(`i')
	gen ff`j'=(f_`j'-f)^2
	sum ff`j', meanonly
	replace err = r(mean) in `j'
	replace bw = `i' in `j'
}

line err bw , xline(0.2552 .175) xlabel(0 (.1) 4 ) xlabel(0 (.1) .4 0.2552 "Default" .175 "Optimal") name(m1, replace)

two  	( line f r2, sort color(gs5%50) lw(1)) ///
		( kdensity r2, kernel(gaussian) bw(0.05) color(gs2%80) lw(0.2)) ///
		( kdensity r2, kernel(gaussian) bw(0.10) color(gs2%80) lw(0.2)) ///
		( kdensity r2, kernel(gaussian) bw(0.175) pstyle(p1)) ///
		( kdensity r2, kernel(gaussian) bw(0.2552) pstyle(p2) ) ///
		( kdensity r2, kernel(gaussian) bw(0.5) color(gs2%80) lw(0.2)) , ///
		legend(order(1 "Truth" 4 "Optimal" 5 "Default" )) name(m2, replace)
		
graph combine m1 m2, imargin(0 0) ysize(5) xsize(9)
graph export kden_3.png, replace

** NP REG
two scatter accel time || ///
	line accel time , color(gs1%20) || ///
	lpoly accel time, kernel(gaussian) bw(0.4) || ///
	lpoly accel time, kernel(gaussian) bw(1.6) || ///
	lpoly accel time, kernel(gaussian) bw(6.4) || ///
	lfit  accel time , legend(off) xscale(off) yscale(off)
graph export smreg_1.png, replace	

** Local constant regression

clear
set obs 200
range x -4 4
gen y = sin(x) + rnormal()/2

two  (scatter y x , msize(2) mcolor(green%20)) ///
     (scatter y x [w=normalden(x,0,.3)], msize(0.5) color(navy%50)) ///
	 (scatter y x [w=normalden(x,-2,.3)], msize(0.5) color(navy%50)) ///
	 (scatter y x [w=normalden(x,2,.3)], msize(0.5) color(navy%50)) ///
  	 (lpoly y x, bw(.3) kernel(gaussian) color(black%50)) , legend(off)
	 
graph export smreg_2.png, replace	
	 
** Crossvalidation 
ssc install cv_kfold	 
frause oaxaca, clear
 qui:reg lnwage educ exper tenure female age

. cv_kfold

. qui:reg lnwage c.(educ exper tenure female age)##c.(educ exper tenure female age)

. cv_kfold


. qui:reg lnwage c.(educ exper tenure female age)##c.(educ exper tenure female age)##c.(educ exper tenure female age)

cv_kfold
cv_regress


****
clear
set obs 200
range x -4 4
gen y = sin(x) + rnormal()/2
lpoly y x, kernel(gaussian)

***
webuse motorcycle, clear
set scheme white2
two scatter accel time || ///
	lpoly accel time , degree(0) n(100) || ///
	lpoly accel time , degree(1) n(100) || ///
	lpoly accel time , degree(2) n(100) || ///
	lpoly accel time , degree(3) n(100) , ///
	legend(order(  2 "LConstant" 3 "Local Linear" 4 "Local Cubic" 5 "Local Quartic"))
cd "G:\My Drive\Class\Class 2023-I\figures"	
graph export lllreg.png

***
frause oaxaca
npregress kernel lnwage age exper
margins, dydx(*)

vc_bw lnwage educ exper tenure female married divorced, vcoeff(age)
vc_reg lnwage educ exper tenure female married divorced, vcoeff(age) k(20)
ssc install addplot
vc_graph educ exper tenure female married divorced, rarea
addplot grph1:, legend(off) title(Education)
addplot grph2:, legend(off) title(Experience)
addplot grph3:, legend(off) title(Tenure)
addplot grph4:, legend(off) title(Female)
addplot grph5:, legend(off) title(Married)
addplot grph6:, legend(off) title(Divorced)

graph combine grph1 grph2 grph3 grph4 grph5 grph6
graph export vc_plot.png