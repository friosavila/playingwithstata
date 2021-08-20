# Two-Way FE: The come back to DID
If you have been following all the literature on DID over the last few months (this has been vast), you may be aware that there has been a lot of discussion regarding what the TWFE could or could not recover in the framework of DID models. 

The bottom: When using the standard 2x2 DID design, the ATT could be recovered by simply running a regression similar to the following:

$$ y = a_0 + a_1 * post + a_2 * treated + a_3 * post * treated + e$$

Where the coefficient $a_3$ captures the ATT. Adding covariates to this framework is not straightforward. I will leave it for now.

The problem comes when we move away from the classic design, and start adding more periods and more groups to the data.

One generalization that was introduced in this setup has been the Two-Way Fixed effect approach. Namely, adding dummies for each period (instead of just a pre/post dummy) and dummies for each individual, rather than a treated not-treated group.

Finally, instead of an interaction, we include a dummy that takes the value of 1 if individual $i$ is already treated at time $t$. This suggests estimating a model like the following:

$$ y_{it} = a_0 + a_i + a_t + a_3 * tr_{it} + e_{it}$$

The problem with this regression, which is discussed in every DID paper that came out (2020-2021) is that the identification of $a_3$ averages over every 2x2 design where a "treated" group changes its treatment status, compared to a "control" group. 

There would be no problem if the "control" groups were formed of individuals who were never treated (or not treated during the period of reference). However, the TWFE design also uses cases such that already treated individuals are used as controls. 

Only if these treatment effects were constant, would the TWFE identify the ATT. Otherwise, the estimated ATT would be biased, because some of the individual treatment effects are substracting (negative weights) rather than adding to the estimation of average treatment effects. If you are interested in reading more about this, I believe Goodman-Bacon (2021) is the best place to read about these caveats of TWFE.

## Solutions

As the running joke goes, Econometricians took away our toys. But some of them are nice, and they brought you some other toys back. 

### **Callaway and Sant'Anna (2020)**

There are currently many strategies that have been suggested for the estimation of ATT that do not suffer from the shortcomings of TWFE. The one I have found most intuitive, and that have spend quite some time implementing it, is the methodology proposed by Callaway and Sant'Anna (2020). 

In principle, what CS2020 does is to estimate (the best way possible) all "good" 2x2 DID designs in your data. The procedure can be time-consuming, because the number 2x2 designs increases with the number of cohorts, and periods in your data. If you have, say 5 cohorts (differential timing) and 10 periods of data, 50 different ATT's would be estimated. And behind each one of these, up to 5 separate regressions need to be estimated. 

Once all individual ATT's are obtained, they can be averaged to obtain summary measures either by cohort/group, calendar year, event type studies, etc. In my own view, this is a very flexible approach, but the flexibility comes at a cost of not being the most efficient estimator in certain circumstances. (Pedro has one paper where they explore this further)

### **Imputation Approach**

A second type of solution, which has been tackled by different researchers independently, has been using an imputation-type approach. The notable papers on this are Borusyak et al (2020) and Gardner (2021) and  This methodology basically bypasses the forbidden control group problem by separating the estimation into steps. 

- The first step uses not-yet treated observations to identify potential outcomes assuming no treatment effect took place. 

   $y_{it}=a_i + a_t + e_{it}$ if not yet treated

- The second step gets Individual level treatments (difference between observed under treatment outcome and predicted (no treated) outcome).

    $y_{it}-\hat{a}_i - \hat{a}_t = att_{it}$ if treated

The second step also requires some aggregation, which could be done simply taking averages of all $att_{it}$ over some group of interest.

Because this is a two step approach, Gardner(2021) proposes estimating this model using a GMM approach, whereas Borusyak et al (2020) uses a different approach to get correct SE (which I must admit cannot yet understand).

### **TWFE: the second comming:** You don't mess up with OLS

While traditional TWFE has received a lot of "but's" because its inability of correctly identifying ATT's, the methodology has been defended by Prof Wooldridge. His message is quite simple, but powerful. 

Yes, TWFE as its traditionally applied, has many limitations regardin the estimation of ATTs. However, if properly implemented, you can still applied it and have efficient estimation of Treatment effects similar to those proposed by Borusyak et al (2020) and Gardner (2021). 

