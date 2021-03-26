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
** x2 Time varying Across time (random walk)
** x3 Time random characteristics 
** All x's correlated with X
** Treatment time will be random.

	clear
	set obs $ids
	gen id=_n 
	
	// Individual time fixed effect
	
	gen ui = rnormal()
	
	// Time fix effect
	
	gen x1 = 0.3^0.5*ui+0.7^0.5*rnormal()
	
	// Time varying at X0
	
	gen x2 = -0.3^0.5*ui+.7^0.5*rnormal()
	
	
	// Defining Treatment Timing (when)
	
	gen wtreat = ceil( runiform(0-$out_time,$time+$out_time ) )
	
	// anything under 1 is always treated, and over 10 never treated
	
	// Treatment heterogeneity
	
	gen het_t = runiform(-.5,.5)*$trhet
	
	// Individual trend heterogeneity
	
	gen ihet_t =(1+runiform(-$itrend , $itrend))
	
	// expanding time
	expand $time
	bysort id:gen time=_n
		
	// Time varying
	
	by id:replace x2 = x2[_n-1] + runiform(-.5,.5) if _n>1
	
	// Time random
	
	gen x3=rnormal()
	
	// Defining Treatment
	
	gen treat = time >= wtreat
	
	// Defining TRUE timing for event
	
	gen event0 = time - (wtreat-1)
	
	// trend effect (that grows with time)
	
	gen     trnd = 1 
	replace trnd = (event0/10)*(event0>0) if $trnd == 1
	
	// The problem is that we do not see all. If WTR is less than 1 , it was alreays terated. and larger than 10 never terated (in the data)
	
	gen     wtreat_c = wtreat 
	replace wtreat_c = 1 if wtreat<1
	replace wtreat_c = 10 if wtreat>10
	
	gen event= time - (wtreat_c-1) + $time
	gen event1= time - (wtreat_c-1) 
	// Creating of Potential outcomes
	// First outcome without treatment 
	
	gen y0 = 1 + x1 + x2 -x3 +ui + $xtrend*time*ihet_t + $noise * rnormal()
	
	// Outcome With treatment
	
	gen y  = y0 + treat * (1+het_t) *  $tsize * trnd
	
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
	global ids    100   // # of Individuals
	global time    10   // # of time periods
	global tsize    4   // size of treatment
	global out_time 2   // Over and "under periods
	global noise    2   // Size of Noise (in sd)
	global trhet    1   // if 0 Homogenous, if 1 heterogenous
	global trnd     1   // if 0 no trend, 1 grows with trend
	global xtrend   0.5 // Common trend 
	global itrend   0.5 // individual trend?
end 
	
////////////////////////////////////////////////////////////////////////////////
capture program drop twfex
program twfex
	twfe_setup
	twfe_data	 
 	// TWFE REG
	reghdfe y x1 x2 x3  i.treat##c.event0  , abs(id id#c.time      ) 
 
end
simulate, reps(100):twfex
ss
	reg tte treat##c.event0  
 	// Event analysis
	reghdfe y x1 x2 x3 ib$time.event , abs(id  )
	margins, dydx(event) noestimcheck plot(yline(0))
	
	
	
	