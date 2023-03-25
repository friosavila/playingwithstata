webdoc init qreg_data, header(   stscheme(ocean)   include(mattex.txt)  ///
						title(DGP for CQR) ) logall replace 
/***
<h1>Conditional Quantile Regressions: A simulation approach</h1>
First apologies. I have been working on the third part of my Qreg interpretation "blog", but has been taking longer than expected, as I'm struggling to find a balance between length, technical details, and what is more important (and motivated me to write that), the interpretation. But, I have not forgotten about that. It is coming.
<br><br>
Now something I realized while writing about Conditional quantile regression, is that we (or at least when I learned this topic), fail to understand what conditional quantile regressions do because it is hard to think about how data looks like in terms of the Data generating process (DGP).
<br><br>
So, to help address this problem, I will provide you here two ways of thinking about what Conditional quantile regressions do, from the perspective of the underlying DGP. So let's start.

<h2>Conditional Quantile regressions: A tale of unobserved heterogeneity</h2>
As the title suggests, one of the ways of thinking about DGP and what conditional quantile regressions do is to think in terms of unobserved heterogeneity. Something, that we cannot control for that is interacting with the effect of observed variables, which can the effect of those variables vary across individuals. 
<br><br> 
On this regard, while unobserved factors that cause the heterogeneity cannot be observed, CQR tries to identify this heterogeneity by imposing some identification assumptions that relate to conditional distributions, but not necessarily individual experiences. 
<br><br>
Namely, consider the conditional distribution of Y that can be written as $F_{Y|X}$. Given this function, it is also possible to identify the conditional quantile as $F^{-1}_{y|x}(\tau)=Q_{y|X}(\tau)$. 
<br><br>
The first identification assumption for conditional quantiles (whichever method you choose to apply) is that:

$$ Q_{y|X}(\tau_1) \leq Q_{y|X}(\tau_2) \iff \tau_1 \leq \tau_2 $$

In other words, conditional quantiles have to be non decreasing in $\tau$. This is an obvious condition, but it does impose important constrains on the on how estimators attempt to identify conditional quantiles. 
<br><br>
Specifically, Assume that conditional quantiles can be estimated using some functional form as follows:

$$ Q_{y|X}(\tau) = g(X,\tau) $$

Under very specific circumstances, if we know an observations $x_i$ and $\tau_i$ (which is a stand-in for the unobserved component), we will have the following:

$$ y_i = g(X_i,\tau_i) = Q_{y|X=x_i}(\tau_i) $$

This means that we could use the same function $g()$ to determine a conditional quantile and the outcome for any particular observation. 
And if this is true, that means the "rank invariance" assumption holds. And we could analyze how $y$ when either $x$ changes if $\tau_i$ remains the same, or $\tau$ changes assuming $x$ remains the same. 

<h3>So where is the heterogeneity?</h3>
As I already mention, all conditional quantile regression methods attempt to identify the function $g(X,\tau)$. To do so, most impose some functional form on $g()$ that would help to identify relationships across all observations who have the same "ranking" $\tau$ but different $X$. The opposite, identifying all quantiles $\tau$ across observations with the same $X$ is also possible, but require may work, depending on the dimension of $X$.
<br><br>
The most common approach, which I'll use for the data simulation, is to assume that, for a fixed $\tau$, the function $g()$ is linear in $X$:
$$ Q_{y|X}(\tau) = g(X,\tau) = X*\beta(\tau)$$

In this setup, the unobserved heterogeneity comes from $\beta(\tau)$ , because we never really know what quantile $\tau$ a person belongs to, the same way that we never observe the true error in a standard LR model. Additionally, quantile regression algorithms will find $\betas(\tau)$ that may generate "reasonable" quantiles, but you may also observe quantile crossings where predicted 90th quantile may have a value below than 10th quantile, for combinations of characteristics that are rare or unobserved in the actual data.

<h2>DGP for conditional quantile regressions</h2>

There are two DGP that have been considered and used for explaining what do CQR does. The first approach is the one I have previously described:
$$y_i=x_i*\beta(\tau_i) \quad \tau_i \sim uniform(0,1) $$
This specification basically assumes a kind of random coefficients models that depend on $\tau$, which follows a uniform distribution (0,1). To simplify things, one usually assumes $\beta(\tau_i)$ to be some linear or nonlinear function of $\tau$.
<br><br>
The second DGP that has been used, and is often more intuitive, is to assume a model with known heteroskedasticity:
$$y_i=g(x)+v_i *h(x) \quad v_i \sim iid \quad or $$
$$y_i=x_i*\beta+v_i *(x_i*\gamma) \quad v_i \sim iid $$
This second approach, however, is a special case of the first one, if we assume that $v_i = F^-1_v(\tau_i)$:
$$y_i=x_i*(\beta+v_i *\gamma)  =  x_i*(\beta+F_v^-1(\tau) *\gamma) = x_i*\beta(\tau_i)$$
Now, if we want to use this DGP process to simulate data, and verify that any particular algorithm (like -qreg-) replicates the "theoretical" quantile beta coefficients $\beta(\tau)$, we need to remember that the first assumption I started with holds:
$$ Q_{y|X}(\tau_1) \leq Q_{y|X}(\tau_2) \iff \tau_1 \leq \tau_2$$
As far as I know, in the case of the random coefficients approach, no general conditions exist to garrantie monotonically increasing conditional quantiles. However, for the heteroskedastic error approach, one simply needs $h(x)$ to be strictly possitive.
<br><br>
Alright, so with this in mind, some coding. 
***/

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

