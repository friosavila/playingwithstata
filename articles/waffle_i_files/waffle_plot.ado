*! v1 Waffle_plot. Simple Waffle plot
capture program drop waffle_plot
capture program drop waffle_i
capture program drop mbyparser
capture program drop make_shares

program waffle_i
	syntax anything, [nobs(int 0) xnobs(int 0) ynobs(int 0) * ///
			sctopt(string asis) flip ///
			color(str asis) pstyle(str) color0(str asis) amargin(real 0) rseed(int 0) legend(str asis)]
	** define dimensions
	numlist "`anything'", range(>=0 <=100 )
	local value `r(numlist)'
	capture numlist "`anything'", range(>=0 <=1 )
	if _rc==0 {
		foreach i in `value' {
			local vvalue `vvalue' `=`i'*100'
		}
		local value `vvalue'
	}
 
	if `nobs'!=0 {
		local xnobs = `nobs'
		local ynobs = `nobs'
	}
	else {
		if `xnobs'==0 local xnobs=10
		if `ynobs'==0 local ynobs=10
	}
	tempname fr
	frame create `fr'
	qui:frame `fr':{
		
		set obs `ynobs'	
		gen y=_n
		expand `xnobs'	
		bysort y:gen x=_n
		
		if `rseed'!=0 {
			set seed `rseed' 
			gen rnd = runiform()
			sort rnd
		}
		*** Rescale x and y
		*replace x = x * 10/`xnobs'
		*replace y = y * 10/`ynobs'
		*** Identify Flags
		qui:replace x=x-.5-`xnobs'/2
		qui:replace y=y-.5-`ynobs'/2
		gen flag = 0 
		foreach i in `value' {
			local cnt=`cnt'+1
			local j = `j'+`i'
			replace flag = `cnt' if _n <= round(_N*`j'/100) & flag==0
		}
 
		*** Prepare Scatter
		local cnt
		foreach i in `value' {
			local cnt=`cnt'+1
			
			local clr:word `cnt' of `color'
			local pst:word `cnt' of `pstyle'
			*display in w "`clr'"
			local mcmc mcolor(`"`clr'"')
 
			if "`clr'"=="" local mcmc 
			
 			local sct `sct' (scatter y x if flag==`cnt', `sctopt' `mcmc'  pstyle(`pst') )
		}
			
			local sct `sct' (scatter y x if flag==0, `sctopt' mc(`color0') )
	   local xmrg = `=0.5*`xnobs'+`amargin''
	   local ymrg = `=0.5*`ynobs'+`amargin'*`ynobs'/`xnobs''	
		   if "`flip'"!="" {
			ren (y x) (x y)
			local aux   = `ynobs'
			local ynobs = `xnobs'
			local xnobs = `aux'
			local aux   = `ymrg'
			local ymrg  = `xmrg'
			local xmrg  = `aux'
	   }
	
		 if `"`legend'"'=="off" | `"`legend'"'=="" {
			local mlg legend(off)
			local legend 
		}
		

	   *display  in w "`ymrg':`xmrg'"
	   ** The plot
		two `sct' , ///
			aspect(`=`ynobs'/`xnobs'') ///	
			ylabel("") xlabel("")  xtitle("") ytitle("") ///
			`options' ///
			xscale( range(-`xmrg'  `xmrg')) yscale( range(-`ymrg'  `ymrg')) `mlg' legend(`legend')
	}
end
 

program mbyparser, rclass
	syntax [varlist(default=none)], [*]
	return local rvars `varlist'
	return local ropt  =`"`options'"'
end

program make_shares
	syntax varlist, [total ototal(varname)]
	tempvar mtotal
	
	if "`total'"!="" {
		qui:egen `mtotal'=rowtotal(`varlist')
	}
	if "`ototal'"!="" {
		qui:gen `mtotal'=`ototal'
		
	}
	foreach i of varlist `varlist' {
		replace `i'=`i'/`mtotal'*100
	}
end

program waffle_plot
	syntax anything [if] [in] [aw/], ///
			[by(string asis) nobs(int 0) xnobs(int 0) ynobs(int 0)  ///  
			SCTopt(string asis)  /// scatter options
			color(str asis) pstyle(str ) color0(str asis) /// other color options
			amargin(real 0) rseed(int 0) ///
			legend(string asis) flip * newframe(name) TOTAL TOTAL1(varname) INDividual]

	** colorpalette(string asis) /// colorpalette			
	** define dimensions
	** Number or variable 
	* First Is it a number?
	qui:mbyparser `by'
	local over  `r(rvars)'
	local byopt `r(ropt)'
	
	capture numlist "`anything'", range(>=0 <=100 )
	if _rc==0 	{
		waffle_i `0'
		exit
	}
	 
	else {
		foreach i of varlist `anything' {
			local nvl `nvl' `i'
		}
		local anything `nvl'
		confirm var `nvl'
		marksample touse
		markout `touse' `anything' `exp' `over' `total1', strok
		if "`total'`total1'"=="" {
 			foreach i of varlist `anything' {
				sum `i' if `touse', meanonly
				if `r(max)'>100 {
					display in red "There are values Larger than 100 in the varlist"
					error 999
				}
			}		
		}	
	}
	
	 
	if `nobs'!=0 {
		local xnobs = `nobs'
		local ynobs = `nobs'
	}
	else {
		if `xnobs'==0 local xnobs=10
		if `ynobs'==0 local ynobs=10
	}
	
	if "`newframe'"=="" tempname newframe
	
	frame put `anything' `exp' `over' `total1' if `touse', into(`newframe')
	
	
	qui: frame `newframe':{
		** Step 1: Get "means"
		** check all variables are <1 
		 
		local less1 = 1 
		foreach i of varlist `anything' {
			qui:sum `i' , meanonly
			
			if `r(max)'>1 local less1 = 0
		}
		
		foreach i of varlist `anything' {
			
			if `less1' == 1 replace `i'=`i'*100
		}
		
		** Shares 
		
		if "`total'`total1'"!="" & "`individual'"!="" make_shares `anything', `total' ototal(`total1')
		
		tempvar mobs xx
		gen `xx'=1
		bysort `xx' `over':gen `mobs'=_N
		** Collapse
		sum `mons', meanonly
		if `r(max)'>1 {
			if "`exp'"!="" local wgt [iw=`exp']
			*if "`group'"!="" local stat (sum)
			collapse `stat' `anything' `total1' `wgt', by(`xx' `over') fast
		}
	 
		if "`total'`total1'"!="" & "`individual'"=="" make_shares `anything', `total' ototal(`total1')
		
		** check if Totals activated
		
		** Step2 Exapnd
		expand `ynobs'
		tempvar y x
		bysort `xx' `over':gen `y'=_n
		expand `xnobs'	
		bysort `xx' `over' `y':gen `x'=_n
		
		** ID for later
		tempvar id
		qui:gen `id'=_n
		if `rseed'!=0 {
			tempvar rnd
			set seed `rseed' 
			gen `rnd' = runiform()
			*sort `rnd'
		}
		
		*** Rescale x and y
		** ID DOTS
		qui:replace `x'=`x'-.5-`xnobs'/2
		qui:replace `y'=`y'-.5-`ynobs'/2
		tempvar flag j
		gen `flag' = 0 
		gen `j'=0
		
		foreach i in `anything' {
			local cnt=`cnt'+1
			replace `j' = `j'+`i'
			bysort `xx' `over' (`rnd' `id'):replace `flag' = `cnt' if _n <= round(_N*`j'/100) & `flag'==0
		}
