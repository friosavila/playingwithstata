# CSDID Version 1.5

## Prolog
Yes, `CSDID` v1.5 is here!. And Im very excited about this!. It took some time for me to handle a few things, in particular the "slowness" related to the aggregations. In particular, using nlcom is fast for most cases (few coefficients and few equations), but it quickly gets slow when you have too many coefficients and equations. The reason for that is that it uses numerical derivatives to apply the delta method. The solution: use analytical derivatives!. Sounds easy, and once you figure out how to track indices within a matrix, walk through the park.

In other words, its conditionally easy. The condition, however, was harder to figure out. One more time is one of those steps that help figuring out the rest. And presto, a faster `CSDID` is born.

For for my own notes, and perhaps your understanding, A very quick revision of what `CSDID` and its "friend" `DRDID` do. You can skip the next section, if you are just interested in how `CSDID` works.

## DID design

As it has been explained extensively, the TWFE model is not an appropriate method to identify ATT if the treatment effects are heterogeneous and the timing of the treatment varies across units. 

There are now many papers that explain in detail why this is the case. I do my own version explain this (see on the left), but the bottom line is as follows. When you estimate a model like the following:

$$ y_{it} = a_i + b_t + \theta (trt_i * post_t) + e_{it}$$

The parameter $\theta$ tries to estimate an average difference comparing the same unit across time, (one of the Differences), as well as comparing different units, with and without treatment, in the same point in time. 

To my understanding, the first difference (changes across time), its still a good first approach. In fact, the way Sant'Anna and Zhao (2020) doubly robust estimator (implemented in `DRDID`) operates when using panel data is to estimate the within unit difference first, before using reweighthing methods to estimate the ATT. 

Now, the second difference is problematic. First, one should understand what groups are being comapred:

1. Treated units vs Never treated units: These are good comparisons
2. Treated units vs not yet treated units: These are also good, unless you think there are anticipation problems.
3. Later treated units vs earlier treated units: These are the bad ones. Because you are using as controls, observations that were already treated. 

> Why is the third kind of comparison a bad average? 

Perhaps saying "bad" is harsh. A better word would be a "potentially innapropriate comparison". So when is it a bad one, and when is it not?

#### **Not so bad**

If you believe that the treatment effect is homogenous, and has a one time shock on the outcome (in other words a one time shift upwards on the potential outcomes), then the standard TWFE is approprite. Even comparison 3 is non problematic, and the earlier treated units are good "controls". 

#### **Definately bad**

If you believe the treatment effects is heterogenous, and further more it changes across time, then the third comparison is innappropriate. Why? because we do not know how the **earlier** treated unit got affected.

Why is this important?.

Assume for a second that you have 2 observations, and that the parallel trend assumption hold for all **before** treatment. If one unit gets treated earlier, and the effect changes across time, then after treatment, its new "outcome trend" will NOT be parallel with the second unit. So, by the time the second unit is treated, you cannot compare it with the first (post treatment), because the parallel assumption does no longer holds!.

#### **What about negative weights?!**

Another way that has been discussed regarding the problems with TWFE has been the generation of Negative weights. For a while, this didn't strike me as an intuitive concept, but this problem is closely related to the bad groups comparisons. Let me try to explain, relaxing a bit of the rigourous math.

When you estimate ATT's, at the end of the day you are simply comparing Treated units vs untreated ones:

$$ ATT =\sum \left( w1 * Y(treated,t) - w0 * Y (untreated,t) \right) $$
   
In this simple case, all treated receive a positive weigth, and all untreated units have an effective "negative" weight, because they need to be substracted. 

Now, if you compare earlier treated units and later treated units you have the following:

$$ ATT =\sum \left( w1 * Y(treated,t) - w0 * Y (treated earlier,t) \right) $$

Because the "earlier" treated unit is used as control, it is entering the equation substracting from the later treated one. However, at time t, it has already been treated, so it is receiveing a "negative" weight!, when it should be possitive. And this is the source of the problem. TWFE would put "negative" weights on some treated units, because it uses them as "controls".  

> So what is the solution? 

The solution, as you may suspect, is to simply avoid bad comparisons. And, yes, this is what Callaway and Sant'Anna (2021) does. It estimates all possible "good" comparisons for the estimation of ATT's, and then simply aggregates them to provide a summary of the results. But that is just half of the work. 