So what were we missing? Heterogeneity!. Granted, I believe Sun and Abraham (2020) have a very similar approach, albeit a bit hidden behind the math. What Prof Wooldridge proposess is, in my view, very similar to the twostep imputation approach I proviously described (at least for the simple case of no controls)

The main difference is that he suggests estimating **both** steps in a single line!. Specifically, the the idea is estimating the following model:

$$y_{it}=a_i + a_t + \sum_{g=g_0}^{G} \sum_{t=g}^{T} 
\lambda_{g,t} \times 1(g,t) +e_{it}$$

What Wooldridge suggests, at least for the case without covariates, is estimate a model where, in addition to the individual and time fixed effects, we saturate **all** possible combinations of Cohorts and times, **IF** that combination corresponds to an effectively treated unit.

The idea is that by saturating the model, the estimated $\lambda's$ are the equivalent to CS2020 $attgt$. These are already equivalent of the  aggregations described in Borusyak et al (2020), for all observations that belong to a particular cohort at a point in time. 

In other words, What I want to get from this is not that TWFE was incorrect, but rather that we were not applying it correctly!.

## Implementation

You may already be familiar with the set of files Prof Wooldridge shared, with the Twitter Community. After reading his paper, and the dofiles, I put together a small script that implements his approach, again no covariates yet, and provides suggestions of how to obtain aggregations similar to the ones provided by Callaway and Sant'Anna (2020). 

So, you will need the following two files:

