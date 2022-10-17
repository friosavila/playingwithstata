## Homework 2: The handout

This document aims to provide a baseline solution for homework 2, but is not meant to be a complete set of all possible answers.

First, we start loading the data:

```{stata}
frause hhprice, clear
```

Assume that you are interested in studying the role of distance to the city center as determinant of housing prices, and assume that distance is independent of other variables not accounted in the model. 

1i) 
- How reliable is this assumption?  Are there any characteristics (available in the data) that might be correlated with distance to the city center and house prices? 

> This is not a reliable assumption. There are many housing characteristics that could be directly related to the distance and to housing prices. For example, living farther from the city may reduce the price of land, and increase land availability. Because of this, houses that are built away from the city may tend to be larger, with more rooms and constructed square feets, etc. Not accounting for this would suggest that living away from the city increases the cost of a house, not because of the living away from the city, but because houses are different.

- What is the effect you expect to see between distance to the city center and house prices? Explain, and justify your intuition.

> There are many possibilities. On the one hand, living farther from the city may increase cost of transportation, reduce access to employment hubs, and access to other amenties (schools, Policing services, and hospitals, among others). Because of this I would expect people pay a premium to live closer to cities.
> Other option: Because of aspects such as contamination, noise or overpopulation, people may be willing to pay more if they can find houses that are farther from the city.

1ii)

We have different models:

```{stata}
gen dist2=distance^2
gen dist3=distance^3
gen ldist=log(distance)
gen lprice = log(price1000)
reg price1000 distance 
est sto m1
reg price1000 distance dist2 
est sto m2
reg price1000 distance dist2 dist3
est sto m3
reg lprice distance dist2 
est sto m4
reg lprice ldist
est sto m5

esttab m1 m2 m3 m4 m5 , se md nogaps nostar
```

**All models**

|              |    price1000 |    price1000 |    price1000 |       lprice |       lprice |
| ------------ | :----------: | :----------: | :----------: | :----------: | :----------: |
| distance     |       -3.215 |       -5.795 |       -4.819 |      -0.0447 |              |
|              |     (0.0869) |      (0.255) |      (0.600) |    (0.00188) |              |
| dist2        |              |       0.0770 |       0.0137 |     0.000486 |              |
|              |              |    (0.00717) |     (0.0359) |  (0.0000529) |              |
| dist3        |              |              |      0.00109 |              |              |
|              |              |              |   (0.000604) |              |              |
| ldist        |              |              |              |              |       -0.314 |
|              |              |              |              |              |    (0.00737) |
| \_cons       |        152.2 |        168.6 |        164.8 |        5.058 |        5.346 |
|              |      (1.194) |      (1.936) |      (2.887) |     (0.0143) |     (0.0177) |
| *N*          |        10376 |        10376 |        10376 |        10376 |        10376 |
| *R*<sup>2</sup> |        0.116 |        0.126 |        0.126 |        0.166 |        0.149 |

First Price Prediction:

```Stata

. est restore m1
(results m1 are active now)

. local p10 = _b[_cons]+_b[distance]*10 
. local p11 = _b[_cons]+_b[distance]*11 
. local pdist = `p10'-`p11'
. display "Price at 10km:" `p10' _n ///
>                 "Price at 11km:" `p11' _n ///
>                 "Premium of 1km farther:" `pdist'
Price at 10km:120.06563
Price at 11km:116.85106
Premium of 1km farther:3.2145743

. 
. est restore m2
(results m2 are active now)

. local p10 = _b[_cons]+_b[distance]*10+_b[dist2]*10^2 
. local p11 = _b[_cons]+_b[distance]*11+_b[dist2]*11^2
. local pdist = `p10'-`p11'
. display "Price at 10km:"  _n ///
>                 "Price at 11km:"  _n ///
>                 "Premium of 1km farther:" `pdist'
Price at 10km:118.40124
Price at 11km:114.2238
Premium of 1km farther:4.1774452

.                 
. est restore m3
(results m3 are active now)
. local p10 = _b[_cons]+_b[distance]*10+_b[dist2]*10^2+_b[dist3]*10^3
. local p11 = _b[_cons]+_b[distance]*11+_b[dist2]*11^2+_b[dist3]*10^3 
. local pdist = `p10'-`p11'

