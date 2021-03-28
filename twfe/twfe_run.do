capture program drop twfe_setup
** Standard DD with Panel data
program twfe_setup
	// Data size
	global ids    100   // # of Individuals
	global time    10   // # of time periods

	// Common and Individual trends
	global xtrend   0.5 // common
	global itrend   0.5 // SHould be a positive number. If 0 no individual trend

	// Size of Idiosyncratic error
	global noise    2   // Size of Noise (in sd) Idiosyncratic noise
	
	global time_dd  0
	// Calibratio for always treated vs never treated (periods before and after
	global out_time 2  // Needs to be INT >= -($time-1)/2
	
	// Treatment Calibration
	// Treatent Size
	global tsize_0   0  
	global tsize_1   2   

	// Treatment Heterogeneity
	global trhet0  	 0.5
	global trhet1    0.5
	
	// Treatment change across time
	global tch_type     1    	
	global tch_early    0

end 


ss
program sim1, eclass
  	twfe_setup
	twfe_data	 
	twfe_label
	reg tte i.treat
	matrix b=_b[1.treat]
	reghdfe y x1 x2 x3  i.treat , abs(id time) 
	matrix b=b,_b[1.treat]
	ereturn post b
end
	simulate, reps(100):sim1
	sum
	// True effects 
	reg tte i.event0_r  
	margins, dydx(event0_r) noestimcheck plot
 	// TWFE REG
	
	// as Event study
	reg tte i.event
	reghdfe y x1 x2 x3 ib$time.event , abs(id  )
	margins, dydx(event) noestimcheck plot(yline(0))
	
	// flexible estimation 

	capture program drop sim2
	program sim2, eclass
	  	twfe_setup
		twfe_data	 
		twfe_label
		reg tte i.treat##c.event1  
		matrix b1=_b[1.treat], _b[1.treat#c.event1]
		matrix coleq b1 = "true"
		matrix colname b1 = treat treatevent
		reghdfe y x1 x2 x3 i.treat##c.event1  , abs(id  time)
		matrix b2=_b[1.treat], _b[1.treat#c.event1]
		matrix coleq b2 = "proxy"
		matrix colname b2 = treat treatevent
		matrix b=b1,b2
		ereturn post b
	end
	
	simulate, reps(200):sim2
	two kdensity  true_b_treat || kdensity  proxy_b_treat
two kdensity  true_b_treatevent || kdensity  proxy_b_treatevent
		// True effects 
	