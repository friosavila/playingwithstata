*! v0.1 by FRA mpdid or Multiple periods did.
* This version implements did::attgp
* Logic. Estimate the ATT of the base (first) year against all subsequent years
* using data BY groups
** assumes all years are available. For now
capture program drop mpdid
program mpdid, eclass
syntax varlist(fv ) [if] [in], ivar(varname) time(varname) gvar(varname) [att_gt]
	marksample touse
	markout `touse' `ivar' `time' `gvar'
	** First determine outcome and xvars
	gettoken y xvar:varlist
	** determine time0
	if "`time0'"=="" {
	    qui:sum `time' if `touse'
		local time0 `r(min)'
	}
	** prepare loops over gvar.
	local att_gt att_gt
	tempvar tr
	qui:gen byte `tr'=`gvar'!=0 if `gvar'!=.
	if "`att_gt'"!="" {
		qui:levelsof `gvar' if `gvar'>0       & `touse', local(glev)
		qui:levelsof `time' if `time'>`time0' & `touse', local(tlev)
		
		tempname b v
 		foreach i of local glev {		
		    foreach j of local tlev {
			    local time1 = min(`i'-1, `j'-1)
				
				qui:drdid `varlist' if inlist(`gvar',0,`i') & inlist(year,`time1',`j'), ivar(`ivar') time(`time') treatment(`tr')
				matrix `b'=nullmat(`b'),e(b)
				matrix `v'=nullmat(`v'),e(V)
				local eqname `eqname' g`i'
				local colname `colname'  t_`time1'_`j'
			}
		}
		matrix `v'=diag(`v')
		matrix colname `b'=`colname'
		matrix coleq   `b'=`eqname'
		matrix colname `v'=`colname'
		matrix coleq   `v'=`eqname'
		matrix rowname `v'=`colname'
		matrix roweq   `v'=`eqname'
	}	
	ereturn post `b' `v'
	ereturn cmd mpdid
	ereturn cmdline mpdid `0'
	
	ereturn display
end 