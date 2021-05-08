# DRDID and CSDID for Stata

## DRDID Version 0.5

Hello everyone, this should be a quick note on the second beta version for drdid command for Stata. Right now, this command produces the basic panel estimator proposed in Sant'Anna and Zhao (2020), as well as both Repeated Crosssection estimators.

I hope this guide may help in using this command.

Once everything is clean and approved. Will be posting at SSC

## Setup

For the replication exercise, I ll use the same dataset used in the example for the drdid command in R. Let's call it lalonde.dta

    use https://friosavila.github.io/playingwithstata/drdid/lalonde.dta, clear

Then, you may need to make sure to copy the files [drdid.ado](https://friosavila.github.io/playingwithstata/drdid/drdid.ado) and [drdid_logit.ado](https://friosavila.github.io/playingwithstata/drdid/drdid_logit.ado) in your personal ado folder. For my pc, it's in `C:\ado\personal`.

## drdid in action

Then, lets simply use it:

    drdid re age educ black married nodegree hisp re74 if treated==0 | sample==2 , ivar(id) time(year) tr( experimental )

and if everything went well, you should be seeing this:

    Estimating IPT
    Estimating Counterfactual Outcome
    Estimating ATT
    ------------------------------------------------------------------------------
         __att__ |      Coef.   Std. Err.      t    P>|t|     [95% Conf. Interval]
    -------------+----------------------------------------------------------------
           _cons |  -901.2703   393.6247    -2.29   0.022    -1672.817   -129.7233
    ------------------------------------------------------------------------------

And the newest update. It can now estimate the repeated cross section estimator.If you do not include "ivar", the program will assume your data is cross section, and estimate the model as if it were cross section. Here the results

    . drdid re c.age c.educ i.black married nodegree hisp re74 if treated==0 | sample==2 ,   time(year) tr( experimental )
    Estimating IPT
    Estimating Counterfactual Outcome
    ATT RC1 estimator
    ------------------------------------------------------------------------------
        __att1__ | Coefficient  Std. err.      t    P>|t|     [95% conf. interval]
    -------------+----------------------------------------------------------------
           _cons |  -901.2703   434.3109    -2.08   0.038    -1752.535    -50.0052
    ------------------------------------------------------------------------------
    ATT RC2 estimator
    ------------------------------------------------------------------------------
        __att2__ | Coefficient  Std. err.      t    P>|t|     [95% conf. interval]
    -------------+----------------------------------------------------------------
           _cons |  -901.2703   408.3169    -2.21   0.027    -1701.586   -100.9543
    ------------------------------------------------------------------------------

Notice that now it reports two numbers. This correspond to RC1 and RC2 estimator from Sant'Anna and Zhao (2020). And one last note. There is an option -noisily-. If you use it, it will report all intermediate steps.

## DRDID for DID 

As you may know, the R implementation of DID builds on DRDID, in addition to the added bells and whistles. So a quick  implementation (that will require a wrapper) for DID with DRDID could be done as follows:

### Setup
Load the data. Here using the same dataset provided along with DID.
```{stata}
use https://friosavila.github.io/playingwithstata/drdid/mpdta.dta, clear
```
Now, the goal for this example is to reproduce at least the point estimates for the DID command:
```{r}
att_gt(yname = "lemp", tname = "year", idname = "countyreal", 
    gname = "first.treat", xformla = ~lpop, data = mpdta)

Reference: Callaway, Brantly and Pedro H.C. Sant'Anna.  "Difference-in-Differences with Multiple Time Periods." Forthcoming at the Journal of Econometrics <https://arxiv.org/abs/1803.09015>, 2020. 

Group-Time Average Treatment Effects:
 Group Time ATT(g,t) Std. Error [95% Simult.  Conf. Band]  
  2004 2004  -0.0145     0.0218       -0.0727      0.0436  
  2004 2005  -0.0764     0.0294       -0.1546      0.0018  
  2004 2006  -0.1404     0.0410       -0.2497     -0.0312 *
  2004 2007  -0.1069     0.0358       -0.2023     -0.0115 *
  2006 2004  -0.0005     0.0226       -0.0607      0.0598  
  2006 2005  -0.0062     0.0191       -0.0571      0.0447  
  2006 2006   0.0010     0.0196       -0.0513      0.0532  
  2006 2007  -0.0413     0.0199       -0.0944      0.0118  
  2007 2004   0.0267     0.0135       -0.0091      0.0626  
  2007 2005  -0.0046     0.0156       -0.0462      0.0371  
  2007 2006  -0.0284     0.0183       -0.0771      0.0202  
  2007 2007  -0.0288     0.0161       -0.0717      0.0142  
---
Signif. codes: `*' confidence band does not cover 0

P-value for pre-test of parallel trends assumption:  0.23267
Control Group:  Never Treated,  Anticipation Periods:  0
Estimation Method:  Doubly Robust
```

This can now be reproduced with drdid with a carefully selected sample :

```
Commands:
drdid  lemp lpop if inlist(first_treat,0,2004) & inlist(year,2003,2004), ivar(countyreal)  time(year) tr(treat)
drdid  lemp lpop if inlist(first_treat,0,2004) & inlist(year,2003,2005), ivar(countyreal)  time(year) tr(treat)
drdid  lemp lpop if inlist(first_treat,0,2004) & inlist(year,2003,2006), ivar(countyreal)  time(year) tr(treat)
drdid  lemp lpop if inlist(first_treat,0,2004) & inlist(year,2003,2007), ivar(countyreal)  time(year) tr(treat)
drdid  lemp lpop if inlist(first_treat,0,2006) & inlist(year,2003,2004), ivar(countyreal)  time(year) tr(treat)
drdid  lemp lpop if inlist(first_treat,0,2006) & inlist(year,2003,2005), ivar(countyreal)  time(year) tr(treat)
drdid  lemp lpop if inlist(first_treat,0,2006) & inlist(year,2003,2006), ivar(countyreal)  time(year) tr(treat)
drdid  lemp lpop if inlist(first_treat,0,2006) & inlist(year,2003,2007), ivar(countyreal)  time(year) tr(treat)
drdid  lemp lpop if inlist(first_treat,0,2007) & inlist(year,2003,2004), ivar(countyreal)  time(year) tr(treat)
drdid  lemp lpop if inlist(first_treat,0,2007) & inlist(year,2003,2005), ivar(countyreal)  time(year) tr(treat)
drdid  lemp lpop if inlist(first_treat,0,2007) & inlist(year,2003,2006), ivar(countyreal)  time(year) tr(treat)
drdid  lemp lpop if inlist(first_treat,0,2007) & inlist(year,2003,2007), ivar(countyreal)  time(year) tr(treat)

and the output!

2004 - 2004
------------------------------------------------------------------------------
     __att__ | Coefficient  Std. err.      t    P>|t|     [95% conf. interval]
-------------+----------------------------------------------------------------
       _cons |  -.0145329   .0221602    -0.66   0.512    -.0581269     .029061
------------------------------------------------------------------------------
2004 - 2005
------------------------------------------------------------------------------
     __att__ | Coefficient  Std. err.      t    P>|t|     [95% conf. interval]
-------------+----------------------------------------------------------------
       _cons |  -.0764267   .0287098    -2.66   0.008    -.1329053   -.0199482
------------------------------------------------------------------------------
2004 - 2006
------------------------------------------------------------------------------
     __att__ | Coefficient  Std. err.      t    P>|t|     [95% conf. interval]
-------------+----------------------------------------------------------------
       _cons |  -.1404536   .0354269    -3.96   0.000    -.2101461   -.0707611
------------------------------------------------------------------------------
2004 - 2007
------------------------------------------------------------------------------
     __att__ | Coefficient  Std. err.      t    P>|t|     [95% conf. interval]
-------------+----------------------------------------------------------------
       _cons |  -.1069093   .0329364    -3.25   0.001    -.1717025   -.0421161
------------------------------------------------------------------------------
```

## CSDID Version 0.1

And with these pieces in places, we can now have a proper first version of R's DID command native to Stata.
By popular demand (3 guys in a chatroom) we are calling it -[csdid.ado](https://friosavila.github.io/playingwithstata/drdid/csdid.ado)-.

As it was suggested on twitter, *csdid* works using *drdid* on the background. And as of right now, it produces what you would get when using att_gt command. 

You will see point estimates are either exactly like those from -did-. but some differences come up. The main reason is that DID does not really use DRDID as the estimator. But it does so on this implementation. here it is:

```
use https://friosavila.github.io/playingwithstata/drdid/mpdta.dta, clear

. csdid  lemp lpop , ivar(countyreal) time(year) gvar(first_treat)
------------------------------------------------------------------------------
             | Coefficient  Std. err.      z    P>|z|     [95% conf. interval]
-------------+----------------------------------------------------------------
g2004        |
t0_2003_2004 |  -.0145329   .0221602    -0.66   0.512     -.057966    .0289002
t0_2003_2005 |  -.0764267   .0287098    -2.66   0.008    -.1326969   -.0201566
t0_2003_2006 |  -.1404536   .0354269    -3.96   0.000     -.209889   -.0710183
t0_2003_2007 |  -.1069093   .0329364    -3.25   0.001    -.1714634   -.0423551
-------------+----------------------------------------------------------------
g2006        |
t0_2003_2004 |  -.0006112   .0222299    -0.03   0.978    -.0441809    .0429586
t0_2004_2005 |   -.006267   .0185075    -0.34   0.735     -.042541    .0300071
t0_2005_2006 |   .0009473    .019409     0.05   0.961    -.0370936    .0389883
t0_2005_2007 |  -.0413123   .0197454    -2.09   0.036    -.0800126   -.0026119
-------------+----------------------------------------------------------------
g2007        |
t0_2003_2004 |   .0266993   .0140788     1.90   0.058    -.0008947    .0542933
t0_2004_2005 |  -.0045906    .015728    -0.29   0.770    -.0354169    .0262357
t0_2005_2006 |  -.0284515   .0181982    -1.56   0.118    -.0641193    .0072163
t0_2006_2007 |  -.0287821   .0162518    -1.77   0.077     -.060635    .0030709
------------------------------------------------------------------------------
```

so what is next? 2 big pieces left. 
1. Adding other estimators including IPW and OR. (this if for DRDID)
2. start working on the aggregators!
3. add bells ans whisles for graphs and stuff. And of course, helpfiles, examples, and the paper that is waiting for me to use and implement this.

