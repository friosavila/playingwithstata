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
	
	// Changes in tsize2 effect (that grows or shrinks with time)
	
	gen     tch_type = 1 
	replace tch_type = (1-1/(event0+.1)) * (event0>0) if $tch_type == 1  // increasing
	replace tch_type = (  1/     event0) * (event0>0) if $tch_type == 2  // Decreasing
		
	// Extra effect for early treatment
	gen     tch_early = 1
	replace tch_early = 1 +       0.5/(wtreat+$out_time)  if $tch_early == 2
	replace tch_early = 1 + 0.5 - 0.5/(wtreat+$out_time)  if $tch_early == 3 
	
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
	global tsize_0   2   
	global tsize_1   2   

	// Treatment Heterogeneity
	global trhet0  	 0
	global trhet1    0
	
	// Treatment change across time
	global tch_type     1   	
	global tch_early    0    

end 

capture program drop twfe_label
program twfe_label
	order 	id time x1 x2 x3 ui  v_it ///
			wtreat wtreat_c treat ///
			event0 event1 event ///
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
/*******************************************************************************

NOTES. This Script has 2 programs for simulations of TWFE scenarios
Programs
twfe_setup: Program used to define parameters for data simulation. 	
twfe_data : Simulates data based on Defined parameters

This Notes Provides some information of How TWFE_SETUP works	
	
I. 	Baseline: Outcome Without treatment 
=======================================
	
1. 	Data size
-------------

Two globals are needed:
	ids 	To define # of Individuals
	time	To define # of periods we observe data
Final Dataset is a balance Dataset with N (ids) individuals and T (time periods)
	
2. 	Exogenous variables, and individual effects
-----------------------------------------------

The program creates 3 exogenous variables.
	x1		Time fixed variable
			x1_i ~ N(0,1)
	x2		Time varying variable set as a Stationary process
			x2_it=0.8*x2_i,t-1 + RUNIFORM(-.5,.5)
	x3		Time varying variable Random across time.
			X3_ut=rnormal
And 1 individual unobserved and time invariant factor 				
	u		Time fixed unobserved factor 
			u_i ~ N(0,1)
	
All X's are correlated with u_i. So one cannot use XTREG, RE	
	
3. 	Trends 
----------

Two types of trends can be simulated.
Common trend and individual trend

	$xtrend	Used to define Common trend slope. This can be any possitive or negative number
	
	$itrend Used to define individual trend slope. 
			When used, the individual trend slope will be defined using a random 
			draw from a uniform distribution between -$itrend to $itrend
		
4. 	Idiosyncratic error
-----------------------

Idiosyncratic error v_it is assumed to distribution as N(0,1). But the size of the error
can be modified using $noise. The final error has a distribution N(0,$noise)
	
5. 	Outcome without treatment
-----------------------------

Given the information above, The data (without treatment) is created as follows:

y0_it = 1+ x1_i + x2_it + x3_it +   b_c * t   +     b_i * t     + u_i + v_it * $noise
                                 \___________/  \_____________/    |   \_____________/
								   Common         Individual     ind.    Idiosyncratic 
									trend		    trend       effect       error

	u_i  ~ N(0,1)
	
	x1_i  = 0.4 * u_i + (1-0.4^2)^.5 * ux1_i
	ux1_i ~ N(0,1)
	
	x2_i1 = 0.4 * u_i 		+ (1-0.4^2)^.5 * ux2_i if t=1
	x2_it = 0.8 * x2_i(t-1) + ux2_it               if t>1
	ux2_it ~ runiform(-.5,.5)
	
	x3_it = 0.4 * u_i + (1-0.4^2)^.5 * ux3_it

	v_it ~ N(0,1)
	
	b_c = $xtrend
	b_i ~ runiform(-$itrend, $trend)

II. Treatment Timing
====================

Treatment period is choosen at random using a uniform distribution. For example
if we consider a $time length of 10 periods, observation "i" has 10% probability
of being treated at period 1, 2, 3,..., 10.

To allow for some observations to be "always treated" or "never treated", 
one can use global "out_time". This should be an integer >=0.

For example if $out_time = 2, then observation "i" could be treated in any of the 
following periods:

			          Observed periods
           ########################################
t' -1	0	1	2	3	4	5	6	7	8	9	10	11	12   <--- Observed time line 
t   1	2	3	4	5	6	7	8	9	10	11	12	13	14   <--- For reference of TRUE timing
   ######                                          ########
   Before										   After 
   data is									       data is
   observed  									   observed

If an observation is treated at t'<1  then it appears always treated
if an observation is treated at t'>10 then it appears never  treated
	
III. Definition of Treatment Status and Treatment effect 
=======================================================

This section describes the different options for modifying the treatment effects

1. Treatment size
-----------------

Treatment size (how much outcome increases) is constructed assuming two components

	 TTE   =     TEFF0  +   TEFF1
	\____/      \_____/    \______/
	Total T      Eff0		 Eff1
    effect

	global
	------
	
	tsize_0     Defines size of TEFF0. This effect can be heterogenous by individual, 
				but it is fixed across time. 
	tsize_1     Defines Max size of TEFF1. This effect can be heterogenous by individual, 
				but it can change across time treated, and when is an individual treated.

	Total Treatment (TTE) is the sum of the two types of effects			
	
2. Treatment Heterogeneity across individual (i)
------------------------------------------------
	
	The following parameters can be used to modify the heterogeneity of the
	Treatment effects for individuals:
	
	 TTE_i   =  het0_i  *  TEFF0  +  het1_i  *  TEFF1
    \_____/    \______/   \_____/   \______/   \_____/
	Total T      Ind.       Eff0	  Ind.	     Eff1
    effect      heter0               heter1
	for i
	
	The factors "het0_i" and "het1_i" are used to induce heterogeneity on the treatment effects.
	
	This heterogeneity is obtained using a random draw from a uniform distributions as follows:
	
	het0_i = 1 + het0_i		where het0_i~runiform(-$trhet0, $trhet0)
	het1_i = 1 + het1_i		where het1_i~runiform(-$trhet1, $trhet1)
	
	Where:
	trhet0	defines the heterogeneity for TEFF0
	trhet1	defines the heterogeneity for TEFF1
	
3. Treatment Heterogeneity across time (t)
------------------------------------------	

	The following parameters can be used to modify the heterogeneity of the
	Treatment effects across time:
	
	 TTE_it   =  het0_i  *  TEFF0  +  het1_i  *  TEFF1  * het1_it *  het2_it
    \______/    \______/   \_____/   \______/   \_____/  \______/   \______/ 
	Total T       Ind.       Eff0	  Ind.	     Eff1      time      time
    effect       heter0               heter1              heter1    heter2
	
	Two parameters are used to determine heterogeneity.
	This affect het1_t and het2_t.
	
	HET1_IT:
	
	The first type of time heterogeneity determines if the treatment effect 
	increases or decreases with the number of periods a unit is treated. 
	
	This is determined using global tch_type. This can have 3 values:
	
	tch_type:
	
	0	The effect does not change with #periods treated
		
	->	het1_t = 1
		
	1	The effect increases with #periods treated. The effect grows at a decreasing rate.
		max effect at P->infinity
	
	->	het1_it = 1 - 1 / (#p_it+.1) 

		For example at #p_it = 1, het1_i1 = 9.1
					at #p_it = 2, het1_i2 = 52
					at #p_it = 3, het1_i3 = 67
	
	2   The effect decreases with #periods treated. The effect shrinks at a decreasig rate. 
		When P -> infinity, TE is zero.
		(thank you Austin Nichols)
	
	->	het1_it = 1 / #p_it 

		For example at #p_it = 1, het1_i1 = 100
					at #p_it = 2, het1_i2 =  50
					at #p_it = 3, het1_i3 =  33.33
	
	HET2_IT:
	
	The second type of time heterogeneity determines if the treatment effect is
	larger or smaller if observation "i" was treated earlier or later compared to other observations.
	
	The timing depends on "t" not "t'"
	
	This is determined using global tch_early. This can have 3 values:

	0  	Effect is the same regardless of when was unit treated.
	
	-> het2_it = 1
	
	1  	Effect is larger for Units treated earlier (includes Out of time window treatment)  
	
	-> het2_it = 1 + ( 0.5 / t0 ) 
	
	where t0 is the time when unit "i" was treated
	
	2  	Effect is larger for Units treated later (includes Out of time window treatment)  
	
	-> het2_it = 1 + ( 0.5 - 0.5 / t0 ) 
	
	where t0 is the time when unit "i" was treated
	
IV. Final Data Creation and Data Structure
==========================================	
		
	Final Outcome is defined as follows:
	
	treat
	y_it = y0_it +  TTE_it * treat_it
	where treat_it=1 if observation i is treated at time t
	
*******************************************************************************/

    set seed 110
	twfe_setup
	twfe_data	 
	twfe_label
	
	xtset id event0 
	xtline y y0 if avg_treat>.2 & avg_treat<.8
	
	ss
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
	
	