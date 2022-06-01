# How to Bootstrap Anything
## the Stata Way

## Introduction: What is Bootstrapping

One of the things econometricians/economist are quite interested in is estimating point estimates. However, because we know point estimates contain errors (sampling errors), we are also interested in estimating the precision of those estimates, at least given the information we have in hand (**the sample**). In other words, its standard errors.

In most intro to econometrics courses, we typically learn that one way we could estimate the precision of those estimates would be drawing multiple samples, estimating the model of interest for each new subsample, and summarizing the estimated coefficients. What ever you find as Standard deviations of the estimated coefficients are the coefficient **Standard Errors**.

We know, however, that collecting multiple samples from the same population is technically impossible. So we need to rely on other approaches:

- **Asymptotic approximations**: where we make use of some of the properties of the estimators (deep knowledge of how those are constructed)
- **Empirical approximation**: Or what I will call Bootstrapping.

## But What is Bootstrapping?

As a non-native speaker, the word bootstrapping didn't mean anything to me but a statistical technique to obtain empirical Standard errors. After a few years in Gradschool, however, I have heard a few times the expression:

> Pull yourself up by your own bootstraps

Which is quite appropriate for describing what Bootstrapping does. Since we do not have access to other samples, we **pull** standard errors by using, and reusing, that sample in different ways, to estimate Standard errors for our estimates.

The differences in how the sample information is **reused** is what differentiates the type of bootstrapping method you are applying.

## Types of Bootstrapping.

There are, in fact, many approaches that can be used to obtained Bootstrap standard errors (BSE), all depending on the assumptions we are willing to impose. And not all of them can be applied in every sceneario. For sake of simplicilty, I will refer to the ones that can be applied for the case of linear regressions. Thus, say that you are interested in a linear regression model that has the following functional form:
$$y=X\beta+e$$

To ground the principles of the different methodologies, we will use the dataset `auto.dta`.

---
### Setup and Asymptotic SE

Just to ground things up, we will estimate a very simple Linear Regression model using `auto.dta` dataset.

```stata
sysuse auto, clear
reg price mpg foreign

      Source |       SS           df       MS      Number of obs   =        74
-------------+----------------------------------   F(2, 71)        =     14.07
       Model |   180261702         2  90130850.8   Prob > F        =    0.0000
    Residual |   454803695        71  6405685.84   R-squared       =    0.2838
-------------+----------------------------------   Adj R-squared   =    0.2637
       Total |   635065396        73  8699525.97   Root MSE        =    2530.9

------------------------------------------------------------------------------
       price | Coefficient  Std. err.      t    P>|t|     [95% conf. interval]
-------------+----------------------------------------------------------------
         mpg |  -294.1955   55.69172    -5.28   0.000    -405.2417   -183.1494
     foreign |   1767.292    700.158     2.52   0.014     371.2169    3163.368
       _cons |   11905.42   1158.634    10.28   0.000     9595.164    14215.67
------------------------------------------------------------------------------
```

---
### Parametric Bootstrap

As the name suggest, parametric bootstrap requires imposing some parametric assumptions on the source of the error in the model: $e$. Those characteristics of the error is what we will learn from the original sample.

For example, we could assume $e$ follows some normal distribution, with variance equal to the variance of the observed error $\sigma^2_e=Var(\hat e)$. 

What you would need to do, then, is **draw/create** different samples using the following rule:

$$\tilde y = X \hat \beta + \tilde e \ where \ \tilde e\sim N(0,var(\hat e))$$

In this case, all $X's$ are fixed, but the **new** samples are given by the different $\tilde y's$, which differ only because of the draws of the errors $\tilde e$.

Once you get multiple of samples, and coefficients for each, you can simply Report the associated Standard Errors.

How to do it in Stata? Here I will cheat a bit, and use Mata, because it will be faster. Note that you will need to copy the whole code into a dofile and run all of it, or type each line individualy in the command window (once you activate mata):

```stata
set seed 10
// First we start mata
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
```
If everythings goes well, it should give you the following 

```stata
                  1              2
    +-------------------------------+
  1 |  -294.1955331    55.59108401  |
  2 |   1767.292243    689.3703271  |
  3 |   11905.41528    1159.921784  |
    +-------------------------------+
```
Things not notice. We are explicitly impossing the assumption of homoskedasticity and normality on the errors. This explain why this standard errors are almost identical to the simple asymptotic standard errors.


---
### Residual Bootstrap

Residual bootstrap is very similar to the parametric bootstrap I described above. The main difference is that we no longer impose assumptions on the errors distributions, and instead use the empirical distribution.

What does this mean? well, In the above example, we have 74 different values for the error $e$, thus resampling means that you create a new $\tilde y$ by drawing 74 errors from this **bag** of errors, where all have the same probability of being choosen.

$$\tilde y  =  x \hat \beta X + \tilde e \ where  \ \tilde e \sim [\hat e_1, \hat e_2,...,\hat e_N]$$ 

How would you implement it?  Lets go to the Mata code:

```stata
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
```

This will give us the following:

```stata
                  1              2
    +-------------------------------+
  1 |  -294.1955331    53.63708346  |
  2 |   1767.292243    703.1172879  |
  3 |   11905.41528    1118.818836  |
    +-------------------------------+
```

Once again, this method keeps $X's$ as fixed, and assumes errors are fully homoskedastic. 

---
### Wild-Bootstrap/multiplicative bootstrap

Wild bootstrap is another variant of residual bootstraps. You start as always estimating the original model, and obtaining the model errors. For the resampling, however, rather than suffling errors, or making assunptions on its distribution, we reuse the error after we *disturb* the error.

