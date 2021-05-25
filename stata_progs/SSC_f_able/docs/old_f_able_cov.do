capture program drop _all
program f_able_cov, 
	*** stripper
	local coln:colnames e(b)
	local coln=subinstr("`coln'","#"," ",.)
	local coln=subinstr("`coln'","c.","",.)
	local coln=subinstr("`coln'","co.","",.)
	local coln=subinstr("`coln'","o.","",.)
	local coln=subinstr("`coln'","_cons","",.)
	**this identifies what are variables
	foreach i of local coln {
	    error 0
	    capture qui _ms_dydx_parse `i'
		if _rc==0 {
			local coln2 `coln2' `i'
		}
	}
	**This eliminates doubles.
	foreach i of local coln2 {
	    local flag=1
	    foreach j of local coln3 {
			if ("`i'"=="`j'") {
				local flag=0
			}
		}
		if `flag' == 1 {
			local coln3 `coln3' `i'
		}
	}
	display "Covariates list:`coln3'"
end	
