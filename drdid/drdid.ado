*! v0 DRDID for Stata by FRA
* For panel only for now
capture program drop drdid
program define drdid, eclass sortpreserve
	syntax varlist [if] [in], ivar(varname) time(varname) TReatment(varname) [noisily ]
	marksample touse
	markout `touse' `ivar' `time' `treatment'
	** First determine outcome and xvars
	gettoken y xvar:varlist
	** Sanity Checks for Time. Only 2 values
	tempvar vals
	qui:bysort `touse' `time': gen byte `vals' = (_n == 1) * `touse'
	su `vals' if `touse', meanonly 
	if  r(sum)!=2 {
	    display in red "Time variable can only have 2 values in the working sample"
		error 1
	}
	drop `vals'
	qui:bysort `touse' `treatment': gen byte `vals' = (_n == 1) * `touse'
	su `vals' if `touse', meanonly
 
	if  r(sum)!=2 {
	    display in red "Treatment variable can only have 2 values in the working sample"
		error 1
	}
	else {
		tempvar trt
		qui:egen byte `trt'=group(`treatment') if `touse'
		qui:replace `trt'=`trt'-1
	}
	** estimate model
	
	display "Estimating IPT"
	qui {
		`isily' ml model lf drdid_logit (`trt'=`xvar') if `touse' , maximize  robust
		`isily' ml display
		tempname iptb iptV
		matrix `iptb'=e(b)
		matrix `iptV'=e(V)
		tempvar prx
		predictnl double `prx'=logistic(xb())
		** Determine dy and dyhat
		capture drop __dy__
		tempvar tag
		bysort `ivar' (`time'):gen double __dy__=`y'[2]-`y'[1] if `touse'
		bysort `ivar' (`time'):gen byte `tag'=_n
		** determine weights
		tempvar w1 w0
		gen double `w1' = `trt'
		gen double `w0' = ((`prx'*(1-`trt')))/(1-`prx')
		
		sum `w1' if `touse', meanonly
		replace `w1'=`w1'/r(mean)
		sum `w0' if `touse', meanonly
		replace `w0'=`w0'/r(mean)
		
		** estimating dy_hat for a counterfactual
	}
	display "Estimating Counterfactual Outcome"
	qui {	
	    tempname regb regV
		`isily' reg __dy__ `xvar' [w=`w0'] if `trt'==0 ,
		matrix `regb' =e(b)
		matrix `regV' =e(V)
		tempvar dyhat
		qui:predict double `dyhat'
		tempvar att
		qui:gen double `att'=__dy__-`dyhat'
		capture drop __att__
		sum `att' if `touse' & `trt'==1, meanonly
		gen double __att__ = r(mean)+  (`w1'-`w0')*`att'-`w1'*r(mean) if `tag'==1  & `touse'
	}
	display "Estimating ATT"
	reg __att__ if   `touse'
	*** Wrapping all
	ereturn local cmd drdid
	ereturn local cmdline drdid `0'
	ereturn scalar att    =`=_b[_cons]'
	ereturn scalar attvar =`=_se[_cons]'
	ereturn matrix iptb `iptb'
	ereturn matrix iptV `iptV'
	ereturn matrix regb `regb'
	ereturn matrix regV `regV'
end

 
