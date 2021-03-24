clear
set seed 1101
set obs 250
gen x = 2+rnormal()/2
gen z = runiform()>.5
gen v = rnormal()
replace x=. if x>5  // Dropping large values for the graph
replace x=1.5 in 1/2  // but setting two points of interest
replace z=0 in 1
replace z=1 in 2
 gen zero=0
* finally, following the DGP, we have:
gen y = 2 + 1*x - 2*z + 2*x*z + v * (1+x+z)
gen id = _n
two (scatter y    x  if z==0 ,  color(navy%20)  ) || ///
	(scatter y    x  if z==1 ,  color(maroon%20)  ) || ///
	(scatter y    x  in 1/5 if z==0, mlabel(id) mlabcolor(black) mlabpos(12) color(navy%80)  )  ///
	(scatter y    x  in 1/5 if z==1, mlabel(id) mlabcolor(black) mlabpos(12) color(maroon%80)  ) , ///
	legend(order(1 "y if z=0" 2 "y if z=1") bplace(nw) position(center) cols(1) region(lstyle(none))  )   xlabel(0.5 1/3 3.5) ylabel(-5 (5) 22)
graph export qr2_1.png, replace

gen dx=1
gen xdx=x+dx
gen xdr=x+0.05
gen y_dx = 2 + 1*xdx - 2*z + 2*xdx*z + v * (1+xdx+z)
** individual effect	for DX		  
gen d1=y_dx-y
gen dz=1	
gen y_dz1 = 2 + 1*x - 2*dz + 2*x*dz + v * (1+x+dz)
replace dz=0
gen y_dz0 = 2 + 1*x - 2*dz + 2*x*dz + v * (1+x+dz)
gen d2=y_dz1-y_dz0

two (scatter y    x  ,  color(gs5%20)  ) || ///
	(scatter y    x  in 1/5 if z==0, mlabel(id) mlabcolor(black) mlabpos(12) color(navy%40)  )  ///
	(scatter y    x  in 1/5 if z==1, mlabel(id) mlabcolor(black) mlabpos(12) color(maroon%40)  ) ///		  
	(pcarrow  y xdr y_dz1 xdr in 1/5 if z==0, color(navy) barbsize(medium)) ///
	(pcarrow  y xdr y_dz0 xdr in 1/5 if z==1, color(maroon) barbsize(medium)) ///
	(scatter y_dz1 x  in 1/5 if z==0,  color(navy%80)  )  ///
	(scatter y_dz0 x  in 1/5 if z==1,  color(maroon%80)  ) , ///
	xlabel(0.5 1/3 3.5) ylabel(-5 (5) 22) ///
	legend(order(4 "f(x,z=0,v) {&rarr} f(x,z=1,v)" 5 "f(x,z=1,v) {&rarr} f(x,z=0,v)")  ///
	bplace(nw) position(center) cols(1) region(lstyle(none)) ) /// 
	name(m1,replace)  graphregion(margin(tiny))  ytitle("y") xtitle("x")
	
two (scatter y    x  ,  color(gs5%10)  ) || ///
	(pcarrow  y x y_dz1 x in 1/100 if z==0, color(navy%50) barbsize(medium)) ///
	(pcarrow  y x y_dz0 x in 1/100 if z==1, color(maroon%50) barbsize(medium)) , ///
	xlabel(0.5 1/3 3.5) ylabel(-5 (5) 22) ///
	legend(order(2 "f(x,z=0,v) {&rarr} f(x,z=1,v)" 3 "f(x,z=1,v) {&rarr} f(x,z=0,v)") ///
	bplace(nw) position(center) cols(1)  region(lstyle(none)) ) /// 
	name(m2,replace)   graphregion(margin(tiny))  ytitle("y") xtitle("x")

graph combine m1 m2 , col(2) title("Impact of Changing Z status") xsize(10) ysize(5)	 
graph export qr2_2.png, replace
******************************************************************************************
gen zr=z+normalden(d1-1)*(runiform()-.5) if z==0
replace zr=z+normalden(d1-3)*(runiform()-.5) if z==1
 
two (scatter d2 x if z==0, color(navy%20)   ) ///
	(scatter d2 x if z==1  , color(maroon%20) ) ///
	(function 1+normalden( x,0,1)*.5 , color("85 62 85") horizontal yaxis(1) range(-3 6) ) ///
	(function 2+normalden( x,2,1)*.5 , color("85 62 85") horizontal yaxis(1) range(-3 6) ) ///
	(function 3+normalden( x,4,1)*.5 , color("85 62 85") horizontal yaxis(1) range(-3 6) ),  ///
	legend( order(1 "Impact of Z=0 {&rarr} Z=1" 2 "(-) Impact of Z=1 {&rarr} Z=0") ///
	bplace(nw) position(center) col(1)   region(lstyle(none))  ) ///
	name(m2,replace)   graphregion(margin(tiny)) xlabel(0.5 1/3 3.5)  ytitle("{&Delta}y")  ///
	title("Distribution of the Impact of Z Status change") xtitle("x") xline(1 2 3, lp(shortdash) lc(gs5)) ylabel(-3 " " -2 (2) 6)
 
 graph export qr2_3.png, replace

