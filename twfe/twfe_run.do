capture program drop twfe_setup
program twfe_setup
	// Data size
	global ids    100   // # of Individuals
	global time    10   // # of time periods

	// Common and Individual trends
	global xtrend   0.5 // common
	global itrend   0.5 // SHould be a positive number. If 0 no individual trend

	// Size of Idiosyncratic error
	global noise    3   // Size of Noise (in sd) Idiosyncratic noise
	
	// Calibratio for always treated vs never treated (periods before and after
	global out_time 1   // Needs to be INT >= 0
	
	// Treatment Calibration
	// Treatent Size
	global tsize_0   0  
	global tsize_1   2   

	// Treatment Heterogeneity
	global trhet0  	 0.5
	global trhet1    0.5
	
	// Treatment change across time
	global tch_type     2     	
	global tch_early    0

end 

  	twfe_setup
	twfe_data	 
	twfe_label
	
	xtset id event0 
	*xtline y y0 if avg_treat>.3 & avg_treat<.7
	scatter tte event0
	reg tte i.treat
	reghdfe y x1 x2 x3  i.treat , abs(id time) 
ww
	// True effects 
	reg tte i.event0_r  
	margins, dydx(event0_r) noestimcheck plot
 	// TWFE REG
	reg tte i.treat
	reghdfe y x1 x2 x3  i.treat , abs(id time) 
	reghdfe y x1 x2 x3  i.treat if wgt>0, abs(id time) 

	reghdfe treat x1 x2 x3  , abs(id time)  resid
	gen wgt = _reghdfe_resid
	replace wgt = - _reghdfe_resid if treat==0
	// as Event study
	reghdfe y x1 x2 x3 ib$time.event , abs(id  )
	margins, dydx(event) noestimcheck plot(yline(0))
	
	// flexible estimation 
	reghdfe y x1 x2 x3  i.treat##c.event  , abs(id id#c.time ) 
	reg tte i.treat##c.event  

		// True effects 
	reg tte treat##c.event0  