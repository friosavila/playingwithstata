# DRDID and CSDID for Stata

## DRDID Version 1.38

Hello everyone, So version 1.38 is out!.

Yes you may notice that this "versioning" number is different from the version "0.1" that is available to install using `net install`. The reason for that is the rythm at which I have been programming, and adding options to the program. 

As always, this should be a quick note on the for the current version for `drdid` command for Stata. There are a few changes that occured (and have not yet documented). You probably already saw the post by Miklos, which gives provides instructions to download the package. So, you can either install it using those instractions, or just copy the files I provide here. 

Since I'll be maintaining the package, both sites will have the same information. Except that here I provide a bit more of my flair. (artistic freedom)

So, after 1 week of rest (and vacation) I came back to add couple of extra options to `drdid`. The now command produces both panel and repeated crossection estimators proposed in Sant'Anna and Zhao (2020), plus one done using `teffects`: The Inverse Probability Weighting Augmented regression estimator (for panel data). While I have not included this on the helpfile yet (still need to fix some of its features), the command now allows you to use weights (which will be used as pweights), and can also produce the 1-step wild-bootstrap. For the case of the Wbootstrap, however, the command only produces CI based on normal distribution, and not based on the symetric t-stat as is used in the original `DRDID` package. 

I have also added the option to produce clustered standard errors, although only when using asymptotic standard errors. The wildbootstrap clustered SE are yet to be programmed. 

You may also notice that the output from the `drdid` has changed slighly. EP (who wishes to remain anonymous) has helped providing a new display for the command, aligning better with `Stata` offical command style. He is also working on providing the option to obtain `DRDID` estimates via `gmm`. This approach is not yet implemented, but once its done, it will provide a richer set of options to estimate and standard errors, and may even allow you to use different explanatory variables in the outcome and probability model.

I have also added a better set of datachecks to make sure you have the data setup correctly. For instance, It will prompt you better error messages if you do not have a 2x2 DID structure. and will check if you do have a correct panel structure when you use the option `ivar`. Before it wouldnt do that, and would give you an incorrect results if you have, say, multiple observations per `ivar` and `time`. 

Finally, to protect data integrity, the influence functions are no longer "saved" or "stored" in the dataset, and neither is `__dy__`. They are not created as temporary variables, and will only save the IF when requested using the options `stub()` and/or `replace`.

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

The latter, however may not have a helpfile that is up to date.

## drdid in action

I tried to keep the syntax of drdid relatively standard. At least standard with other commands I have worked before. So some of the options may change slightly, as other features are integrated.

The general syntax of the command is as follows

``` 
drdid depvar [indepvar] [if] [in] [iw], [ivar(varname)] time(varname) tr(varname) [estimator] [boot cluster(varname) stub(string) replace]
```

Here an explanation of all the pieces:

- **`depvar`** : is your dependent variable or outcome of interest
- **`indepvar`**: are your independent variables, you may or may not have variables here. These variables will included in the outcome regression specification and the propensity score estimation.
- **`ivar`**: is a variable that identifies the panel ID. If you drop this, the command will use repeated crossection estimators instead. If included, it will estimate the panel estimators. 
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
- **`boot`**: When used, the command will estimate the 1-step wild-bootstrap (or multiplier bootstrap), with 999 repetions. It currently implements Mammen(1993) approach. This does not work after **`all`** or after **`ipwra'**.
- **`cluster`**: When used, the command will estimate the clustered standard errors based. This option does not yet work in combination with *`boot`*
- **`stub`**: When used, the *recentered influence function* will be stored in the dataset with the name **`stub`**_`att`_. If the variable already exists, you can request to overwrite it using `replace`. This option does not work when one requests **all** estimators, or when **`ipwra`** estimator is requested.

So, how does this work? Lets start with the lanlonde dataset, and the Panel estimators. For a quick application, I ll use the `all` option:

```
drdid re age educ black married nodegree hisp re74 if treated==0 | sample==2 , ivar(id) time(year) tr( experimental )  all 
```

and if everything went well, you should be seeing this:

```
Doubly robust difference-in-differences estimator summary
------------------------------------------------------------------------------
             | Coefficient  Std. err.      z    P>|z|     [95% conf. interval]