. display "Price at 10km:" `p10' _n ///
>                 "Price at 11km:" `p11' _n ///
>                 "Premium of 1km farther:" `pdist'
Price at 10km:119.06424
Price at 11km:114.53329
Premium of 1km farther:4.5309488

. est restore m4
(results m4 are active now)

. local p10 = exp(_b[_cons]+_b[distance]*10+_b[dist2]*10^2)*exp(0.5*e(rss)/e(N))
. local p11 = exp(_b[_cons]+_b[distance]*11+_b[dist2]*11^2)*exp(0.5*e(rss)/e(N))
. local pdist = `p10'-`p11'

. display "Price at 10km:" `p10' _n ///
>                 "Price at 11km:" `p11' _n ///
>                 "Premium of 1km farther:" `pdist'               
Price at 10km:116.00205
Price at 11km:112.07211
Premium of 1km farther:3.9299383

. est restore m5
(results m5 are active now)

. local p10 = exp(_b[_cons]+_b[ldist]*log(10))*exp(0.5*e(rss)/e(N))
. local p11 = exp(_b[_cons]+_b[ldist]*log(11))*exp(0.5*e(rss)/e(N))
. local pdist = `p10'-`p11'

. display "Price at 10km:" `p10' _n ///
>                 "Price at 11km:" `p11' _n ///
>                 "Premium of 1km farther:" `pdist'
Price at 10km:111.91984
Price at 11km:108.61531
Premium of 1km farther:3.3045315


```
Each model has different predictions of Prices.
Based on this models, we predict that prices of houses at 10km away from the city range betwee 111.92K dollars (model5) to 120k (model 1).

Now, all models suggest that living away from the city is cheaper. Each mode, however, have different predictions. Linear model predicts that a house would be 3.21K cheaper, whereas the cubic model suggests houses are cheaper by almost 4.5K.

**Extra** Elasticity:

Easy one: Model 5: Just the Beta -0.314
Other models: 

$$\frac{\Delta price}{Price} * \frac{Distance(=10.5)}{1}$$

Model1: $e=\frac{-3.21}{120.06+3.21/2}*{10.5}=-.277$

Model2: $e=\frac{-4.18}{118.04+4.18/2}*{10.5}=-.365$

Model3: $e=\frac{-4.53}{114.53+4.53/2}*{10.5}=-.407$

Model4: $e=\frac{-3.92}{116.00+3.92/2}*{10.5}=-.349$

Model5: $e=\frac{-3.30}{111.92+3.30/2}*{10.5}=-.305$

Last model is slightly different just because of approximations.

1iii) New model

```Stata
gen lland=log(land)
regress lprice ldist rooms i.car lland i.type_h

      Source |       SS           df       MS      Number of obs   =    10,376
-------------+----------------------------------   F(7, 10368)     =   1126.23
       Model |  1011.17904         7  144.454149   Prob > F        =    0.0000
    Residual |  1329.84103    10,368  .128263988   R-squared       =    0.4319
-------------+----------------------------------   Adj R-squared   =    0.4316
       Total |  2341.02007    10,375  .225640489   Root MSE        =    .35814

------------------------------------------------------------------------------
      lprice | Coefficient  Std. err.      t    P>|t|     [95% conf. interval]
-------------+----------------------------------------------------------------
       ldist |  -.4835198   .0069146   -69.93   0.000    -.4970739   -.4699658
       rooms |   .2035576   .0049689    40.97   0.000     .1938177    .2132976
             |
         car |
          1  |   .0215345   .0155431     1.39   0.166     -.008933     .052002
          2  |   .1298282   .0157864     8.22   0.000     .0988839    .1607726
          3  |   .1169113    .018214     6.42   0.000     .0812084    .1526142
             |
       lland |   .1314963   .0069067    19.04   0.000     .1179578    .1450348
    1.type_h |  -.1732361   .0109353   -15.84   0.000    -.1946713   -.1518009
       _cons |   4.236588   .0386843   109.52   0.000     4.160759    4.312417
------------------------------------------------------------------------------

```
ldist: to live 10% farther from the city would imply a decline in housing prices of about 4.83%. This aligns to the price "savings" one enjoys by living farther from the city.

