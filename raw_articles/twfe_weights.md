# TWFE DID - Negative Weights. 
## Where do they come from? and How can I see them?

I imagine that if you are reading this post, you may be interested in DID, and are trying to understand, or visualize, some of the problems related with the so-colled TWFE-DID estimator. 

Chances are that by the time you read this post, the standard TWFE-DID estimator may be a thing of the past, and that the literature as a whole has moved to any of the other estimators that came up between 2019 - 2021. For this reason it may be important to clarify what do I mean with TWFE-DID estimator.

### What is TWFE? 

TWFE is an acronym that stands for **T**wo **W**ay **F**ixed **E**ffect estimator.  It usually refers to a linear regression model (although it can be applied to nonlinear cases) where one attempts to control for effects or unobserved factors that we believe are constant across two dimensions.

Typically, this two dimensions are time (everybody should experience the shocks across time), and individual or cohort (similar groups should share similar unobserved effects).


## Setup


$$ ATT = E( y(1) - y(0)|D=1) $$
$$ ATT = E( y | D=1, T=post) -  E( y | D=1, T=pre) - E(\gamma|D=1)  $$

```{r}
use http://pped.org/bacon_example.dta, clear
** Identify ever treated units
sort  stfips year
by stfips: egen ever_treated=max(post)
** Identify Cohort of treatment (when was an observation treated)
by stfips: egen aux = min(year) if post ==1
by stfips: egen gvar = max(aux) 
replace gvar = 0 if gvar==.
** Identify Pre and Post Treatment: For treated Observations only.
gen pre_post=post if ever_treated==1 &
```

We can now get the weights. Because its a balance dataset, weights are easy to get:

```
sum post , meanonly
gen mean_post=r(mean)

bysort stfips: egen post_i=mean(post)
bysort year  : egen post_t=mean(post)

gen p_tilde=post-post_i-post_t+mean_post if ever_treated==1

** We may want to drop units that were always treated

drop if gvar==1964
```

Non-treated units can have both possitive and negative weights. Treated Units, however should have positive weights AFTER treatment, and Negative BEFORE treatment.

```
two (scatter p_tilde year if gvar==1969  & pre_post ==1, connect(l) ) ///
    (scatter p_tilde year if gvar==1970  & pre_post ==1, connect(l) ) ///
	(scatter p_tilde year if gvar==1971  & pre_post ==1, connect(l) ) ///
	(scatter p_tilde year if gvar==1972  & pre_post ==1, connect(l) ) , ///
	legen(order(1 "Gvar=1969" 2 "Gvar=1970" 3 "Gvar=1971" 4 "Gvar=1972")) ///
	yline(0)
	
two	(scatter p_tilde year if gvar==1977  & pre_post ==0, connect(l) ) ///
    (scatter p_tilde year if gvar==1980  & pre_post ==0, connect(l) ) ///
	(scatter p_tilde year if gvar==1984  & pre_post ==0, connect(l) ) ///
	(scatter p_tilde year if gvar==1985  & pre_post ==0, connect(l) ) , ///
	legen(order(1 "Gvar=1977" 2 "Gvar=1980" 3 "Gvar=1984" 4 "Gvar=1985")) ///
	yline(0)
```

We usually have no problems with Pre-treatment weights having the incorrect sign, because we expect that there is no treatment effect to begin with.

However, all of the attention has been focused on the negative weights that Post-treatment units may receive. But Who are getting those?

## Consequences

Simulate some data:

```
gen te=runiform()
by stfips:replace te=te[1]
gen y = 0 
replace y = te if pre_post ==1 & p_tilde<0

*replace y = te if pre_post ==0 & p_tilde>0
```

Even though Effect is possitive. (because of delayed effect), the TWFE ATT is negative.