In other words:

$$ys=X \hat \beta + \hat e * v $$

where $v$ is the source of the noise we need to add to the model. Technically we can use any distribution for $v$, as long as $E(v)=0$ and $Var(v)=1$. The most common wildbootstrap implementations use **mammen** distribution, but for simplicitly I will use a normal distribution:

```stata
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
		// Here is where we "draw" a different error multiplying the original error by v ~ N(0,1)
		ys = x*b+e:*rnormal(nobs,1,0,1)
		bb[i,]=(invsym(x'*x)*x'ys)'
	}
	// Now just report SE
	b,diagonal(sqrt(variance(bb)))
end
```
Results:
```stata
                  1              2
    +-------------------------------+
  1 |  -294.1955331    59.62775803  |
  2 |   1767.292243     586.545592  |
  3 |   11905.41528    1357.383088  |
    +-------------------------------+
```

Although it does seem surprising, this approach allows you to control for heteroskedasticiy, which is why the standard errors are quite similar to the ones you would get using `reg, robust`.

The other advantage of this method is that you do not really need to get an estimate of the error itself. Instead, you could obtain the Influence Functions of the estimated parameters, and disturb those to obtain standard errors. This makes method feasible for a larger set of estimators, assuming you can derive the corresponding Influence Functions.

---
### Paired bootstrap/Nonparametric bootstrap

Paired bootstrap is perhaps the most commonly used method, even though it could also be the most computationally intensive approach. 

The basic idea is the same one I started this post with. You use your original samples, and draw subsamples with replacement so they are of the same size as the original sample. Then, as in previous approaches, you estimate the parameters of interest for each subsample, and summarize the results. 

What really differentiates this approach from the others, is that the whole set obs observations and characteristics are used in the resampling (not only residuals). Because of this, it does behave well when there is heteroskedasticity, and is relatively easy to implement even for complex model estimators.

There is the added advantage that Stata has a module exclusively dedicated to make the implementation of paired bootstrap easy. However, before I go into that, lets implement it in mata, as I have done before.

```stata
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
Result:
                  1              2
    +-------------------------------+
  1 |  -294.1955331    61.88438186  |
  2 |   1767.292243    575.3963704  |
  3 |   11905.41528    1374.021799  |
    +-------------------------------+
```

---

### Easier Paired bootstrap

Assuming you do not like to do this with Mata, or that your estimator is a bit more complex than a simple OLS, a better approach for implementing paired bootstrap in `Stata` is simply using the `bootstrap` prefix:

For example:
```stata
bootstrap, seed(10) reps(1000):reg price mpg foreign
```

And of course, this approach can implement bootstrap for any 1 line command:

```stata
bootstrap, seed(10) reps(1000):qreg price mpg foreign
bootstrap, seed(10) reps(1000):poisson price mpg foreign
```

Being faster for some methods than others. 

Often, however, you may want to "bootstrap" something more complex. For example a two/three/...K step estimator. You can still use bootstrap, but it requires a bit more programming. So lets go with a simple 2-step heckman estimator. My recommendation, first implement the estimator for 1 run:

```stata
webuse womenwk
** data prep
gen dwage=wage!=.
** estimation
probit dwage married children educ age
predict mill, score
reg wage educ age mill
** delete the variable that was created as intermediate step
drop mill
```

Notice that `mill` was dropped at the end. This is important, because bootstrap will have to create it all over again.

Finally, we write our little bootstrap program

```stata
** I like to add eclass properties here
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
```

and apply bootsrap:

```stata
. bootstrap, reps(250):two_heckman
(running two_heckman on estimation sample)

warning: two_heckman does not set e(sample), so no observations will be excluded from the resampling
         because of missing values or other reasons. To exclude observations, press Break, save the
         data, drop any observations that are to be excluded, and rerun bootstrap.

Bootstrap replications (250)
----+--- 1 ---+--- 2 ---+--- 3 ---+--- 4 ---+--- 5 
..................................................    50
..................................................   100
..................................................   150
..................................................   200
..................................................   250

Bootstrap results                                        Number of obs = 2,000
                                                         Replications  =   250

------------------------------------------------------------------------------
             |   Observed   Bootstrap                         Normal-based
             | coefficient  std. err.      z    P>|z|     [95% conf. interval]
-------------+----------------------------------------------------------------
   education |   .9825259   .0500337    19.64   0.000     .8844617     1.08059
         age |   .2118695   .0218391     9.70   0.000     .1690657    .2546734
        mill |   4.001615   .5787537     6.91   0.000     2.867279    5.135952
       _cons |   .7340391   1.154367     0.64   0.525    -1.528479    2.996557
------------------------------------------------------------------------------
```

A warning comes up because sample was not defined, but in this case that is not important. That can be "fixed" by adding "esample" to the posting step:

```stata
** I like to add eclass properties here
 program two_heckman2, eclass
** you implement your estimator:
     probit dwage married children educ age
	 tempvar smp
    ** define sample, based on the first step. 
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
end
```

## Conclusions

There you have it. a very quick overview on how bootstrap works, and how to program it in Stata. 

Now, not all methods work in every situation. To fully account for clustering, and weights, resampling methods require you to know, understand, and incorporate the original sampling structure (how the data was collected) to correctly account for those features when estimating standard errors. 

Accounting for clustering is usually straight forward, but Strata and weights may require more attention. I ll try to cover some of those modifications in a future blog.

Hope you find this useful. And if you have comments or questions, send me an email or comment.





