*! version 3.0  (2021) By Fernando Rios-Avila
* Inspired  by grqreg (Pedro Azevedo)
* This is an attempt to "update" grqreg by allowing for factor notation
* and providing more flexibility in how plots are generated. (and how are options used)
capture program drop grqreg2
capture program drop qreg_stripper
capture program drop is_vlist_in_xlist
capture program drop estore
capture program drop mynlist
capture program drop qrgraph
capture program drop rifhdreg_stripper
capture program drop rif_striper

program define grqreg2, rclass

    syntax [varlist( fv default=none)]             ///
        [,                          ///
        Quantile(string)            /// defines list of quantiles 
        cons                        /// Indicates to plot constant
        ols olsopt(string)          /// If one wants OLS results
        raopt(string) 				///	
		lnopt(string)                 /// Options for RArea plot
		grcopt(string)                 /// Options for GRcombine plot
		twopt(string) 					/// Options for two way plot
		seed(string)			    /// If one uses bsreg
		savemat						/// If one wants to save the results as matrices in r()
		estore(string)				/// If one wants to save the results in e() (est store)
		esave(string)				/// If one wants to save the results as str (est save)
		from(string)				/// if you have stored coefficients
        ]
	
	if "`from'"!="" {
	    ** idea.. if we can do from memory, we save time and money!!
		qrgraph `varlist',  from(`from') `cons'  `ols' raopt(`raopt') lnopt(`lnopt') grcopt(`grcopt')  twopt(`twopt') 
		exit
	}
	if !inlist("`e(cmd)'","qreg","bsqreg","mmqreg","rifhdreg") {
	    display in red "This command can only be used after -qreg- ,-bsqreg- or mmqreg "
		error 1
	}
	else {
	    tempname lastreg
	    estimates store `lastreg'
	}
	** Gathering information
	** Get command line
	if "`quantile'"!="" {
		mynlist "`quantile'"
		local qlist `r(numlist)'
	}
	else {
	    mynlist "10(5)90"
		local qlist `r(numlist)'
	}
	local xvars `=subinstr("`e(cmdline)'","`e(cmd)'","",1)'
	*local xvars `=subinstr("`xvars'","qreg","",1)'
	if inlist("`e(cmd)'","qreg","bsqreg","mmqreg") {
	 	qui:qreg_stripper `xvars'
		** estimate all variables
		local cmd  `e(cmd)'
		local xvar `r(xvar)'
		local yvar `r(yvar)'
		local qnt  `r(qnt)'
		local oth  `r(oth)'
		local ifin `r(ifin)'
		local wgt  `r(wgt)'
	}
	else {
	    qui:rifhdreg_stripper `xvars'
		local cmd  `e(cmd)'
		local xvar `r(xvar)'
		local yvar `r(yvar)'
		local qnt  `r(q)'
		local qopt `r(qopt)'
		local oth  `r(oth)'
		local ifin `r(ifin)'
		local wgt  `r(wgt)'
	}
	** verify variables in list exist.
	ms_fvstrip `xvar', expand dropomit
	local xlist `r(varlist)'
		
	if "`varlist'"!="" {

		ms_fvstrip `varlist', expand dropomit
		local vlist `r(varlist)'
		is_vlist_in_xlist, vlist(`vlist') xlist(`xlist')
	}
	** check if bsqreg
	local crnst  `c(rngstate)'
	** estimate all qreg
	tempvar aux bs   ll  ul qq
	tempvar     bso  llo ulo  
	if "`cmd'"=="mmqreg" {
	    local qtc "qtile"
	}
	
	if "`ols'"!="" {
	    tempname olsaux
		qui:regress `yvar' `xvar' `ifin' `wgt',  `olsopt'
		matrix `olsaux'=r(table)
	}
	
	if "`cmd'"=="rifhdreg" {
		foreach q of local qlist {
			qui:`cmd' `yvar' `xvar' `ifin' `wgt',  `oth' rif(q(`q' `qopt')) 
			matrix `aux'=r(table)
			matrix `qq'=nullmat(`qq') \ `q' 
			matrix `bs'=nullmat(`bs') \ `aux'["b" ,"`qtc':"]
			matrix `ll'=nullmat(`ll') \ `aux'["ll","`qtc':"]
			matrix `ul'=nullmat(`ul') \ `aux'["ul","`qtc':"]
			if "`ols'"!="" {
				matrix `bso'=nullmat(`bso') \ `olsaux'["b" ,":"]
				matrix `llo'=nullmat(`llo') \ `olsaux'["ll",":"]
				matrix `ulo'=nullmat(`ulo') \ `olsaux'["ul",":"]
			}
		}
	}
	else {
	    foreach q of local qlist {
			if "`cmd'"=="bsqreg" {
				if "`seed'"!="" set seed `seed'		
			}
			qui:`cmd' `yvar' `xvar' `ifin' `wgt',  `oth' q(`q')
			matrix `aux'=r(table)
			matrix `qq'=nullmat(`qq') \ `q' 
			matrix `bs'=nullmat(`bs') \ `aux'["b" ,"`qtc':"]
			matrix `ll'=nullmat(`ll') \ `aux'["ll","`qtc':"]
			matrix `ul'=nullmat(`ul') \ `aux'["ul","`qtc':"]
			if "`ols'"!="" {
				matrix `bso'=nullmat(`bso') \ `olsaux'["b" ,":"]
				matrix `llo'=nullmat(`llo') \ `olsaux'["ll",":"]
				matrix `ulo'=nullmat(`ulo') \ `olsaux'["ul",":"]
			}
		}
	}
	
	tempname sbs sols
	** Making Graphs
	** what variables?
	local cnt =0
	if "`varlist'"=="" {
	    local fxvar `xvar'
	}    
	else {
	    local fxvar `varlist'
	}
	
	*Makes graphs for ALL variables
	ms_fvstrip `fxvar', expand dropomit
	local vlist `r(varlist)'
	if "`cons'"!="" local vlist `vlist' _cons
    local gcnt: word count `vlist'

	
	foreach v of local vlist {
		local cnt = `cnt' + 1
		matrix `sbs' = `qq',`bs'[....,"`qtc':`v'"],`ll'[....,"`qtc':`v'"],`ul'[....,"`qtc':`v'"]
		svmat `sbs'
		** if OLS is requested
		if "`ols'"!="" {
			matrix `sols'=`bso'[....,"`v'"],`llo'[....,"`v'"],`ulo'[....,"`v'"]
			svmat `sols'
			local olsci (line `sols'1 `sols'2 `sols'3 `sbs'1, lpattern(solid - -) lcolor(black gs5 gs5) )
 
		}
		** label variables
		local vlab
		capture local vlab:variable label `v'
		if "`v'"=="_cons" local vlab Intercept
		if "`vlab'"=="" local vlab `v'
		label var `sbs'1 "Quantile"
		tempname m`cnt'
		if `gcnt'>1 {
			twoway  (rarea `sbs'3 `sbs'4 `sbs'1 , `raopt' ) || ///
				   (line `sbs'2 `sbs'1, lp(solid) `lnopt') `olsci' , ///
				   name(`m`cnt'', replace) legend(off) nodraw ///
				   title(`vlab') `twopt'
			local grcmb	 `grcmb' `m`cnt''
		}
		else {
		    twoway  (rarea `sbs'3 `sbs'4 `sbs'1 , `raopt' ) || ///
				   (line `sbs'2 `sbs'1, lp(solid) `lnopt') `olsci' , ///
				   legend(off)   ///
				   title(`vlab') `twopt'
		}
		qui:drop `sbs'*	   
		capture drop `sols'*
	}
	
	if `gcnt'>1 {
		graph combine `grcmb', `grcopt'
		graph drop `grcmb'
	}
	
	if "`savemat'"!="" {
	    return matrix qq `qq'
		return matrix bs `bs'
		return matrix ll `ll'
		return matrix ul `ul'
		return local  xvars `xval'
		return matrix bso `bso'
		return matrix llo `llo'
		return matrix ulo `ulo'
	}
	
	if "`estore'"!="" {
	    estore, qq(`qq') bs(`bs') ll(`ll') ul(`ul') xlist(`xlist') bso(`bso') llo(`llo') ulo(`ulo') `ols'
		est store `estore'
	}
	
	if "`esave'"!="" {
	    estore, qq(`qq') bs(`bs') ll(`ll') ul(`ul') xlist(`xlist') bso(`bso') llo(`llo') ulo(`ulo') `ols'
		est save `esave'
	}
	
	qui:est restore `lastreg'
	set rngstate `crnst' 
end

program define estore, eclass
	syntax, xlist(string) qq(string) bs(string) ll(string) ul(string) [bso(string) llo(string) ulo(string) ols]
	tempname b
	matrix `b'=1
	ereturn post `b'
	ereturn local cmd grqreg2
	ereturn local xlist `xlist'
	ereturn matrix qq `qq'
	ereturn matrix bs `bs'
	ereturn matrix ll `ll'
	ereturn matrix ul `ul'
	if "`ols'"!="" {
	    ereturn matrix bso `bso'
		ereturn matrix llo `llo'
		ereturn matrix ulo `ulo'
	    ereturn local ols ols
	}
	
end

program define mynlist,rclass
        syntax anything, 
        numlist `anything',  range(>0 <100) sort
        loca j scalar(_pi)
        foreach i in  `r(numlist)' {
                if `i'!=`j' {
                    local numlist `numlist' `i'
                } 
                local j=`i'
        }
        return local numlist `numlist'
end

program define is_vlist_in_xlist
syntax , vlist(str) xlist(str)
	foreach i of local vlist {
	    local flag=0
	    foreach j of local xlist {
		    if "`i'"=="`j'" {
			    local flag=1
			}
		}
		if `flag' == 0 {
		    display in red "Error, variable `i' not found in varlist"
			error 1
		}
	}
end 

program define qreg_stripper, rclass
	syntax anything [if] [in] [aw iw pw fw], [Quantile(real .5)] *
	local xvar `=subinstr("`anything'","`e(depvar)'","",1)' 
	local yvar `e(depvar)'
	local qnt  `quantile'
	local oth  `options'
	local ifin `if' `in'
	if "`e(wtype)'`e(wexp)'"!="" local wgt  [`e(wtype)'`e(wexp)']
	return local xvar `xvar'
	return local yvar `yvar'
	return local oth  `oth'
	return local ifin `ifin'
	return local wgt `wgt'
end

program define qrgraph,
	syntax [varlist( fv default=none)]             ///
			, from(string) ///
			[ cons  raopt(str) lnopt(str) 	grcopt(str)	twopt(str) ]
	tempname lastreg
	capture:est store `lastreg'
			
	qui:est restore `from'	
	tempname qq bs ll ul bso llo ulo 
	matrix `qq'=e(qq)
	matrix `bs'=e(bs)
	matrix `ll'=e(ll)
	matrix `ul'=e(ul)
	
	if "`e(ols)'"!="" {
		matrix `bso'=e(bso)
		matrix `llo'=e(llo)
		matrix `ulo'=e(ulo)
		local ols `ols'
	}
	
	local xlist `e(xlist)'
	
	if "`varlist'"!="" {
 		ms_fvstrip `varlist', expand dropomit
		local vlist `r(varlist)'
		is_vlist_in_xlist, vlist(`vlist') xlist(`xlist')
	}
	
	local cnt =0
	if "`varlist'"=="" {
	    local fxvar `xlist'
	}    
	else {
	    local fxvar `vlist'
	}
	
	ms_fvstrip `fxvar', expand dropomit
	local vlist `r(varlist)'
	
	if "`cons'"!= "" {
	   local vlist `vlist' _cons
	}
	************************************
	 
    local gcnt: word count `vlist'
 
	tempname sols sbs
	
	foreach v of local vlist {
		local cnt = `cnt' + 1
		matrix `sbs' = `qq',`bs'[....,"`qtc':`v'"],`ll'[....,"`qtc':`v'"],`ul'[....,"`qtc':`v'"]
		svmat `sbs'
		** if OLS is requested
		if "`ols'"!="" {
			matrix `sols'=`bso'[....,"`v'"],`llo'[....,"`v'"],`ulo'[....,"`v'"]
			svmat `sols'
			local olsci (line `sols'1 `sols'2 `sols'3 `sbs'1, lpattern(solid - -) lcolor(black gs5 gs5) )
 
		}
		** label variables
		local vlab
		capture local vlab:variable label `v'
		if "`v'"=="_cons" local vlab Intercept
		if "`vlab'"=="" local vlab `v'
		label var `sbs'1 "Quantile"
		tempname m`cnt'
		if `gcnt'>1 {

			twoway  (rarea `sbs'3 `sbs'4 `sbs'1 , `raopt' ) || ///
				   (line `sbs'2 `sbs'1, lp(solid) `lnopt') `olsci' , ///
				   name(`m`cnt'', replace) legend(off) nodraw ///
				   title(`vlab') `twopt'
			local grcmb	 `grcmb' `m`cnt''
		}
		else {
		    twoway  (rarea `sbs'3 `sbs'4 `sbs'1 , `raopt' ) || ///
				   (line `sbs'2 `sbs'1, lp(solid) `lnopt') `olsci' , ///
				   legend(off)   ///
				   title(`vlab') `twopt'
		}
		qui:drop `sbs'*	   
		capture drop `sols'*
	}
	
	if `gcnt'>1 {
		graph combine `grcmb', `grcopt'
		graph drop `grcmb'
	}
	
	capture:est restore `lastreg'
	
end

** for RIF REG

program define rifhdreg_stripper, rclass
	syntax anything [if] [in] [aw iw pw fw], rif(str)  [*]
	local xvar `=subinstr("`anything'","`e(depvar)'","",1)' 
	local yvar `e(depvar)'
	local oth  `options'
	local ifin `if' `in'
	if "`e(wtype)'`e(wexp)'"!="" local wgt  [`e(wtype)'`e(wexp)']
	local rif  `rif'
	rif_striper, `rif'
	
	return local xvar `xvar'
	return local yvar `yvar'
	return local oth  `oth'
	return local ifin `ifin'
	return local wgt `wgt'
	return local q    `r(q)'
	return local qopt `r(oth)'
end

program define rif_striper, rclass
	syntax , q(numlist) [*]
	return local q    `q'
	return local oth  `options'
end