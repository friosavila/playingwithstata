# Two-Way FE: The come back to DID

If you have been following all the literature on DID over the last year. Of course you have, that is why you are reading this, and why I wrote it. 

So first, when using the standard 2x2 DID design, the ATT could be recovered by simply running a regression similar to the following:

$$ y = a_0 + a_1 * post + a_2 * treated + a_3 * post * treated + e$$

Where the coefficient $a_3$ captures the ATT. Adding covariates to this framework is not straightforward. Based on Sant'Anna and Zhao (2020), one way to add covariates using fully interacted covariates. If you go back to SZ2020, check, for example, the outcome regressionapproach, for repeated crossection.

The problem comes when we move away from the classic design, and start adding more periods and more groups to the data.

One generalization that was introduced in this setup has been the Two-Way Fixed effect approach. Namely, adding dummies for each period (instead of just a pre/post dummy) and dummies for each individual, rather than a treated/not-treated group.

Finally, instead of an interaction, we include a dummy that takes the value of 1 if individual $i$ is already treated at time $t$. This suggests estimating a model like the following:

$$ y_{it} = a_0 + a_i + a_t + a_3 * tr_{it} + e_{it}$$

The problem with this regression, which is discussed in every DID paper that came out (2020-2021) is that the identification of $a_3$ averages over every 2x2 design where a "treated" group changes its treatment status, compared to a "control" group. 

There would be no problem if the "control" groups were formed of individuals who were never treated (or not treated during the period of reference). However, the TWFE design also uses cases such that already treated individuals are used as controls. 

Only if these treatment effects were constant, would the TWFE identify the ATT. Otherwise, the estimated ATT would be biased, because some of the individual treatment effects are substracting (negative weights) rather than adding to the estimation of average treatment effects. If you are interested in reading more about this, Goodman-Bacon (2021) is the best place to read about these caveats of TWFE.

## Solutions

As the running joke goes, Econometricians took away our toys. But some of them are nice, and they bring you some others back. 

### **Callaway and Sant'Anna (2021)**

There are currently many strategies that have been suggested for the estimation of ATT that do not suffer from the shortcomings of TWFE. The one I have found most intuitive, and that have spend quite some time implementing it, is the methodology proposed by Callaway and Sant'Anna (2021). 

In principle, what CS2021 does is to estimate (the best way possible) all "good" 2x2 DID designs in your data. The procedure can be time-consuming, because the number 2x2 designs increases with the number of cohorts, and periods in your data. If you have, say 5 cohorts (differential timing) and 10 periods of data, 50 different ATT's would be estimated. And behind each one of these, up to 5 separate regressions need to be estimated. 

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

Yes, TWFE as traditionally applied, has many limitations regarding the estimation of ATTs. However, if properly implemented, you can still applied it and have efficient estimation of Treatment effects similar to those proposed by Borusyak et al (2020) and Gardner (2021). 

So what were we missing? Heterogeneity!. Granted, I believe Sun and Abraham (2020) have a very similar approach, albeit a bit hidden behind the math. And with a different perspective. Specifically, they say, when analyzing event studies, you may get contaminated coefficients. Something similar to the arguments using TWFE. Their solution, estimate the dynamic effects separetely for each cohort. 

Interstingly, what Prof Wooldridge proposess is very similar to SA. But, rather than interacting dynamic effects with cohorts, he proposes interacting cohort effects with time specific effects. This is also similar to the twostep imputation approach I proviously described (at least for the simple case of no controls). Specifically, the the idea is estimating one of the two following model:

$$y_{it}=a_i + a_t + \sum_{g=g_0}^{G} \sum_{t=g}^{T} 
\lambda_{g,t} \times 1(g,t) +e_{it}$$

$$y_{it}=a_i + a_t + \sum_{g=g_0}^{G} \sum_{t\ge g}^{T} 
\lambda_{g,t} \times 1(g,t) +e_{it}$$

What Wooldridge suggests, at least for the case without covariates, is to estimate a model where, in addition to the individual (or cohort) and time fixed effects, we saturate **all** possible combinations of Cohorts and times, **IF** that combination corresponds to an effectively treated unit. Now, this gives you two options (in the equations above). The first one is to use **never-treated** as controls, whereas the second approach uses the **not-yet-treated** as controls.

