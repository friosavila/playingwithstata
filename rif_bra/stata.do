/*
ssc install rif
ssc install color_style, replace
set scheme white2
color_style egypt
*/

*** 
cd "H:\My Drive\RIF_brazil\rif_bra_files"
set scheme white2
color_style egypt
clear
set seed 2
set obs 1000
gen r1 = runiform()

gen x1=(2*_n-1)/(2*_N)*5
xtile xx=runiform(),n(10)
gen x2 = xx<=5
gen x2b = xx<=6
sort r1
gen u =invnormal((2*_n-1)/(2*_N))
gen y = 0 + x1 + 2*x2 + u*(0.1 + 0.2*x1+1*x2)

font_style Garamond
two (scatter y x1 if x2==0 ) (scatter y x1 if x2==1), legend(order(2 "x2=1" 1 "x2=0")) ///
title(DGP: y=b0+b1x1+b2x2+e(g0+g1x1+g2x2)) xsize(14) ysize(9)
graph export fig1.png,  replace


two (scatter y x1 if x2==0 ) (scatter y x1 if x2==1) ///
	(function y = x + invnormal(.5)*(.1+0.2*x), range(0 5) pstyle(p1) lwidth(.75) lcolor(*.57) ) ///
	(function y = x + 2 + invnormal(0.5)*(.1+0.2*x + .5), range(0 5) pstyle(p2) lwidth(.75) lcolor(*.57) ) ///
	, legend(order(2 "x2=1" 1 "x2=0"))  ///
title(DGP: y=b0+b1x1+b2x2+e(g0+g1x1+g2x2)) xsize(14) ysize(9) xtitle(x1)
graph export fig2.png,  replace


two (scatter y x1 if x2==0 ) (scatter y x1 if x2==1) ///
	(function y = x + invnormal(.1)*(.1+0.2*x), range(0 5) pstyle(p1) lwidth(.75) lcolor(*.57) ) ///
	(function y = x + invnormal(.9)*(.1+0.2*x), range(0 5) pstyle(p1) lwidth(.75) lcolor(*.57) ) ///
	(function y = x + 2 + invnormal(.1)*(.1+0.2*x + .5), range(0 5) pstyle(p2) lwidth(.75) lcolor(*.57) ) ///
	(function y = x + 2 + invnormal(.9)*(.1+0.2*x + .5), range(0 5) pstyle(p2) lwidth(.75) lcolor(*.57) ) ///
	, legend(order(2 "x2=1" 1 "x2=0"))  ///
title(DGP: y=b0+b1x1+b2x2+e(g0+g1x1+g2x2)) xsize(14) ysize(9) xtitle(x1)
graph export fig3.png,  replace


histogram x1, pstyle(p1) name(m1, replace) graphregion(margin(zero))
histogram x2, barwidth(0.5) xlabel(0 1)  pstyle(p2) name(m2, replace) graphregion(margin(zero))
histogram y, pstyle(p3) name(m3, replace) graphregion(margin(zero))
graph combine m1 m2 m3, cols(3) ysize(3) xsize(10) scale(2) nocopies
graph export fig4.png,  replace

*** changes in x1
pctile q0 = y , n(100)	
gen q = _n if _n<100
gen x1b=x1+1

gen y1 = 0 + (x1b) + 2*x2 + u*(0.1 + 0.2*(x1b)+1*x2)
pctile q1 = y1 , n(100)	
two ( histogram x1,   pstyle(p1) color(*.5)) ///
	( histogram x1b,  pstyle(p1)   ), name(m1, replace) graphregion(margin(zero)) legend(off) xtitle(x1)

two ( histogram y , pstyle(p3) color(*.5)) ///
	( histogram y1,    pstyle(p3) color(%80)), name(m3, replace) graphregion(margin(zero)) legend(off) xtitle("y")
gen dq1=q1-q0

two line q0 q1 q , ytitle(Quantile) || (line dq1 q, yaxis(2) lwidth(1) color(navy%50) ytitle("Dq", axis(2))), graphregion(margin(zero)) ///
 legend(order(1 "Before" 2 "After" 3 "Change" ) ring(0) position(11) ) name(m4, replace) xtitle(Percentile) 

graph combine m1 m3 m4, cols(3) ysize(3) xsize(10) scale(1.7)  nocopies
graph export fig5.png,  replace

