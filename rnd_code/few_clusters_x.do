/// simulation
clear all
** reuires boottest
** ssc install boottest, replace
capture program drop sim_c1
program sim_c1, eclass
	clear
	set obs $nclusters
	gen ui = rnormal()
	gen id=_n
	gen x = rnormal()
	expand $nobspc 
	gen y = 0.5*x +ui+ rnormal()
	** Regression without adjusting for clusters
	reg y x, 
	*predict res, res
	gen res=y-0.5*x
	sum res, meanonly
	replace res=res-r(mean)
	ereturn display
	matrix tt=r(table)
	matrix b=tt["b","x"],tt["ll","x"],tt["ul","x"] 
	
	** Regression . Standard errors adjusted for clusters
	reg y x, cluster(id)
	matrix tt=r(table)
	matrix b=b,tt["ll","x"],tt["ul","x"] 
	** Regression using WildBootstrap
	mata:reg_wldb("y","x","res","id",$nclusters,$nobspc,1000)
	adde repost V=Vwb
	ereturn display
	matrix tt=r(table)
	*boottest x, nograph cluster(id)
	*matrix xtemp = r(CI)
	*matrix b=b,xtemp[1,1],xtemp[1,2]
	matrix b=b,tt["ll","x"],tt["ul","x"] 

	matrix colname b = b ll ul cll cul wll wul
	ereturn post b
end


/// setup
global nclusters 10
global nobspc    10
global reps		 1000


simulate, seed(1) reps(200): sim_c1

gen n=_n
gen flag = inrange(0.5,_b_ll,_b_ul)
gen flagc = inrange(0.5,_b_cll,_b_cul)
gen flagw = inrange(0.5,_b_wll,_b_wul)

sum flag*

local rm1 = r(mean)
two (pcspike _b_ll n _b_ul  n , color(gs3%30)) ///
	(scatter _b_b n if flag == 0, color(red) msize(vsmall)) ///
	(scatter _b_b n if flag == 1, color(blue) msize(vsmall)) , ///
	legend(off) xtitle(simulation) note("Coverage `rm1'" "Nclusters: $nclusters") ///
	yline(0.5 , lp(-) lcolor(black))
	
sum flagc
local rm2 :display %5.2f r(mean)	
two (pcspike _b_cll n _b_cul  n , color(gs10)) ///
	(scatter _b_b n if flagc == 0, color(red) msize(vsmall)) ///
	(scatter _b_b n if flagc == 1, color(blue) msize(vsmall)) , ///
	legend(off)	xtitle(simulation) note("Coverage `rm2'" "Nclusters: $nclusters" ) ///
	yline(0.5 , lp(-) lcolor(black))

sum flagw
local rm3 :display %5.2f r(mean)	
two (pcspike _b_wll n _b_wul  n , color(gs10)) ///
	(scatter _b_b n if flagw == 0, color(red) msize(vsmall)) ///
	(scatter _b_b n if flagw == 1, color(blue) msize(vsmall)) , ///
	legend(off)	xtitle(simulation) note("Coverage `rm3'" "Nclusters: $nclusters" ) ///
	yline(0.5 , lp(-) lcolor(black))	
****	


