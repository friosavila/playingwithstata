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
	
	gen het_t = runiform(-$trhet , $trhet )
	
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
	global tsize    4   // size of treatment (after 10 periods if trnd=1 or a jump of 4.
	global out_time 2   // Over and "under periods" To have always treated and never treated
	global noise    2   // Size of Noise (in sd) Idiosyncratic noise
	global trhet    .5  // Treatment heterogeneity by individual. tsize * (1+ u(-z,z) )  So each individual has a random effect
	global trnd     0   // 0 or 1. If 0, effect is a one time shock. Otherwise, it grows (in average) in tsize/10 each period
	global xtrend   0.5 // Common trend for all individuals. y = 1+x1+x2+x3+0.5*time
	global itrend   0.5 // individual trend. It generates heteroneity around the common trend. (1+ runiform(-$itrend , $itrend)) 
end 
	
////////////////////////////////////////////////////////////////////////////////
    set seed 110
	twfe_setup
	twfe_data	 
	// True effects 
	reg tte treat##c.event0  
 	// TWFE REG
	reghdfe y x1 x2 x3  i.treat , abs(id time) 
	// as Event study
	reghdfe y x1 x2 x3 ib$time.event , abs(id  )
	*margins, dydx(event) noestimcheck plot(yline(0))
	
	// flexible estimation 
	reghdfe y x1 x2 x3  i.treat##c.event1  , abs(id id#c.time time     ) 
		// True effects 
	reg tte treat##c.event0  
	
	