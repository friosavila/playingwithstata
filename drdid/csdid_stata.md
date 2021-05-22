# CSDID Version 1.0

## Prolog
Yes, `CSDID` is here!.

This took longer, just because I was a bit burned with the first week of `DRDID` coding. Even having the base code (Thank you Pedro!) it was hard to understand how each moving piece moved. And, if you do not understand how it all moves, you cannot move forward. 

In any case...Yes, It clicked again, and we have a new version!

So a bit of the Guts of the program. As it has been suggested in twitter, and confirmed by the authors (Pedro and Barty), R's `DID` is a wrapper around `DRDID`. `DRDID` does the heavy lifting of the 2x2 setup, and `DID` collects everything, summarizes, and makes nice tables for you. 

So that was the part that required some ingenuity. How to aggregate all the information, (averages) and correctly report what we wanted to see. It is a bit harder than in R because **Mata** does not have some of the tools. (wishes and grumbles comming!). And on top of that, how to apply the Wild Bootstrap procedure. 

Since the WB is relatively easy (once the IF's are created) I decided to take a different route and start with the asymptotic versions of the aggregators first. After a talk with Barty, It click, and I realize a very easy way to do it. Ok, let me show you.

## Setup 

So, to use `csdid` you will need three sets of files:
- [drdid.ado](https://friosavila.github.io/playingwithstata/drdid/drdid.ado). This is the workhorse of the estimation. Does the actual estimation, and gets the IF.
- [csdid.ado](https://friosavila.github.io/playingwithstata/drdid/csdid.ado). This is the main program that works like `DID` works. It will call on `drdid.do`, and put all the pieces into a nice table. It kind of does the work that `att_gt` does.
- [csdid_estat.ado](https://friosavila.github.io/playingwithstata/drdid/csdid_estat.ado). This file will be used as a post-estimation program. It does the work that `aggte` and `summarize` does. 

In contrast with **`DID`**, my command will use **`drimp`** as the default estimator method. However, all other estimators within **`drdid`** will be allowed (except `all`). They key is to declare the method using option **`method()`**. Interestingly enough, **`DID`** uses `dripw` as the default. So I will use that for the following replication.

## Simple Help

The general syntaxis of the command will be as follows:

```
csdid depvar indepvar [if] [in] [iw], ivar(varname) time(year) gvar(group_var) method(drdid estimator) [notyet]
```

Here an explanation of all the pieces:

- **`depvar`** : is your dependent variable or outcome of interest
- **`indepvar`**: are your independent variables, you may or may not have variables here. These variables will included in the outcome regression specification and/or the propensity score estimation.
- **`ivar`**: is a variable that identifies the panel ID. If you drop this, the command will use repeated crossection estimators instead. If included, it will estimate the panel estimators. This option may change to groupvar.
- **`time`**: identifies the time variable (for example year). It does not matter if the periods are contiguous or not. this variable should overlap all possible periods within `gvar'
- **`gvar`**: is the variable that identifies the first time an observation is treated. It should be within the "time" bracket. Observations with `gvar==0` are never treated units.
- **method(`estimator`)** is used to indicate which estimator you want to use. Below the list of all that is available:
  - **`drimp`** Estimates the DR improved estimator. If you add `rc1` it provides you with the alternative estimator (that is not locally efficient). Default
  - **`dripw`** Estimates the DR IPW estimator. You can also use `rc1` to provide the alternative (not locally efficient) estimator.
  - **`reg`** Estimates the Outcome regression estimator. 
  - **`stdipw`** Estimates the Standard IPW estimator.
  - **`ipw`** Estimates the estimator similar to Abadies (2005)
  - **`ipwra`** Estimates the IPW regression augmented estimator. This is estimated through `Stata` command `teffects ipwra`. Not available for Repeated Crossection
- **`notyet`** request using not yet treated variables as controls, rather than never-treated only.

Now for the post estimation command (aggregations) you have the following:

```
estat [subcommand]
```

And this are the options:

- **`pretrend`**: This tests if all the pre-treatment effects are all equal to 0.
- **`simple`**: Estimates the simple aggregation of all post treatment effects.
- **`group`**: Estimates the group effects
- **`calendar`**: Estimates the calendar time effects 
- **`event`**: Estimates the dynamic aggregation/event study effects 
	
## Replication

So lets see how this works.  First, load the data, and estimate the model. To replicate the `DID` simple output, I will use `method(dripw)`.
```
use https://friosavila.github.io/playingwithstata/drdid/mpdta.dta, clear

. csdid  lemp lpop , ivar(countyreal) time(year) gvar(first_treat) method(dripw)

Callaway Sant'Anna (2021)
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
-------------+----------------------------------------------------------------
wgt          |
       w2004 |    .104712   .0229413     4.56   0.000      .059748    .1496761
       w2006 |   .2094241   .0317607     6.59   0.000     .1471742     .271674
       w2007 |   .6858639    .051479    13.32   0.000     .5849668    .7867609
------------------------------------------------------------------------------
Control: Never Treated
```

I find this output a bit easier to understand than the baseline output in R. 

Each `equation` represents the group treatment. And each `coefficient` represents the two years (pre and post) used to estimate the ATT. 

All point estimates are the same as the R command. The standard errors are different, because R's `DID` uses bootstrap standard errors by default, whereas I use the asymptotic normal ones as default. You can replicate this in R using the `bstrap = F` option.

The last equation is something that will be used for the aggregation. Corresponds to the Weights each group has in sample. 

So what about the aggregation. The first thing would be the pretest for parallel assumption:

```
. estat pretrend
Pretrend Test. H0 All Pre-treatment are equal to 0

 ( 1)  [g2006]t_2003_2004 = 0
 ( 2)  [g2006]t_2004_2005 = 0
 ( 3)  [g2007]t_2003_2004 = 0
 ( 4)  [g2007]t_2004_2005 = 0
 ( 5)  [g2007]t_2005_2006 = 0

           chi2(  5) =    6.84
         Prob > chi2 =    0.2327

```

We can also reproduce the simple, calendar and group aggregations:

```
. estat simple
Simple Average Treatment

------------------------------------------------------------------------------
             | Coefficient  Std. err.      z    P>|z|     [95% conf. interval]
-------------+----------------------------------------------------------------
      simple |  -.0417518   .0115028    -3.63   0.000    -.0642969   -.0192066
------------------------------------------------------------------------------

. estat calendar
Time Estimated Effects

------------------------------------------------------------------------------
             | Coefficient  Std. err.      z    P>|z|     [95% conf. interval]
-------------+----------------------------------------------------------------
       t2004 |  -.0145297   .0221292    -0.66   0.511     -.057902    .0288427
       t2005 |  -.0764219   .0286713    -2.67   0.008    -.1326166   -.0202271
       t2006 |  -.0461757   .0212107    -2.18   0.029     -.087748   -.0046035
       t2007 |  -.0395822   .0129299    -3.06   0.002    -.0649242   -.0142401
------------------------------------------------------------------------------

. estat group
Group Effects

------------------------------------------------------------------------------
             | Coefficient  Std. err.      z    P>|z|     [95% conf. interval]
-------------+----------------------------------------------------------------
       g2004 |  -.0845759   .0245649    -3.44   0.001    -.1327222   -.0364297
       g2006 |  -.0201666   .0174696    -1.15   0.248    -.0544065    .0140732
       g2007 |  -.0287814    .016239    -1.77   0.076    -.0606091    .0030464
------------------------------------------------------------------------------

```

And the one that is the most difficult to program. The event studies one:

```

. estat event
Event Studies:Dynamic effects

------------------------------------------------------------------------------
             | Coefficient  Std. err.      z    P>|z|     [95% conf. interval]
-------------+----------------------------------------------------------------
         E_3 |   .0267278   .0140657     1.90   0.057    -.0008404     .054296
         E_2 |  -.0036165   .0129283    -0.28   0.780    -.0289555    .0217226
         E_1 |   -.023244   .0144851    -1.60   0.109    -.0516343    .0051463
          E0 |  -.0210604   .0114942    -1.83   0.067    -.0435886    .0014679
          E1 |  -.0530032   .0163465    -3.24   0.001    -.0850417   -.0209647
          E2 |  -.1404483   .0353782    -3.97   0.000    -.2097882   -.0711084
          E3 |  -.1069039   .0328865    -3.25   0.001    -.1713602   -.0424476
------------------------------------------------------------------------------

```

And that is it! a functional Stata Native DID program!

## What is next?

1. Some stress testing. Right now i have worked with balanced panel datasets. Who knows how it will react with less than ideal situations.
2. Some verification. Basically add conditions so all `att_gt` that can be estimated, are estimated. You know, the safegards and bugs.
3. WB, Now that I know better how the "weights" play into the analysis, this should be easier. But, I still need to figure out how to report the CI.
4. Help files. And of course...Graphs! 
   
   