-------------+----------------------------------------------------------------
ATET         |
       dripw |  -871.3271   396.0211    -2.20   0.028    -1647.514   -95.14007
       drimp |  -901.2703   393.6127    -2.29   0.022    -1672.737   -129.8037
         reg |  -1300.645   349.8259    -3.72   0.000    -1986.291   -614.9985
         ipw |  -1107.872   408.6127    -2.71   0.007    -1908.738   -307.0058
      stdipw |  -1021.609   397.5201    -2.57   0.010    -1800.734   -242.4845
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
 
We could also estimate the implement the repeated crossection estimators to this data, by simply excluding `ivar()` option. This could also be applied, for example, if you have access to unbalanced panel data.

Perhaps the main problem with this option is that the estimations will be less efficient, with larger standard errors. The loss of efficiency is caused because we are now ignoring an important piece of information: the panel id.

```
. drdid re age educ black married nodegree hisp re74 if treated==0 | sample==2 ,  time(year) tr( experimental )  all 

Doubly robust difference-in-differences estimator summary
------------------------------------------------------------------------------
             | Coefficient  Std. err.      z    P>|z|     [95% conf. interval]
-------------+----------------------------------------------------------------
ATET         |
       dripw |  -871.3271   410.2751    -2.12   0.034    -1675.452   -67.20268
   dripw_rc1 |  -871.3271   435.0661    -2.00   0.045    -1724.041   -18.61332
       drimp |  -901.2703   408.3107    -2.21   0.027    -1701.545    -100.996
   drimp_rc1 |  -901.2703   434.3043    -2.08   0.038    -1752.491   -50.04954
         reg |  -1300.645   418.5023    -3.11   0.002    -2120.894   -480.3951
         ipw |  -1107.872   619.4393    -1.79   0.074    -2321.951    106.2068
      stdipw |  -1021.609    495.464    -2.06   0.039    -1992.701   -50.51783
------------------------------------------------------------------------------
Note: This table is provided for comparison across estimations only. You cannot use it to compare estimates across different estimators
dripw :Doubly Robust IPW
drimp :Doubly Robust Improved estimator
reg   :Outcome regression or Regression augmented estimator
ipw   :Abadie(2005) IPW estimator
stdipw:Standardized IPW estimator
sipwra:IPW and Regression adjustment estimator.
```

It is possible, however, to apply clustered standard errors using the panel id. This is useful if you have unbalanced data, and want to keep all observations in the sample. In this case, it will be the equivalent to using `ivar`, because the data is fully balanced.

```
. drdid re age educ black married nodegree hisp re74 if treated==0 | sample==2 ,  time(year) tr( experimental )  all  cluster(id)

Doubly robust difference-in-differences estimator summary
------------------------------------------------------------------------------
             | Coefficient  Std. err.      z    P>|z|     [95% conf. interval]
-------------+----------------------------------------------------------------
ATET         |
       dripw |  -871.3271   396.1635    -2.20   0.028    -1647.793   -94.86092
   dripw_rc1 |  -871.3271   396.1635    -2.20   0.028    -1647.793   -94.86092
       drimp |  -901.2703   393.6127    -2.29   0.022    -1672.737   -129.8037
   drimp_rc1 |  -901.2703   393.6127    -2.29   0.022    -1672.737   -129.8037
         reg |  -1300.645   349.8259    -3.72   0.000    -1986.291   -614.9985
         ipw |  -1107.872   408.6127    -2.71   0.007    -1908.738   -307.0058
      stdipw |  -1021.609   397.5201    -2.57   0.010    -1800.734   -242.4845
------------------------------------------------------------------------------
Note: This table is provided for comparison across estimations only. You cannot use it to compare estimates across different estimators
dripw :Doubly Robust IPW
drimp :Doubly Robust Improved estimator
reg   :Outcome regression or Regression augmented estimator
ipw   :Abadie(2005) IPW estimator
stdipw:Standardized IPW estimator
sipwra:IPW and Regression adjustment estimator.
```

