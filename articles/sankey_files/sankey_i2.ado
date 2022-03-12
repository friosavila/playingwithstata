*! v1 by Fernando Rios Avila
*program drop get_coordinates
program get_coordinates, rclass
	syntax varlist, [width(varlist)] [n(int 1)]
	gettoken x0 rest:varlist
	gettoken y0 rest:rest
	gettoken x1 rest:rest
	gettoken y1 rest:rest
	
	return local x0 = `x0'[`n']
	return local y0 = `y0'[`n']
	return local x1 = `x1'[`n']
	return local y1 = `y1'[`n']
	
	if "`width'"=="" {
		return local wd0 = 0.01
		return local wd1 = 0.01
	}
	else {
		gettoken wdt1 rest:width
		gettoken wdt2 rest:rest
		
		if "`wdt2'"=="" {
			return local wd0 = `wdt1'[`n']
			return local wd1 = `wdt1'[`n']
		}
		else {
			return local wd0 = `wdt1'[`n']
			return local wd1 = `wdt2'[`n']
		}
	}		
end

*program drop adjust_coordinates
program adjust_coordinates
	syntax varlist, [width(varlist)] 
	
	gettoken x0 rest:varlist
	gettoken y0 rest:rest
	gettoken x1 rest:rest
	gettoken y1 rest:rest
	
	if "`width'"=="" {
		tempvar width0 width1
		gen `width0' =0.01
		gen `width1' =0.01
	}
	else {
		local width0:word 1 of `width'
		local width1:word 2 of `width'
		if "`width1'"=="" {
			tempvar width1
			gen `width1'=`width0'
		}
	}		
	sum `width0' `width1'
	
	tempvar yy0 yy1
	clonevar `yy0' = `y0'
	clonevar `yy1' = `y1'
	tempvar tw0 tw1
	bysort `yy0' `x0' (`yy1'):egen `tw0'=sum(`width0'*2)
	bysort `yy1' `x1' (`yy0'):egen `tw1'=sum(`width1'*2)
	
	*sort `yy0' `yy1'
 	bysort `yy0' `x0' (`yy1'): replace `y0'=`y0'-`tw0'*.5+sum(`width0'*2)-`width0'
	bysort `yy1' `x1' (`yy0'): replace `y1'=`y1'-`tw1'*.5+sum(`width1'*2)-`width1'
end

*program drop sankey_i2
program sankey_i2
syntax varlist, [width0(varname) width1(varname) color(varname) pstyle(varname) * adjust]  
	
	tempname new
	local nn = _N
	
 
	
 	frame put `varlist' `color' `pstyle' `width0' `width1', into(`new')
	frame `new': {
		
		if "`adjust'"!="" qui:adjust_coordinates `varlist',  width(`width0' `width1')
		
		tempvar x y
		
		range `x' 0 1 25
		gen `y'=normal((`x'-.5)*7)
						
		** From ... to
		forvalues j = 1/`nn' {
			
				get_coordinates `varlist', width(`width0' `width1')  n(`j')
				local x0 = r(x0)
				local y0 = r(y0)
				local x1 = r(x1)
				local y1 = r(y1)
				local wd0 = r(wd0)
				local wd1 = r(wd1)
				
				if "`color'"!="" local col = `color'[`j']
				if "`pstyle'"!="" local pst = `pstyle'[`j']
			
				qui:gen yy0_`j' = `y0' + `y' * (`y1'-`y0') - `wd0'-(`wd1'-`wd0')*`y'
				qui:gen yy1_`j' = `y0' + `y' * (`y1'-`y0') + `wd0'+(`wd1'-`wd0')*`y'
				qui:gen xx_`j'  = `x0' + `x' * (`x1'-`x0') 
				
				local toplot `toplot' (rarea yy0_`j' yy1_`j' xx_`j', color(`col') pstyle(`pst') )		
				 
		}
		
		
		two `toplot'   , `options'
	}
	
end
 