Each additional room, however, increases the cost in 20.3% or 22.57% (if using the exact formula). Along with land size (which has an elasticity of 0.13) indicate that larger houses are indeed priced at higher values. 

We do observe that parking spots have a nonlinear effect on price of houses. Compared to houses with no parking spots, having only 1 car has no statstically significant effect on housing prices. Having 2 parking spots, however, is costly, increasing the cost of houses in about 13%, but with almost no differential cost for houses with 3 parking spots.

Finally, Townhomes, are substantially cheaper compared to other types of housing options. In average, compared to houses with the same characteristics, townhomes are 17.3% cheaper, or about 19k dollars cheaper (using as reference the average price of a house)

1iv) Here we need two separate procedures

```stata
reg lprice rooms i.car ldist lland i.type_h i.type_h#c.ldist i.type_h#c.lland  

. reg lprice rooms i.car ldist lland i.type_h i.type_h#c.ldist i.type_h#c.lland

      Source |       SS           df       MS      Number of obs   =    10,376
-------------+----------------------------------   F(9, 10366)     =   1123.97
       Model |  1156.20715         9  128.467461   Prob > F        =    0.0000
    Residual |  1184.81292    10,366  .114297986   R-squared       =    0.4939
-------------+----------------------------------   Adj R-squared   =    0.4935
       Total |  2341.02007    10,375  .225640489   Root MSE        =    .33808

--------------------------------------------------------------------------------
        lprice | Coefficient  Std. err.      t    P>|t|     [95% conf. interval]
---------------+----------------------------------------------------------------
         rooms |    .174755   .0047751    36.60   0.000     .1653949    .1841151
               |
           car |
            1  |   .0105354   .0147539     0.71   0.475     -.018385    .0394559
            2  |   .1024036   .0150276     6.81   0.000     .0729466    .1318607
            3  |   .0587983   .0174285     3.37   0.001     .0246351    .0929616
               |
         ldist |  -.6295607   .0077121   -81.63   0.000    -.6446779   -.6144434
         lland |   .3384169   .0092149    36.72   0.000     .3203539    .3564799
      1.type_h |   .7499464   .0895567     8.37   0.000     .5743981    .9254948
               |
type_h#c.ldist |
            1  |    .483243   .0184265    26.23   0.000     .4471236    .5193624
               |
type_h#c.lland |
            1  |  -.3428781   .0138295   -24.79   0.000    -.3699867   -.3157695
               |
         _cons |   3.416324   .0460151    74.24   0.000     3.326126    3.506523
--------------------------------------------------------------------------------
```
There are two options here. First, one can simply look at the t-values and P values of the interactions (`type_h#ldist`) and (`type_h#lland`)

alternatively, you can also use a joint test using "test"

```stata
 test 1.type_h#c.ldist 1.type_h#c.lland

 ( 1)  1.type_h#c.ldist = 0
 ( 2)  1.type_h#c.lland = 0

       F(  2, 10366) =  634.43
            Prob > F =    0.0000

```

In both cases you reject the null hypothesis that both type of households have the same price profiles respect to distance and landsize. 

Interstingly, being located 1km farther from the city has a stronger effect for regular houses, comapred to town homes. Specifically, if a house is located 10% farther (1.2km farther for the average), the price of a regular house would drop in 6.3%. Whereas the price of a town home would only fall in 1.46%. 

In contrast, while larger houses pay a premium for additional land (with an elasticity of .338), Townhomes prices are almost not affected regardless of the land size (elasticity -0.0045).

For the second part, Chow test, one is effectively testing interactions with all variables.

