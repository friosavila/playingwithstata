*! v0.5 DRDID for Stata by FRA Incorporates RC1 and RC2 estimators
* v0.2 DRDID for Stata by FRA Fixes typo with tag
* v0.2 DRDID for Stata by FRA Allows for Factor notation
* v0.1 DRDID for Stata by FRA Typo with ID TIME
* For panel only for now
capture program drop drdid
program define drdid, eclass sortpreserve
	syntax varlist(fv ) [if] [in], [ivar(varname)] time(varname) TReatment(varname) [noisily ]
	marksample touse
	markout `touse' `ivar' `time' `treatment'
	** First determine outcome and xvars
	gettoken y xvar:varlist
	** Sanity Checks for Time. Only 2 values
	tempvar vals
	qui:bysort `touse' `time': gen byte `vals' = (_n == 1) * `touse'
	su `vals' if `touse', meanonly 
	if  r(sum)!=2 {
	    display in red "Time variable can only have 2 values in the working sample"
		error 1
	}
	else {
		tempvar tmt
		qui:egen byte `tmt'=group(`time') if `touse'
		qui:replace `tmt'=`tmt'-1	    
	}
	
	drop `vals'
	qui:bysort `touse' `treatment': gen byte `vals' = (_n == 1) * `touse'
	su `vals' if `touse', meanonly
 
	if  r(sum)!=2 {
	    display in red "Treatment variable can only have 2 values in the working sample"
		error 1
	}
	else {
		tempvar trt
		qui:egen byte `trt'=group(`treatment') if `touse'
		qui:replace `trt'=`trt'-1
	}
	**# for panel estimator
	if "`ivar'"!="" {
	    	display "Estimating IPT"
		qui {
			`isily' ml model lf drdid_logit (`trt'=`xvar') if `touse' , maximize  robust
			`isily' ml display
			tempname iptb iptV
			matrix `iptb'=e(b)
			matrix `iptV'=e(V)
			tempvar prx
			predictnl double `prx'=logistic(xb())
			** Determine dy and dyhat
			capture drop __dy__
			tempvar tag
			bysort `touse' `ivar' (`time'):gen double __dy__=`y'[2]-`y'[1] if `touse'
			bysort `touse' `ivar' (`time'):gen byte `tag'=_n if `touse'
			** determine weights
			tempvar w1 w0
			gen double `w1' = `trt'
			gen double `w0' = ((`prx'*(1-`trt')))/(1-`prx')
			
			sum `w1' if `touse', meanonly
			replace `w1'=`w1'/r(mean)
			sum `w0' if `touse', meanonly
			replace `w0'=`w0'/r(mean)
			
			** estimating dy_hat for a counterfactual
		}
		display "Estimating Counterfactual Outcome"	
		qui {	
			tempname regb regV
			`isily' reg __dy__ `xvar' [w=`w0'] if `trt'==0 ,
			matrix `regb' =e(b)
			matrix `regV' =e(V)
			tempvar dyhat
			qui:predict double `dyhat'
			tempvar att
			qui:gen double `att'=__dy__-`dyhat'
			capture drop __att__
			sum `att' if `touse' & `trt'==1, meanonly
			gen double __att__ = r(mean)+  (`w1'-`w0')*`att'-`w1'*r(mean) if `tag'==1  & `touse'
		}
		display "Estimating ATT"
		reg __att__ if   `touse'
		*** Wrapping all
		ereturn local cmd drdid
		ereturn local cmdline drdid `0'
		ereturn scalar att    =`=_b[_cons]'
		ereturn scalar attvar =`=_se[_cons]'
		ereturn matrix iptb `iptb'
		ereturn matrix iptV `iptV'
		ereturn matrix regb `regb'
		ereturn matrix regV `regV'
	}
	else {
	**# for Crossection estimator    
	    *** if no ivar means its RC.
		display "Estimating IPT"
		qui {
			`isily' ml model lf drdid_logit (`trt'=`xvar') if `touse' , maximize  robust
			`isily' ml display
			tempname iptb iptV
			matrix `iptb'=e(b)
			matrix `iptV'=e(V)
			tempvar prx
			predictnl double `prx'=logistic(xb())
			** outcomes
			tempvar w1 w0
			gen double `w1' =    `trt'
			gen double `w0' = (1-`trt')*`prx'/(1-`prx')
		}
		display "Estimating Counterfactual Outcome"	
		qui {
			tempvar y01 y00 y10 y11
			`isily' reg `y' `xvar' [w=`w0'] if `trt'==0 & `tmt'==0,
			predict double `y00'
			`isily' reg `y' `xvar' [w=`w0'] if `trt'==0 & `tmt'==1,
			predict double `y01'
			tempvar y0
			gen double `y0'=`y00'*(`tmt'==0)+`y01'*(`tmt'==1)
			`isily' reg `y' `xvar'  		   if `trt'==1 & `tmt'==0,
			predict double `y10'
			`isily' reg `y' `xvar'  		   if `trt'==1 & `tmt'==1,
			predict double `y11'
			
			tempvar ww1 ww0 ww11 ww10 ww01 ww00 www0 
			gen double `ww10' = `w1'*(`tmt'==0)
			gen double `ww11' = `w1'*(`tmt'==1)
			gen double `ww00' = `w0'*(`tmt'==0)
			gen double `ww01' = `w0'*(`tmt'==1)
			gen double `www0'=`trt'			
			** Normalizing weights
			foreach i in `ww10' `ww11' `ww00' `ww01' `www0' {
				sum `i' if `touse', meanonly
				replace `i'=`i'/r(mean)
			}
			** estimating ATT
			capture drop __att1__ __att2__ 
			tempvar att1 att2
			gen double `att1'=(`y'-`y0')*(`ww11'-`ww10'-(`ww01'-`ww00'))
			sum `att1' if `touse' 
			gen double __att1__=r(mean) if `touse'
			gen double `att2'=__att1__+ ///
							   ((`www0'-`ww11')*(`y11'-`y01'))- ///
							   ((`www0'-`ww10')*(`y10'-`y00'))
			** then att2				   
			sum `att2' if `touse'
			gen double __att2__=r(mean) if `touse'
			** estimating IFS
			tempvar rif1 rif2
			gen double `rif1'=.
			gen double `rif2'=.
			mata:rif_drdid("`y' `y00' `y01' `y10' `y11'", ///
							"`ww00' `ww01' `ww10' `ww11' `www0'", ///
							"`trt'","`tmt'","`touse'","`rif1'","`rif2'")
			replace __att1__=__att1__+`rif1'
			replace __att2__=__att2__+`rif2'
		}
			qui:reg __att1__ if   `touse'
			adde return scalar dof
			regress
			noisily reg __att2__ if   `touse'
	}

end


mata 
	void rif_drdid(string scalar y, w , tr, tm, touse, nv1, nv2){
		real matrix yy,ww,trt,tmt
		yy =st_data(., y,touse)
		ww =st_data(., w,touse)
		trt=st_data(.,tr,touse)
		tmt=st_data(.,tm,touse)
		//now i need vectors for YY's WW's etc
		//mata:rif_drdid
		// ("`y'    `y00' `y01'  `y10'  `y11'"
		//  yy[,1] yy[,2] yy[,3] yy[,4] yy[,5]
		//"`ww00' `ww01' `ww10' `ww11' `www0'"
		//,"`trt'","`tmt'","`touse'")
		//   w00    w01      w10    w11
		// ww[,1]  ww[,2]	ww[,3] ww[,4]
		
		n111=ww[,4]:*((yy[,1]:-yy[,3]):-mean(yy[,1]:-yy[,3],ww[,4]))
		n110=ww[,3]:*((yy[,1]:-yy[,2]):-mean(yy[,1]:-yy[,2],ww[,3]))
		
		n101=ww[,2]:*((yy[,1]:-yy[,3]):-mean(yy[,1]:-yy[,3],ww[,2]))
		n100=ww[,1]:*((yy[,1]:-yy[,2]):-mean(yy[,1]:-yy[,2],ww[,1]))
		//n11=n111:-n110
		//n10=n101:-n100
		n1=(n111:-n110):-(n101:-n100)
		
		n211=ww[,5]:*((yy[,5]:-yy[,4]):-mean(yy[,5]:-yy[,4],ww[,5])):+
			(ww[,4]:*((yy[,1]:-yy[,5]):-mean(yy[,1]:-yy[,5],ww[,4])))
		n210=ww[,5]:*((yy[,3]:-yy[,2]):-mean(yy[,3]:-yy[,2],ww[,5])):+
			(ww[,3]:*((yy[,1]:-yy[,4]):-mean(yy[,1]:-yy[,4],ww[,3])))
		n21=n211:-n210
		n2=n21:-(n101:-n100)
		//n20=n10
		st_store(.,nv1,touse,n1)
		st_store(.,nv2,touse,n2)

	}


end


 
