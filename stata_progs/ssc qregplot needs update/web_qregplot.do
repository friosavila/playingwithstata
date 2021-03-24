webdoc init qregplot, header(stscheme(ocean)     ///
						title(Fun with quantile regressions) ) replace logall 
/***
<h1> -qregplot- : plotting quantile coefficients </h1>
<p> This page aims to show how to use qregplot, as a tool for plotting 
coefficients from quantile regression, which could have been obtained from 
many quantile type commands. I'll show you some examples for each.
<br><br>
So this page can be considered as an extended version of the qregplot help file.
<h2>The Setup</h2>
<p>To work with the following examples, you will need to either or install the following:</p>
</p>
***/						
ssc install qregplot, replace
ssc install mmqreg, replace
ssc install qrprocess, replace
ssc install ivqreg2, replace
ssc install qreg2, replace
ssc install xtqreg, replace
/***
<p> and, for the data, we will use a very small dataset, available from Stata datasets examples:</p>
</p>
***/
webuse womenwk, clear
set scheme s2color
/***
<p> So lets start. Say that you want to estimate a model, where wages are a function of age education,  marital status, and 
county of residence.
<br><br>
Furthermore, lets say that we are interested in conditional quantile regressions. 
</p>
***/
qreg wage age education married i.county
/***
<p>
Now we simply want to plot the coefficients across the distribution for all coefficients but the county dummies.
Because I know I may have to re-edit the graphs, I'll save the coefficients into e_qreg.
</p>
***/
qregplot age education married , estore(e_qreg) q(5(5)95)
graph export qfig1.png, replace
/***
<img src = "qfig1.png">
<p>This is a good start, but I would like to use variable labels for titles in each figure. But I dont want to re-estimate them all.
 What I can do is plot "from" the stored coefficients.
</p>
***/
qregplot age education married , from(e_qreg) q(5(5)95) label
graph export qfig2.png, replace
/***
<img src = "qfig2.png">
<p>Not quite there yet, I would like the CI to be softer, so I ll use rarea options:
</p>
***/
qregplot age education married , from(e_qreg) q(5(5)95) label raopt( color(%30))
graph export qfig3.png, replace
/***
<img src = "qfig3.png">
<p>
Finally, say that I want to see this, but in 3 rows. This would be a graph combine option :
</p>
***/
qregplot age education married , from(e_qreg) q(5(5)95) label raopt( color(%30)) grcopt( col(1) ysize(10) xsize(5))
graph export qfig4.png, replace
/***
<img src = "qfig4.png">
<p>
I like this figure the best, So I ll store it in memory for later use. I will also concentrate on age and education. and drop married.
</p>
***/

qregplot age education , from(e_qreg) q(5(5)95) label raopt( color(%30)) grcopt( col(1) ysize(7) xsize(5) name(qreg1, replace))
graph export qfig5.png, replace
/***
<img src = "qfig5.png">
<p>
Now, suppouse you are not sure about standard errors for -qreg-, and decide to instead restimate the model using bsqreg,
and will get ready for "plotting".
<br><br>
The good thing is you do not need to specify quantiles at this point, but you need to indicate number of reps(#). Here I will use 50.
Also, for consistency, I ll use the same seed for each iteration.
<br><br>
Other than that, I ll use the same graphic options as before:
</p>
***/
bsqreg wage age education married i.county, reps(50)
qregplot age education , estore(e_bsqreg) q(5(5)95) seed(101) label raopt( color(%30)) grcopt( col(1) ysize(7) xsize(5) name(bsqreg1, replace))
graph export qfig6.png, replace

/***
<img src = "qfig6.png">
<p>
Once again you grow concern about the assumptions required for the standard errors or if 50 iterations is enough. But what are alternatives?
<br><br>
One option is for you to apply -qreg2- which provides "Heteroskedasticity robust standard errors" 
</p>
***/
qreg2 wage age education married i.county, 
qregplot age education , estore(e_qreg2) q(5(5)95) seed(101) label raopt( color(%30)) grcopt( col(1) ysize(7) xsize(5) name(qreg2_1, replace))
graph export qfig7.png, replace

/***
<img src = "qfig7.png">
<p>
Now a different question pops into your mind. You read that qunitile regressions some times violate the 
monotonicity assumption. And that an alternative to deal with this is to estimate them via momements. 
<br><br>
One option for that is -xtqreg-. However, for this to work, you will need to use county as your "panel id"
</p>
***/
xtqreg wage age education married, i(county)
qregplot age education , estore(e_xtqreg) q(5(5)95) seed(101) label raopt( color(%30)) grcopt( col(1) ysize(7) xsize(5) name(xtqreg1, replace))
graph export qfig8.png, replace
/***
<img src = "qfig8.png">
<p>
Of course, you may not be sure about using xtqreg, and assume "county" is your panel id. 
So, you could use either mmqreg or ivqreg2. Both are also based on quantile via moments, but ivqreg2 could
also help dealing with endogeneity. I ll show you the resuls based on ivqreg.
<br>
The main caveat of using ivqreg2, is that it doesnt allow for factor notation yet. This can be fixed using "xi:".
</p>
***/

xi: ivqreg2 wage age education married i.county
qregplot age education , estore(e_ivqreg2) q(5(5)95)  label raopt( color(%30)) grcopt( col(1) ysize(7) xsize(5) name(ivqreg1, replace))
graph export qfig9.png, replace

/***
<img src = "qfig9.png">
<p>
If you had a problem of endogeneity, you could also use ivqreg to address such problem, and qregplot for looking at those coefficients.
<br><br>
Finally, say you were not interested in conditional quantiles, but unconditional quantiles (Long story behind this that will be covered 
at some other point). You can use qregplot for plotting those too!
<br>
Different from other plots, however, you need to explicitly add at least one quantile for qregplot to identify what is what you are doing.
</p>
***/

rifhdreg wage age education married i.county, rif(q(10))
qregplot age education , estore(e_rifhdreg) q(5(5)95)  label raopt( color(%30)) grcopt( col(1) ysize(7) xsize(5) name(rif1, replace))
graph export qfig10.png, replace
/***
<img src = "qfig10.png">
<p> So one last thing that has been usually done. Compare coefficients side by side.
Since all data has already been stored, doing the coefficients should be an easy task.
<br>
Perhaps the only caveat, we need to do this for a single variable at a time. So i ll show it for education:
</p>
***/

* qreg
set graph off
qregplot education , from(e_qreg) raopt( color(%30)) twopt(name(qreg2, replace) title("Conditional Quantile Regression"))
* mmqreg via ivqreg
qregplot education , from(e_ivqreg2) raopt( color(%30)) twopt(name(ivqreg22, replace) title("MM-Quantile Regression"))
* mmqreg via rifhdreg
qregplot education , from(e_rifhdreg) raopt( color(%30)) twopt(name(rif2, replace) title("Unconditional Quantile Regression"))
set graph on
 
graph combine qreg2 ivqreg22 rif2, col(3) xsize(10) ysize(4) ycommon
graph export qfig11.png, replace

/***
<img src = "qfig11.png">

<p>
There you have it. one command -qregplot- Many posibilities!.
And if you are reproducing this difigures, you can use "from()" options to twik  all coefficients
<br><br>
Comments welcome!
</p>
***/
webdoc close