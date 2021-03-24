clear 
set seed 2038942
set obs 1000
gen i=_n

gen u=rnormal(0,.5)
mat m=(0, 1, 2)
mat sd=(1, 2, 3)
drawnorm x1 x2 x3, means(m) sds(sd)
gen double y=2*x1+4*x2-0.5*x3+u
replace y=cond(y>0, y, 0)
tobit y x1 x2 x3, ll(0)



capture program drop mytobit_p
program mytobit_p
	syntax newvarname [if] [in] , [ my_ystar my_e *]
	** This just does standard tobit margins
	if "`my_ystar'`my_e'" =="" {
	    tobit_p `0'
	}
	** here I will do my version of tobit margins
	marksample touse, novarlist
	if "`my_e'" !=""  {
	    tempvar xb sigma2
	    _predict double `xb'   , eq(#1)
		_predict double `sigma2', eq(#2)
		tempvar xb_sig lambda
		gen double `xb_sig'=`xb'/sqrt(`sigma2')
		sum `xb_sig'
		gen double `lambda'=normalden(`xb_sig')/normal(`xb_sig') 
		sum `lambda'  
		replace    `lambda'=0         if `xb_sig'>0 & `lambda'==.
		sum `lambda'  
		replace    `lambda'=`xb_sig'/( 0.9453756004262056*abs(`xb_sig')^-1.9829325222070033-1.0000056985402233) if `xb_sig'<0 & `lambda'==.
		sum `lambda'  `xb_sig' if `lambda'!=.
		sum `lambda'  `xb_sig' if `lambda'==.
		gen `typlist' `varlist' = `xb'+sqrt(`sigma2')*`lambda' if `touse'
		label var `varlist' "my_e"
	}	
	else if "`my_ystar'"!="" {
		tempvar xb sigma2
	    _predict double `xb'   , eq(#1)
		_predict double `sigma2', eq(#2)
		tempvar xb_sig lambda
		gen double `xb_sig'=`xb'/sqrt(`sigma2')
		gen `typlist' `varlist' = normal(`xb_sig')*`xb'+sqrt(`sigma2')*normalden(`xb_sig') if `touse'
		label var `varlist' "my_ystar"
	}
end

adde local predict mytobit_p
margins, dydx(*) predict(my_e)
margins, dydx(*) predict(my_ystar)
 


