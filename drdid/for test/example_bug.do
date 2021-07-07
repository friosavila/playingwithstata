
*Fernando's example
use https://friosavila.github.io/playingwithstata/drdid/mpdta.dta, clear
csdid  lemp lpop , ivar(countyreal) time(year) gvar(first_treat) method(dripw) notyet
/*
2004, not found
r(111);
*/

*Kiril's example
// Generate a complete panel of 300 units observed in 15 periods
clear all
timer clear
set seed 10
global T = 15
global I = 300
set obs `=$I*$T'
gen i = int((_n-1)/$T )+1 					// unit id
gen t = mod((_n-1),$T )+1					// calendar period
tsset i t
// Randomly generate treatment rollout years uniformly across Ei=10..16 (note that periods t>=16 would not be useful since all units are treated by then)
gen Ei = ceil(runiform()*7)+$T -6 if t==1	// year when unit is first treated
bys i (t): replace Ei = Ei[1]
gen K = t-Ei 								// "relative time", i.e. the number periods since treated (could be missing if never-treated)
gen D = K>=0 & Ei!=. 						// treatment indicator
// Generate the outcome with parallel trends and heterogeneous treatment effects
gen tau = cond(D==1, (t-12.5), 0) 			// heterogeneous treatment effects (in this case vary over calendar periods)
gen eps = rnormal()							// error term
gen Y = i + 3*t + tau*D + eps 
*
cap drop gvar
gen gvar = cond(Ei==., 0, Ei)
csdid Y, ivar(i) time(t) gvar(gvar) notyet
/*
2, not found
r(111);
*/
