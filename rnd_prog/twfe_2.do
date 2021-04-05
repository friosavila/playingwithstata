*** TWFE if Treatment is homogenous
*** Pretreatment is the same (no Trends).

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
	reghdfe y d, abs(id time)
	matrix b=_b[d]
	ereturn post b
end

simulate, reps(1000):twfe1
histogram _b_c1


*** STEP 2:
*** Add Individual effects (random constants) u_i
*** a time constant variable x1
*** a time varying variable x2
*** and a time changing (from X0) variable (as a random walk).
*** modify treatment so some times never treated, while others always treated
*** Important. Pretreatment holds. (no trends)

program drop twfe2
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
	gen wtr = ceil(runiform(0-2,`time'+2))
	** individual level effect
	gen ui = rnormal()
	** expand time
	** time constant variable THat is correlated to ui
	gen x1 = 0.75^2*rnormal()+0.25^2*ui
	** for time changing 
	gen x3 = 0.75^2*rnormal()+0.25^2*ui
	expand `time'
	bysort id:gen time = _n
	** time varying variable (corr with x1)
	gen x2 = (0.2)^.5*x1 + (0.7)^.5*rnormal()
	** Time changing, as a random walk
	by id:replace x3 =x3[_n-1]+(0.5*(runiform()-.5)) if _n>1
	
	** create a treatment variable
	gen d=time>=wtr
	** ID for event. True event start after Treatment starts.
	gen event0 = (time - (wtr -1) )
	** Observed event. we do not observe negatives...so need to modify wtr
	gen wtr_c=wtr
	replace wtr_c=1  if wtr<1
	replace wtr_c=10 if wtr>10
	** Measured event (because of censored data)
	gen event = (time - (wtr_c -1) )+`time'
	
	** create an outcome variable + noise (if never treated)
	gen y0 = 1+x1+x2+x3+ui + `noise'*rnormal()
	** Add the treatment for those we observe treated
	gen y = y0 + `tsize'*d

	** two-way fixed effects
	reghdfe y x1 x2 x3 d, abs(id time )
	** RE
	** and as an events study 
	reghdfe y x1 x2 x3 ib`time'.event, abs(id )
	margins, dydx(event) noestimcheck plot( name(m1, replace))
	
	** Estimation of "weights"
	reghdfe y x1 x2 x3 , abs(id time) resid
	gen resid_y=_reghdfe_resid
	reghdfe d x1 x2 x3 , abs(id time) resid
	gen resid_d=_reghdfe_resid
	** weights
	egen vard=mean(resid_d^2)
	gen swgt=resid_d/vard
	**
	bysort id:egen avgt=mean(d)
	scatter swgt event, color(%20) name(m2, replace)
	reg resid_y c.resid_d##i.d
	two scatter swgt  avgt if d==1 , color(%20) || ///
			scatter swgt  avgt if d==0 , color(%20) , name(m3, replace)
end
 
****

*** Question. How the treatment affects the outcome?
*** Is a one shot effect? 
*** a cumulative effect?
*** diminishing effect?
*** for now...simple heterogeneity
program drop twfe3
program twfe3, eclass
	clear
	local iobs 100
	local time 10
	local noise 2
	local tsize 2
	*set seed 54321
	set obs  `iobs' 
	gen id = _n
	** when treated 
	gen wtr = ceil(runiform(0-2,`time'+2))
	** individual level effect
	gen ui = rnormal()
	** expand time
	** time constant variable THat is correlated to ui
	gen x1 = 0.75^2*rnormal()+0.25^2*ui
	** for time changing 
	gen x3 = 0.75^2*rnormal()+0.25^2*ui
	** Treatment Heterogeneity 
	gen het_t = 1+runiform(-.3,.3)
	expand `time'
	bysort id:gen time = _n
	** time varying variable (corr with x1)
	gen x2 = (0.2)^.5*x1 + (0.7)^.5*rnormal()
	** Time changing, as a random walk
	by id:replace x3 =x3[_n-1]+(0.5*(runiform()-.5)) if _n>1
	
	** create a treatment variable
	gen d=time>=wtr
	** ID for event. True event start after Treatment starts.
	gen event0 = (time - (wtr -1) )
	** Observed event. we do not observe negatives...so need to modify wtr
	gen wtr_c=wtr
	replace wtr_c=1  if wtr<1
	replace wtr_c=10 if wtr>10
	** Measured event (because of censored data)
	gen event = (time - (wtr_c -1) )+`time'
	
	** create an outcome variable + noise (if never treated)
	gen y0 = 1+x1+x2+x3+ui + `noise'*rnormal()
	** Add the treatment for those we observe treated
	gen y = y0 + `tsize'*d*het_t

	gen trt =y-y0
	** two-way fixed effects
	reghdfe y x1 x2 x3 d, abs(id time )
	** RE
	xtset id
	xtreg y x1 x2 x3 d i.time,
	** and as an events study 
	reghdfe y x1 x2 x3 ib`time'.event, abs(id )
	margins, dydx(event) noestimcheck plot( name(m1, replace))
	
	** Estimation of "weights"
	reghdfe y x1 x2 x3 , abs(id time) resid
	gen resid_y=_reghdfe_resid
	reghdfe d x1 x2 x3 , abs(id time) resid
	gen resid_d=_reghdfe_resid
	** weights
	egen vard=mean(resid_d^2)
	gen swgt=resid_d/vard
	**
	bysort id:egen avgt=mean(d)
	scatter swgt event, color(%20) name(m2, replace)
	reg resid_y c.resid_d##i.d
	two scatter swgt  avgt if d==1 , color(%20) || ///
			scatter swgt  avgt if d==0 , color(%20) , name(m3, replace)
end
 
 
** Alternative. Effect is random by person, and increases with time
program drop twfe4
program twfe4, eclass

	clear
	local iobs 100
	local time 10
	local noise 2
	local tsize 2
	*set seed 54321
	set obs  `iobs' 
	gen id = _n
	** when treated 
	gen wtr = ceil(runiform(0-2,`time'+2))
	** individual level effect
	gen ui = rnormal()
	** expand time
	** time constant variable THat is correlated to ui
	gen x1 = 0.75^2*rnormal()+0.25^2*ui
	** for time changing 
	gen x3 = 0.75^2*rnormal()+0.25^2*ui
	
	** Treatment Heterogeneity 
	gen het_t = 1+runiform(-.3,.3)
	expand `time'
	bysort id:gen time = _n
	
	** time varying variable (corr with x1)
	gen x2 = (0.2)^.5*x1 + (0.7)^.5*rnormal()
	** Time changing, as a random walk
	by id:replace x3 =x3[_n-1]+(0.5*(runiform()-.5)) if _n>1

	
	** create a treatment variable
	gen d=time>=wtr
	** ID for event. True event start after Treatment starts.
	gen event0 = (time - (wtr -1) )
	** Observed event. we do not observe negatives...so need to modify wtr
	gen wtr_c=wtr
	replace wtr_c=1  if wtr<1
	replace wtr_c=10 if wtr>10
	** Measured event (because of censored data)
	gen event = (time - (wtr_c -1) )+`time'
	
	** create an outcome variable + noise (if never treated)
	gen y0 = 1+x1+x2+x3+ui + `noise'*rnormal()
	** Add the treatment for those we observe treated
	gen y = y0 + `tsize'*d*het_t

	gen trt =y-y0
	** two-way fixed effects
	reghdfe y x1 x2 x3 d, abs(id time )
	** RE
	xtset id
	xtreg y x1 x2 x3 d i.time,
	** and as an events study 
	reghdfe y x1 x2 x3 ib`time'.event, abs(id )
	margins, dydx(event) noestimcheck plot( name(m1, replace))
	
	** Estimation of "weights"
	reghdfe y x1 x2 x3 , abs(id time) resid
	gen resid_y=_reghdfe_resid
	reghdfe d x1 x2 x3 , abs(id time) resid
	gen resid_d=_reghdfe_resid
	** weights
	egen vard=mean(resid_d^2)
	gen swgt=resid_d/vard
	**
	bysort id:egen avgt=mean(d)
	scatter swgt event, color(%20) name(m2, replace)
	reg resid_y c.resid_d##i.d
	two scatter swgt  avgt if d==1 , color(%20) || ///
			scatter swgt  avgt if d==0 , color(%20) , name(m3, replace)
end
 
 
************************ 
 
 ** adding trends
program twfe6, eclass
	clear
	local iobs 100
	local time 10
	local noise 2
	local tsize 4
	*set seed 54321
	set obs  `iobs' 
	gen id = _n
	** when is the unit treated :it can be treated after data is collected, or before (so always treated and never treated.
	
	gen wtr = ceil(runiform(0-4,`time'+3))
	
	** individual level effect
	gen ui = rnormal()
	** expand time
	** time constant variable
	gen x1 = rnormal()
	** for time changing
	gen x3 = rnormal()
	** for heterogneity random for each observations. 
		gen het_t = 1+runiform(-.3,.3)
	
	expand `time'
	bysort id:gen time = _n
	** time varying variable (corr with x1)
	gen x2 = (0.2)^.5*x1 + (0.7)^.5*rnormal()
	** Time changing, as a random walk
	by id:replace x3 =x3[_n-1]+((runiform()-.5)) if _n>1
	
	** create a treatment variable
	gen d=(time>=wtr)
	** True event moment:
	gen event0 = (time - (wtr -1) )
	** but we only see what is in the data. Thus need to cap WTR
	gen wtr2=wtr
	replace wtr2=0 if wtr<0
	replace wtr2=10 if wtr>10
	** So the event construction is based on what we observe.
	gen event = (time - (wtr2 -1) )+`time'
	
	** create an outcome variable + noise (if never treated)
	gen y0 = 1+x1+x2+x3+ui + 0.5*time + `noise'*rnormal()
	** Add the treatment for those we observe, 
	gen  y = y0 + `tsize'*d*het_t
	*(event0/10)  
 
	** two-way fixed effects
	reghdfe y x1 x2 x3 d, abs(id   )
	reghdfe y x1 x2 x3 d, abs(id time  )
	** RE
	xtset id
	xtreg y x1 x2 x3 d i.time,
	** and as an events study 
	reghdfe y x1 x2 x3 ib`time'.event, abs(id )
	margins, dydx(event) noestimcheck plot
	
	** weights construction
	reghdfe d x1 x2 x3 , abs(id time) resid
	gen res_d=_reghdfe_resid
	egen varrr=mean(_reghdfe_resid^2)
	gen wgt= _reghdfe_resid/varr
	reghdfe y x1 x2 x3 , abs(id time) resid
	gen res_y=_reghdfe_resid
	two scatter wgt event || histogram event, yaxis(2) color(%50) discrete
	scatter res_y res_d
end  