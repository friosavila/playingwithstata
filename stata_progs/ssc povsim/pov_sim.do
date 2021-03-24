

capture program drop _prank
program define _prank
	syntax newvarlist , svar(varname) mvar(varname) [ byvar(varname) wvar(varname) tvar(varname) ]  
	local v1 :word 1 of `varlist'
	local v2 :word 2 of `varlist'
	local v3 :word 3 of `varlist'
	// Sort by, touse, main var and sort variable
	sort `tvar' `byvar' `svar' `wvar'
	if "`wvar'"=="" {
	    local wvar2=1
	}
	else {
	    local wvar2 `wvar'
	}
	tempvar sumw awgt nn g
	by `tvar' `byvar':gen double `sumw'=sum(`wvar2'/_N)
	by `tvar' `byvar':gen double `awgt'=`wvar2'/`sumw'[_N]
	by `tvar' `byvar':replace    `sumw'=sum(`awgt')
	by `tvar' `byvar':gen double `nn'=`sumw'[_N]
	by `tvar' `byvar':gen double `v1'=sum(`mvar'*`awgt'/`nn')
	by `tvar' `byvar' `svar' :gen double `v2'=0.5*(`sumw'[_N]+`sumw'[1]-`awgt'[1])/`nn'
    by `tvar' `byvar':gen double `v3'=sum((`mvar'-`v1'[_N])*(`v2'-0.5)*`awgt'/`nn')
	by `tvar' `byvar':replace    `v1'=`v1'[_N]
	by `tvar' `byvar':replace    `v3'=2*`v3'[_N]/`v1'[_N]
end


 capture program drop pov_gg
program pov_gg,   sortpreserve
syntax varname [if] [in], [weight(varname) gini_goal(numlist >0) growth(numlist )  ] gen(str)
	// First define sample
	qui {
		tempvar touse
		gen byte `touse' = 1
		replace `touse' = 1 `if' `in'  
		markout `touse' `weight' `varlist'
		
		// step 1. estimate gini
		tempvar glp rnk cov
		// uses prank from above
		_prank `glp' `rnk' `cov', svar(`varlist') mvar(`varlist') wvar(`weight') tvar(`touse')
		local gini0 = `cov'[1]
		local mean0 = `glp'[1]
		// safe saves
		if "`gini_goal'"=="" {
			local gini_goal `gini0'
		}
		if "`growth'"=="" {
			local growth 0
		}
		// calculate sig0 for that gini
		local sig0= invnormal( (`gini0'+ 1) * 0.5) * sqrt(2) 
		// calculate sig1 for gini_goal
		local sig1= invnormal( (`gini_goal'+ 1) * 0.5) * sqrt(2) 
		tempvar sim0 sim1
		// estimating yhats or derivatives for both scenarios
		gen double `sim0'=`mean0'*normalden( invnormal(`rnk') -  `sig0') * 1/normalden(invnormal(`rnk'))
		gen double `sim1'=`mean0'*(1+`growth')*normalden( invnormal(`rnk') -  `sig1') * 1/normalden(invnormal(`rnk'))
		// sim data based on real data:
		tempvar yhat
		gen double `yhat' = `varlist' * `sim1'/`sim0' 
		ren `yhat' `gen'
	}
	*return post local gini = `gini0'
	*return post local mean = `mean0'
end

** once data has been created we can analyze it
capture program drop poverty_sum 
program poverty_sum , rclass sortpreserve
	syntax varlist [if] [in] , pline(str) [ weight(varname) alpha(numlist >=0) by(varname) ] 

	tempvar touse
	qui:gen byte `touse' = 0
	qui:replace `touse' = 1 `if' `in'  
	qui:markout `touse' `weight' `varlist' `by'
	qui:replace `touse' = 0 if `pline' ==. 

	if "`weight'" == "" {
		tempvar weight 
		qui:gen byte `weight'=1
	}
	if "`alpha'" == "" {
		local alpha 0 1 2
	}
	
	tempname table taux
	
	foreach j of varlist `varlist' {
		local clname
		local vlist
		local cnt =0
		foreach i of local alpha {
			local cnt =	 `cnt'+1
			tempvar `j'_`cnt'			
			if `i' == 0 {
				qui:gen double ``j'_`cnt''= `j' < `pline' if `touse'
			}
			else {
				qui:gen double ``j'_`cnt''= ((`pline'-`j')/`pline' * (`j' < `pline'))^`i'  if `touse'
			}
			label var ``j'_`cnt'' "`j' alpha = `i'" 
			local vlist `vlist'  ``j'_`cnt''			
			local clname  `clname'  alpha=`i'
			
		}	
		local rwname `j'
		qui:tabstat `vlist' [aw=`weight'] if `touse', save
		matrix `taux' =  r(StatTotal)	
		matrix colname `taux' = `clname'
		matrix rowname `taux' = `rwname'
	 
		matrix `table'=nullmat(`table') \ `taux'
	}
	display as result "Povery measures by variable"
	matrix list `table', noheader title(Poverty)
	return matrix table = `table'
	
end 

**example
use http://fmwww.bc.edu/RePEc/bocode/o/oaxaca.dta, clear
drop if lnwage==.
gen wage = exp(lnwage)

pov_gg wage, gen(newwage) growth(0.05) gini_goal(0.27)
poverty_sum wage newwage, pline(20) alpha(0 0.1 0.2 0.3 3)






