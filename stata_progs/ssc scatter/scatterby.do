use https://www.stata-press.com/data/r16/physed, clear
set scheme s2color
capture program drop scatterby
program scatterby,
	syntax anything, by(varname) [kden *]
	qui:levelsof `by', local(byl)
	set graph off
	foreach i of varlist `anything' {
	    foreach j of varlist `anything' {
		    local vv
			if "`i'"!="`j'" {
				foreach k of local byl {
					local vv `vv' (scatter `i' `j' if `by'==`k')
				}
			}
			else {
				if "`kden'"!="" {
					foreach k of local byl {
						local vv `vv' (kdensity `i' if `by'==`k' )
					}
				}
				else {
				    local xycommon ycommon xcommon
				    foreach k of local byl {
						local vv `vv' (scatter `i' `j' if `by'==.z, xlabel(0 " " 1 " ") ylabel(0 " " 1 " ") )
					}
				}	
			}
			local nf=`nf'+1
			two `vv', plotregion(margin(zero)) graphregion(margin(zero)) legend(off) name(`i'`j', replace)
			local gmn `gmn' `i'`j'
		}
	}
	set graph on
	local nf=sqrt(`nf')
	graph combine `gmn', col(`nf')
	
	graph drop `gmn'
end
xtile r=runiform(), n(4)
scatterby flexibility speed strength, by(grp)


two line le_male le_female year if year==., legend( position(0)) yscale(off) xscale(off) graphregion(off)