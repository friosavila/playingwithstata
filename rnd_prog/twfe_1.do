*** Lesson 1: TWFE if Treatment is homogenous
** Using Program to Simulate all later
program drop twfe1
program twfe1, eclass
	clear
	local iobs 100
	local time 10
	local noise 2
	local tsize 4
	*set seed 54321
	set obs  `iobs' 
	gen id = _n
	** when treated 
	gen wtr = ceil(runiform(0,`time'))
	** expand time
	expand `time'
	bysort id:gen time = _n
	** create a treatment variable
	gen d=time>=wtr
	** create an outcome variable
	gen y = `tsize'*d                // homogeneous treatment effect
	*replace y = 100 if id==1 & t==4 // effects increase

	** add a bit of noise
	replace y = y+`noise'*rnormal()

	** two-way fixed effects
	reghdfe y i.time d, abs(id)
	matrix b=_b[d]
	ereturn post b
end

simulate, reps(1000):twfe1
histogram _b_c1



*** Lesson 2: TWFE if Treatment is Homogenous but we model this as an Events study
capture program drop twfe2
program twfe2, eclass
	clear
	local iobs 100
	local time 10
	local noise 2
	local tsize 4
	*set seed 54321
	set obs  `iobs' 
	gen id = _n
	** when treated 
	gen wtr = ceil(runiform(0,`time'))
	** expand time
	expand `time'
	bysort id:gen time = _n
	** create a treatment variable
	gen d=time>=wtr
	** As a before and after
	** Event is 0 before the treatment...
	** but codding it so Events is always possitive
	**gen event0 = (time - (wtr -1) ) 
	gen event = (time - (wtr -1) )+`time'

	** create an outcome variable
	gen y = `tsize'*d                // homogeneous treatment effect
	*replace y = 100 if id==1 & t==4 // effects increase

	** add a bit of noise
	replace y = y+`noise'*rnormal()

	** two-way fixed effects (exclude time)
	reghdfe y ib`time'.event , abs(id  )
	margins, dydx(event) plot noestimcheck
end
twfe2
** twfe

************
capture program drop twfe3
program twfe3, eclass
	clear
	local iobs 100
	local time 10
	local noise 2
	local tsize 4
	*set seed 54321
	set obs  `iobs' 
	gen id = _n
	** Heterogenous effects by ID
	gen het_t = (runiform()-.5)*0.2
	** when treated 
	gen wtr = ceil(runiform(0,`time'))
	** expand time
	expand `time'
	bysort id:gen time = _n
	** create a treatment variable
	gen d=time>=wtr
	** create an outcome variable
	gen y = `tsize'*d*(1+het_t)          // homogeneous treatment effect
	
	** add a bit of noise
	replace y = y+`noise'*rnormal()

	** two-way fixed effects
	reghdfe y i.time d, abs(id)
	matrix b=_b[d]
	ereturn post b
end

simulate, reps(400):twfe3
histogram _b_c1

******* as event study
************
capture program drop twfe4
program twfe4, eclass
	clear
	local iobs 100
	local time 10
	local noise 2
	local tsize 4
	*set seed 54321
	set obs  `iobs' 
	gen id = _n
	** Heterogenous effects by ID
	gen het_t = (runiform()-.5)*0.2
	** when treated 
	gen wtr = ceil(runiform(0,`time'))
	** expand time
	expand `time'
	bysort id:gen time = _n
	** create a treatment variable
	gen d=time>=wtr
	**  event
	gen event = (time - (wtr -1) )+`time'
	** create an outcome variable
	gen y = `tsize'*d*(1+het_t)   // Heterogenous treatment effect
	
	** add a bit of noise
	replace y = y+`noise'*rnormal()

	** two-way fixed effects
	reghdfe y ib`time'.event , abs(id  )
	margins, dydx(event) plot noestimcheck
end

twfe4

******** as event study
******** Effect that accumulates with length of treatment 
capture program drop twfe5
program twfe5, eclass
	clear
	local iobs 100
	local time 10
	local noise 2
	local tsize 4
	*set seed 54321
	set obs  `iobs' 
	gen id = _n
	** Heterogenous effects by ID
	gen het_t = (runiform()-.5)*0.5
	** when treated 
	gen wtr = ceil(runiform(0,`time'))
	** expand time
	expand `time'
	bysort id:gen time = _n
	** create a treatment variable
	gen d=time>=wtr
	**  event
	gen event0 = (time - (wtr -1) )
	gen event = (time - (wtr -1) )+`time'
	** create an outcome variable
	gen y = `tsize'*d*(1+het_t)^event0   // Heterogenous treatment effect
	
	** add a bit of noise
	replace y = y+`noise'*rnormal()

	** two-way fixed effects
	reghdfe y ib`time'.event , abs(id  )
	margins, dydx(event) plot noestimcheck
end

twfe5
****
******** Effect that increases with time in a linear way
capture program drop twfe5b
program twfe5b, eclass
	clear
	local iobs 100
	local time 10
	local noise 2
	local tsize 4
	*set seed 54321
	set obs  `iobs' 
	gen id = _n
	** Heterogenous effects by ID
	gen het_t = (runiform()-.5)*0.5
	** when treated 
	gen wtr = ceil(runiform(0,`time'))
	** expand time
	expand `time'
	bysort id:gen time = _n
	** create a treatment variable
	gen d=time>=wtr
	**  event
	gen event0 = (time - (wtr -1) )
	gen event = (time - (wtr -1) )+`time'
	** create an outcome variable
	gen y = `tsize'*d+(d>0)*(0.5*event0)   // Heterogenous treatment effect
	
	** add a bit of noise
	replace y = y+`noise'*rnormal()

	** two-way fixed effects
	reghdfe y ib`time'.event , abs(id  )
	margins, dydx(event) plot noestimcheck
end

twfe5


*** adding noise that affect individual effect
capture program drop twfe6
program twfe6, eclass
	clear
	local iobs 100
	local time 10
	local noise 2
	local tsize 4
	*set seed 54321
	set obs  `iobs' 
	gen id = _n
	gen ui = (rchi2(3)-3)/3
	** Homogenous effect  
	gen het_t = 0
	* gen het_t = (runiform()-.5)*0.5
	** when treated 
	gen wtr = ceil(runiform(0,`time'))
	** expand time
	expand `time'
	bysort id:gen time = _n
	** create a treatment variable
	gen d=time>=wtr
	**  event
	gen event0 = (time - (wtr -1) )
	gen event = (time - (wtr -1) )+`time'
	** create an outcome variable
	gen y = `tsize'*d*(1+het_t)^event0   // Heterogenous treatment effect
	
	** add a bit of noise
	replace y = y+`noise'*rnormal() + ui

	** two-way fixed effects
	reghdfe y ib`time'.event , abs(id  )
	margins, dydx(event) plot noestimcheck
end


*** adding other controls that change across time
capture program drop twfe6
program twfe6, eclass
	clear
	local iobs 100
	local time 10
	local noise 2
	local tsize 4
	*set seed 54321
	set obs  `iobs' 
	gen id = _n
	gen ui = (rchi2(3)-3)/3
	** Homogenous effect  
	gen het_t = 0
	* gen het_t = (runiform()-.5)*0.5
	** when treated 
	gen wtr = ceil(runiform(0,`time'))
	** expand time
	expand `time'
	bysort id:gen time = _n
	gen x1 = rnormal()+2
	** create a treatment variable
	gen d=time>=wtr
	**  event
	gen event0 = (time - (wtr -1) )
	gen event = (time - (wtr -1) )+`time'
	** create an outcome variable
	gen y =1+x1+`tsize'*d*(1+het_t)   // Homogenous treatment effect because het_t=0
	
	** add a bit of noise
	replace y = y+`noise'*rnormal() + ui

	** two-way fixed effects
	reghdfe y x1 ib`time'.event , abs(id  )
	margins, dydx(event) plot noestimcheck
end
twfe6


capture program drop twfe7
program twfe7, eclass
	clear
	local iobs 100
	local time 10
	local noise 2
	local tsize 4
	*set seed 54321
	set obs  `iobs' 
	gen id = _n
	gen ui = (rchi2(3)-3)/3
	** Homogenous effect  
	gen het_t = (runiform()-.5)*0.5 
	** when treated 
	gen wtr = ceil(runiform(0,`time'))
	** expand time
	expand `time'
	bysort id:gen time = _n
	gen x1 = rnormal()+2
	** create a treatment variable
	gen d=time>=wtr
	**  event
	gen event0 = (time - (wtr -1) )
	gen event = (time - (wtr -1) )+`time'
	** create an outcome variable
	gen y =1+x1+`tsize'*d*(1+het_t)   // Homogenous treatment effect because het_t=0
	
	** add a bit of noise
	replace y = y+`noise'*rnormal() + ui

	** two-way fixed effects
	reghdfe y x1 ib`time'.event , abs(id  )
	margins, dydx(event) plot noestimcheck
end

twfe7 

** What if TE is not completly randome, but conditionally random
capture program drop twfe8
program twfe8, eclass
	clear
	local iobs 100
	local time 10
	local noise 2
	local tsize 2
	*set seed 54321
	set obs  `iobs' 
	gen id = _n
	gen ui = (rchi2(3)-3)/3
	gen x0 = rnormal()
	** Homogenous effect  
	gen het_t = (runiform()-.5)*0.5 
	** when treated 
	** x0 affects treatment. High X0 treated earlier
	gen wtr = ceil(normal(-x0)*`time')
	** expand time
	expand `time'
	bysort id:gen time = _n
	gen x1 = rnormal()+2
	** create a treatment variable
	gen d=time>=wtr
	**  event
	gen event0 = (time - (wtr -1) )
	gen event = (time - (wtr -1) )+`time'
	** create an outcome variable
	gen y =1+x0 + x1+`tsize'*d*(1+het_t)   // Homogenous treatment effect because het_t=0
	
	** add a bit of noise
	replace y = y+`noise'*rnormal() + ui

	** two-way fixed effects
	reghdfe y x1 ib`time'.event , abs(id  )
	margins, dydx(event) plot noestimcheck
end

twfe8


** What if some units are always treated vs never treated
capture program drop twfe9
program twfe9, eclass
	clear
	local iobs 100
	local time 10
	local noise 2
	local tsize 2
	*set seed 54321
	set obs  `iobs' 
	gen id = _n
	gen ui = (rchi2(3)-3)/3
	gen x0 = rnormal()
	** Homogenous effect  
	gen het_t = (runiform()-.5)*0.5 
	** when treated 
	** x0 affects treatment. High X0 treated earlier
	gen wtr = ceil(normal(-x0)*(`time'+4))-2
	replace wtr=0 if wtr<0
	replace wtr=11 if wtr>10
	
	** expand time
	expand `time'
	bysort id:gen time = _n
	gen x1 = rnormal()+2
	** create a treatment variable
	gen d=time>=wtr
	**  event
	gen event0 = (time - (wtr -1) )
	gen event = (time - (wtr -1) )+`time'
	** create an outcome variable including individual effects
	gen y =1+x0 + x1+ ui+`tsize'*d*(1+het_t)   // Homogenous treatment effect because het_t=0
	
	** gen e_i for noise
	gen ei = rnormal()
	** add a bit of noise and individual effects
	replace y = y+`noise'*ei 
	** and create the outcome if Nothing happend.
	gen y0 =1+x0 + x1+ ui
	** two-way fixed effects
	reghdfe y x1 ib`time'.event , abs(id  )
	margins, dydx(event) plot noestimcheck
	reghdfe y x1 d , abs(id time )
end

*** adding an underlying trend

capture program drop twfe9
program twfe9, eclass
	clear
	local iobs 100
	local time 10
	local noise 2
	local tsize 2
	*set seed 54321
	set obs  `iobs' 
	gen id = _n
	gen ui = (rchi2(3)-3)/3
	gen x0 = rnormal()
	** Homogenous effect  
	gen het_t = (runiform()-.5)*0.5 
	** when treated 
	** x0 affects treatment. High X0 treated earlier
	gen wtr = ceil(normal(-x0)*(`time'+4))-2
	replace wtr=0 if wtr<0
	replace wtr=11 if wtr>10
	
	** expand and create time
	expand `time'
	bysort id:gen time = _n
	gen x1 = rnormal()+2
	** create a treatment variable
	gen d=time>=wtr
	**  event
	gen event0 = (time - (wtr -1) )
	gen event = (time - (wtr -1) )+`time'
	** create an outcome variable including individual effects
	gen y =1+x0 + x1+ ui+`tsize'*d*(1+het_t)   // Homogenous treatment effect because het_t=0
	** but add a small trend
	replace y = y + 0.5*t
	** gen e_i for noise
	gen ei = rnormal()
	** add a bit of noise and individual effects
	replace y = y+`noise'*ei 
	** and create the outcome if Nothing happend.
	gen y0 =1+x0 + x1+ ui
	** two-way fixed effects
	reghdfe y x1 ib10.event time, abs(id )
	margins, dydx(event) plot noestimcheck
	reghdfe y x1 d , abs(id time )
end


program twfe10, eclass
	clear
	local iobs 100
	local time 10
	local noise 2
	local tsize 2
	*set seed 54321
	set obs  `iobs' 
	gen id = _n
	gen ui = (rchi2(3)-3)/3
	gen x0 = rnormal()
	** Homogenous effect  
	gen het_t = (runiform()-.5)*0.5 
	** when treated 
	** x0 affects treatment. High X0 treated earlier
	gen wtr = ceil(normal(-x0)*(`time'+4))-2
	replace wtr=0 if wtr<0
	replace wtr=11 if wtr>10
	
	** expand and create time
	expand `time'
	bysort id:gen time = _n
	gen x1 = rnormal()+2
	** create a treatment variable
	gen d=time>=wtr
	**  event
	gen event0 = (time - (wtr -1) )
	gen event = (time - (wtr -1) )+`time'
	** create an outcome variable including individual effects
	gen y =1+x0 + x1+ ui+`tsize'*d*(1+het_t)   // Homogenous treatment effect because het_t=0
	** but add a small trend
	replace y = y + 0.5*t
	** gen e_i for noise
	gen ei = rnormal()
	** add a bit of noise and individual effects
	replace y = y+`noise'*ei 
	** and create the outcome if Nothing happend.
	gen y0 =1+x0 + x1+ ui
	** two-way fixed effects
	reghdfe y x1 ib10.event time, abs(id )
	margins, dydx(event) plot noestimcheck
	reghdfe y x1 d , abs(id time )
end