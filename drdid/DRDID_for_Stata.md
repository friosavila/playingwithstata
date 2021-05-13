# DRDID and CSDID for Stata

## DRDID Version 1.2

Hello everyone, this should be a quick note on the third beta version for `drdid` command for Stata. I promise a proper helpfile, examples, and the whole nine will be provided in time. My collegues are working on some of the details for an easier installation of the command. but for now, you can do "install" `drdid` by simply copying the file on your personal ado folder.

So, after one week of "Serious-Series-of-Serious" Mata and Stata programming, I completed a version of the command that replicates R's `DRDID`. Of course with a bit of my own flavor. The command now produces both panel and repeated crossection estiators proposed in Sant'Anna and Zhao (2020), plus one done using `teffects`. The Inverse Probability Weighting Augmented regression estimator (for panel). 

I hope this guide may help in using this command, at least until is properly released through SSC. Please if you find any bugs or difficulties, do not hesitate to contact me at friosa@gmail.com, or throught twitter!

Once everything is clean and approved. Will be posting at SSC

## Setup

For the replication exercise, I ll use the same dataset used in the example for the drdid command in R. Let's call it lalonde.dta. 

    use https://friosavila.github.io/playingwithstata/drdid/lalonde.dta, clear

Then, you may need to make sure to copy the files [drdid.ado](https://friosavila.github.io/playingwithstata/drdid/drdid.ado) and [drdid_logit.ado](https://friosavila.github.io/playingwithstata/drdid/drdid_logit.ado) in your personal ado folder. For my pc, it's in `C:\ado\personal`.

## drdid in action

I tried to keep the syntax of drdid relatively standard. At least standard with other commands I have worked before. So some of the options may change slightly.

The general syntax of the command is as follows

```{stata}
drdid depvar [indepvar] [if in] , [ivar(varname)] time(varname) tr(varname) [estimator]
```

Here an explanation of all the pieces:

- `depvar` is your dependent variable or outcome
- `indepvar` are your independent variables, you may or may not have variables here.
- `ivar` is a variable that identifies the panel ID. If you drop this, it will use the repeated crossection data instead. If included, it will estimate the panel estimators.
- `time` identifies the time variable (year). 
- `tr` is the treatment variable, and identifies the treatment group.
- `estimator` is used to indicate which estimator you want to use. Below the list of all that is available:
  - `drimp` Estimates the DR improved estimator. If you add `rc1` it provides you with the alternative estimator (that is not locally efficient)
  - `dripw` Estimates the DR IPW estimator. You can also use `rc1` to provide the alternative (not locally efficient) estimator.
  - `reg` Estimates the Outcome regression estimator. 
  - `stdipw` Estimates the Standard IPW estimator.
  - `aipw` Estimates the estimator similar to Abadies (2005)
  - `ipwra` Estimates the IPW regression augmented estimator. Not available for Repeated Crossection
  - `all` Estimates all options. Perhaps you may find it useful for robustness. (I did it for replication)

So, how does this work? Lets start with the lanlonde dataset, and the Panel estimators. For a quick application, I ll use the `all` option:

```
drdid re age educ black married nodegree hisp re74 if treated==0 | sample==2 , ivar(id) time(year) tr( experimental )  all 
```

and if everything went well, you should be seeing this:

```stata

NOT DRDID: DID with Standard IPW with RA
------------------------------------------------------------------------------
             | Coefficient  Std. err.      z    P>|z|     [95% conf. interval]
-------------+----------------------------------------------------------------
       dripw |  -871.3271   396.0332    -2.20   0.028    -1647.538   -95.11643
       drimp |  -901.2703   393.6247    -2.29   0.022     -1672.76   -129.7802
         reg |  -1300.645   349.8365    -3.72   0.000    -1986.312   -614.9776
        aipw |  -1107.872   408.6252    -2.71   0.007    -1908.763   -306.9814
      stdipw |  -1021.609   397.5322    -2.57   0.010    -1800.758   -242.4607
      sipwra |  -908.2912   278.5062    -3.26   0.001    -1454.153    -362.429
------------------------------------------------------------------------------
```

For the Repeated Cross section estimator, I will use the simulated dataset provided also in R's `DRDID`.

```
use https://friosavila.github.io/playingwithstata/drdid/sim_rc.dta, clear
```

And let me use the same syntax as before, to obtain all estimates at the same time:

```
drdid y x1 x2 x3 x4, time(post) tr( d)   all 


. drdid y x1 x2 x3 x4, time(post) tr( d)   all 
------------------------------------------------------------------------------
             | Coefficient  Std. err.      z    P>|z|     [95% conf. interval]
-------------+----------------------------------------------------------------
       dripw |  -.1677954   .2008992    -0.84   0.404    -.5615506    .2259597
   dripw_rc1 |  -3.633433   3.107123    -1.17   0.242    -9.723283    2.456416
       drimp |  -.2088586   .2003375    -1.04   0.297     -.601513    .1837957
   drimp_rc1 |  -3.683729   3.114496    -1.18   0.237    -9.788028     2.42057
         reg |  -8.790978   7.778475    -1.13   0.258    -24.03651    6.454554
        aipw |   -19.8933   53.86822    -0.37   0.712    -125.4731    85.68648
      stdipw |  -15.80331    9.08793    -1.74   0.082    -33.61532    2.008708
------------------------------------------------------------------------------


```

And that is it!. Please, if you find any bugs or encounter any problems. Let me know. So, what is next?

## CSDID Version 0.1

Yes, `CSDID` is next!. It may take some time. Havent done much progress since the v0.1. But may come back to this soon. There was a small bug so I think we are at version v0.2 now. See below for an example:

With these pieces in places, we can now have a proper first version of R's DID command native to Stata.
By popular demand (3 guys in a chatroom) we are calling it -[csdid.ado](https://friosavila.github.io/playingwithstata/drdid/csdid.ado)-.

As it was suggested on twitter, *csdid* works using *drdid* on the background. And as of right now, it produces what you would get when using att_gt command. Also, it will use  the `drimp` option with `drdid`. But will be including all other estimators (except `all') in the future.

You will see point estimates are either exactly like those from -did-. but some differences come up. The main reason is that DID does not really use DRDID as the estimator. But it does so on this implementation. here it is:

```
use https://friosavila.github.io/playingwithstata/drdid/mpdta.dta, clear

. csdid  lemp lpop , ivar(countyreal) time(year) gvar(first_treat)
Callaway Santana (2021)
------------------------------------------------------------------------------
             | Coefficient  Std. err.      z    P>|z|     [95% conf. interval]
-------------+----------------------------------------------------------------
g2004        |
 t_2003_2004 |  -.0145329   .0221602    -0.66   0.512     -.057966    .0289002
 t_2003_2005 |  -.0764267   .0287098    -2.66   0.008    -.1326969   -.0201566
 t_2003_2006 |  -.1404536   .0354269    -3.96   0.000     -.209889   -.0710183
 t_2003_2007 |  -.1069093   .0329364    -3.25   0.001    -.1714634   -.0423551
-------------+----------------------------------------------------------------
g2006        |
 t_2003_2004 |  -.0006112   .0222299    -0.03   0.978    -.0441809    .0429586
 t_2004_2005 |   -.006267   .0185075    -0.34   0.735     -.042541    .0300071
 t_2005_2006 |   .0009473    .019409     0.05   0.961    -.0370936    .0389883
 t_2005_2007 |  -.0413123   .0197454    -2.09   0.036    -.0800126   -.0026119
-------------+----------------------------------------------------------------
g2007        |
 t_2003_2004 |   .0266993   .0140788     1.90   0.058    -.0008947    .0542933
 t_2004_2005 |  -.0045906    .015728    -0.29   0.770    -.0354169    .0262357
 t_2005_2006 |  -.0284515   .0181982    -1.56   0.118    -.0641193    .0072163
 t_2006_2007 |  -.0287821   .0162518    -1.77   0.077     -.060635    .0030709
------------------------------------------------------------------------------
Control: Never Treated

```

## what is next?

So what is next? 2 big pieces left. 

1. We need start working on the `csdid` part. The basic structure is ready (see above), but details and other options are still in development.
   
2. Start working on the aggregators!. This is what really needs some work. But yes, it will come. We will put special emphsis on the visualizations.

3. Clean everything up, more efficient code, proper help file. And if you find bugs...kill the bugs!