We can also do the same using the simulated dataset provided also in R's `DRDID`. This to show how it estimates the model assuming repeated crossection.

```
use https://friosavila.github.io/playingwithstata/drdid/sim_rc.dta, clear
```

And let me use the same syntax as before, to obtain all estimates at the same time. Notice that I'm not including the "ivar" indicator. So the command uses the repeated crossection estimators:

```
. drdid y x1 x2 x3 x4, time(post) tr( d)   all

Doubly robust difference-in-differences estimator summary
------------------------------------------------------------------------------
             | Coefficient  Std. err.      z    P>|z|     [95% conf. interval]
-------------+----------------------------------------------------------------
ATET         |
       dripw |  -.1677954   .2007987    -0.84   0.403    -.5613537    .2257628
   dripw_rc1 |  -3.633433   3.105569    -1.17   0.242    -9.720237     2.45337
       drimp |  -.2097772   .1978384    -1.06   0.289    -.5975333    .1779789
   drimp_rc1 |  -3.683518   3.112235    -1.18   0.237    -9.783387    2.416351
         reg |  -8.790978   7.774585    -1.13   0.258    -24.02888    6.446929
         ipw |   -19.8933   53.84128    -0.37   0.712    -125.4203    85.63367
      stdipw |  -15.80331   9.083384    -1.74   0.082    -33.60641      1.9998
------------------------------------------------------------------------------
Note: This table is provided for comparison across estimations only. You cannot use it to compare estimates across different estimators
dripw :Doubly Robust IPW
drimp :Doubly Robust Improved estimator
reg   :Outcome regression or Regression augmented estimator
ipw   :Abadie(2005) IPW estimator
stdipw:Standardized IPW estimator
sipwra:IPW and Regression adjustment estimator.

```

What about Wild bootstrap? You can request WB SE but if you do that, you need to request specific estimator. Below an example for dripw:

```

. drdid y x1 x2 x3 x4, time(post) tr( d)  dripw

Doubly robust difference-in-differences                  Number of obs = 1,000
Outcome model  : least squares
Treatment model: inverse probability
------------------------------------------------------------------------------
             | Coefficient  Std. err.      z    P>|z|     [95% conf. interval]
-------------+----------------------------------------------------------------
ATET         |
           d |
   (1 vs 0)  |  -.1677954   .2007987    -0.84   0.403    -.5613537    .2257628
------------------------------------------------------------------------------

. drdid y x1 x2 x3 x4, time(post) tr( d)  dripw boot

Doubly robust difference-in-differences                  Number of obs = 1,000
Outcome model  : least squares
Treatment model: inverse probability
------------------------------------------------------------------------------
             | Coefficient  Std. err.      z    P>|z|     [95% conf. interval]
-------------+----------------------------------------------------------------
ATET         |
           d |
   (1 vs 0)  |  -.1677954   .2060326    -0.81   0.415     -.571612    .2360211
------------------------------------------------------------------------------

```


And that is it!. Please, if you find any bugs or encounter any problems. Let me know. So, what is next?

# CSDID Version 1.0

Yes, `CSDID` is here!.

This took longer, just because I was a bit burned with the first week of `DRDID` coding. Even having the base code (Thank you Pedro!) it was hard to understand how each moving piece moved. And, if you do not understand how it all moves, you cannot move forward. 

In any case...Yes, It clicked again, and we have a beta version!

I used to add information about `CSDID` here, but since it has just been completed, I'll create its own page!
Please use the menu on the right, and go to the new corresponding page.

## what is next for `DRDID`?

1. `drdid` is basically done. Last thing missing will be WB with clustered stadnard errors, and making sure CLusters are nested within panel id. That will be next.
2. Along with E.P., we are also working on adding `gmm` estimators to `drdid`. It will just be to provide you with more options for analysis and report. He also provided a new Display. function. 
3. There is also the "problem" of Wild Bootstrap. The code its done, but display is missing. It produces correct SE, but the CI generated in R relies on a symetric t-statistic. Easy to obtain, harder to display in a neat way.
 
If you have comments or questions, please, let me know!

