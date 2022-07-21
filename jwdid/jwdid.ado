capture program drop jwdid
program jwdid, eclass
	syntax varlist [if] [in] [pw], Ivar(varname) Tvar(varname) Gvar(varname) [notyet group]
	marksample  touse
	markout    `touse' `ivar' `tvar' `gvar'
	gettoken y x:varlist 
	
	** Count gvar
	qui:count if `gvar'==0 & `touse'==1 
	if `r(N)'==0 {
		qui:sum `gvar' if `touse'==1 
		replace `touse'=0 if `touse'==1 & `tvar'>=r(max)
	}
	qui:capture drop __tr__
	qui:gen byte __tr__=0 if `touse'
	qui:replace  __tr__=1 if `tvar'>=`gvar' & `gvar'>0  & `touse'
	qui:replace  __tr__=1 if `touse' & "`tyet'"!=""
	qui:levels `gvar' if `touse' & `gvar'>0, local(glist)
	sum `tvar' if `touse' , meanonly
	qui:levels `tvar' if `touse' & `tvar'>r(min), local(tlist)
	
	foreach i of local glist {
		foreach j of local tlist {
			if "`tyet'"!="" {
				local xvar `xvar' c.__tr__#i`i'.`gvar'#i`j'.`tvar' ///
							      i`j'.`tvar'#c.(`x')
 			
			}
			else if `j'>=`i' {
				local xvar `xvar' c.__tr__#i`i'.`gvar'#i`j'.`tvar' ///
							      i`j'.`tvar'#c.(`x')
			}
		}
	}
	
	if "`group'"=="" reghdfe `y' `xvar' if `touse' [`weight'`exp'], abs(`ivar' `tvar') cluster(`ivar') keepsingletons	
	else {		 
		reghdfe `y' `xvar' if `touse' [`weight'`exp'], abs(`gvar' `tvar') cluster(`ivar') keepsingletons
	}
	ereturn local cmd jwdid
	ereturn local cmdline jwdid `0'
	ereturn local estat_cmd jwdid_estat
	ereturn local ivar `ivar'
	ereturn local tvar `tvar'
	ereturn local gvar `gvar'
end