The other half of the job is to actually estimate the treatment effects the best way possible, accounting for as much information as reasonable. This, as Pedro would say, is the building block that was proposed on his earlier work in Sant'Anna and Zhao (2020).

#### **So why was the older `CSDID` slow?**

As I mentioned before, `CSDID` works together with `DRDID` to obtain the best estimate for treatment effects. In essence `DRDID` estimates what is call the $ATT(g,t)$, which is simply the Average treatment effect on the treated, for group $g$ (when the group gets treated) measure at time $t$. Setting all the additional refinements of the doubly robust estimators, when $t \geq g$, this is simply estimated as:

$$ ATT(g,t) = \bigg[ EY(g)_t-EY(NT)_t \bigg] - \bigg[ EY(g)_{g-1}-EY(NT)_{g-1} \bigg]$$

Here, **NT** stands for "never treated", which can almost always be used a good control group. $EY(c)_t$ is the expected value of the oucome at time $t$, for group $c$. The first parenthesis calculates the differences in outcomes at time $t$, while the second parenthesis estimate the outcome difference at time $g-1$, which is the period before the treatment took place. 

When $t < g$, the $ATT(g,t)$ are simply defined as:

$$ ATT(g,t) = \bigg[ EY(g)_t-EY(NT)_t \bigg] - \bigg[ EY(g)_{t-1}-EY(NT)_{t-1} \bigg]$$

Which can be used to check if the parallel trends assumptions hold by looking if the period-to-period outcome change. 

Now, you can see that this easily creates a large number of potential $ATT's$ to look at. Some could be interesting, but some would be too small to say anything about them. Here is where the step aggregation comes. 

For any of the aggregations proposed in Callaway and Sant'Anna (2021), the general formula for the aggregations is:

$$ AGGTT = \frac{\sum ( w_{g,t} * ATT(g,t))}{\sum ( w_{g,t})} $$

where $w_{g,t}$ is a weight of how much information was used to estimate $ATT(g,t)$. Larger and more precise estimators should receive more weights, whereas those based on just a handful of observations, should be downeighted. Thus, to obtain standard errors for this parameter, we need to rely on the delta method, differentiating the above expression with respect to each $ATT(g,t)$ and each $w_{g,t}$. Needless to say, it can become a very long expression to track.

In the previous iteraton of `CSDID`, this was done using `nlcom`. `nlcom` uses the delta method to estimate SE for nonlinear combination of parameters. It is usally pretty fast, but when you are trying to evaluate expressions with a large number of parameters, it can turn slow pretty quick. Furthermore, there is a limit in how many equations you can tell nlcom to keep track. A few people contacted me already reporting this problem.

#### **Is there a solution?**

Yes, whenever there is a problem, there is a solution. Afterall, R's `DID` can do it, why can't I (and Stata). So that is what took some time to figure out. I simply needed to correctly track what elements enter a particular aggregation, and then multiply matrices, and summarize the  Variance Covariance Matrix using the good old Sandwich Formula. 

$$ Var(AGGTT) = H' * \Omega * H $$
$$ H = \left[ \begin{matrix} \frac{\partial AGGTT}{\partial ATT(g,t)} \\ \\ \frac{\partial AGGTT}{\partial w_{g,t}}\end{matrix} \right]$$

where $\Omega$ is the variance convariance for all the $ATT(g,t)$ and the $w_{g,t}$.

## Setup 

Alright, the previous section was more of a brief introduction on the magic behind `CSDID` and `DRDID`. But now what you are really here for. The new `CSDID`. 

