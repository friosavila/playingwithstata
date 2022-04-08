*! v1.1 Wages by Race. Fixes kden
*! v1 Wages by Race
capture program drop joyplot
capture program drop _rangevar

program _rangevar, sortpreserve rclass
	syntax varlist, [radj(real 0.0) nobs(real 0.0) rvar(string) rangeasis]
	
		if "`rangeasis'"=="" {
			** S1: Readjust range
			sum `varlist', meanonly
			local vmin  = r(min)-(r(max)-r(min))*`radj'
			local vmin2 = r(min)-(r(max)-r(min))*(`radj'+.05)
			*display in w "`vmin':`vmin2'"
			local vmax = r(max)+(r(max)-r(min))*`radj'
			** S2: Create the Range So Kdensities can be ploted
			
			range `rvar' `vmin' `vmax' `nobs'
			if "`:var label `varlist''"!="" label var `rvar' "`:var label `varlist''"
			else label var `rvar' `varlist'			
		}
		else {
			tempvar tk
			bysort `varlist':gen `tk'=_n==_N
			
			local vmin2 = `varlist'[1]
			clonevar `rvar' = `varlist' if `tk'==1
			if "`:var label `varlist''"!="" label var `rvar' "`:var label `varlist''"
			else label var `rvar' `varlist'			
		}
	return local vmin =`vmin'
	return local vmin2=`vmin2'
	return local vmax =`vmax'
end

program joyplot
	syntax varname [if] [in] [aw/], [BYvar(varname) ///
	radj(real 0)   /// Range Adjustment. How much to add or substract to the top bottom.
	dadj(real 1)   /// Adjustment to density. Baseline. 1/grps
	bwadj(numlist >=0 <=1)  /// Adj on BW 0 uses average, 1 uses individual bw's
	bwadj2(real 1)  /// Adj on BW 0 uses average, 1 uses individual bw's
	kernel(string)   ///
	nobs(int 200)  ///
	colorpalette(string) /// Uses Benjans Colors with all the options. 
	strict notext textopt(string) ///
	rangeasis gap0 alegend ///
	lcolor(passthru) lwidth(passthru)  iqr * ]
	
	marksample touse
	if "`kernel'"=="" local kernel gaussian
	if "`bwadj'"=="" local bwadj=0
	
	tempname frame
	frame put `varlist' `byvar' `exp' `ovar' if `touse', into(`frame') 
	

	qui:frame `frame': {
		
 		capture confirm numeric var `byvar'
		if _rc!=0 {
			tempvar nb
			encode `byvar', gen(`nb')
			local byvar `nb'
		}
		
		tempname rvar
		
		** Create Rage var
 		_rangevar `varlist', radj(`radj') nobs(`nobs') rvar(`rvar')
		local vmin = r(vmin)
		local vmin2 = r(vmin2)
		local vmax = r(vmax)
		
		*display in w "`vmin':`vmax'"
		** S3: First pass BWs	
		if "`byvar'"=="" {
			tempvar byvar
			gen byte `byvar' = 1
		}	
		
		levelsof `byvar', local(lvl)
		local bwmean = 0
		local cn     = 0
		
		if "`exp'"=="" local wgtx
		if "`exp'"!="" local wgtx [aw=`exp']
		
		
		foreach i of local lvl {
			local cn = `cn'+1
			kdensity `varlist' if `byvar'==`i'  `wgtx', kernel(`kernel')   nograph
			local bw`cn' = r(bwidth)			
			if `bwmean'==0 local bwmean = r(bwidth)
			else local bwmean = `bwmean'*(`cn'-1)/`cn'+r(bwidth)/`cn'
		}

		** S4: Second pass. recalc BW's
		local cn     = 0
		foreach i of local lvl {
			local cn = `cn'+1
			local bw`cn' =`bwadj2'*(`bwadj'*`bw`cn''+(1-`bwadj')*`bwmean')
		}
		** s5: get initial Densities
		local cn     = 0
		local fmax   = 0
		foreach i of local lvl {
			local cn     = `cn'+1
			tempvar f`cn'
 			kdensity `varlist' if `byvar'==`i'   `wgtx' , gen(`f`cn'') kernel(`kernel') at(`rvar') bw(`bw`cn'') nograph
			qui:sum `f`cn''
			if r(max)>`fmax' local fmax = r(max)
		}
		
		if "`gap0'"=="" local gp=1
		else     {
			local fmax=1
			local gp=0 
		}

		** s5: Rescale Densities
		local cnt = `cn'
		local cn = 0
		foreach i of local lvl {
			local cn     = `cn'+1
			
			qui: replace `f`cn''=(`f`cn''/`fmax')*`dadj'/`cnt'+1/`cnt'*(`cnt'-`cn')*`gp'
			
			tempvar f0`cn'
			gen `f0`cn'' =1/`cnt'*(`cnt'-`cn')*`gp' if `rvar'!=.
		}
						
		
		****************************
		** IQR
		if "`iqr'"!="" {
			local cn     = 0
			
			foreach i of local lvl {
				local cn     = `cn'+1
				tempvar prng`cn' pt`cn' p0`cn'
				qui:pctile `prng`cn''=`varlist' if `byvar'==`i'   `wgtx', n(4) 
				kdensity `varlist' if `byvar'==`i'   `wgtx' , gen(`pt`cn'') ///
															  kernel(`kernel') at(`prng`cn'') bw(`bw`cn'') nograph
 
				replace `pt`cn''=(`pt`cn''/`fmax')*`dadj'/`cnt'+1/`cnt'*(`cnt'-`cn')*`gp'	in 1/3
				gen `p0`cn''=1/`cnt'*(`cnt'-`cn')*`gp'	in 1/3
				
			}	
		}
		****************************
		
		
		keep if `rvar'!=.
		** Text part (if no text)
		if "`text'"=="" {
			local cn = 0
			foreach i of local lvl {
				local cn     = `cn'+1
				local lbl: label (`byvar') `i', `strict'
				local totext `totext' `=`f0`cn''+0.5/`cnt'' `vmin2'  `"`lbl'"'
			}
		}	
		** Auto Legend
		if "`alegend'"!="" {
			local cn = 1
			if "`iqr'"!="" local uno 1
			foreach i of local lvl {
				
				local lbl: label (`byvar') `i', `strict'
				local aleg `aleg' `cn' `"`lbl'"'
				local cn     = `cn'+1+0`uno' 
			}
		}
		** colors
		if "`colorpalette'"!="" {
			if strpos( "`colorpalette'" , ",") == 0 local colorpalette `colorpalette', nograph n(`cnt')
			else local colorpalette `colorpalette' nograph n(`cnt') 		
			colorpalette `colorpalette'
			** Putting all together
			local cn = 0 
			foreach i of local lvl {
				local cn = `cn'+1
				local ll:word `cn' of `r(p)'
				if "`iqr'"!="" local iqrline (rspike `pt`cn'' `p0`cn'' `prng`cn'', color("`ll'") lwidth(.3) /*pstyle(p`cn')*/)
				
				local joy `joy' (rarea `f`cn'' `f0`cn'' `rvar', color("`ll'")  `lcolor' `lwidth' /*pstyle(p`cn')*/)  `iqrline'
			}
		}
		else {
			local cn = 0 
			foreach i of local lvl {
				local cn = `cn'+1
 
				if "`iqr'"!="" local iqrline (rspike `pt`cn'' `p0`cn'' `prng`cn'', lwidth(.3) pstyle(p`cn'))
				local joy `joy' (rarea `f`cn'' `f0`cn'' `rvar',  `lcolor' `lwidth' pstyle(p`cn'))  `iqrline'
			}
		}
		***************************************************************************************************************
		if "`alegend'"!="" local leg   legend(order(`aleg'))
		else if strpos( "`options'" , "legend")==0 local leg legend(off)
		else local leg
		
		if "`gap0'"!="" local ylabx 
		else local ylabx ylabel("")
		
		two `joy' , ///
			text(`totext' , `textopt') ///
			`options' `leg' `ylabx' 

		
	}
	
	
end