```Stata
** Chowtest: using the command from SSC (easy route)
chowtest lprice rooms i.car ldist lland i.type_h, group(type_h)
Chow's Structural Change Test:
  Ho: no Structural Change
  Chow Test = 251.02        P-Value > F(7 , 10362) = 0.0000
** using Interactions
reg lprice c.(rooms i.car ldist lland)##i.type_h
test  1.type_h 1.type_h#c.rooms 1.type_h#1.car 1.type_h#2.car 1.type_h#3.car 1.type_h#c.ldist 1.type_h#c.lland

 ( 1)  1.type_h = 0
 ( 2)  1.type_h#c.rooms = 0
 ( 3)  1.car#1.type_h = 0
 ( 4)  2.car#1.type_h = 0
 ( 5)  3.car#1.type_h = 0
 ( 6)  1.type_h#c.ldist = 0
 ( 7)  1.type_h#c.lland = 0

       F(  7, 10362) =  251.02
            Prob > F =    0.0000
** Using Double Regression, v1
** Unrestricted
reg lprice c.(rooms i.car ldist lland)##i.type_h
local ssru = e(rss)
** restricted
reg lprice rooms i.car ldist lland
local ssrr = e(rss)

. display (`ssrr'-`ssru')/ `ssru' * (10362/7)
251.01862  //~F(7,10362)

```

All methods should give you the same results
Conclusion, Town homes have difference pricing profiles. The most evident differences, the price premiums for land size, distance, and # of rooms.

1iv) 
General steps;
1-Get residuals
2-get squared residuals
3-model Res^2 as function of characteristics

``` stata
reg  lprice rooms i.car ldist lland i.type_h
predict res, res
predict lprice_hat
gen res2=res*res
** BP test
reg res2 rooms i.car ldist lland i.type_h

      Source |       SS           df       MS      Number of obs   =    10,376
-------------+----------------------------------   F(7, 10368)     =    107.26
       Model |  23.4872971         7  3.35532815   Prob > F        =    0.0000
    Residual |  324.334968    10,368  .031282308   R-squared       =    0.0675
-------------+----------------------------------   Adj R-squared   =    0.0669
       Total |  347.822265    10,375  .033525038   Root MSE        =    .17687

-> F-stat and p-value suggest Heteroskedasticity
** White
reg res2 c.(rooms i.car ldist lland i.type_h)##c.(rooms i.car ldist lland i.type_h)


      Source |       SS           df       MS      Number of obs   =    10,376
-------------+----------------------------------   F(28, 10347)    =     44.15
       Model |  37.1215997        28  1.32577142   Prob > F        =    0.0000
    Residual |  310.700665    10,347  .030028092   R-squared       =    0.1067
-------------+----------------------------------   Adj R-squared   =    0.1043
       Total |  347.822265    10,375  .033525038   Root MSE        =    .17329

-> Sample conclusion

** AWhite
reg res2 c.lprice_hat##c.lprice_hat

. reg res2 c.lprice_hat##c.lprice_hat

      Source |       SS           df       MS      Number of obs   =    10,376
-------------+----------------------------------   F(2, 10373)     =     56.34
       Model |  3.73763611         2  1.86881805   Prob > F        =    0.0000
    Residual |  344.084629    10,373  .033171178   R-squared       =    0.0107
-------------+----------------------------------   Adj R-squared   =    0.0106
       Total |  347.822265    10,375  .033525038   Root MSE        =    .18213

-> Sample conclusion

```

All tests coincide. We have a problem of heteroskedasticity, and because of that the chow test using the last approach (2 regressions), is incorrect.
Why? Even if the coefficients were to be the same, the SSR would be different because of heteroscedasticty. 
Further, if errors are heteroskedastic, one should use robust standard errors, (or other methods)

In practice, conclusions will most likely remain consistent.

1vi: FGLS

estimate an alternative model:
```stata
gen lres2=log(res2)
reg lres2 rooms i.car ldist lland i.type_h
predict lres2_hat
gen hx=exp(lres2_hat)
eststo m1:reg lprice rooms i.car ldist lland i.type_h 
eststo m2:reg lprice rooms i.car ldist lland i.type_h [w=1/hx]
esttab m1 m2, se no gaps md nostar
```