First, in order to use `CSDID` you will need five sets of files:
- [drdid.ado](https://friosavila.github.io/playingwithstata/drdid/drdid.ado). This is the workhorse of the estimation. Implements the 2x2 DID estimation for any possible pair of treated and untreated groups, as gets the Recentered Influence functions. This is what is used to make Statistical inferences. This implements Sant'Anna and Zhao (2020).
- [csdid.ado](https://friosavila.github.io/playingwithstata/drdid/csdid.ado). This is the main program that implements Callaway and Sant'Anna (2021). It will call on `drdid.ado`, and put all the `attgt's` into a nice table. Itdoes the work that `att_gt` does. It does come with couple of new surprises.
- [csdid_estat.ado](https://friosavila.github.io/playingwithstata/drdid/csdid_estat.ado). This file will be used as a post-estimation program. It does the work that `aggte` and `summarize` does. And it now does it quickly, because it only uses the info left by `csdid`. 
- [csdid_stats.ado](https://friosavila.github.io/playingwithstata/drdid/csdid_stats.ado). This is a new program that joins the `CSDID` family. (It may still recive a name change). This program will do mostly the same that `csdid_estat.ado` does, with a small difference. It will not work on your current dataset, it will work on a new dataset that you can create and store all the Influence functions created in `CSDID`. This is my attempt to simulate R's capacity to "save" entire datsets within objects for later use. 
- [csdid_table.ado](https://friosavila.github.io/playingwithstata/drdid/csdid_table.ado). This program works whenever `wboot` is called. It simply posts the Wildbootstrap confidence intervals. 

In contrast with **`DID`**, my command uses **`drimp`** as the default estimator method. However, all other estimators within **`drdid`** will be allowed (except `all` and `stdipwra`). They key is to declare the method using option **`method()`**. Interestingly enough, **`DID`** uses `dripw` as the default. So I will use that for the following replication.

## Simple Help file

Yes, I promise, at some point a proper helpfile will be created. 

**`csdid`**

The general syntaxis of the command will be as follows:

```
csdid depvar indepvar [if] [in] [iw], ivar(varname) time(year) gvar(group_var) method(drdid estimator) [notyet] [saverif(file) replace cluster(varname) wboot agg(aggregation method)]
```

Here an explanation of all the pieces:

- **`depvar`** : is your dependent variable or outcome of interest
- **`indepvar`**: are your independent variables, you may or may not have variables here. These variables will be included in the outcome regression specification and/or the propensity score estimation. Ideally, this are time constant variables. But time varying variables are allowed. In those cases, **ATT's** are estimated using pre-treatment values.
- **`ivar`**: is a variable that identifies the panel ID. If you drop this, the command will use repeated crossection estimators instead. If included, it will estimate the panel estimators. If you use `ivar', you will need to have a proper panel data setup, with only one observation per ID per period. 
- **`time`**: identifies the time variable (for example year). It does not matter if the periods are contiguous or not. This variable should overlap all possible periods within `gvar'.
- **`gvar`**: is a variable that identifies the first time an observation is treated. It should be within the "time" bracket. Observations with **`gvar==0`** are considered never treated units. 
- **method(`estimator`)** is used to indicate which estimator you want to use. Below the list of all that is available:
  - **`drimp`** Estimates the DR improved estimator. If you add `rc1` it provides you with the alternative estimator (that is not locally efficient). Default
  - **`dripw`** Estimates the DR IPW estimator. You can also use `rc1` to provide the alternative (not locally efficient) estimator.
  - **`reg`** Estimates the Outcome regression estimator. 
  - **`stdipw`** Estimates the Standard IPW estimator.
  - **`ipw`** Estimates the estimator similar to Abadies (2005)

- **`notyet`** request using not yet treated variables as controls, rather than never-treated observations.

New options:

- **`saverif(new file)`**: This option allows you to save all the Recentered Influence functions created by `CSDID` into a new datafile. If you are familar with the `ster` files in Stata, this file will work in a similar way, where important information left by `CSDID` is stored for later use. It requires you to provide a new file name. It can be combined with **`replace`**, if the data-file already exists.
- **`cluster(varname)`**: You can use this to declare a variable to obtained clustered standard errors. If you declare **`ivar`** make sure that **`cluster`** remains constant within panel ID (cluster is nested)
- **`wboot`**: This option requests the estimation of Wild Bootstrap Standard errors. When using this option, Covariances across parameters are not estimated. And Confidence intervals are obtained based on Normal distribution. Future updates will allow you use a "seed" for replication, select CI , and allow alternative Confidence interval methods. 
- **`agg(aggregation method)`**: this is the newest option. You can request `csdid` to directly produce any of the aggregations of interest, rather than report the `attgt's`. This can be combined with `wboot`, and `saverif()`. In all cases, however, I recommend using the `saverif()` option to keep a copy of the RIFs, for later inspection, even if you want to produce any aggregations from the start.

**`csdid_estat`**

This program works on the background to obtain all aggregations. This command will always estimate SE for aggregations using the analytical VCOV matrices, even if you request Wbootstrap estimations in `csdid`. If you want the Wbootstrap estimates, you can use **`csdid_stats`**, or use the **`agg()`** after **`csdid`**.

```
estat [subcommand], [estore(name) esave(name) replace *]
```

And this are the options:

- **`pretrend`**: This tests if all the pre-treatment effects are all equal to 0.
- **`simple`**: Estimates the simple aggregation of all post treatment effects.
- **`group`**: Estimates the group average treatment effects
- **`calendar`**: Estimates the calendar time average treatment effects 
- **`event`**: Estimates the dynamic aggregation/event study effects. If you use `event`, it is also possible to combine it with :
  -  `, window(#1 #2)`: With this option, you can request to produce only a subset of all the posible dynamic effects.
- **`estore(name)`**: It allows you to save output table as an estimation equation. 
- **`esave(name)`**: It allows you to save output table as an `ster` file. It can be combined with `replace`.
- **`all`**: This produces all statistics. 

All comands after estat, with the exception of `pretrend`, leave an `r(table)` element, as well as `r(b)` and `r(V)` matrices. 
  
**`csdid_stats`**

This is the newest command on this package. The purpose of this command is to work like `csdid_estat`, but when you are using a file previosly saved using the option `saverif()`. It works pretty much the same as `csdid_estat`, except that you can request analytical standard errors, as well as WildBootstrap standard errors.  Compared to `csdid_estat`, this may be slower because it reproduces all Standard errors directly from the RIFs.

```
csdid_stats [subcommand], [estore(name) esave(name) replace]
```

And this are the options:

- **`pretrend`**: This tests if all the pre-treatment effects are all equal to 0.
- **`simple`**: Estimates the simple aggregation of all post treatment effects.
- **`group`**: Estimates the group average treatment effects
- **`calendar`**: Estimates the calendar time average treatment effects 
- **`event`**: Estimates the dynamic aggregation/event study effects. If you use `event`, it is also possible to combine it with :
  **`estore(name)`**: It allows you to save output table as an estimation equation. 
- **`esave(name)`**: It allows you to save output table as an `ster` file. It can be combined with `replace`.
- **`wboot`**: Request the Wbootstrap Standard errors.

All comands, with the exception of `pretrend`, leave an `r(table)` element, as well as `r(b)` and `r(V)` matrices. 
 

## Replication

So lets see how this works.  First, load the data, and estimate the model. To replicate the `DID` simple output, I will use `method(dripw)`.
```
use https://friosavila.github.io/playingwithstata/drdid/mpdta.dta, clear

. csdid  lemp lpop , ivar(countyreal) time(year) gvar(first_treat) method(dripw)


............
Difference-in-difference with Multiple Time Periods
Outcome model  : least squares
Treatment model: inverse probability
------------------------------------------------------------------------------
             | Coefficient  Std. err.      z    P>|z|     [95% conf. interval]
-------------+----------------------------------------------------------------
g2004        |
 t_2003_2004 |  -.0145297   .0221292    -0.66   0.511     -.057902    .0288427
 t_2003_2005 |  -.0764219   .0286713    -2.67   0.008    -.1326166   -.0202271
 t_2003_2006 |  -.1404483   .0353782    -3.97   0.000    -.2097882   -.0711084
 t_2003_2007 |  -.1069039   .0328865    -3.25   0.001    -.1713602   -.0424476
-------------+----------------------------------------------------------------
g2006        |
 t_2003_2004 |  -.0004721   .0222234    -0.02   0.983    -.0440293     .043085
 t_2004_2005 |  -.0062025   .0184957    -0.34   0.737    -.0424534    .0300484
 t_2005_2006 |   .0009606   .0194002     0.05   0.961    -.0370631    .0389843
 t_2005_2007 |  -.0412939   .0197211    -2.09   0.036    -.0799466   -.0026411
-------------+----------------------------------------------------------------
g2007        |
 t_2003_2004 |   .0267278   .0140657     1.90   0.057    -.0008404     .054296
 t_2004_2005 |  -.0045766   .0157178    -0.29   0.771    -.0353828    .0262297
 t_2005_2006 |  -.0284475   .0181809    -1.56   0.118    -.0640814    .0071864
 t_2006_2007 |  -.0287814    .016239    -1.77   0.076    -.0606091    .0030464
------------------------------------------------------------------------------
Control: Never Treated

See Callaway and Sant'Anna (2021) for details

```

I find this output a bit easier to understand than the baseline output in R. Each `equation` represents the group treatment. And each `coefficient` represents the two years (pre and post) used to estimate the ATT. 

All point estimates are the same as the R command. The standard errors are different, because R's `DID` uses Wbootstrap standard errors by default, whereas I use the asymptotic normal ones as default. You can replicate this in R using the `bstrap = F` option. In the previous version, you also saw the "weights" equations. They are still produced, but are no longer shown.

So what about the aggregation. The first thing would be the pretrend test for parallel assumption. The output is subject to change.


```
. estat pretrend
Pretrend Test. H0 All Pre-treatment are equal to 0
chi2(5) = 6.841824981670454
p-value       = .2326722805724242
```

We can also reproduce the simple, calendar and group aggregations:

```

. estat simple 
Average Treatment Effect on Treated
------------------------------------------------------------------------------
             | Coefficient  Std. err.      z    P>|z|     [95% conf. interval]
-------------+----------------------------------------------------------------
         ATT |  -.0417518   .0115028    -3.63   0.000    -.0642969   -.0192066
------------------------------------------------------------------------------

. estat calendar
ATT by Calendar Period
------------------------------------------------------------------------------
             | Coefficient  Std. err.      z    P>|z|     [95% conf. interval]
-------------+----------------------------------------------------------------
       T2004 |  -.0145297   .0221292    -0.66   0.511     -.057902    .0288427
       T2005 |  -.0764219   .0286713    -2.67   0.008    -.1326166   -.0202271
       T2006 |  -.0461757   .0212107    -2.18   0.029     -.087748   -.0046035
       T2007 |  -.0395822   .0129299    -3.06   0.002    -.0649242   -.0142401
------------------------------------------------------------------------------

. estat group
ATT by group
------------------------------------------------------------------------------
             | Coefficient  Std. err.      z    P>|z|     [95% conf. interval]
-------------+----------------------------------------------------------------
       G2004 |  -.0845759   .0245649    -3.44   0.001    -.1327222   -.0364297
       G2006 |  -.0201666   .0174696    -1.15   0.248    -.0544065    .0140732
       G2007 |  -.0287814    .016239    -1.77   0.076    -.0606091    .0030464
------------------------------------------------------------------------------

```

And the one that was the most difficult to program, but is the most interesting. The event study/dynamic effects:

```
. estat event
ATT by Periods Before and After treatment
Event Study:Dynamic effects
------------------------------------------------------------------------------
             | Coefficient  Std. err.      z    P>|z|     [95% conf. interval]
-------------+----------------------------------------------------------------
         T-3 |   .0267278   .0140657     1.90   0.057    -.0008404     .054296
         T-2 |  -.0036165   .0129283    -0.28   0.780    -.0289555    .0217226
         T-1 |   -.023244   .0144851    -1.60   0.109    -.0516343    .0051463
           T |  -.0210604   .0114942    -1.83   0.067    -.0435886    .0014679
         T+1 |  -.0530032   .0163465    -3.24   0.001    -.0850417   -.0209647
         T+2 |  -.1404483   .0353782    -3.97   0.000    -.2097882   -.0711084
         T+3 |  -.1069039   .0328865    -3.25   0.001    -.1713602   -.0424476
------------------------------------------------------------------------------
```

What If i wanted to get the event aggregation to begin with? 
I can do this, from the csdid command line. I can also store the RIF's in a new file. and request Wild Bootstrap Standard errors.

```
 csdid  lemp lpop , ivar(countyreal) time(year) gvar(first_treat) method(dripw) agg(event) saverif(rif_example) wboot replace 
File rif_example.dta will be replaced
............
file rif_example.dta saved

Difference-in-difference with Multiple Time Periods
Outcome model  : least squares
Treatment model: inverse probability
------------------------------------------------------------------------------
             |                WBoot
             | Coefficient  std. err.      z    P>|z|     [95% conf. interval]
-------------+----------------------------------------------------------------
         T-3 |   .0267278    .014263     1.87   0.061    -.0012272    .0546828
         T-2 |  -.0036165   .0135835    -0.27   0.790    -.0302397    .0230067
         T-1 |   -.023244   .0140833    -1.65   0.099    -.0508467    .0043587
           T |  -.0210604   .0107957    -1.95   0.051    -.0422196    .0000989
         T+1 |  -.0530032   .0166204    -3.19   0.001    -.0855786   -.0204279
         T+2 |  -.1404483   .0349942    -4.01   0.000    -.2090357   -.0718609
         T+3 |  -.1069039   .0316514    -3.38   0.001    -.1689394   -.0448684
------------------------------------------------------------------------------
Control: Never Treated

See Callaway and Sant'Anna (2021) for details

```

Now, I dont want to re-estimate this model again, but I'm interested in other aggregations, and able to save the RIF's from before. What I can do now is obtain the Wildbootstrap estimates. 

```
.  csdid_stats simple , wboot
------------------------------------------------------------------------------
             | Coefficient  Std. err.      z    P>|z|     [95% conf. interval]
-------------+----------------------------------------------------------------
         ATT |  -.0417518   .0112599    -3.71   0.000    -.0638208   -.0196827
------------------------------------------------------------------------------

. csdid_stats calendar, wboot 
------------------------------------------------------------------------------
             | Coefficient  Std. err.      z    P>|z|     [95% conf. interval]
-------------+----------------------------------------------------------------
       T2004 |  -.0145297   .0234217    -0.62   0.535    -.0604354    .0313761
       T2005 |  -.0764219   .0278336    -2.75   0.006    -.1309747   -.0218691
       T2006 |  -.0461757   .0217366    -2.12   0.034    -.0887787   -.0035727
       T2007 |  -.0395822   .0129156    -3.06   0.002    -.0648962   -.0142681
------------------------------------------------------------------------------

. csdid_stats group , wboot
------------------------------------------------------------------------------
             | Coefficient  Std. err.      z    P>|z|     [95% conf. interval]
-------------+----------------------------------------------------------------
       G2004 |  -.0845759   .0235067    -3.60   0.000    -.1306482   -.0385037
       G2006 |  -.0201666   .0176825    -1.14   0.254    -.0548238    .0144905
       G2007 |  -.0287814   .0169083    -1.70   0.089    -.0619211    .0043584
------------------------------------------------------------------------------

. csdid_stats event , wboot
------------------------------------------------------------------------------
             | Coefficient  Std. err.      z    P>|z|     [95% conf. interval]
-------------+----------------------------------------------------------------
         T-3 |   .0267278   .0142834     1.87   0.061    -.0012671    .0547227
         T-2 |  -.0036165   .0140355    -0.26   0.797    -.0311256    .0238927
         T-1 |   -.023244    .014844    -1.57   0.117    -.0523378    .0058498
           T |  -.0210604   .0116786    -1.80   0.071      -.04395    .0018293
         T+1 |  -.0530032   .0173973    -3.05   0.002    -.0871012   -.0189052
         T+2 |  -.1404483   .0365071    -3.85   0.000     -.212001   -.0688957
         T+3 |  -.1069039    .034774    -3.07   0.002    -.1750597   -.0387481
------------------------------------------------------------------------------

```

And done! Much faster, and hopefully No bugs! 
Please, let me know if you have any questions!

## What is next?

1. Some stress testing. I have done a few for now, But as questions arrive, more fixes will be possible. The command has been tested for crossection and for unbalance panel. In contrast with `DID`, this version will use all 2x2 balance data, even if some are not observed for all periods. 
2. Some verification. Many data verifications have been added. But some checks may be missing. For instance, right now the command doesnt check if your weights are fixed for panel ID (which should be). 
3. Help files. And of course...Graphs! Right now, you can get very crude graphs with coefplot, or with -event_plot-. But I ll make sure our Graphic's Guru gets his hands on this.
   

   
   
