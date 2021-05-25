*! v1.0 Restricted Cubic Splines for f_able.
*!      based on mkspline Stata tech notes
*!      This version uses centile when no weights are provided, and _pctile when weights are used.
capture program drop  f_rcspline
program define f_rcspline
	syntax anything=/exp [if] [in], [Knots(str) NKnots(str) weight(varname)]
	
	if "`knots'`nknots'"=="" {
	    display in red "Knots or NKnots required"
	    error 1
	}
	if "`knots'"!="" & "`nknots'"!="" {
	    display in red "Only one option allowed"
	    error 1
	}
	if "`nknots'"!="" {
	    numlist "`nknots'", max(1) range(>=3 <=7)
		local knot `r(numlist)'
		if `nknots'==3 {
			local mylist 10 50 90
		}
		if `nknots'==4 {
			local mylist 5 35 65 95
		}
		if `nknots'==5 {
			local mylist  5 27.5 50 72.5 95
		}
		if `nknots'==6 {
			local mylist 5 23   41 59   77 95
		}
		if `nknots'==7 {
			local mylist 2.5 18.33 34.17 50 65.83 81.67 97.5
		}
		
		if "`weight'"!="" {
			_pctile `exp' `if' `in' [aw=`weight'],  p(`mylist')
			forvalues j = 1 / `nknots' {
				local k`j' = `r(r`j')'
			}
		}
		else {
			qui:centile `exp' `if' `in',  centile(`mylist')
			forvalues j = 1 / `nknots' {
				local k`j' = `r(c_`j')'
			}
		}
	}
	
	else if "`knots'"!="" {
	    numlist "`knots'", min(3) sort
		foreach i in `r(numlist)' {
		    local j= `j'+1
		    local k`j' = `i'
		}
		local nknots `j'
	}
	
	forvalues i  = 2/ `=`nknots'-1' {
		local ii = `i'-1
		local n = `nknots'
		local n_1 = `nknots'-1
		fgen `anything'`i'=(max(`exp'-`k`ii'',0)^3- ///
				(`k`n''-`k`n_1'')^-1*  ///
				((max(`exp'-`k`n_1'',0)^3)*(`k`n''-`k1')-(max(`exp'-`k`n'',0)^3)*(`k`n_1''-`k1'))   )  /  ///
				(`k`n''-`k1')^2
	}
end