|              |      OLS:lprice | FGLS:      lprice |
| ------------ | :----------: | :----------: |
| rooms        |        0.204 |        0.178 |
|              |    (0.00497) |    (0.00493) |
|     No Car spots         |          | |
| 1.car        |       0.0215 |       0.0168 |
|              |     (0.0155) |     (0.0126) |
| 2.car        |        0.130 |        0.101 |
|              |     (0.0158) |     (0.0133) |
| 3.car        |        0.117 |       0.0777 |
|              |     (0.0182) |     (0.0159) |
| ldist        |       -0.484 |       -0.512 |
|              |    (0.00691) |    (0.00665) |
| lland        |        0.131 |        0.199 |
|              |    (0.00691) |    (0.00713) |
| regular Houses     |             |            |
| 1.type\_h     |       -0.173 |      -0.0835 |
|              |     (0.0109) |     (0.0108) |
| \_cons       |        4.237 |        3.980 |
|              |     (0.0387) |     (0.0354) |
| *N*          |        10376 |        10376 |
| *R*<sup>2</sup> |        0.432 |        0.462 |

For the most part conclusions do not change, The premium of an additional room is slighly lower (17.8% vs 20.4%), the added cost paid for an additional parking slot is marginally smaller (10.1% vs 13% for 2 carspots), with a somewhat larger price elasticities to distnce fromt the city, and land. 

Perhaps the biggest difference comes from the house types, where the price difference between a town home and regular house declined by almost half, from 17.3% to  8.35%.

## 2) Claims and costs

Start by loading the data

```stata
frause insurance, clear
```
So in this case, the model we will be working with is one where the we are trying to determine if it is possible to predict if, giving that someone had some type of medical expense, they will be making a claum to their insurance.

```stata
* This is a LPM

. reg insuranceclaim smoker  age bmi children  steps

      Source |       SS           df       MS      Number of obs   =     1,338
-------------+----------------------------------   F(5, 1332)      =    212.32
       Model |  144.048776         5  28.8097551   Prob > F        =    0.0000
    Residual |   180.73822     1,332  .135689354   R-squared       =    0.4435
-------------+----------------------------------   Adj R-squared   =    0.4414
       Total |  324.786996     1,337  .242922211   Root MSE        =    .36836

------------------------------------------------------------------------------
insurancec~m | Coefficient  Std. err.      t    P>|t|     [95% conf. interval]
-------------+----------------------------------------------------------------
      smoker |   .3887522   .0268858    14.46   0.000     .3360091    .4414953
         age |   .0032045   .0007308     4.38   0.000     .0017709    .0046381
         bmi |   .0266535   .0023408    11.39   0.000     .0220615    .0312455
    children |  -.1701291   .0084108   -20.23   0.000     -.186629   -.1536293
       steps |  -.0143177   .0061175    -2.34   0.019    -.0263187   -.0023166
       _cons |  -.1748361   .1054299    -1.66   0.097    -.3816628    .0319907

```

According to the model, smokers are about 38.9% more likely to make an insurance claim, compared to non smokers. This may reflect the fact that smokers, who may have lower health condition, are more likely to have more frequen and higher medical expenses incresing their propensity to make insurance claims

We also see that older people and those with higher BMI are more likely to make a claim. If we compare two individuals who are 10 years appart, the older individual will be almst 3.2% more likely to make the claim. In addition, a 1 point increase in BMI will also increase the propensity to make a claim in about 2.7%. 
As with smoking, it may be that older individuals and those with less healthy weight (thus higher BMI) face higher health costs, which makes them more likely to make claims.

The one that is somewhat less intuitive is the impact of children. An additional child reduces the propensity to make claims in 17%. It is possible that children increase happiness and thus health, which is why they make fewer insurance claims. However, it may also be that having more children has an impact on time availability. Thus parents have less time, thus are less likely to make insurance claims, at least for themselves.

