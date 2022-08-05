*! v1 FRA 8/5/2022 Has almost everything we need
program jwdid, eclass
	syntax varlist [if] [in] [pw], Ivar(varname) Tvar(varname) Gvar(varname) [never group method(name)]
	marksample  touse
	markout    `touse' `ivar' `tvar' `gvar'
	gettoken y x:varlist 
	
	** Count gvar
	qui:count if `gvar'==0 & `touse'==1 
	if `r(N)'==0 {
		qui:sum `gvar' if `touse'==1 , meanonly
		replace `touse'=0 if `touse'==1 & `tvar'>=r(max)
	}
	qui:capture drop __tr__
	qui:gen byte __tr__=0 if `touse'
	qui:replace  __tr__=1 if `tvar'>=`gvar' & `gvar'>0  & `touse'
	qui:replace  __tr__=1 if `touse' & "`never'"!=""
	qui:capture drop __etr__
	qui:gen byte __etr__=0 if `touse'
	qui:replace  __etr__=1 if `touse' & `tvar'>=`gvar' & `gvar'>0
	
	qui:levels `gvar' if `touse' & `gvar'>0, local(glist)
	sum `tvar' if `touse' , meanonly
	qui:levels `tvar' if `touse' & `tvar'>r(min), local(tlist)
	** Center Covariates
	if "`weight'"!="" local wgt aw
	if "`x'"!="" {
			capture drop _x_*
			qui:hdfe `y' `x' if `touse'	[`wgt'`exp'], abs(`gvar') 	keepsingletons  gen(_x_)
			capture drop _x_`y'
			local xxvar _x_*
	}
	***
	foreach i of local glist {
		foreach j of local tlist {
			if "`never'"!="" {
				local xvar `xvar' c.__tr__#i`i'.`gvar'#i`j'.`tvar' ///
							  i`i'.`gvar'#i`j'.`tvar'#c.(`xxvar') 
 			
			}
			else if `j'>=`i' {
				local xvar `xvar' c.__tr__#i`i'.`gvar'#i`j'.`tvar' ///
							 i`i'.`gvar'#i`j'.`tvar'#c.(`xxvar')   
			}

		}
	}
	** for xs
	
	foreach i of local glist {
		local ogxvar `ogxvar' i`i'.`gvar'#c.(`x')
	}
	foreach j of local tlist {
		local otxvar `otxvar' i`j'.`tvar'#c.(`x')
	}
 	
	if "`method'"=="" {
		if "`group'"=="" {
			reghdfe `y' `xvar'   `otxvar'	///
				if `touse' [`weight'`exp'], abs(`ivar' `tvar') cluster(`ivar') keepsingletons	
		}	
		else {		 
			reghdfe `y' `xvar'  `x'  `ogxvar' `otxvar'  ///
			if `touse' [`weight'`exp'], abs(`gvar' `tvar') cluster(`ivar') keepsingletons
		}
	}
	else {
		`method'  `y' `xvar'  `x'  `ogxvar' `otxvar' i.`gvar' i.`tvar' ///
		if `touse' [`weight'`exp'], cluster(`ivar') 
	}
	ereturn local cmd jwdid
	ereturn local cmdline jwdid `0'
	ereturn local estat_cmd jwdid_estat
	ereturn local ivar `ivar'
	ereturn local tvar `tvar'
	ereturn local gvar `gvar'
	
end