** Alt change in x1 

gen x1c = x1 + runiform()*(5-x1)*(runiform()<(1-x1/5))
gen y1c = 0 + (x1c) + 2*x2 + u*(0.1 + 0.2*(x1c)+1*x2)
 pctile q1c = y1c , n(100)	
gen dq1c=q1c-q0

two ( histogram x1,   pstyle(p1) color(*.5)) ///
	( histogram x1c,  pstyle(p1)   ), name(m1, replace) graphregion(margin(zero)) legend(off) xtitle(x1)


two ( histogram y , pstyle(p3) color(*.5)) ///
	( histogram y1c,    pstyle(p3) color(%80)), name(m3, replace) graphregion(margin(zero)) legend(off) xtitle("y")
	
two line q0 q1c q , ytitle(Quantile) || (line dq1c q, yaxis(2) lwidth(1) color(navy%50) ytitle("Dq", axis(2))), graphregion(margin(zero)) ///
 legend(order(1 "Before" 2 "After" 3 "Change" ) ring(0) position(11) ) name(m4, replace) xtitle(Percentile) 
graph combine m1 m3 m4, cols(3) ysize(3) xsize(10) scale(1.7)  nocopies
graph export fig5b.png,  replace	
	
*** Change in X2
gen y2 = 0 + x1 + 2*x2b + u*(0.1 + 0.2*x1+1*x2b)
pctile q2 = y2, n(100)	

replace x2b=x2b+.1
replace x2=x2-.1
two ( histogram x2, barwidth(0.5) xlabel(0 1)  pstyle(p2) color(*.5)) ///
	( histogram x2b, barwidth(0.5) xlabel(0 1)  pstyle(p2)), name(m2, replace) graphregion(margin(zero)) legend(off) xtitle("x2")

two ( histogram y , pstyle(p3) color(*.5)) ///
	( histogram y2,    pstyle(p3) color(%80)), name(m3, replace) graphregion(margin(zero)) legend(off) xtitle("y")



gen dq2=q2-q0
two line q0 q1 q , ytitle(Quantile) || (line dq2 q, yaxis(2) lwidth(1)  color(navy%50) ytitle("Dq", axis(2))), graphregion(margin(zero)) ///
 legend(order(1 "Before" 2 "After" 3 "Change" ) ring(0) position(11) ) name(m4, replace) xtitle(Percentile) 
 
 
graph combine m2 m3 m4, cols(3) ysize(3) xsize(10) scale(1.7)  name(mm, replace) nocopies
 
graph export fig6.png,  replace

*** Analyzing Any Statistics
** Original    : y
** Change in x1: y1
** Change in x2: y2

 

tabstat y y1 y2 , stats(mean variance sd skewness kurtosis cv) save
matrix tt=r(StatTotal)
matrix tt=tt,tt[....,2]-tt[....,1],tt[....,3]-tt[....,1]
matrix colname tt = "Original" "After dx1" "After dx2" "Change dX1" "Change dX2"

esttab matrix(tt, fmt(%5.3f)), md

** QTE
gen y_0 = 0 + x1 + u*(0.1 + 0.2*x1)
gen y_1 = 0 + x1 + 2 + u*(0.1 + 0.2*x1+1)

pctile q_1 = y_1, n(100)	
pctile q_0 = y_0, n(100)	

gen dqte=q_1 - q_0

two ( histogram y_0 , pstyle(p3) color(*.5)) ///
	( histogram y_1,  pstyle(p3) color(%80)), name(m3, replace) graphregion(margin(zero)) legend(off) xtitle("y")

two line q_0 q_1 q , ytitle(Quantile) || (line dqte q, yaxis(2) lwidth(1)  color(navy%50) ytitle("Dq", axis(2))), graphregion(margin(zero)) ///
 legend(order(1 "Before" 2 "After" 3 "Change" ) ring(0) position(11) ) name(m4, replace) xtitle(Percentile) 	
	
graph combine m3 m4, cols(3) ysize(3) xsize(8) scale(1.7)  nocopies
graph export fig7.png


*** Example
use http://fmwww.bc.edu/RePEc/bocode/o/oaxaca.dta, clear
 
sum lnwage educ exper tenure female [w=wt] if lnwage!=.

rifhdreg  lnwage educ exper tenure female [pw=wt], rif( q(10) )



