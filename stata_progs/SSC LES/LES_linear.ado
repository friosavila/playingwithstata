*!v1.1 adds min consumption estimation
capture program drop LES_linear
version 13
program LES_linear, rclass
syntax [if] ,  expenditures(str) poverty(str) [controls(str) wgt(str) /*totexp(str)*/ ]
    marksample touse 
	markout `touse' `controls' `expenditures' `wgt'
	 
	if "`wgt'"=="" local wgt=1
	qui {
	*matrix drop _all
	local cnt=0
	tempvar totexp
	egen double `totexp'=rowtotal(`expenditures')
	tempname m_i sh_i n_i nij 
	foreach i in `expenditures' {
	    local cnt=1+`cnt'
		reg `i' `totexp' `controls' if `touse'==1 [w=`wgt']
		matrix `m_i'=nullmat(`m_i')\_b[`totexp']
		tempvar sh_`i'
		capture gen `sh_`i''=`i'/`totexp'  
		reg `sh_`i'' if `touse'==1 [w=`wgt']
		matrix `sh_i'=nullmat(`sh_i')\_b[_cons]
	}

	matrix list `m_i'
	matrix list `sh_i'
	local mrow=rowsof(`m_i')
	forvalues i=1/`mrow' {
	matrix `n_i'=nullmat(`n_i')\ `m_i'[`i',1]/`sh_i'[`i',1]
	}
	sum `totexp' if `touse'==1 [w=`wgt']
	local mn_exp=r(mean)
	
	if 0.9*`mn_exp'>=`poverty' {
		local sig_c=(`mn_exp'-`poverty')/`mn_exp'
		}
	else {
		local sig_c=1/10
		}	
	matrix `nij'=J(`cnt',`cnt',.)
	
	forvalues i=1/`cnt' {
		forvalues j=1/`cnt' {
			if `i'==`j'  matrix `nij'[`i',`j']=-`n_i'[`i',1]*(`sig_c'*(1-`m_i'[`i',1])+`sh_i'[`i',1])
			if `i'!=`j'  matrix `nij'[`i',`j']=-`n_i'[`i',1]*(`sig_c'*( -`m_i'[`j',1])+`sh_i'[`j',1])
		}
	}
	}
	matrix roweq `nij' = cons_i
	matrix coleq `nij' = price_j 
	matrix coleq `m_i' = beta
	matrix coleq `sh_i'= budget_sh
	matrix coleq `n_i' = inc_elas
 	tempname all	
	tempname gamma
	matrix `gamma'=`mn_exp'*(`sh_i'-`m_i'*`sig_c')
	matrix coleq `gamma'=min_good
	matrix `all'=`m_i',`sh_i',`n_i', `gamma'
	matrix rowname `all'=`expenditures'
	matrix colname `nij'=`expenditures'
	matrix rowname `nij'=`expenditures'
	matrix list `all', format(%10.5g)
	matrix list `nij', format(%6.5f)
	local F=-1/`sig_c'
	local G=((1+`F')/`F')*`mn_exp'
	display as text " "
	display as text "Sample Constrain                 : `if' "
	display as text "Cost of Minimum comodities Basket:" as result `G'
	display as text "Implicit Frisch parameter        :" as result `F'
	display as text "Avg Household Income             :" as result `mn_exp'
	display as text "Povery Line                      :" as result `poverty'
	return matrix all=`all'
	return matrix nij=`nij'
	return scalar frisch=`F'
	return scalar gamma=`G'
	return scalar avg_exp=`mn_exp'
end
