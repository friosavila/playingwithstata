program circ_histogram
	syntax varname [if] [in] [aw /], by(varname) ///
											[mlabel(varname) over(varname) ///
											dist1(real 0) dist2(real 0) ///
											lwidth(passthru) name(passthru) ///
											title(passthru) subtitle(passthru)]
	tempname mframe
	marksample touse
	confirm numeric variable `by' `over'
	markout `touse' `by' `over' 
	frame put `varlist' `exp' `by' `over' `mlabel' if `touse' , into(`mframe')
	frame  `mframe' {
		** First Weighted mean by group
		sort `by' `over' 
		if "`exp'"=="" {
			gen exp= 1
		}
		else gen exp=`exp'
		by `by' `over':egen aux1=sum(`varlist'*exp)
		by `by' `over':egen aux2=sum(exp)
		gen mean = aux1/aux2
		
		** keep obs 1
		by `by' `over':gen kp=_n==1
		keep if kp==1
		
		local N = _N
		** sorting
		sort `over' mean
		** define distances
		sum mean, meanonly
		
		local t = `dist1'*r(mean)
		local d = `dist2'*r(mean)
		
		** Generate Angle
		gen 	angle = (.25*_N - _n)/_N*360
		replace angle = angle +180           if _n/_N>.5
		gen nn=(_n/_N*360)
		** generate coordinates:
		gen x=sin(2*_pi*nn/360)*`t'
		gen y=cos(2*_pi*nn/360)*`t'

		gen x1=sin(2*_pi*nn/360)*(`t'+mean)
		gen y1=cos(2*_pi*nn/360)*(`t'+mean)

		gen x2=sin(2*_pi*nn/360)*(`t'+mean+`d')
		gen y2=cos(2*_pi*nn/360)*(`t'+mean+`d')
		
		** PCI label
		
		forvalues i=1/`N'	{
			if "`mlabel'"!="" {
				local vv `=`mlabel'[`i']'
				local sct `sct' (scatteri `=y2[`i']' `=x2[`i']' (0) "`vv'" , msymbol(i) mlabangle(`=ang[`i']') )
			}
			else {				
				local vv `=`by'[`i']'
				local sct `sct' (scatteri `=y2[`i']' `=x2[`i']' (0) "`:label (`by') `vv''" , msymbol(i) mlabangle(`=ang[`i']') )			
			}
		}

		** Plots by over
		if "`over'"!="" {
			levelsof `over', local(overlv)
			foreach i of local overlv {
				local cnt = `cnt'+1
				local lgd `lgd' `cnt' "`:label (`over') `i''"
				local pcs `pcs' ( pcspike y x y1 x1 if `over'==`i', `lwidth' )
			}
			local lgd  order(`lgd')
		}
		else {
			local pcs  (pcspike y x y1 x1  , `lwidth' )
			local lgd off
		}
		** Ranges
		sum x1 
		local xmax=r(max)*1.1
		local xmin=r(min)*1.1
		
		sum y1 
		local ymax=r(max)*1.1
		local ymin=r(min)*1.1
		
		** finally the plot
			two `pcs'  /// the lines
				`sct', /// the labels
				 aspect(1) ///
				xscale(lstyle(none) r(`ymin' `ymax')) ///
				yscale(lstyle(none) r(`xmin' `xmax')) ///
				ylabel("") xlabel("")  xtitle("") ytitle("") ///
				legend( `lgd' ) ///
				`title' `name' `subtitle'  
		
	}
	
	
end