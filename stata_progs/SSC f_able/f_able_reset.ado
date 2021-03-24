*!v1 FRA restores Est attributes
program f_able_reset, eclass
	if "`e(predict_old)'"!="" {
		ereturn local predict `e(predict_old)'
		ereturn local predict_old  
	}
	
	foreach i of varlist `e(nldepvar)' {
		ereturn hidden local _`i' 
	}
	ereturn local nldepvar 
	ereturn local hidden margins_prolog 
	ereturn local hidden margins_epilog 
end