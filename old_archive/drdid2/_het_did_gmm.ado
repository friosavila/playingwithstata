*! version 1.0.0  17may2021

program define _het_did_gmm, rclass sortpreserve
        syntax varlist(numeric fv ts) [if] [in]                 ///
                        [fweight iweight pweight aweight],      ///
                        [                               		///
                            groupvar(string)					///
							psvars(string)						///
							estimator(string)					///
							treatvar(string)					///
							timevar(string)						///
							probit								///
							csdid								///
							noCONstant                     		///
							ITERate(integer 100)				///
							vce(passthru)						///
							touse2(string)						///
							*									///
                        ]

	// !! constant per equation 
	// !! make parmlist a separate program 
	// !! handling weights ?? verify Fernando vs GMM 
	// !! conditioning on t==0 ?? robust vs cluster cond t=0 
	// !! unbalanced samples 
		
	marksample touse 

	tempname init b V 
	
	// Getting weights 
	
	if "`weight'" != "" {
		local wgt [`weight' `exp']
	}

	// depvar and varlist 
	
	gettoken lhs rhs : varlist
    _fv_check_depvar `lhs'
	
	fvexpand `rhs'
	local xvars "`r(varlist)'"
	
	// Getting initial values for gmm 
	
	_Init_Values if `touse' `wgt', estimator(`estimator') 	///
					 `probit' 								///
					  xvars(`xvars') 						///
					  treatvar(`treatvar')					///
					  groupvar(`groupvar')					///
					  lhs(`lhs')
	
	matrix `init' = r(init)

	// Defining which estimator, parameters, instruments, and equations
	
	local estimator dripw

	local eqlist "atet treatment outcome w0 w1"
	_Param_list, vars(`xvars') pnom(treatment) `constant'
	local parmt "`s(parmlist)'"
	_Param_list, vars(`xvars') pnom(outcome) `constant'
	local parmy "`s(parmlist)'"
	local parms "atet:_cons `parmt' `parmy' w0:_cons w1:_cons"

	if ("`vce'"=="") {
		local vce vce(cluster `groupvar')
	}
	di ""
	gmm _gmm_`estimator' if `touse' `wgt',							///
					    `probit'									///
					    ty(`treatvar')								///
					    y(`lhs')									///
						groupvar(`groupvar')						///
						timevar(`timevar')							///
					    from(`init')								///
						equations(`eqlist')							///
						parameters(`parms')							///
						instruments(treatment:`xvars', `constant')	///
						instruments(outcome: `xvars', `constant')	///
                        quickderivatives							///
                        winit(unadjusted, independent) onestep		///
						conv_maxiter(`iterate') `vce' iterlogonly	///
						valueid("EE criterion")

		matrix `b' = e(b)
		matrix `V' = e(V)		

		_Re_Stripe, treatvar(`treatvar')
		local stripe "`s(stripe)'"
		matrix colname `b' =  `stripe'
		matrix colname `V' = `stripe'
		matrix rowname `V' = `stripe'
		quietly replace `touse2' = e(sample)
		local N = e(N)
        return local vcetype "`e(vcetype)'"
		if ("`e(vce)'"=="cluster") {
			local N_clust = e(N_clust)
			return scalar N_clust = `N_clust'
			return local vce "`e(vce)'"
			return local clustvar "`e(clustvar)'"
		}
		return matrix b = `b'
		return matrix V = `V'
		return scalar N = `N'
end

program define _Re_Stripe, sclass
	syntax [anything], [treatvar(string)]
	local cols: colfullnames e(b)
	local uno: word 1 of `cols'
	local stripe0: list cols - uno
	local stripe "ATET:r1vs0.`treatvar' `stripe0'"
	sreturn local stripe "`stripe'"
end 

program define _Param_list, sclass
	syntax [anything], [vars(string) pnom(string) noCONstant] 
	local k: list sizeof vars
	local parmlist ""
	forvalues i=1/`k' {
	    local x: word `i' of `vars'
	    local parmlist "`parmlist' `pnom':`x'"
	}
	if ("`constant'"=="") {
		local parmlist "`parmlist' `pnom':_cons"
	}
	sreturn local parmlist "`parmlist'"
end 

program define Stri_PE_S, sclass
	syntax [anything], [ tvars(string) xvars(string) tr(string)]
	
	local kx: list sizeof xvars
	local kt: list sizeof tvars 
	local stripe "ATET:r1vs0.`tr'"
	
	forvalues i=1/`kt' {
			local tv: word `i' of tvars 
			local stripe "`stripe' treatment:`tv'"
	}
	forvalues i=1/`kx' {
			local xv: word `i' of xvars 
			local stripe "`stripe' treatment:`xv'"
	}
	sreturn local stripe "`stripe'"
end

program define _Init_Values, rclass
	syntax [anything] [if][in]								///
					  [fweight iweight pweight aweight], 	///
					  [										///
					  estimator(string) 					///
					  probit 								///
					  xvars(string) 						///
					  treatvar(string)						///
					  groupvar(string)						///
					  lhs(string)							///
					  ]

	marksample touse 
	
	if "`weight'" != "" {
		local wgt [`weight' `exp']
	}
	
	tempvar dy pscore wgt0 dyhat att
	tempname bps by init muw muatt b V
	
	local pest logit 
	if ("`probit'"!="") {
	    local pest probit
	}
	
	if ("`estimator'"=="dripw") {
		quietly `pest' `treatvar' `xvars' if `touse' `wgt'
		matrix `bps' = e(b)
		quietly predict double `pscore' if `touse', pr 
		
		bysort `groupvar' (`timevar'): ///
			generate double `dy'=`lhs'[2]-`lhs'[1] if `touse'
		
		quietly reg `dy' `xvars' if (`treatvar'==0 & `touse') `wgt', 
		matrix `by' = e(b)
		quietly predict double `dyhat' if `touse'
		
		gen double `wgt0' = `pscore' * (1 - `treatvar')/(1 - `pscore')
		quietly mean `wgt0' `treatvar' if `touse' `wgt'
		matrix `muw' = e(b)
		
		generate double `att'= ///
			(`treatvar'/`muw'[1,2]-`wgt0'/`muw'[1,1])*(`dy'-`dyhat') if `touse'

		quietly mean `att' if `touse' `wgt'
		matrix `muatt' = e(b)
		
		matrix `init' = `muatt', `bps', `by', `muw'
	}
	if ("`estimator'"=="imp") {
		mlexp (`treatvar'*{xb:`xvar' _cons}- (`treatvar'==0)*exp({xb:}) ) if `touse', vce(robust)
	}
	return matrix init = `init'
	
end
** change line 201 from year==1975 to touse