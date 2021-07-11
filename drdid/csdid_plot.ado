capture program drop  csdid_plot
program csdid_plot
	syntax, [style(passthru) title(passthru) name(passthru) ]
	tempvar mm 
	tempvar kk
	if "`e(agg)'"=="event" | "`r(agg)'"=="event" {
		if "`e(agg)'"=="event" {
			 qui:csdid
			 local evlist = subinstr("`:colname e(b)'","T","",.)
			 matrix `mm'=r(table)'
		}
		else if "`r(agg)'"=="event" {		 
			 local evlist = subinstr("`:colname r(b)'","T","",.)
			 matrix `mm'=r(table)'
		}
		
		qui:svmat `mm'
		qui:gen `kk' =.
		foreach i of local evlist {
		 	local k = `k'+1
		 	qui:replace `kk'=`i' in `k'
		}
		csdid_default, `options' `style'
		csdid_plot_event `kk'  `mm'1  `mm'5 `mm'6	, ///
					style(`r(style)')	  `title' `name'  		   
		drop `mm'? 
	}
	
	if "`e(agg)'"=="group" | "`r(agg)'"=="group" {
		if "`e(agg)'"=="group" {
			 qui:csdid
			 local evlist :colname e(b)
			 matrix `mm'=r(table)'
		}
		else if "`r(agg)'"=="group" {		 
			 local evlist :colname r(b)
			 matrix `mm'=r(table)'
		}
		
		qui:svmat `mm'
		qui:gen str `kk' =""
		foreach i of local evlist {
		 	local k = `k'+1
		 	qui:replace `kk'="`i'" in `k'
		}
		tempname k2
		qui:encode `kk', gen(`k2')
		 
		csdid_default, `options' `style'
		csdid_plot_group `k2'  `mm'1  `mm'5 `mm'6	, ///
					style(`r(style)')	  `title' `name'  		   
		drop `mm'? 
	}
end

capture program csdid_default, rclass
	syntax, [style(str)]
	
	if "`style'"=="" return local style rspike
	else             return local style `style'
end

capture program drop csdid_plot_event
program csdid_plot_event 
	syntax varlist, style(str) [title(passthru) name(passthru)	 ]
	gettoken t rest:varlist
	gettoken b rest:rest
	gettoken ll rest:rest 
	gettoken uu rest:rest 
	
	
	if "`style'"=="rspike" {
	two   rspike  `ll' `uu' `t'   if `t'<0 , pstyle(p1) color(%40) lw(3) || ///
		  scatter  `b'      `t'   if `t'<0 , pstyle(p1) || ///
		  rspike  `ll' `uu' `t'   if `t'>=0, color(%40) pstyle(p2) lw(3) || ///
		  scatter  `b'      `t'   if `t'>=0, pstyle(p2) , ///
		  legend(order(1 "Pre-treatment" 3 "Post-treatment")) xtitle("Periods to Treatment") ytitle("ATT") ///
		  yline(0 , lp(dash) lcolor(black)) `title' `name' 
	}	  
	
	if "`style'"=="rarea" {
	two   (rarea  `ll' `uu' `t'   if `t'<0 , pstyle(p1) color(%40) lw(0) ) || ///
		  (scatter  `b'     `t'   if `t'<0 , pstyle(p1) connect(l) ) || ///
		  (rarea  `ll' `uu' `t'   if `t'>=0, color(%40) pstyle(p2) lw(0) ) || ///
		  (scatter  `b'     `t'   if `t'>=0, pstyle(p2) connect(l) ), ///
		  legend(order(1 "Pre-treatment" 3 "Post-treatment")) xtitle("Periods to Treatment") ytitle("ATT") ///
		  yline(0 , lp(dash) lcolor(black))  `title' `name' 
	}
	
	if "`style'"=="rcap" {
	two   (rcap  `ll' `uu' `t'   if `t'<0, pstyle(p1) color(%60) lw(1) ) || ///
		  (scatter  `b'      `t'   if `t'<0 , pstyle(p1) connect(l) ) || ///
		  (rcap `ll' `uu' `t'   if `t'>=0, color(%60) pstyle(p2) lw(1) ) || ///
		  (scatter  `b'      `t'   if `t'>=0, pstyle(p2) connect(l) ), ///
		  legend(order(1 "Pre-treatment" 3 "Post-treatment")) xtitle("Periods to Treatment") ytitle("ATT") ///
		  yline(0 , lp(dash) lcolor(black))  `title' `name'
	}
	
	if "`style'"=="rbar" {
	two   (rbar  `ll' `uu' `t'   if `t'<0, pstyle(p1) color(%60) lw(0) barwidth(0.5) ) || ///
		  (scatter  `b'      `t'   if `t'<0 , pstyle(p1) connect(l) ) || ///
		  (rbar `ll' `uu' `t'   if `t'>=0, color(%60) pstyle(p2) lw(0) barwidth(0.5) ) || ///
		  (scatter  `b'      `t'   if `t'>=0, pstyle(p2) connect(l) ), ///
		  legend(order(1 "Pre-treatment" 3 "Post-treatment")) xtitle("Periods to Treatment") ytitle("ATT") ///
		  yline(0 , lp(dash) lcolor(black))  `title' `name'
	}
end


capture program drop csdid_plot_group
program csdid_plot_group
	syntax varlist, style(str) [title(passthru) name(passthru)	 ]
	gettoken t rest:varlist
	gettoken b rest:rest
	gettoken ll rest:rest 
	gettoken uu rest:rest 
		
	qui:levelsof `t', local(tlev)
	local tlb: value label `t'
	local xlab 0 " "
	foreach i of local tlev {
	    local j = `j'+1
	    local xlab `xlab' `i' "`:label `tlb' `i''"
	}
	
	local xlab `xlab' `=`j'+1' " "
	
	if "`style'"=="rspike" {
	two   (`style'  `ll' `uu' `t'   , pstyle(p1) color(%40) lw(3) ) || ///
		  (scatter  `b'      `t'   , pstyle(p1)    ) , ///
		  legend(off) xtitle("Groups") ytitle("ATT") ///
		  yline(0 , lp(dash) lcolor(black)) `title' `name' xlabel(`xlab')
	}	  
	
	if "`style'"=="rarea" {
	two   (`style'  `ll' `uu' `t'   	 , pstyle(p1) color(%40) lw(0) ) || ///
		  (scatter  `b'     `t'   	 , pstyle(p1)  ) , ///
		  legend(off) xtitle("Groups") ytitle("ATT") ///
		  yline(0 , lp(dash) lcolor(black)) `title' `name' xlabel(`xlab')
	}
	
	if "`style'"=="rcap" {
	two   (`style'  `ll' `uu' `t'   	 , pstyle(p1) color(%40)  lw(1) ) || ///
		  (scatter  `b'     `t'   	 , pstyle(p1)  ) , ///
		  legend(off) xtitle("Groups") ytitle("ATT") ///
		  yline(0 , lp(dash) lcolor(black)) `title' `name' xlabel(`xlab')
	}
	
	if "`style'"=="rbar" {
	two   (`style'  `ll' `uu' `t'   	 , pstyle(p1) color(%40) lw(0) barwidth(0.5) ) || ///
		  (scatter  `b'     `t'   	 , pstyle(p1)  ) , ///
		  legend(off) xtitle("Groups") ytitle("ATT") ///
		  yline(0 , lp(dash) lcolor(black)) `title' `name' xlabel(`xlab')
	}
end