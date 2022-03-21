*! v0 Waffle_i. Simple Waffle plot
capture program drop waffle_i
program waffle_i
	syntax anything, [nobs(int 0) xnobs(int 0) ynobs(int 0) * ///
			msize(passthru) msymbol(passthru) ///
			color(str) pstyle(str) color0(str) amargin(real 0)]
	** define dimensions
	numlist "`anything'", range(>=0 <=100 )
	local value `r(numlist)'
 
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
			replace flag = `cnt' if _n <= (_N*`j'/100) & flag==0
		}
 
		*** Prepare Scatter
		local cnt
		foreach i in `value' {
			local cnt=`cnt'+1
			
			local clr:word `cnt' of `color'
			local pst:word `cnt' of `pstyle'
			*display in w "`clr'"
			local mcmc mcolor("`clr'")
 
			if "`clr'"=="" local mcmc 
			
 			local sct `sct' (scatter y x if flag==`cnt', `msize' `msymbol' `mcmc'  pstyle(`pst') )
		}
			
			local sct `sct' (scatter y x if flag==0, `msize' `msymbol' mc("`color0'") )
	
	   local xmrg = `=0.5*`xnobs'+`amargin''
	   local ymrg = `=0.5*`ynobs'+`amargin'*`ynobs'/`xnobs''
	   *display  in w "`ymrg':`xmrg'"
		two `sct' , ///
			aspect(`=`ynobs'/`xnobs'') ///	
			ylabel("") xlabel("")  xtitle("") ytitle("") ///
			`options' ///
			xscale( range(-`xmrg'  `xmrg')) yscale( range(-`ymrg'  `ymrg'))
	}
end

*xscale( range(`=-`amargin'-0.5*`xnobs''                  `=0.5*`xnobs'+`amargin'') ) ///
*yscale(lstyle(thin) range(`=-0.5*`ynobs'-`amargin'*`ynobs'/`xnobs''  `=0.5*`ynobs'+`amargin'*`ynobs'/`xnobs'') ) ///