sysuse auto, clear

reg price mpg foreign
gen one=1
mata
y=st_data(.,"price")
x=st_data(.,"mpg foreign one")
e=y:-x*(invsym(x'*x)*(x'*y))
if_= (e:*x)*invsym(x'*x) 
nk = 1000
b=J(nk,3,.)
for(i=1;i<=nk;i++){
	b[i,]=mean(rnormal(74,1,0,1):*if_)*74	
}
sqrt(mean(b:^2))

end

// First we start mata
set seed 10
mata:
    // load all data
    y = st_data(.,"price")
    // You load X's and the constant
    x = st_data(.,"mpg foreign"),J(rows(y),1,1)
    // Estimate Betas:
    b = invsym(x'*x)*x'y
    // Estimate errors:
    e = y:-x*b
    // Estimate STD of errors
    std_e=sqrt(sum(e:^2)/73)
	// Now we can do the bootstrap:
	// We first create somewhere to store the different betas
	bb = J(1000,3,.)
	// and start a loop
	for(i=1;i<=1000;i++){
		// each time we draw a different value for y..say ys
		ys = x*b+rnormal(74,1,0,std_e)
		// and estimate the new beta, storing it into bb
		bb[i,]=(invsym(x'*x)*x'ys)'
	}
	// Now just report SE
	b,diagonal(sqrt(variance(bb)))
end

set seed 10
// First we start mata
mata:
    // This remains the same as before
    y = st_data(.,"price")
    x = st_data(.,"mpg foreign"),J(rows(y),1,1)
    b = invsym(x'*x)*x'y
    e = y:-x*b
    // Now we need to know how many observations we have
    nobs=rows(y)
    // Same as before
	bb = J(1000,3,.)
	for(i=1;i<=1000;i++){
		// Here is where we "draw" a different error everytime, 
        // runiformint(nobs,1,1,nobs) <- This says Choose a randome number between 1 to K
        // and use that value to assing as the new error to create ys
		ys = x*b+e[runiformint(nobs,1,1,nobs)]
		bb[i,]=(invsym(x'*x)*x'ys)'
	}
	// Now just report SE
	b,diagonal(sqrt(variance(bb)))
end

set seed 10
// First we start mata
mata:
    // This remains the same as before
    y = st_data(.,"price")
    x = st_data(.,"mpg foreign"),J(rows(y),1,1)
    b = invsym(x'*x)*x'y
    e = y:-x*b
    nobs=rows(y)
    bb = J(1000,3,.)
	for(i=1;i<=1000;i++){
		// Here is where we "draw" a different error multiplying the original error by v ~ N(0,1)
		ys = x*b+e:*rnormal(nobs,1,0,1)
		bb[i,]=(invsym(x'*x)*x'ys)'
	}
	// Now just report SE
	b,diagonal(sqrt(variance(bb)))
end


set seed 10
mata:
    // This remains the same as before
    y = st_data(.,"price")
    x = st_data(.,"mpg foreign"),J(rows(y),1,1)
    b = invsym(x'*x)*x'y
    e = y:-x*b
    nobs=rows(y)
    bb = J(1000,3,.)
	for(i=1;i<=1000;i++){
		// What I do here is get a vector that will identify the resampling.
		r_smp = runiformint(nobs,1,1,nobs)
		// then use this resampling vector to reestimate the betas
		brs = invsym(x[r_smp,]'*x[r_smp,])*x[r_smp,]'y[r_smp,]
		bb[i,]=brs'
	}
	// Now just report SE
	b,diagonal(sqrt(variance(bb)))
end



capture program drop two_heckman
program two_heckman, eclass
** you implement your estimator:
     probit dwage married children educ age
    predict mill, score
    reg wage educ age mill
    ** Delete all variables that were created 
    capture drop  mill  
    ** Finally, you will Store all the coefficients into a matrix
    matrix b=e(b)
    ** and "post" them into e() so they can be read as an estimation output
    eretur post b
end

bootstrap, reps(250):two_heckman

capture program drop two_heckman2
program two_heckman2, eclass
** you implement your estimator:
     probit dwage married children educ age
	 tempvar smp
    ** define sample
    gen byte `smp'=e(sample)
    predict mill, score
    reg wage educ age mill
        ** Delete all variables that were created 
    capture drop  mill  
    ** Finally, you will Store all the coefficients into a matrix
    matrix b=e(b)
    ** and "post" them into e() so they can be read as an estimation output
    ereturn post b, esample(`smp')
end
bootstrap, reps(250):two_heckman2