/***
So here you have two different examples of how to generate quantile regressions. 
Now to see how well these coefficients can be identified using -qreg-, we can estimate series of CQR, and compared the coefficients with the True coefficients.
Here an example:
***/
** Model with random coefficients
qui:qreg y_1 x1 x2, nolog
qregplot x1 x2, cons  raopt( color(gs4%50)) q(5(5)95)
addplot 1:line b1 tau100 if inrange(tau100,4,96), sort lwidth(1)
addplot 2:line b2 tau100 if inrange(tau100,4,96), sort lwidth(1)
addplot 3:line b0 tau100 if inrange(tau100,4,96), sort lwidth(1)
graph export qdgp1.png, replace
/***
<img src="qdgp1.png" class="center">
***/

** Model with Heteroskedastic errors 
qui:qreg y_2 x1 x2, nolog
qregplot x1 x2, cons   raopt( color(gs4%50)) q(5(5)95)
addplot 1:line g1 tau100 if inrange(tau100,4,96), sort lwidth(1)
addplot 2:line g2 tau100 if inrange(tau100,4,96), sort lwidth(1)
addplot 3:line g0 tau100 if inrange(tau100,4,96), sort lwidth(1)
graph export qdgp2.png, replace
/***
<img src="qdgp1.png" class="center">
***/

/***
Of course, a simple 1 shot exercise is not enough to judge how qreg replicates DGP coefficients (or if the DGP coefficients as created correspond to the qreg coefficients). So to do this, I can just prepare a small Montecarlo simulation exercise. First for the random coefficients
***/
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
/***
If everything works the way it's supposed to, the means should be close to zero. And that is what we see here. (although you may argue, they are small but not quite zero). Remember, one should normally use 10000 simulations, not 500 as I did here.
<br><br>
For completeness, we can do this again for the heteroscedastic model:
***/

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
/***
And again, we can see that the mean of coefficients is very close to zero, which suggest that the theoretical coefficients do match the coefficients identified by -qreg-.
<br> <br>
One thing that I have found useful for analyzing CQR, in terms of the DGP, is to see what happens when the rank invariance assumption does not hold. This is a kind of counter-example, that may help understand why CQR cannot always be interpreted as individual effects, but effects across distributions.
<br><br>
For this example, I will concentrate on a model with a single explanatory variable, and use the random coefficients approach:
***/

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

/***
This isn't obvious, but for this model, the rank invariance assumption does not hold. This is easy to see, if we plot the data above, color coding for different levels of $\tau$.
***/

two scatter y x, color(%20) || ///
	scatter y x if abs(tau-.1)<.05 || ///
	scatter y x if abs(tau-.5)<.05 || ///
	scatter y x if abs(tau-.9)<.05, ///
	legend(order(2 "Tau ~ 0.1" 3 "Tau ~ 0.5" 4 "Tau ~ 0.9") cols(3))
graph export qdgp3.png, replace
/***
<img src="qdgp3.png" class="center">	
<br>
So what we see here is that the rank invariance assumption holds, but only for $X<1$. When $X>1$, everything flips. Observations with a smaller $\tau$, have a larger $y$, and vice-versa. This implies that this DGP does create heterogeneity, but the $\beta 's$ cannot be identified by -qreg-.
<br> <br> 
A simple way to see this is to estimate CQR, and plot the predicted values for those models:
***/
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

/***
<img src="qdgp4.png" class="center">	
<br>
As you can see, qreg (and any other program) estimates coefficients so that higher predicted quantiles are always larger than lower quantiles (at least within the observed range of $x$). 
<br><br>
In this case, the rank invariance assumption does not hold, and the model specification is incorrect. It would be better to describe effects as simply comparing conditional distributions. Also, a better approximation could be using a quadratic term or a simple spline:
***/

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
/***
<img src="qdgp5.png" class="center">	
<br>
However, the simple Qreg still provides the best linear approximation, to the average conditional quantile effect:
***/
qreg y  x , q(10) nolog
qui:qreg y  x d2 , q(10)
f_able d2, auto
margins, dydx(x)
qreg y  x , q(90) nolog
qui:qreg y  x d2 , q(90)
f_able d2, auto
margins, dydx(x)

/***
<h2>Conclusion</h2>
In this post, I provided you with some code that I hope you find helpful to simulate and better understand what kind of information CQR can identify, and understand the implications of the rank invariance assumption. 
<br><br>
There is still the problem of How should one interpret these results. 
<br><br>
Interpreting CQR is a problem on its own. I'm still writing part III on the interpretation of QREG models, which emphasizes some of the details I describe here. So, yes, that is still to come.
<br><br>
As always, thank you for reading. Comments or questions, welcome. 
***/
webdoc close