The idea is that by saturating the model, the estimated $\lambda's$ are the equivalent to CS2020 $attgt$. These are already equivalent of the aggregations described in Borusyak et al (2020), for all observations that belong to a particular cohort at a point in time. 

In other words, What I want to get from this is not that TWFE was incorrect, but rather that we were not applying it correctly!.

Now, once you have the $attgt's$ or here $\lambda_{g,t}$, one can aggregate them as needed to obtain dynamic effects, average effects, etc, etc.

## Implementation

You may already be familiar with the set of files Prof Wooldridge shared with the Twitter Community. if not, you can access it [here](https://www.dropbox.com/sh/zj91darudf2fica/AADj_jaf5ZuS1muobgsnxS6Za?dl=0). After reading his paper, a few times, and reviewing the dofiles, I put together a small script that implements his approach. This time **with covarites!**. I also provide suggestions of how to obtain aggregations similar to the ones provided by Callaway and Sant'Anna (2021). I'm also including a small surprise, adding an option to implement nonliear Staggered DID!

So, you will need the following two files:

- [jwdid.ado](https://friosavila.github.io/playingwithstata/jwdid/jwdid.ado) This file applies the twowayFE method. With not yet and never treated options
- [jwdid_estat.ado](https://friosavila.github.io/playingwithstata/jwdid/jwdid_estat.ado) A set of utilities to get the Standard Aggregations.

And for the example, lets use the one for CSDID.

```stata
use https://friosavila.github.io/playingwithstata/drdid/mpdta.dta, clear

jwdid  lemp , ivar(countyreal) tvar(year) gvar(first_treat)
```

As you can see, the syntax is very similar to csdid. You need to add an Individual fixed effect, a year fixed effect and the cohort variable `gvar`. 

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
-----------------------------------------------------------------------------------------
                        |               Robust
                   lemp | Coefficient  std. err.      t    P>|t|     [95% conf. interval]
------------------------+----------------------------------------------------------------
__tr__#first_treat#year |
             2004 2004  |  -.0193724   .0223818    -0.87   0.387    -.0633465    .0246018
             2004 2005  |  -.0783191   .0304878    -2.57   0.010    -.1382195   -.0184187
             2004 2006  |  -.1360781   .0354555    -3.84   0.000    -.2057386   -.0664177
             2004 2007  |  -.1047075   .0338743    -3.09   0.002    -.1712613   -.0381536
             2006 2006  |   .0025139   .0199328     0.13   0.900    -.0366487    .0416765
             2006 2007  |  -.0391927   .0240087    -1.63   0.103    -.0863634     .007978
             2007 2007  |   -.043106   .0184311    -2.34   0.020    -.0793182   -.0068938
                        |
                  _cons |    5.77807    .001544  3742.17   0.000     5.775036    5.781103
-----------------------------------------------------------------------------------------

Absorbed degrees of freedom:
-----------------------------------------------------+
 Absorbed FE | Categories  - Redundant  = Num. Coefs |
-------------+---------------------------------------|
  countyreal |       500         500           0    *|
        year |         5           0           5     |
-----------------------------------------------------+
* = FE nested within cluster; treated as redundant for DoF computation
```

However, you may also be interested in doing this using cohort FE instead of individual FE. If so, you can request it:

```stata

.  jwdid  lemp , ivar(countyreal) tvar(year) gvar(first_treat) group
WARNING: Singleton observations not dropped; statistical significance is biased (link)
(MWFE estimator converged in 2 iterations)

HDFE Linear regression                            Number of obs   =      2,500
Absorbing 2 HDFE groups                           F(   7,    499) =       3.81
Statistics robust to heteroskedasticity           Prob > F        =     0.0005
                                                  R-squared       =     0.0288
                                                  Adj R-squared   =     0.0233
                                                  Within R-sq.    =     0.0001
Number of clusters (countyreal) =        500      Root MSE        =     1.4911

                                      (Std. err. adjusted for 500 clusters in countyreal)
-----------------------------------------------------------------------------------------
                        |               Robust
                   lemp | Coefficient  std. err.      t    P>|t|     [95% conf. interval]
------------------------+----------------------------------------------------------------
__tr__#first_treat#year |
             2004 2004  |  -.0193724   .0223953    -0.87   0.387     -.063373    .0246283
             2004 2005  |  -.0783191   .0305062    -2.57   0.011    -.1382556   -.0183826
             2004 2006  |  -.1360781   .0354769    -3.84   0.000    -.2057806   -.0663756
             2004 2007  |  -.1047075   .0338947    -3.09   0.002    -.1713015   -.0381135
             2006 2006  |   .0025139   .0199448     0.13   0.900    -.0366724    .0417001
             2006 2007  |  -.0391927   .0240232    -1.63   0.103    -.0863919    .0080064
             2007 2007  |   -.043106   .0184423    -2.34   0.020    -.0793401    -.006872
                        |
                  _cons |    5.77807   .0665051    86.88   0.000     5.647405    5.908734
-----------------------------------------------------------------------------------------

Absorbed degrees of freedom:
-----------------------------------------------------+
 Absorbed FE | Categories  - Redundant  = Num. Coefs |
-------------+---------------------------------------|
 first_treat |         4           0           4     |
        year |         5           1           4     |
-----------------------------------------------------+
```

Both will give you numerically the same, but the second approach can be used with other methods. (for example poisson and logit).

Each one of the coefficients correspond to a Treatment effect for group G at time T. In contrast with CSDID. This happens because it is using **not-yet-treated** observations as controls. If you prefer to use **never-treated**, you can request it using `never` option:

```stata


. jwdid  lemp , ivar(countyreal) tvar(year) gvar(first_treat) group never
WARNING: Singleton observations not dropped; statistical significance is biased (link)
(MWFE estimator converged in 2 iterations)

HDFE Linear regression                            Number of obs   =      2,500
Absorbing 2 HDFE groups                           F(  12,    499) =       2.87
Statistics robust to heteroskedasticity           Prob > F        =     0.0008
                                                  R-squared       =     0.0288
                                                  Adj R-squared   =     0.0213
                                                  Within R-sq.    =     0.0001
Number of clusters (countyreal) =        500      Root MSE        =     1.4926

                                      (Std. err. adjusted for 500 clusters in countyreal)
-----------------------------------------------------------------------------------------
                        |               Robust
                   lemp | Coefficient  std. err.      t    P>|t|     [95% conf. interval]
------------------------+----------------------------------------------------------------
__tr__#first_treat#year |
             2004 2004  |  -.0105032   .0233633    -0.45   0.653    -.0564058    .0353993
             2004 2005  |  -.0704232   .0311344    -2.26   0.024    -.1315938   -.0092525
             2004 2006  |  -.1372587   .0366116    -3.75   0.000    -.2091906   -.0653269
             2004 2007  |  -.1008114   .0345251    -2.92   0.004    -.1686439   -.0329788
             2006 2004  |   .0065201   .0234394     0.28   0.781     -.039532    .0525723
             2006 2005  |   .0037693   .0314934     0.12   0.905    -.0581067    .0656452
             2006 2006  |  -.0008253   .0337989    -0.02   0.981     -.067231    .0655804
             2006 2007  |  -.0374552   .0358971    -1.04   0.297    -.1079833     .033073
             2007 2004  |   .0305067   .0151062     2.02   0.044     .0008272    .0601862
             2007 2005  |   .0277808   .0196384     1.41   0.158    -.0108034    .0663649
             2007 2006  |  -.0033064   .0245699    -0.13   0.893    -.0515796    .0449669
             2007 2007  |  -.0293608   .0265613    -1.11   0.270    -.0815465     .022825
                        |
                  _cons |   5.774174   .0670214    86.15   0.000     5.642495    5.905853
-----------------------------------------------------------------------------------------

Absorbed degrees of freedom:
-----------------------------------------------------+
 Absorbed FE | Categories  - Redundant  = Num. Coefs |
-------------+---------------------------------------|
 first_treat |         4           0           4     |
        year |         5           1           4     |
-----------------------------------------------------+

```

This is far closer to Callaway and Sant'Anna (2021) output.

### ***But What about controls??***

This one took me longer to crack, because of the math structure, and code practice. But today (august 4 2022), i got some inspiration and crack it down. The caveat, you should only use time constant variables!

So how to apply it? just add it!

```stata
. jwdid  lemp lpop, ivar(countyreal) tvar(year) gvar(first_treat) group
WARNING: Singleton observations not dropped; statistical significance is biased (link)
(MWFE estimator converged in 2 iterations)

HDFE Linear regression                            Number of obs   =      2,500
Absorbing 2 HDFE groups                           F(  22,    499) =     364.06
Statistics robust to heteroskedasticity           Prob > F        =     0.0000
                                                  R-squared       =     0.8732
                                                  Adj R-squared   =     0.8717
                                                  Within R-sq.    =     0.8695
Number of clusters (countyreal) =        500      Root MSE        =     0.5404

                                         (Std. err. adjusted for 500 clusters in countyreal)
--------------------------------------------------------------------------------------------
                           |               Robust
                      lemp | Coefficient  std. err.      t    P>|t|     [95% conf. interval]
---------------------------+----------------------------------------------------------------
   __tr__#first_treat#year |
                2004 2004  |   -.021248    .021724    -0.98   0.329    -.0639298    .0214338
                2004 2005  |    -.08185   .0273694    -2.99   0.003    -.1356234   -.0280766
                2004 2006  |  -.1378704   .0307884    -4.48   0.000    -.1983612   -.0773796
                2004 2007  |  -.1095395   .0323153    -3.39   0.001    -.1730302   -.0460487
                2006 2006  |   .0025368    .018879     0.13   0.893    -.0345554     .039629
                2006 2007  |  -.0450935   .0219826    -2.05   0.041    -.0882834   -.0019035
                2007 2007  |  -.0459545   .0179714    -2.56   0.011    -.0812636   -.0106455
                           |
first_treat#year#c._x_lpop |
                2004 2004  |   .0046278   .0175804     0.26   0.792    -.0299129    .0391685
                2004 2005  |   .0251131   .0179003     1.40   0.161    -.0100561    .0602822
                2004 2006  |   .0507346   .0210659     2.41   0.016     .0093457    .0921234
                2004 2007  |   .0112497   .0266118     0.42   0.673    -.0410353    .0635346
                2006 2006  |   .0389352   .0164686     2.36   0.018     .0065789    .0712915
                2006 2007  |   .0380597   .0224724     1.69   0.091    -.0060925     .082212
                2007 2007  |  -.0198351   .0161949    -1.22   0.221    -.0516538    .0119835
                           |
                      lpop |   1.065461   .0218238    48.82   0.000     1.022583    1.108339
                           |
        first_treat#c.lpop |
                     2004  |   .0509824   .0377558     1.35   0.178    -.0231975    .1251622
                     2006  |  -.0410954   .0473896    -0.87   0.386    -.1342031    .0520122
                     2007  |   .0555184   .0392124     1.42   0.157    -.0215233    .1325601
                           |
               year#c.lpop |
                     2004  |   .0110137   .0075537     1.46   0.145    -.0038274    .0258548
                     2005  |   .0207333   .0081044     2.56   0.011     .0048103    .0366564
                     2006  |   .0105354   .0108157     0.97   0.330    -.0107145    .0317853
                     2007  |    .020921   .0118084     1.77   0.077    -.0022793    .0441212
                           |
                     _cons |     2.1617   .0699859    30.89   0.000     2.024197    2.299204
--------------------------------------------------------------------------------------------

Absorbed degrees of freedom:
-----------------------------------------------------+
 Absorbed FE | Categories  - Redundant  = Num. Coefs |
-------------+---------------------------------------|
 first_treat |         4           0           4     |
        year |         5           1           4     |
-----------------------------------------------------
```

What it does in the background is to create the auxiliary variables, similar to what Prof. Wooldridge does. This extra variables will start with `_x_`. So try to avoid creating variables with the prefix. Other than that, the ATTGTs are still the first set of coefficients in the outcome.

Now the **fun** part. What if you want to get aggregates, CS2021 style. Well, I programmed them as part of the post estimation command `estat`. You have only 4 options: simple, calendar and group, or event. Unfortunately, you cannot get pretrends,...yet.

In the background, it simply calls on `margins`, and estimates the different aggregations over specific groups:

```
. estat simple

Average marginal effects                                   Number of obs = 291
Model VCE: Robust

Expression: Linear prediction, predict()
dy/dx wrt:  1.__tr__

------------------------------------------------------------------------------
             |            Delta-method
             |      dy/dx   std. err.      z    P>|z|     [95% conf. interval]
-------------+----------------------------------------------------------------
    1.__tr__ |   -.050627   .0124973    -4.05   0.000    -.0751212   -.0261329
------------------------------------------------------------------------------


. estat calendar
note: 2209 observations omitted because of missing values in over() variable.

Average marginal effects                               Number of obs   =   291
Model VCE: Robust                                      

Expression: Linear prediction, predict()
dy/dx wrt:  1.__tr__
Over:       __calendar__

------------------------------------------------------------------------------
             |            Delta-method
             |      dy/dx   std. err.      z    P>|z|     [95% conf. interval]
-------------+----------------------------------------------------------------
__tr__       |
__calendar__ |
       2004  |   -.021248    .021724    -0.98   0.328    -.0638263    .0213303
       2005  |    -.08185   .0273694    -2.99   0.003     -.135493    -.028207
       2006  |  -.0442656   .0173734    -2.55   0.011    -.0783168   -.0102144
       2007  |  -.0524323   .0150158    -3.49   0.000    -.0818628   -.0230018
------------------------------------------------------------------------------

. estat group
note: 2209 observations omitted because of missing values in over() variable.

Average marginal effects                               Number of obs   =   291
Model VCE: Robust                                      

Expression: Linear prediction, predict()
dy/dx wrt:  __tr__
Over:       __group__

------------------------------------------------------------------------------
             |            Delta-method
             |      dy/dx   std. err.      z    P>|z|     [95% conf. interval]
-------------+----------------------------------------------------------------
__tr__       |
   __group__ |
       2004  |   -.087627   .0230474    -3.80   0.000    -.1327991   -.0424549
       2006  |  -.0212783   .0185912    -1.14   0.252    -.0577165    .0151598
       2007  |  -.0459545   .0179714    -2.56   0.011    -.0811779   -.0107311
------------------------------------------------------------------------------

------------------------------------------------------------------------------

. estat event

Average marginal effects                                   Number of obs = 291
Model VCE: Robust

Expression: Linear prediction, predict()
dy/dx wrt:  1.__tr__
Over:       __event__

------------------------------------------------------------------------------
             |            Delta-method
             |      dy/dx   std. err.      z    P>|z|     [95% conf. interval]
-------------+----------------------------------------------------------------
1.__tr__     |
   __event__ |
          0  |  -.0332122    .013366    -2.48   0.013     -.059409   -.0070154
          1  |  -.0573456   .0171496    -3.34   0.001    -.0909583    -.023733
          2  |  -.1378704   .0307884    -4.48   0.000    -.1982145   -.0775263
          3  |  -.1095395   .0323153    -3.39   0.001    -.1728762   -.0462027
------------------------------------------------------------------------------

```

But the **fun** doesnt end there. One of the benefits of this approach is that you can use it with other nonlinear models: leading cases **logit** and **poisson**. 

```
gen emp=exp(lemp)

. jwdid  emp lpop, ivar(countyreal) tvar(year) gvar(first_treat) method(poisson)

Iteration 0:   log pseudolikelihood =   -2047585  
Iteration 1:   log pseudolikelihood = -190812.61  
Iteration 2:   log pseudolikelihood = -144661.24  
Iteration 3:   log pseudolikelihood = -143819.12  
Iteration 4:   log pseudolikelihood = -143818.87  
Iteration 5:   log pseudolikelihood = -143818.87  

Poisson regression                                    Number of obs =    2,500
                                                      Wald chi2(29) = 23470.49
Log pseudolikelihood = -143818.87                     Prob > chi2   =   0.0000

                                         (Std. err. adjusted for 500 clusters in countyreal)
--------------------------------------------------------------------------------------------
                           |               Robust
                       emp | Coefficient  std. err.      z    P>|z|     [95% conf. interval]
---------------------------+----------------------------------------------------------------
   __tr__#first_treat#year |
                2004 2004  |  -.0309557   .0175183    -1.77   0.077    -.0652908    .0033795
                2004 2005  |   -.066224   .0254345    -2.60   0.009    -.1160747   -.0163733
                2004 2006  |  -.1329713   .0235873    -5.64   0.000    -.1792017    -.086741
                2004 2007  |  -.1170228   .0223698    -5.23   0.000    -.1608667   -.0731788
                2006 2006  |  -.0090494   .0242793    -0.37   0.709    -.0566359    .0385371
                2006 2007  |  -.0681486   .0249653    -2.73   0.006    -.1170798   -.0192175
                2007 2007  |  -.0399916   .0167272    -2.39   0.017    -.0727763   -.0072068

                           |
first_treat#year#c._x_lpop |
                2004 2004  |   .0118798   .0070871     1.68   0.094    -.0020106    .0257702
                2004 2005  |   .0209935   .0118557     1.77   0.077    -.0022431    .0442302
                2004 2006  |   .0409103   .0095157     4.30   0.000     .0222599    .0595607
                2004 2007  |   .0250348   .0112217     2.23   0.026     .0030408    .0470289
                2006 2006  |   .0375838    .013539     2.78   0.006     .0110477    .0641198
                2006 2007  |   .0453804   .0163558     2.77   0.006     .0133236    .0774373
                2007 2007  |  -.0109675   .0071836    -1.53   0.127    -.0250472    .0031121
                           |
                      lpop |   1.039625   .0167659    62.01   0.000     1.006765    1.072486
                           |
        first_treat#c.lpop |
                     2004  |  -.0132716   .0402332    -0.33   0.742    -.0921273    .0655842
                     2006  |  -.0811734   .0328143    -2.47   0.013    -.1454883   -.0168586
                     2007  |   .0162899   .0249528     0.65   0.514    -.0326167    .0651965
                           |
               year#c.lpop |
                     2004  |  -.0066118   .0044864    -1.47   0.141     -.015405    .0021814
                     2005  |  -.0077402   .0058809    -1.32   0.188    -.0192666    .0037863
                     2006  |  -.0090772    .006498    -1.40   0.162     -.021813    .0036587
                     2007  |  -.0035862   .0054527    -0.66   0.511    -.0142732    .0071008
                           |
               first_treat |
                     2004  |   .2361076   .2067084     1.14   0.253    -.1690335    .6412487
                     2006  |    .592705   .1760361     3.37   0.001     .2476806    .9377294
                     2007  |  -.1440501   .1216656    -1.18   0.236    -.3825104    .0944101
                           |
                      year |
                     2004  |  -.0105493   .0207842    -0.51   0.612    -.0512856    .0301871
                     2005  |   .0112893   .0268825     0.42   0.675    -.0413994     .063978
                     2006  |   .0453898   .0289869     1.57   0.117    -.0114234     .102203
                     2007  |   .0542584   .0278424     1.95   0.051    -.0003118    .1088285
                           |
                     _cons |   2.484455   .0770439    32.25   0.000     2.333452    2.635458
--------------------------------------------------------------------------------------------

```

Notice that I could have used `ppmlhdfe`. But because of the small number of FE, its just as easy as adding the cohort FE and time FE directly in the model. You can also use use `estat` to obtain aggregations! They will be very long, but to give you a hint of what you will get:

```
estat event
[omitting what you dont want to see]

---------------------------------------------------------------
              |            Delta-method
              |   Contrast   std. err.     [95% conf. interval]
--------------+------------------------------------------------
_at@__event__ |
  (2 vs 1) 0  |  -37.35025   15.75917     -68.23764   -6.462846
  (2 vs 1) 1  |  -117.3918   33.88822     -183.8115   -50.97213
  (2 vs 1) 2  |  -204.6293   39.72574     -282.4903   -126.7683
  (2 vs 1) 3  |  -182.7539   39.14667       -259.48   -106.0278
---------------------------------------------------------------
```


## Conclusion

So we have a new Toy in town. Version 1.1. It is similar to the imputation approaches, it is easy to apply, and has been show to be more efficient than Callaway and Sant'Anna (2021), but works under stronger assumptions. 

Given its nature, It may be a good approach for the estimation of DID models. I believe, however, that just like previous imputation approaches, it will provide reasonble estimations of DID as long as the outcome model is correctly specified. However, as Sant'Anna and Zhao (2020) discuss, if the outcome model is highly nonlinear, it may fail to provide an unbiased estimate of the ATT. In practical terms, however, chances are that both methodologies would provide similar results. 

