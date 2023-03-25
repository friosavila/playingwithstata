*** Required programs
ssc install qregplot
ssc install f_able
ssc install addplot

** General set up
** Generating 1000 obs
clear
set obs 1000
set seed 1
** and generating TAU
gen tau = runiform()
gen tau100=tau*100
** I create X1 and X2 to be strictly possitive correlated variables. 
gen corr_factor=rnormal()
gen x1=ceil( 3*normal((0.4*rnormal()+0.6*corr_factor)) *10)/10
gen x2=ceil( abs( 0.4*rnormal()+0.6*corr_factor) *10)/10
** For Option 1, I will take the random coefficients aproach.
** Where the betas are functions of tau
gen b0 = tau*2-tau^2
gen b1 = 2*tau^2
gen b2 = normal((tau-.5)*7)
** The outcome is then the randome coefficients times the characteristics
gen y_1 = b0 + b1 *x1 +b2*x2
reg y_1 x1 x2
** for Option 2, I will use a model with with heteroskedasticity
** first the iid error (with mean 0) (here normal)
gen v = invnormal(tau)

** and the model with heteroskedasticity could be:
* y_2 = 0.5 + 0.5 * x1 + 0.5 * x2 + v*(2 - 0.2* x1 + x2)
** THis implies the following Betas:
gen g0 = 0.5 + 2* invnormal(tau)
gen g1 = 0.5 -.2* invnormal(tau)
gen g2 = 0.5 + 1* invnormal(tau)
** so the data can be created like this:
* gen y_21= 0.5 + 0.5 * x1 + 0.5 * x2 + v*(2 - 0.2* x1 + x2)
** or like this:
gen y_2 = g0 + g1*x1+g2*x2

** Model with random coefficients
qui:qreg y_1 x1 x2, nolog
qregplot x1 x2, cons  raopt( color(gs4%50)) q(5(5)95)
addplot 1:line b1 tau100 if inrange(tau100,4,96), sort lwidth(1)
addplot 2:line b2 tau100 if inrange(tau100,4,96), sort lwidth(1)
addplot 3:line b0 tau100 if inrange(tau100,4,96), sort lwidth(1)
graph export qdgp1.png, replace

** Model with Heteroskedastic errors 
qui:qreg y_2 x1 x2, nolog
qregplot x1 x2, cons   raopt( color(gs4%50)) q(5(5)95)
addplot 1:line g1 tau100 if inrange(tau100,4,96), sort lwidth(1)
addplot 2:line g2 tau100 if inrange(tau100,4,96), sort lwidth(1)
addplot 3:line g0 tau100 if inrange(tau100,4,96), sort lwidth(1)
graph export qdgp2.png, replace

** Create data:
clear
set obs 1000
set seed 1
gen tau = runiform()
gen corr_factor=rnormal()
gen x1=ceil( 3*normal((0.4*rnormal()+0.6*corr_factor)) *10)/10
gen x2=ceil( abs( 0.4*rnormal()+0.6*corr_factor) *10)/10
gen b0=.
gen b1=.
gen b2=.
gen y_1=.
** and simulate
program sim_qreg1
	replace tau = runiform()
	replace b0 = tau*2-tau^2
	replace b1 = 2*tau^2
	replace b2 = normal((tau-.5)*7)
	** The outcome is then the randome coefficients times the characteristics
	replace y_1 = b0 + b1 *x1 +b2*x2
	qreg y_1 x1 x2, q(10)
	matrix b1=e(b)-[2*0.1^2, normal((0.1-.5)*7), 0.1*2-0.1^2]
	qreg y_1 x1 x2, q(50)
	matrix b2=e(b)-[2*0.5^2, normal((0.5-.5)*7), 0.5*2-0.5^2]
	qreg y_1 x1 x2, q(90)
	matrix b3=e(b)-[2*0.9^2, normal((0.9-.5)*7), 0.9*2-0.9^2]
	matrix coleq b1 = q10
	matrix coleq b2 = q50
	matrix coleq b3 = q90
	matrix colname b1 =b1 b2 b0
	matrix colname b2 =b1 b2 b0
	matrix colname b3 =b1 b2 b0
	matrix b =b1,b2,b3
	ereturn post b
end
set seed 10
simulate, reps(500):sim_qreg1
sum

