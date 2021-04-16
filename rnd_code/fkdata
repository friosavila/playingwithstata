** Assumption. You have a dataset that you want to use
clear all
use http://fmwww.bc.edu/RePEc/bocode/o/oaxaca.dta, clear
misstable summarize
gen id = _n
set seed 10101
gen seed = runiform(0,100)
expand 1648 in 1, gen(tag)
foreach i of varlist lnwage educ exper tenure isco female lfp age single married divorced kids6 kids714 wt {
	replace `i'=. if tag==1
}
replace seed = runiform(0,100) if tag==1
replace lfp = runiform()<.87 if tag==1
mi set wide
mi register impute lnwage educ exper tenure   isco female age single married   kids6 kids714 wt
mi impute chain (pmm, knn(100))    educ   female   age single married kids6 kids714 wt (pmm if lfp==1, knn(100) ) lnwage  exper tenure isco  = seed lfp, add(5)

forvalues i = 1/5 {
	preserve
		keep if tag==1
		keep _`i'_* lfp 
		ren _`i'_* *
		save fake_oaxaca_`i', replace
	restore
}
frame create test

frame test: {
	use http://fmwww.bc.edu/RePEc/bocode/o/oaxaca.dta, clear
	qui:reg lnwage educ exper tenure female
	est sto m1
	qui:qreg lnwage educ exper tenure female, q(10)
	est sto m2
	qui:heckman lnwage educ exper tenure female age, selec(lfp =educ     female age single married kids6 kids714) two
	est sto m3
}

forvalues i = 1/5 { 
	frame test: {
		use fake_oaxaca_`i', clear
		
		qui:reg lnwage educ exper tenure female
		est sto m1`i'
		qui:qreg lnwage educ exper tenure female, q(10)
		est sto m2`i'
 
		qui:heckman lnwage educ exper tenure female age, selec(lfp =educ     female age single married kids6 kids714) two
	est sto m3`i'
	} 
}
** OLS
esttab m1 m11 m12 m13 m14 m15, mtitle(Original Fake1 Fake2 Fake3 Fake4 Fake5)
** qreg 10
esttab m2 m21 m22 m23 m24 m25, mtitle(Original Fake1 Fake2 Fake3 Fake4 Fake5)
** heckman
esttab m3 m31 m32 m33 m34 m35, mtitle(Original Fake1 Fake2 Fake3 Fake4 Fake5)  
frame test: {
	use http://fmwww.bc.edu/RePEc/bocode/o/oaxaca.dta, clear
	mean lnwage exper tenure educ   female   age single married kids6 kids714 

	corr lnwage exper tenure educ   female   age single married kids6 kids714 , cov

}
forvalues i = 1/2 { 
	frame test: {
	use fake_oaxaca_`i', clear
mean lnwage exper tenure educ   female   age single married kids6 kids714 

	corr lnwage exper tenure educ   female   age single married kids6 kids714 , cov
	} 
}
