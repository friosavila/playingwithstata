*! v1.0 Restricted Cubic Splines for f_able.
*!      based on mkspline Stata tech notes
capture program drop  frcspline
program define frcspline
	syntax anything=/exp, [Knots(string) NKnots(string)]
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
			 _pctile `exp', p(10 50 90)
		}
		if `nknots'==4 {
			 _pctile `exp', p(5 35 65 95)
		}
		if `nknots'==5 {
			 _pctile `exp', p(5 27.5 50 72.5 95)
		}
		if `nknots'==6 {
			 _pctile `exp', p(5 23   41 59   77 95)
		}
		if `nknots'==7 {
			 _pctile `exp', p(2.5 18.33 34.17 50 65.83 81.67 97.5)
		}
		forvalues j = 1 / `nknots' {
			local k`j' = `r(r`j')'
		}
	}
	
	else if "`knots'"!="" {
	    numlist "`knots'", min(3) range(>0 <100) sort
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