clear
set obs 1000
set seed 1
gen tau = runiform()
gen corr_factor=rnormal()
gen x1=ceil( 3*normal((0.4*rnormal()+0.6*corr_factor)) *10)/10
gen x2=ceil( abs( 0.4*rnormal()+0.6*corr_factor) *10)/10
gen g0=.
gen g1=.
gen g2=.
gen y_2=.
** and simulate
program sim_qreg2
	replace tau = runiform()
	replace g0 = 0.5 + 2* invnormal(tau)
	replace g1 = 0.5 -.2* invnormal(tau)
	replace g2 = 0.5 + 1* invnormal(tau)
	** The outcome is then the randome coefficients times the characteristics
	replace y_2 = g0 + g1 *x1 +g2*x2
	qreg y_2 x1 x2, q(10)
	matrix b1=e(b)-[ 0.5 -.2* invnormal(.1) , 0.5 + 1* invnormal(.1), 0.5 + 2* invnormal(.1)]
	qreg y_2 x1 x2, q(50)
	matrix b2=e(b)-[ 0.5 -.2* invnormal(.5) , 0.5 + 1* invnormal(.5), 0.5 + 2* invnormal(.5)]
	qreg y_2 x1 x2, q(90)
	matrix b3=e(b)-[ 0.5 -.2* invnormal(.9) , 0.5 + 1* invnormal(.9), 0.5 + 2* invnormal(.9)]
	matrix coleq b1 = q10
	matrix coleq b2 = q50
	matrix coleq b3 = q90
	matrix colname b1 =b1 b2 b0
	matrix colname b2 =b1 b2 b0
	matrix colname b3 =b1 b2 b0
	matrix b =b1,b2,b3
	ereturn post b
end
set seed 10
simulate, reps(500):sim_qreg2
sum 

*** create 1000 obs
clear
set obs 1000
set seed 10
*** create x to be positive (similar to above)
gen x = 3*runiform()
*** create Tau
gen tau  = runiform()
*** and create two random coefficients
gen b0 = tau-.5
gen b1 = .5-tau
*** create the outcome
gen y = b0 + b1* x


two scatter y x, color(%20) || ///
	scatter y x if abs(tau-.1)<.05 || ///
	scatter y x if abs(tau-.5)<.05 || ///
	scatter y x if abs(tau-.9)<.05, ///
	legend(order(2 "Tau ~ 0.1" 3 "Tau ~ 0.5" 4 "Tau ~ 0.9") cols(3))
graph export qdgp3.png, replace
qui:qreg y  x  , q(10)
predict q10
qui:qreg y  x  , q(50)
predict q50
qui:qreg y  x  , q(90)
predict q90
two scatter y x, color(%20) || ///
	scatter y x if abs(tau-.1)<.05, color(navy) || ///
	scatter y x if abs(tau-.5)<.05, color(maroon) || ///
	scatter y x if abs(tau-.9)<.05, color(forest_green) || ///
	line q10 q50 q90 x, sort lw(1 1 1) color( navy maroon forest_green) ///
	legend(order(2 "Tau ~ 0.1" 3 "Tau ~ 0.5" 4 "Tau ~ 0.9" ///
	5 "q10hat" 6 "q50hat" 7 "q90hat" ) cols(3))
graph export qdgp4.png, replace


*ssc install f_able
f_spline d=x, k(1)
qui:qreg y  x d2 , q(10)
predict q10x
qui:qreg y  x d2 , q(50)
predict q50x
qui:qreg y  x d2 , q(90)
predict q90x

two scatter y x, color(%20) || ///
	scatter y x if abs(tau-.1)<.05, color(navy) || ///
	scatter y x if abs(tau-.5)<.05, color(maroon) || ///
	scatter y x if abs(tau-.9)<.05, color(forest_green) || ///
	line q10x q50x q90x x, sort lw(1 1 1) color( navy maroon forest_green) ///
	legend(order(2 "Tau ~ 0.1" 3 "Tau ~ 0.5" 4 "Tau ~ 0.9" ///
	5 "q10hat" 6 "q50hat" 7 "q90hat" ) cols(3))
graph export qdgp5.png, replace
qreg y  x , q(10) nolog
qui:qreg y  x d2 , q(10)
f_able d2, auto
margins, dydx(x)
qreg y  x , q(90) nolog
qui:qreg y  x d2 , q(90)
f_able d2, auto
margins, dydx(x)