********************************************************************
  		*** Step3: Prepare Scatter
		local cnt
		foreach i in `anything' {
			local cnt=`cnt'+1

			if `"`color'"'!="" {
				local clr:word `cnt' of `color'
				local mcmc mcolor(`"`clr'"') 			 
			}

			else if `"`clr'"'=="" local mcmc
			local pst:word `cnt' of `pstyle'
			local sct `sct' (scatter `y' `x' if `flag'==`cnt', `sctopt' `mcmc'  pstyle(`pst') )	
		}
			
	   local sct `sct' (scatter `y' `x' if `flag'==0, `sctopt' mc(`color0') )
	   local xmrg = `=0.5*`xnobs'+`amargin''
	   local ymrg = `=0.5*`ynobs'+`amargin'*`ynobs'/`xnobs''
	   *display  in w "`ymrg':`xmrg'"
	   ** Option flip
	   
	   if "`flip'"!="" {
			ren (`y' `x') (`x' `y')
			local aux   = `ynobs'
			local ynobs = `xnobs'
			local xnobs = `aux'
			local aux   = `ymrg'
			local ymrg  = `xmrg'
			local xmrg  = `aux'
	   }
		** Legend default OFF
	   if `"`legend'"'=="off" | `"`legend'"'=="" {
			local mlg legend(off)
			local legend 
		}
	   
	   
	   *** step 4: Do the scatter
	   if "`over'"!="" {
	   two `sct' , ///
			aspect(`=`ynobs'/`xnobs'') ///	
			by(`over', `byopt' noiylabel noixlabel noixtick noiytick `mlg'   ) ///
			xscale(noline) yscale(noline) ytitle("") xtitle("")	`options' ///
			xscale( range(-`xmrg'  `xmrg') ) yscale( range(-`ymrg'  `ymrg') ) legend(`legend')  xlabel(,nogrid) ylabel(,nogrid)
	   }
	   else {
			two `sct' , ///
			aspect(`=`ynobs'/`xnobs'')  ///	
			xscale(noline) yscale(noline) ytitle("") xtitle("")	`options' ///
			xscale( range(-`xmrg'  `xmrg') ) yscale( range(-`ymrg'  `ymrg') ) `mlg' legend(`legend')  ///
			xlabel("",nogrid) ylabel("",nogrid) 
	   }
	   
	}
end

*xscale( range(`=-`amargin'-0.5*`xnobs''                  `=0.5*`xnobs'+`amargin'') ) ///
*yscale(lstyle(thin) range(`=-0.5*`ynobs'-`amargin'*`ynobs'/`xnobs''  `=0.5*`ynobs'+`amargin'*`ynobs'/`xnobs'') ) ///
/*			else if `"`colorpalette'"'!="" {
				if strpos( `"`colorpalette'"' , ",") == 0 local colorpalette `colorpalette', nograph n(`cnt')
				else local colorpalette `colorpalette' nograph n(`cnt') 
				
				colorpalette `colorpalette'

				local mcmc mcolor("`r(p`cnt')'") 
			}*/
/**
To Be considered, a faster version of waffle plot
Does not rely on by.

This will be faster because it creates a single plot rather than multiple put together.
So far biggest limitation, How to add Holes

distinct agegrp
local cols=ceil(sqrt(17))
display `cols'

gen x2 = x
gen y2 = y

drop yc xc
sum y
gen yc = r(max)
gen xc = 0
forvalues i = 1 / 17 {
	local xcnt = `xcnt'+1
	if `xcnt'>7 {
		local xcnt = 1
	}
	if `xcnt'==1 local ycnt = `ycnt'+1
	
	replace x2 = x + (`xcnt'-1)*(9+3)	if agegrp==`i'
	replace y2 = y - (`ycnt'-1)*(9+5)	if agegrp==`i'
	
	replace xc = xc+  (`xcnt'-1)*(9+3)     if agegrp==`i'
	replace yc = yc- (`ycnt'-1)*(9+5) + 2  if agegrp==`i'
	
}
sum y2 
local l1 = `r(max)'-`r(min)'
sum x2
local l2 = `r(max)'-`r(min)'
** 
two scatter  y2 x2 || scatter  y2 x2 if flag==1 || (scatter yc xc if ll==1, msymbol(none) mlab(s)   mlabpos(0) mlabsize(3)), aspectratio(`=`l1'/`l2'') xlabel("") ylabel("")
**/