two (scatter d2 x if z==0, color(navy%20)   ) ///
	(scatter d2 x if z==1, color(maroon%20) ) ///
	(function 1+normalden( x,0,1)*.5 , color("85 62 85") horizontal yaxis(1) range(-3 7) ) ///
	(function 2+normalden( x,2,1)*.5 , color("85 62 85") horizontal yaxis(1) range(-3 7) ) ///
	(function 3+normalden( x,4,1)*.5 , color("85 62 85") horizontal yaxis(1) range(-3 7) ) ///
	(function -2 + 2*x, color(forest_green) yaxis(1) range(.5 3.5) lw(0.5) ) ,  ///
	legend( order(1 "Impact of Z=0 {&rarr} Z=1" 2 "(-) Impact of Z=1 {&rarr} Z=0" 6 "E(y(1)|x)-E(y(0)|x)" ) ///
	bplace(nw) position(center) col(1)   region(lstyle(none))  ) ///
	name(m2,replace)   graphregion(margin(tiny)) xlabel(0.5 1/3 3.5)  ytitle("{&Delta}y")  ///
	title("Conditional Distribution" "Impact of Z Status change") xtitle("x") ylabel(-2(2)6) xline(1 2 3, lp(shortdash) lc(gs5))  
 
   graph export qr2_4.png, replace

 
*gen d3 = - 2 + 2*x
 two (scatter d2 x if z==0, color(navy%10)   ) ///
	(scatter d2 x if z==1, color(maroon%10) ) ///
	(function 1+normalden( x,0,1)*.5 , color(gs5%40) horizontal yaxis(1) range(-3 7) ) ///
	(function 2+normalden( x,2,1)*.5 , color(gs5%40) horizontal yaxis(1) range(-3 7) ) ///
	(function 3+normalden( x,4,1)*.5 , color(gs5%40) horizontal yaxis(1) range(-3 7) ) ///
	(function -2 + 2*x, color(gs5%40) yaxis(1) range(.5 3.5) lw(0.5) ) ///
	( function normalden(x,2,0.5), range(0.5 3.5) recast(area) color(forest_green%30) yaxis(2) ylabel(0(0.4)2, axis(2) ) ytitle("density of x",axis(2))) ///
	(pcarrowi 5 2.5 2 2 (12) "PC Treatment effect", color(black) mlabcol(black)) ,  ///
	legend( order(1 "Impact of Z=0 {&rarr} Z=1" 2 "(-) Impact of Z=1 {&rarr} Z=0" 6 "{&Delta}E(y|x,z)/{&Delta}z" ) ///
	bplace(nw) position(center) col(1)   region(lstyle(none))  ) ///
	name(m2,replace)   graphregion(margin(tiny)) xlabel(0.5 1/3 3.5)  ytitle("{&Delta}y")  ///
	title("Distribution of the Impact of Z Status change") xtitle("x") ylabel(-2(2)6) xline(1 2 3, lp(shortdash) lc(gs5))  
graph export  qr2_5.png, replace	
 	
 two (histogram d2 if z==0 , color(navy%20) bin(30) ylabel(0(.1).5) xlabel(-2(2)6) xline(2, lp(-) lc(black)) )  ///
	(histogram d2 if z==1, color(maroon%20) bin(30) ) 	/// 
	(function normalden( x,2,sqrt(2)) , color(forest_green)   yaxis(1) range(-3 7) ) , ///
	legend( order(1 "Impact of Z=0 {&rarr} Z=1" 2 "(-) Impact of Z=1 {&rarr} Z=0"  ) ///
	bplace(nw) position(center) col(1)   region(lstyle(none))  )  ///
	title("Unconditional distribution of the Impact of Z Status change") ///
	xtitle("{&Delta}y")  
 graph export  qr2_6.png, replace

clear
set seed 1101
set obs 2500000
gen x = 2+rnormal()/2
gen z = runiform()>.5
gen v = rnormal()
gen y = 2 + 1*x - 2*z + 2*x*z + v * (1+x+z)
gen y1 = 2 + 1*x - 2*1 + 2*x*1 + v * (1+x+1)
gen y0 = 2 + 1*x - 2*0 + 2*x*0 + v * (1+x)
 
range yy -10 25 141
  
kdensity y0 , gen(fy0) at(yy) nodraw 
kdensity y1 , gen(fy1) at(yy) nodraw 
kdensity y ,  gen(fyy) at(yy) nodraw 
drop if yy==. 
 
drop if yy<0 | yy>10
two (line fy0 yy, color(navy%80) ) ///
	(line fyy yy, color(forest_green%80) ) ///
	(line fy1 yy, color(maroon%80) ) ///
	(scatteri 	`=fy0[17]' `=yy[17]' "0% treated" ///
				`=fyy[21]' `=yy[21]' "Current" ///
				`=fy1[25]' `=yy[25]' "100% treated" ///
				, mlabcol(black)), ///
	xline(4 , lp(-) lc(navy)) xline(5 , lp(-) lc(forest_green)) ///
	xline(6 , lp(-) lc(maroon)) ///
	legend(order(1 "E(Z)=0.0; E(Y)=4" 2 "E(Z)=0.5; E(Y)=5" 3 "E(Z)=1.0; E(Y)=6") ///
	bplace(ne) position(center) col(1)   region(lstyle(none))  )  ///
	xtitle("y") xlabel(0(2)10 5)
	 
graph export  qr2_7.png, replace	
