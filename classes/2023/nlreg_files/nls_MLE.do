*** NLR
** NWR
clear
range x -5 5 100
gen y = (x^4 - 18* x^2 + 15*x)
gen dy = (4*x^3 - 36* x + 15)
gen ddy = (12*x^2 - 36)
scatter dy x
** Say we want to
mata:
 // function to obtain the Value, the gradient and Hessian 
 real matrix  fgh_x(real matrix x, real scalar g){
 	real matrix y
 	if (g==0)      y =    -x:^4 :- 18*x:^2 :+ 15*x
	else if (g==1) y =  -4*x:^3 :- 36*x    :+ 15
	else if (g==2) y = -12*x:^2 :- 36   
	return(y)
 }

 x = -2 , 2 ,0 
 xt = x,fgh_x(x,0),fgh_x(x,1)
for(i=1;i<8;i++) {
	 x = x :- fgh_x(x,1):/fgh_x(x,2)
	 xt = xt \ x,fgh_x(x,0),fgh_x(x,1)
}
end

two ( scatter y dy ddy x, connect(l) msize(4 3 2 ) mcolor( %20 %20 %20) ), ///
	xline(-3.189918291    2.764709535    .4252087556)
	
** NLS in Stata Manual!
clear
set seed 101
set obs 100
** Generating fake data
gen x = runiform()
gen y = 1+0.5*x^0.5+rnormal()*.1
*** Load data in Mata...to make things quick
mata
x=st_data(.,"x")
y=st_data(.,"y")
end

mata
// Initial data
b=1\1\1
b0=999\999\999
bb=b'
// and a loop to see when data converges
while (sum(abs(b0:-b))> 0.000001 ) { 
	b0=b	
	// residuals
	e=y:-(b[1]:+b[2]*x:^b[3])
	// pseudo regressors
	sx=J(100,1,1),x:^b[3],b[2]*x:^b[3]:*ln(x)
	// gradient and Hessian
	g=-cross(sx,e)
	H=cross(sx,sx)
	// updating B
	b=b-invsym(H)*g
	// Storing results
	bb=bb\b'
}
/// Now STD ERR (for fun 😃 )
vcv = e'e / (100-3) * invsym(H)
b , diagonal(vcv):^0.5
end

nl (y = {b0=1} + {b1=1} * x ^ {b2=1})

** Example 2 NLS vs logit
frause oaxaca, clear
nl (lfp = logistic({b0}+{b1:female age educ}))   
logit lfp female age educ

** IRSL
gen one =1
mata:
y = st_data(.,"lfp")
x = st_data(.,"female age educ one")
end

mata:
b=0\0\0\0
// Initial data

b0=999\999\999\999
bb=b'
// and a loop to see when data converges
while (sum(abs(b0:-b))> 0.000001 ) { 
	b0=b	
	// residuals
	yhat = logistic(x*b)
	e=y:-yhat
	// pseudo regressors
	sx=yhat:*x
	// weights 
	ww=sqrt(yhat:*(1:-yhat))
	// gradient and Hessian
	g=-cross(sx,ww,e)
	H=cross(sx,ww:^2,sx)
	// updating B
	b=b-invsym(H)*g
	// Storing results
	bb=bb\b'
}
/// Now STD ERR (for fun 😃 )
vcv = e'e / (100-3) * invsym(H)
b , diagonal(vcv):^0.5
end

************************ MLE
** Define Program
capture program drop my_ols
program define my_ols
  args lnf ///   <- Stores the LL for obs i
       xb  ///   <- Captures the Linear combination of X's
       lnsigma // <- captures the Log standard error
  ** Start creating all aux variables and lnf     
  qui {
    tempvar sigma // Temporary variable
    gen double `sigma' = exp(`lnsigma')
    tempvar y
    local y $ML_y1
    replace `lnf'      = log( normalden(`y',`xb',`sigma' ) )
  }     
end

frause oaxaca, clear
ml model lf   /// Ask to use -ml- to estimate a model with method -lf-
   my_ols     /// your ML program
   (xb: lnwage = age educ female  ) /// 1st Eq (only one in this case)
   (lnsig: = female ) // Empty, (no other Y, but could add X's)
   // I could haave added weights, or IF conditions
ml check     // checks if the code is correct
ml maximize  // maximizes
ml display   // shows results

** Logit

logit lfp educ i.female age i.married i.divorced
margins, expression(exp(xb())/(1+exp(xb())))
margins

** marginal effects
margins, dydx(educ) 
margins, expression( logistic(xb())*(1-logistic(xb()))*_b[educ] )
margins, dydx(*) expression( logistic(xb())*(1-logistic(xb()))*_b[educ] )