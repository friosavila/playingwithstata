clear
set obs 200
gen x = rnormal()
gen v = rnormal()
gen y = 1+ x - x^2+ v * (1+3*normal(x))
scatter y x
forvalues xp = 1/99 {
local p = `xp'/100 
set graph off
two (scatter y x, color(%30)) ///
	(function y = 1+ x - x^2 , range(-3 3)) ///
	(function y =invnormal(`p')+ 1+ x - x^2 + invnormal(`p')*3*normal(x), range(-3 3)) 
graph export xl`xp'.png	, replace
}


clear
set obs 50
gen p = _n/(_N+1)
gen x = invnormal(p)
gen id = _n
expand 99
bysort id:gen p2 = _n/(_N+1)
gen v = invnormal(p2)
gen y = 1+ x - x^2+ v * (1+3*normal(x))
gen a0=.
gen a1=.
forvalues xp = 1/99 {
    local p = `xp'/100
    qui:qrprocess y x, q(`p')
	replace a0 = _b[_cons] in `xp'
	replace a1 = _b[x] in `xp'
	display "`p'"
}

forvalues xp = 1(2)99 {
local p = `xp'/100 
set graph off
local a0 = `=a0[`xp']'
local a1 = `=a1[`xp']'
two (scatter y x if _n<400, color(%30)) ///
	(function y = 1+ x - x^2 + invnormal(`p') * (1+3*normal(x)) , range(-3 3)) 
	
graph export xl`xp'.png	, replace
}