- [jwdid.ado](https://friosavila.github.io/playingwithstata/jwdid/jwdid.ado)       This file applies the twowayFE method. It is not yet the Mundlack approach he adovocates on his paper.
- [jwdid_estat.ado](https://friosavila.github.io/playingwithstata/jwdid/jwdid_estat.ado) A set of utilities to get the Standard Aggregations.

And for the example, lets use the one for CSDID.

```stata
use https://friosavila.github.io/playingwithstata/drdid/mpdta.dta, clear

jwdid  lemp , i(countyreal) t(year) gvar(first_treat)
```

As you can see, the syntax is very similar to csdid. You need to add an Individual fixed effect, a year fixed effect and the cohort variable `gvar`. This version Only accepts the outcome variable.

In the background, it uses Sergio Correira `reghdfe`. So you may recognize the output:

```stata
 WARNING: Singleton observations not dropped; statistical significance is biased (link)
(MWFE estimator converged in 2 iterations)

HDFE Linear regression                            Number of obs   =      2,500
Absorbing 2 HDFE groups                           F(   7,    499) =       3.82
Statistics robust to heteroskedasticity           Prob > F        =     0.0005
                                                  R-squared       =     0.9933
                                                  Adj R-squared   =     0.9915
                                                  Within R-sq.    =     0.0101
Number of clusters (countyreal) =        500      Root MSE        =     0.1389

                                        (Std. err. adjusted for 500 clusters in countyreal)
-------------------------------------------------------------------------------------------
                          |               Robust
                     lemp | Coefficient  std. err.      t    P>|t|     [95% conf. interval]
--------------------------+----------------------------------------------------------------
first_treat#year#c.__tr__ |
               2004 2004  |  -.0193724   .0223818    -0.87   0.387    -.0633465    .0246018
               2004 2005  |  -.0783191   .0304878    -2.57   0.010    -.1382195   -.0184187
               2004 2006  |  -.1360781   .0354555    -3.84   0.000    -.2057386   -.0664177
               2004 2007  |  -.1047075   .0338743    -3.09   0.002    -.1712613   -.0381536
               2006 2006  |   .0025139   .0199328     0.13   0.900    -.0366487    .0416765
               2006 2007  |  -.0391927   .0240087    -1.63   0.103    -.0863634     .007978
               2007 2007  |   -.043106   .0184311    -2.34   0.020    -.0793182   -.0068938
                          |
                    _cons |    5.77807    .001544  3742.17   0.000     5.775036    5.781103
-------------------------------------------------------------------------------------------

Absorbed degrees of freedom:
-----------------------------------------------------+
 Absorbed FE | Categories  - Redundant  = Num. Coefs |
-------------+---------------------------------------|
  countyreal |       500         500           0    *|
        year |         5           0           5     |
-----------------------------------------------------+
* = FE nested within cluster; treated as redundant for DoF computation

```

Each one of the coefficients correspond to a Treatment effect for group G at time T. In contrast with CSDID, it won't produce the ATTGTS for units Before the treatment.

So, you may want to say, I want to get some aggregation, like Simple, Calendar and group, or Event. Those are easy to produce, and are preprogrammed withing `estat`.

In the background, it simply calls on `margins`, and estimates the different aggregations over specific groups:

```
. estat simple

Average marginal effects                                   Number of obs = 291
Model VCE: Robust

Expression: Linear prediction, predict()
dy/dx wrt:  __tr__

------------------------------------------------------------------------------
             |            Delta-method
             |      dy/dx   std. err.      z    P>|z|     [95% conf. interval]
-------------+----------------------------------------------------------------
      __tr__ |  -.0477099    .013265    -3.60   0.000    -.0737088   -.0217111
------------------------------------------------------------------------------

. estat calendar
note: 2209 observations omitted because of missing values in over() variable.

Average marginal effects                               Number of obs   = 2,500
Model VCE: Robust                                      Subpop. no. obs =   291

Expression: Linear prediction, predict()
dy/dx wrt:  __tr__
Over:       __calendar__

------------------------------------------------------------------------------
             |            Delta-method
             |      dy/dx   std. err.      z    P>|z|     [95% conf. interval]
-------------+----------------------------------------------------------------
__tr__       |
__calendar__ |
       2004  |  -.0193724   .0223818    -0.87   0.387    -.0632398    .0244951
       2005  |  -.0783191   .0304878    -2.57   0.010    -.1380742    -.018564
       2006  |  -.0436835   .0188309    -2.32   0.020    -.0805914   -.0067755
       2007  |  -.0487369   .0157447    -3.10   0.002     -.079596   -.0178778
------------------------------------------------------------------------------

. estat group
note: 2209 observations omitted because of missing values in over() variable.

Average marginal effects                               Number of obs   = 2,500
Model VCE: Robust                                      Subpop. no. obs =   291

Expression: Linear prediction, predict()
dy/dx wrt:  __tr__
Over:       __group__

------------------------------------------------------------------------------
             |            Delta-method
             |      dy/dx   std. err.      z    P>|z|     [95% conf. interval]
-------------+----------------------------------------------------------------
__tr__       |
   __group__ |
       2004  |  -.0846193   .0256989    -3.29   0.001    -.1349882   -.0342503
       2006  |  -.0183394    .020082    -0.91   0.361    -.0576993    .0210205
       2007  |   -.043106   .0184311    -2.34   0.019    -.0792304   -.0069816
------------------------------------------------------------------------------

. estat event
note: 2209 observations omitted because of missing values in over() variable.

Average marginal effects                               Number of obs   = 2,500
Model VCE: Robust                                      Subpop. no. obs =   291

Expression: Linear prediction, predict()
dy/dx wrt:  __tr__
Over:       __event__

------------------------------------------------------------------------------
             |            Delta-method
             |      dy/dx   std. err.      z    P>|z|     [95% conf. interval]
-------------+----------------------------------------------------------------
__tr__       |
   __event__ |
          0  |  -.0310669   .0136209    -2.28   0.023    -.0577633   -.0043705
          1  |  -.0522349   .0188729    -2.77   0.006     -.089225   -.0152448
          2  |  -.1360781   .0354555    -3.84   0.000    -.2055696   -.0665866
          3  |  -.1047075   .0338743    -3.09   0.002    -.1710999   -.0383151
------------------------------------------------------------------------------

```

Next edition on this? figure out an easy approach to adding covariates, and other aggregations. As well as producing the "pretrend" estimates.

## Conclusion

So we have a new Toy in town. It is similar to the imputation approaches, it is easy to apply, and has been show to be more efficient than Callaway and Sant'Anna (2020). 

Given its nature, It may be a good approach for the estimation of DID models. I believe, however, that just like previous imputation approaches, it will provide reasonble estimations of DID as long as the outcome model is correctly specified. However, as Sant'Anna and Zhao (2020) discuss, if the outcome model is highly nonlinear, it may fail to provide an unbiased estimate of the ATT. In practical terms, however, chances are that both methodologies would provide similar results. 

For instance, if you recall my "union wage premium" excercise, Imputation methods didnt fair too well, finding premiums where none should exist. 