rifhdreg  lnwage educ exper tenure female [pw=wt], rif( q(10) )

sum educ if lnwage!=. [aw=wt]
gen educ2=(educ-r(mean))^2
sum educ2 if lnwage!=. [aw=wt]
replace educ2=educ2/r(mean)
rifhdreg  lnwage educ educ2 exper tenure female [pw=wt], rif( q(10) )
 
 
qregplot educ educ2 exper tenure female,  col(3) xsize(10) ysize(5) q(10(2.5)95)   

graph export fig8.png, replace

gen wage=exp(lnwage)
rifhdreg  wage educ educ2 exper tenure female [pw=wt], rif(gini) scale(100)
est sto m1
rifhdreg  lnwage educ educ2 exper tenure female [pw=wt], rif(std) 
est sto m2
rifhdreg  wage educ educ2 exper tenure female [pw=wt], rif(iqratio(20 80))
est sto m3
esttab m1 m2 m3, mtitle(gini Std IQRatio8020) se nogap scalar(rifmean)

gen hiten=tenure>8

rifhdreg  lnwage educ educ2 exper hiten female [pw=wt], rif(q(10))
qregplot hiten, name(m1, replace) q(15(2.5)95)
rifhdreg  lnwage educ educ2 exper hiten female [pw=wt], rif(q(10)) over(hiten)
qregplot hiten, name(m2, replace) q(15(2.5)95)

rifhdreg  lnwage deduc exper tenure female [pw=wt], rif(q(10))

webuse nlswork, clear
rifhdreg ln_wage collgrad age i.race nev_mar union c_city ttl_exp, rif(q(10)) 
qregplot collgrad, q(2.5(2.5)97.5) name(m1, replace) title(UQR)
rifhdreg ln_wage collgrad age i.race nev_mar union c_city ttl_exp, rif(q(10))  ///
   over(collgrad)
qregplot collgrad, q(2.5(2.5)97.5) name(m2, replace) title(QTE over())
rifhdreg ln_wage collgrad age i.race nev_mar union c_city ttl_exp, rif(q(10)) ///
   over(collgrad) rwlogit( age i.race nev_mar union c_city ttl_exp)
qregplot collgrad, q(2.5(2.5)97.5) name(m3, replace) title(QTE over() RWGT)

graph combine m1 m2 m3, col(3) xsize(10) ysize(4) ycommon nocopies scale(1.3)
graph export fig9.png, replace

gen wage=exp(ln_wage)
rifhdreg  wage collgrad age i.race nev_mar union c_city ttl_exp, rif(gini) scale(100)
est sto m1
rifhdreg  ln_wage collgrad age i.race nev_mar union c_city ttl_exp, rif(std) 
est sto m2
rifhdreg  wage collgrad age i.race nev_mar union c_city ttl_exp, rif(iqratio(20 80))
est sto m3

rifhdreg  wage collgrad age i.race nev_mar union c_city ttl_exp, rif(gini) scale(100) over(collgrad) 
est sto m1b
rifhdreg  ln_wage collgrad age i.race nev_mar union c_city ttl_exp, rif(std)  over(collgrad)
est sto m2b
rifhdreg  wage collgrad age i.race nev_mar union c_city ttl_exp, rif(iqratio(20 80)) over(collgrad)
est sto m3b

esttab m1 m1b m2 m2b m3 m3b , nogap se mtitle(Gini TE-Gini Std TE-Std IQRT QTE-IQTR) beta(4)


**************************

use http://fmwww.bc.edu/RePEc/bocode/o/oaxaca.dta, clear
gen wage = exp(lnwage)
oaxaca_rif wage educ exper tenure [pw=wt], rif( q(50) ) by(female)

oaxaca_rif wage educ exper tenure [pw=wt], rif( q(50) ) by(female) rwlogit(educ exper tenure)

oaxaca_rif wage educ exper tenure [pw=wt], rif( q(10) ) by(female)
est sto m1
oaxaca_rif wage educ exper tenure [pw=wt], rif( q(90) ) by(female)
est sto m2
oaxaca_rif wage educ exper tenure [pw=wt], rif( gini ) by(female) scale(100)
est sto m3
oaxaca_rif wage educ exper tenure [pw=wt], rif( iqratio(80 20) ) by(female)
est sto m4

esttab m1 m2 m3 m4, nogaps se mtitle(q10 q90 gini iqratio)