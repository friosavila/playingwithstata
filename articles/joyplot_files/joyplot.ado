*! v1.1 Wages by Race. Fixes kden
*! v1 Wages by Race
capture program drop joyplot
program joyplot
	syntax varname [if] [in] [aw/], [byvar(varname) ///
	radj(real 0)   /// Range Adjustment. How much to add or substract to the top bottom.
	dadj(real 1)   /// Adjustment to density. Baseline. 1/grps
	bwadj(numlist >=0 <=1)  /// Adj on BW 0 uses average, 1 uses individual bw's
	bwadj2(real 1)  /// Adj on BW 0 uses average, 1 uses individual bw's
	kernel(string)   ///
	frame(name)    /// IF want to save data.
	nobs(int 200)  ///
	colorpalette(string) /// Uses Benjans Colors with all the options. 
	strict notext textopt(string) ///
	rangeasis gap0 ///
	lcolor(passthru) lwidth(passthru)   * ]
	
	marksample touse
	if "`kernel'"=="" local kernel gaussian
	if "`frame'"=="" tempvar frame
	
	if "`bwadj'"=="" local bwadj=0
	
	frame put `varlist' `byvar' `exp' `ovar' if `touse', into(`frame') 
	
	qui:frame `frame': {
		
		if "`rangeasis'"=="" {
			** S1: Readjust range
			sum `varlist', meanonly
			local vmin = r(min)-r(mean)*`radj'
			local vmin2 = r(min)-r(mean)*(`radj'+.05)
			*display in w "`vmin':`vmin2'"
			local vmax = r(max)+r(mean)*`radj'
			** S2: Create the Range So Kdensities can be ploted
			tempname rvar
			range `rvar' `vmin' `vmax' `nobs'
			label var `rvar' "`:var label `varlist''"
		}
		else {
			tempvar tk
			bysort `varlist':gen `tk'=_n==_N
			tempname rvar
			local vmin2 = `varlist'[1]
			clonevar `rvar' = `varlist' if `tk'==1
			label var `rvar' "`:var label `varlist''"
		}
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
			else {
				local bwmean = `bwmean'*(`cn'-1)/`cn'+r(bwidth)/`cn'
			}
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
			*display in w "kdensity `varlist' if `byvar'==`i'  , gen(`f`cn'') kernel(`kernel') at(`rvar') bw(`bw`cn'') nograph"
			kdensity `varlist' if `byvar'==`i'   `wgtx' , gen(`f`cn'') kernel(`kernel') at(`rvar') bw(`bw`cn'') nograph
			qui:sum `f`cn''
			if r(max)>`fmax' local fmax = r(max)
		}
		if "`gap0'"=="" local gp=1
		else            local gp=0 
		** s5: Rescale Densities
		local cnt = `cn'
		local cn = 0
		foreach i of local lvl {
			local cn     = `cn'+1
			
			qui: replace `f`cn''=(`f`cn''/`fmax')*`dadj'/`cnt'+1/`cnt'*(`cnt'-`cn')*`gp'
			
			tempvar f0`cn'
			gen `f0`cn'' =1/`cnt'*(`cnt'-`cn')*`gp' if `rvar'!=.
		}
		keep if `rvar'!=.
		** Text part
		if "`text'"=="" {
			local cn = 0
			foreach i of local lvl {
				local cn     = `cn'+1
				local lbl: label (`byvar') `i', `strict'
				local totext `totext' `=`f0`cn''+0.5/`cnt'' `vmin2'  `"`lbl'"'
			}
		}	
		** colors
		if strpos( "`colorpalette'" , ",") == 0 local colorpalette `colorpalette', nograph n(`cnt')
		else local colorpalette `colorpalette' nograph n(`cnt') 
		
		colorpalette `colorpalette'
		** Putting all together
		
		
		local cn = 0 
		foreach i of local lvl {
			local cn = `cn'+1
			local ll:word `cn' of `r(p)'
			local joy `joy' (rarea `f`cn'' `f0`cn'' `rvar', color("`ll'")  `lcolor' `lwidth' ) 
		}
		
		if strpos( "`options'" , "legend")==0 local leg legend(off)
		else local leg 
		two `joy' , ///
			text(`totext' , `textopt') ///
			`options' `leg' ylabel("") 

		
	}
	
	
end