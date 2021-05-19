# DRDID and CSDID for Stata

## DRDID Version 1.35

Hello everyone, this should be a quick note on the forth beta version for `drdid` command for Stata. You probably already saw the post by Miklos, which gives provides instructions to download the package. So, you can either install it through there, or just copy the files I provide here. 

Since I'll be maintaining the package, both sites will have the same information. Except that here I provide a bit more of my flair. (artistic freedom)

Almost two weeks of "Serious-Series-of-Serious" Mata and Stata programming (Yes One punch man), I completed a version of the command that replicates R's `DRDID`. The command produces both panel and repeated crossection estimators proposed in Sant'Anna and Zhao (2020), plus one done using `teffects`: The Inverse Probability Weighting Augmented regression estimator (for panel data). While I have not included this on the helpfile yet (still need to fix some of its features), the command now allows you to use weights (which will be used as pweights), and can also produce the 1-step wild-bootstrap.

For the case of the Wbootstrap, however, the command only produces CI based on normal distribution, and not based on the symetric t-stat as is used in the original `DRDID` package. 

One more aspect the command will integrate, thanks to EP (who wishes to remain anonymous), will be the estimation of the `DRDID` via `gmm`. This approach is not yet implemented, but its being programmed as we speak. This will provide a richer set of options to estimate and standard errors, and may even allow you to use different explanatory variables in the outcome and probability model.

Alright, I hope this guide helps in using this command, at least until is properly released through SSC. Please if you find any bugs or difficulties, do not hesitate to contact me at friosa@gmail.com, or throught twitter!

## Setup

For the replication exercise, I ll use the same dataset used in the example for the drdid command in R. Let's call it lalonde.dta. 

```
use https://friosavila.github.io/playingwithstata/drdid/lalonde.dta, clear
```

