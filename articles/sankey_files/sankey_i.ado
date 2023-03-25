*! v1 Sankey by me FRA
program sankey_i
syntax anything, [*]
	numlist "`anything'", min(4) max(6) 
	tempname new
	frame create `new'
	frame `new': {
		range x 0 1 25
		gen y=normal((x-.5)*7)
		** From ... to
		
		local x0: word 1 of `anything' 
		local y0: word 2 of `anything'
		local x1: word 3 of `anything'
		local y1: word 4 of `anything' 
		local wd0: word 5 of `anything'
		local wd1: word 6 of `anything'
		
		if "`wd0'"=="" 	local wd0 = 0.001
		if "`wd1'"==""  local wd1 = `wd0'
			
		gen yy0 = `y0' + y * (`y1'-`y0') - `wd0'-(`wd1'-`wd0')*y
		gen yy1 = `y0' + y * (`y1'-`y0') + `wd0'+(`wd1'-`wd0')*y
		gen xx  = `x0' + x * (`x1'-`x0') 
			
		two (rarea yy0 yy1 xx ) ///
			(scatteri  `y0' `x0' (12) "Point A", msize(3) mlabsize(small) ) ///
			(scatteri  `y1' `x1' (6) "Point B", msize(3) mlabsize(small) ) , `options'
			
	}
	
end