Finally steps, (number of steps per day) is a good indicator of health status. People walk more are healtier, thus reducing their chances to have large medical bills and make insurance claims. 

ii) Heteroskedasticty test, same as before.
Remeber LPM are always heteroskedastic. So you must address this one way or another.

For Ramsay Test

```
 reg insuranceclaim smoker  age bmi children  steps
 predict ins_hat
 gen ins_hat2=ins_hat^2
 gen ins_hat3=ins_hat^3
  reg insuranceclaim smoker  age bmi children  steps ins_hat2 ins_hat3
  test ins_hat2 ins_hat3
 
```

You reject the NULL of no misspecification, which suggests you have a functional form problem. 

iii) How is cost related to all other variables in the model

```stata
corr charges smoker  age bmi children  steps

(obs=1,338)

             |  charges   smoker      age      bmi children    steps
-------------+------------------------------------------------------
     charges |   1.0000
      smoker |   0.7873   1.0000
         age |   0.2990  -0.0250   1.0000
         bmi |   0.1983   0.0038   0.1093   1.0000
    children |   0.0680   0.0077   0.0425   0.0128   1.0000
       steps |  -0.3056  -0.2678  -0.1680  -0.6812   0.0554   1.0000


```

As suspected, Charges are positively correlated to all variables, but Steps. Surprisingly, children and charges are also possitively correlated, albeit the correlation is small.

We may expect coefficients of all other variables to decline, if we include `charges` in the model specification.

Adding two variables to the model

```stata
gen lcharges=log(charges)
gen chr_d = 0 if charge<=6000
replace chr_d = 1 if charge>6000 & charge<=12000
replace chr_d = 2 if charge>12000

eststo m0:reg insuranceclaim smoker  age bmi children  steps 
eststo m1:reg insuranceclaim smoker  age bmi children  steps lcharges
eststo m2:reg insuranceclaim smoker  age bmi children  steps i.chr_d
esttab m0 m1 m2, md se nogaps nostar
```


|              | insuranceclaim | insuranceclaim | insuranceclaim |
| ------------ | :----------: | :----------: | :----------: |
| smoker       |        0.389 |        0.481 |        0.400 |
|              |     (0.0269) |     (0.0438) |     (0.0368) |
| age          |      0.00320 |      0.00529 |      0.00241 |
|              |   (0.000731) |    (0.00107) |    (0.00102) |
| bmi          |       0.0267 |       0.0273 |       0.0269 |
|              |    (0.00234) |    (0.00235) |    (0.00235) |
| children     |       -0.170 |       -0.164 |       -0.173 |
|              |    (0.00841) |    (0.00869) |    (0.00861) |
| steps        |      -0.0143 |      -0.0143 |      -0.0137 |
|              |    (0.00612) |    (0.00610) |    (0.00616) |
| lcharges     |              |      -0.0599 |              |
|              |              |     (0.0224) |              |
| 0.chr\_d      |              |              |            0 |
|              |              |              |          (.) |
| 1.chr\_d      |              |              |       0.0586 |
|              |              |              |     (0.0337) |
| 2.chr\_d      |              |              |       0.0145 |
|              |              |              |     (0.0408) |
| \_cons       |       -0.175 |        0.243 |       -0.175 |
|              |      (0.105) |      (0.188) |      (0.105) |
| *N*          |         1338 |         1338 |         1338 |
Standard errors in parentheses

The results suggest the impact of adding charges is unexpected.
When adding impact as log of wages, we see a significant but negative effect on the likelihood of making claims. However, when using dummies, the impact is positive when comparing low to middle expenses (at 10%). However the impact is non significant for the group with highest expenditure level.

The coefficients for other variables do not seem to change much. with magnituds that are similar to the model without charges. 
This suggest we may have a problem of model specification, which could be related to how we are including charges. However, even if that is the case, our previous conclusions stands. Nevertheless, it may be the case that there are factors other than cost, explaining the magnitud and direction of the estimated coefficients.