Then, you may need to make sure to copy the files [drdid.ado](https://friosavila.github.io/playingwithstata/drdid/drdid.ado) in your personal ado folder. For my pc, it's in `C:\ado\personal`. You could also install the files typing:

```
net install drdid, from ("https://raw.githubusercontent.com/friosavila/csdid_drdid/v0.1/code")
```

## drdid in action

I tried to keep the syntax of drdid relatively standard. At least standard with other commands I have worked before. So some of the options may change slightly, as other features are integrated.

The general syntax of the command is as follows

```{stata}
drdid depvar [indepvar] [if] [in] [iw], [ivar(varname)] time(varname) tr(varname) [estimator] [boot]
```

Here an explanation of all the pieces:

- **`depvar`** : is your dependent variable or outcome of interest
- **`indepvar`**: are your independent variables, you may or may not have variables here. These variables will included in the outcome regression specification and the propensity score estimation.
- **`ivar`**: is a variable that identifies the panel ID. If you drop this, the command will use repeated crossection estimators instead. If included, it will estimate the panel estimators. This option may change to groupvar.
- **`time`**: identifies the time variable (for example year). It does not matter if the periods are contiguous or not. However, its important that you have only 2 values in `time` for the working sample. The earlier period will be used as `pre` , whereas the later period will be used as `post'.
- **`tr`**: is the treatment variable. It does not matter what values you use, as long as there are only two values in the used sample. Observations with lower values are the `control group`, whereas observations with the higher values are the `treated groups`.
- **`estimator`** is used to indicate which estimator you want to use. Below the list of all that is available:
  - **`drimp`** Estimates the DR improved estimator. If you add `rc1` it provides you with the alternative estimator (that is not locally efficient)
  - **`dripw`** Estimates the DR IPW estimator. You can also use `rc1` to provide the alternative (not locally efficient) estimator.
  - **`reg`** Estimates the Outcome regression estimator. 
  - **`stdipw`** Estimates the Standard IPW estimator.
  - **`ipw`** Estimates the estimator similar to Abadies (2005)
  - **`ipwra`** Estimates the IPW regression augmented estimator. This is estimated through `Stata` command `teffects ipwra`. Not available for Repeated Crossection
  - **`all`** Provides all estimators. Perhaps you may find it useful for robustness. (I did it for replication). This results cannot be used to make comparison across estimators. 
- **`boot`**: When used, the command will estimate the 1-step wild-bootstrap (or multiplier bootstrap), with 999 repetions. It currently implements Mammen(1993) approach. 

So, how does this work? Lets start with the lanlonde dataset, and the Panel estimators. For a quick application, I ll use the `all` option:

```
drdid re age educ black married nodegree hisp re74 if treated==0 | sample==2 , ivar(id) time(year) tr( experimental )  all 
```

and if everything went well, you should be seeing this:

```stata
------------------------------------------------------------------------------
             | Coefficient  Std. err.      z    P>|z|     [95% conf. interval]
-------------+----------------------------------------------------------------
       dripw |  -871.3271   396.0332    -2.20   0.028    -1647.538   -95.11643
       drimp |  -901.2703   393.6247    -2.29   0.022     -1672.76   -129.7802
         reg |  -1300.645   349.8365    -3.72   0.000    -1986.312   -614.9776
         ipw |  -1107.872   408.6252    -2.71   0.007    -1908.763   -306.9814
      stdipw |  -1021.609   397.5322    -2.57   0.010    -1800.758   -242.4607
      sipwra |  -908.2912   393.8673    -2.31   0.021    -1680.257   -136.3255
------------------------------------------------------------------------------
Note: This table is provided for comparison across estimations only. You cannot use them to compare across estimates across different estimators
dripw :Doubly Robust IPW
drimp :Doubly Robust Improved estimator
reg   :Outcome regression or Regression augmented estimator
ipw   :Abadie(2005) IPW estimator
stdipw:Standardized IPW estimator
sipwra:IPW and Regression adjustment estimator.

```

For the Repeated Cross section estimator, I will use the simulated dataset provided also in R's `DRDID`.

```
use https://friosavila.github.io/playingwithstata/drdid/sim_rc.dta, clear
```

And let me use the same syntax as before, to obtain all estimates at the same time. Notice that I'm not including the "ivar" indicator. So the command uses the repeated crossection estimators:

```
. drdid y x1 x2 x3 x4, time(post) tr( d)   all 
------------------------------------------------------------------------------
             | Coefficient  Std. err.      z    P>|z|     [95% conf. interval]
-------------+----------------------------------------------------------------
       dripw |  -.1677954   .2008992    -0.84   0.404    -.5615506    .2259597
   dripw_rc1 |  -3.633433   3.107123    -1.17   0.242    -9.723283    2.456416
       drimp |  -.2097772   .1979374    -1.06   0.289    -.5977273    .1781729
   drimp_rc1 |  -3.683518   3.113792    -1.18   0.237    -9.786439    2.419403
         reg |  -8.790978   7.778475    -1.13   0.258    -24.03651    6.454554
         ipw |   -19.8933   53.86822    -0.37   0.712    -125.4731    85.68648
      stdipw |  -15.80331    9.08793    -1.74   0.082    -33.61532    2.008708
------------------------------------------------------------------------------
Note: This table is provided for comparison across estimations only. You cannot use them to compare across estimates across different estimators
dripw :Doubly Robust IPW
drimp :Doubly Robust Improved estimator
reg   :Outcome regression or Regression augmented estimator
ipw   :Abadie(2005) IPW estimator
stdipw:Standardized IPW estimator
sipwra:IPW and Regression adjustment estimator.

```

And that is it!. Please, if you find any bugs or encounter any problems. Let me know. So, what is next?

## CSDID Version 0.1

Yes, `CSDID` is next!. It may take some time. Havent done much progress since the v0.1. But may come back to this soon. There was a small bug so I think we are at version v0.2 now. See below for an example:

With these pieces in places, we can now have a proper first version of R's DID command native to Stata.
By popular demand (3 guys in a chatroom) we are calling it -[csdid.ado](https://friosavila.github.io/playingwithstata/drdid/csdid.ado)-.

As it was already mention on Twitter **`csdid`**, or rather R's **`DID`**  works using **`drdid`** on the background. And as of right now, **`csdid`**  produces what you would get when using att_gt command. 

In contrast with **`DID`**, my command will use **`drimp`** as the default estimator method. However, all other estimators within **`drdid`** will be allowed (except `all`). They key is to declare the method using option **`method()`**. Interestingly enough, **`DID`** uses `dripw` as the default. So I will use that for the following replication.

```
use https://friosavila.github.io/playingwithstata/drdid/mpdta.dta, clear

. csdid  lemp lpop , ivar(countyreal) time(year) gvar(first_treat) method(dripw)
Callaway Sant'Anna (2021)
------------------------------------------------------------------------------
             | Coefficient  Std. err.      z    P>|z|     [95% conf. interval]
-------------+----------------------------------------------------------------
g2004        |
 t_2003_2004 |  -.0145297   .0221629    -0.66   0.512    -.0579681    .0289087
 t_2003_2005 |  -.0764219    .028715    -2.66   0.008    -.1327022   -.0201415
 t_2003_2006 |  -.1404483    .035432    -3.96   0.000    -.2098939   -.0710028
 t_2003_2007 |  -.1069039   .0329366    -3.25   0.001    -.1714584   -.0423494
-------------+----------------------------------------------------------------
g2006        |
 t_2003_2004 |  -.0004721   .0222553    -0.02   0.983    -.0440918    .0431475
 t_2004_2005 |  -.0062025   .0185223    -0.33   0.738    -.0425055    .0301004
 t_2005_2006 |   .0009606    .019428     0.05   0.961    -.0371177    .0390389
 t_2005_2007 |  -.0412939   .0197495    -2.09   0.037    -.0800021   -.0025856
-------------+----------------------------------------------------------------
g2007        |
 t_2003_2004 |   .0267278   .0140817     1.90   0.058    -.0008718    .0543274
 t_2004_2005 |  -.0045766   .0157357    -0.29   0.771    -.0354179    .0262647
 t_2005_2006 |  -.0284475   .0182016    -1.56   0.118    -.0641219    .0072269
 t_2006_2007 |  -.0287814   .0162574    -1.77   0.077    -.0606454    .0030826
------------------------------------------------------------------------------
Control: Never Treated
```
I find this output a bit easier to understand than the baseline output in R. 

Each `equation` represents the group treatment. And each `coefficient` represents the two years (pre and post) used to estimate the ATT. 

All point estimates are the same as the R command. The standard errors are different, because R's `DID` uses bootstrap standard errors by default, whereas I use the asymptotic normal ones as default.

## what is next?

So what is next? 

1. `drdid` is basically done. I do need to include an option for clusters. So that may come next. Also weights. 
2. Along with E.P., we are also working on adding `gmm` estimators to `drdid`. It will just be to provide you with more options for analysis and report.
3. I need to start working on the `csdid` part. The basic structure is ready (see above), but details and other options are still in development. The aggregation is a bit complicated because some features in R are not so easy to replicate with Mata. Not so easy, but not impossible. I'll get there.
4. Once aggregators are done, we will put special emphsis on the visualizations. Im currently thinking this can work as an `estat/postestimation` option. 
5. Clean everything up, more efficient code, proper help file. And if you find bugs...kill the bugs! This is of course the less fun part. But necessary. 
6. If you have comments or questions, please, let me know!

