////////////////////////////////////////////////////////////////////////////////
//
// Simulations for understading DID with even tstudies
//
////////////////////////////////////////////////////////////////////////////////


capture program drop twfe_data
program twfe_data
** basic data structure
** 3 types of data
** ui individual time fixed effect 
** x1 Time Fixed characteristic 
** x2 Time varying Across time 
** x3 Time random characteristics 
** All x's correlated with X
** Treatment time will be random.

	clear
	set obs $ids
	gen id=_n 
	
	// Individual time fixed effect
	
	gen ui = rnormal()
	
	// Time fix effect
	
	gen x1 = 0.4*ui+sqrt(1-.4^2)*rnormal()
	
	// Time varying at X0
	
	gen x2 = -0.4*ui+sqrt(1-.4^2)*rnormal()
		
	// Defining Treatment Timing (when)
	
	gen wtreat = ceil( runiform(0-$out_time, $time + $out_time ) )
	
	// anything under 1 is always treated, and over 10 never treated
	
	// Treatment heterogeneity
	
	gen het_t0 = runiform(-$trhet0 , $trhet0 )
	if $trhet0 == 0 replace het_t0 =0
	
	gen het_t1 = runiform(-$trhet1 , $trhet1 )
	if $trhet1 == 0 replace het_t1 =0
	// Individual trend heterogeneity
	
	gen ihet_t =runiform(-$itrend , $itrend )
	if $itrend == 0 replace ihet_t =0
	
	// expanding time
	expand $time
	bysort id:gen time=_n
		
	// Time varying
	
	by id:replace x2 = 0.8*x2[_n-1] + runiform(-.5,.5) if _n>1
	
	// Time random
	
	gen x3=ui*.4 + sqrt(1-.4^2)*rnormal()
	
	// Defining Treatment
	
	gen treat = time >= wtreat
	
	// Defining TRUE timing for event
	
	gen event0 = time - (wtreat-1)
	qui:sum event0
	gen event0_r = event0 +1-r(min)
	
	// Changes in tsize2 effect (that grows or shrinks with time)
	
	gen     tch_type = 1 
	replace tch_type = (1-1/(event0+.1)) * (event0>0) if $tch_type == 1  // increasing
	replace tch_type = (  1/     event0) * (event0>0) if $tch_type == 2  // Decreasing
		
	// Extra effect for early treatment
	gen     tch_early = 1
	replace tch_early = 1 +       0.5/(wtreat+$out_time)  if $tch_early == 1
	replace tch_early = 1 + 0.5 - 0.5/(wtreat+$out_time)  if $tch_early == 2 
	
	// The problem is that we do not see all. If WTR is less than 1 , it was alreays terated. and larger than 10 never terated (in the data)
	
	gen     wtreat_c = wtreat 
	replace wtreat_c = 1 if wtreat<1
	replace wtreat_c = 10 if wtreat>10
	
	gen event1= time - (wtreat_c-1)
	gen event = time - (wtreat_c-1) + $time
	 
	// Creating of Potential outcomes
	// First outcome without treatment 
	gen v_it =rnormal()
	
	gen y0 = 1 + x1 + x2 -x3 +ui + $xtrend * time + ihet_t * time + $noise * v_it
	
	// Outcome With treatment
	
	gen y  = y0 + treat * $tsize_0 * (1+het_t0) +  treat * (1+het_t1) *  $tsize_1 * tch_type * tch_early
	
	// auxiliary variables
	// avg T per id:
	
	by id: egen avg_treat=mean(treat)
	
	// gen True treat
	gen tte = y - y0
end	
/// Other Stuff Weights and Residualized outcome
/// basic setup
capture program drop twfe_setup
program twfe_setup
	// Data size
	global ids    100   // # of Individuals
	global time    10   // # of time periods

	// Common and Individual trends
	global xtrend   0.5 // common
	global itrend   0.0 // SHould be a positive number. If 0 no individual trend

	// Size of Idiosyncratic error
	global noise    2   // Size of Noise (in sd) Idiosyncratic noise
	
	// Calibratio for always treated vs never treated (periods before and after
	global out_time 1   // Needs to be INT >= 0
	
	// Treatment Calibration
	// Treatent Size
	global tsize_0   1   
	global tsize_1   2   

	// Treatment Heterogeneity
	global trhet0  	 0
	global trhet1    0
	
	// Treatment change across time
	global tch_type     0   	
	global tch_early    1    

end 

capture program drop twfe_label
program twfe_label
	order 	id time x1 x2 x3 ui  v_it ///
			wtreat wtreat_c treat ///
			event0 event0_r event1 event ///
			y0 y tte avg_treat 
			
	label var id        "Individual id"
	label var time      "time variable"
	label var x1        "Time fixed variable"
	label var x2        "Stationary time varying variable"
	label var x3        "Random variable"
	label var ui        "Time fixed, unobserved, individual effect"
	label var v_it      "Idiosyncratic error. Changes across time and individuals"
	label var wtreat    "When was observation 'i' treated"
	label var wtreat_c  "Censored: When was Observation treated"
	label var treat     "=1 if observation is treated. (wtreat>=time)"
	label var event0    "True Event time variable."
	label var event0_r  "True Event time variable. Rescaled"
	label var event1    "Censored Event time variable. Due to Out time-window wtreat"
	label var event     "Censored Rescaled. For use with Factor variables"	
	label var y0        "Outcome assuming no treatment"	
	label var y         "Outcome with treatment"	
	label var tte       "True Treatment effect"
	label var avg_treat "Prop. of periods 'i' is treated."
	label var het_t0    "Aux variable"
	label var het_t1    "Aux variable"
	label var ihet_t    "Aux variable"
	label var tch_type  "Aux variable"
	label var tch_early "Aux variable"
end

    set seed 110
	twfe_setup
	twfe_data	 
	twfe_label
	
	xtset id event0 
	*xtline y y0 if avg_treat>.3 & avg_treat<.7
	scatter tte event0
	ddd
	
	// True effects 
	reg tte treat#c.event0_r  
 	// TWFE REG
	reghdfe y x1 x2 x3  i.treat , abs(id time) 
	// as Event study
	reghdfe y x1 x2 x3 ib$time.event , abs(id  )
	*margins, dydx(event) noestimcheck plot(yline(0))
	
	// flexible estimation 
	reghdfe y x1 x2 x3  i.treat##c.event1  , abs(id id#c.time time     ) 
		// True effects 
	reg tte treat##c.event0  
	
	