*! v0 DRDID for Stata by FRA
* For panel only for now
capture program drop drdid2
program define drdid2, eclass sortpreserve
	syntax varlist [if] [in], ivar(varname) time(varname) TReatment(varname) [noisily ]
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
 	}
	capture drop `vals'
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
	** estimate model
	
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
		gen double `w1' = `trt'
		gen double `w0' = ((`prx'*(1-`trt')))/(1-`prx')
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
		** determining weights
		tempvar ww1 ww0 ww11 ww10 ww01 ww00 www0 
		gen double `ww10' = `w1'*(`tmt'==0)
		gen double `ww11' = `w1'*(`tmt'==1)
		gen double `ww00' = `w0'*(1-`trt')*(`tmt'==0)
		gen double `ww01' = `w0'*(1-`trt')*(`tmt'==1)
		gen double `www0'=`trt'
		** Normalizing
		foreach i in `ww10' `ww11' `ww00' `ww01' `www0' {
			sum `i' if `touse', meanonly
			replace `i'=`i'/r(mean)
		}
		*gen double `ww1'=`ww11'-`ww10'
		*gen double `ww0'=`ww01'-`ww00'
		** 
		** First ATT1
		tempvar att1 att2
		gen double `att1'=`y'-`y0'
		sum `att1' if `touse' & `trt'==1, 
		gen double __att1__=r(mean) if `touse'
		gen double `att2'=__att1__+ ///
						   ((`www0'-`ww11')*(`y11'-`y01'))- ///
						   ((`www0'-`ww10')*(`y10'-`y00'))
		** then att2				   
		sum `att2' if `touse'
		gen double __att2__=r(mean) if `touse'
		** estimating IFS
		mata:rif_drdid("`y' `y00' `y01' `y10' `y11'","`ww00' `ww01' `ww10' `ww11' `www0'","`trt'","`tmt'","`touse'")
		
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
end

 
mata 
	void rif_drdid(string scalar y, w , tr, tm, touse){
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
		
		n211=ww[,5]*((yy[,5]:-yy[,4]):-mean(yy[,5]:-yy[,4],ww[,5])):+
			(ww[,4]*((yy[,1]:-yy[,5]):-mean(yy[,1]:-yy[,5],ww[,4])))
		n210=ww[,5]*((yy[,3]:-yy[,2]):-mean(yy[,3]:-yy[,2],ww[,5])):+
			(ww[,3]*((yy[,1]:-yy[,4]):-mean(yy[,1]:-yy[,4],ww[,3])))
		n21=n211-n210
		//n20=n10
		n2=n21:-(n101:-n100)
	}
	///("`y00' `y01' `y10' `y11'","`ww00' `ww01' `ww10' `ww11' `www0'","`trt'","`tmt'","`touse'")

end












