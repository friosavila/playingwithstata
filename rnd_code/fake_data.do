webdoc init fake_data, header(   stscheme(ocean)   include(mattex.txt)  ///
						title(Creating Sharable data) ) replace logall 
/***
<h1>How to come public, with private data</h1>
In a current work with Stephen Jenkins, one problem we face when we starting the submission for the publication process is providing a replication package along with the paper.
<br><br>
Providing the code for the model estimations that we created, and even including the Code developed by others authors, is relatively simple. The problem, which many people may face, is how to distribute data when due to privacy or proprietary reasons, we are not allowed to share. 
<br><br>
As a matter of fact, on this particular project, only Stephen has seen the data, whereas I have worked from the far, primary on the code that estimates the new models (if interest in the research, I'm providing the links to previous papers we have worked on below).
<br><br>
So now that is time for the "big" paper to be published, we need some strategy to construct a synthetic dataset that will fulfill all privacy protection constraints, while still transferring the moments' structure that we care about, as well as those we may not be so interested in, but may be of interest for other people.
<br><br>
So, with this idea in mind, I came up with a simple strategy that may help to do just that. An application of Multiple Imputation. This may not be THE best method to do this, so I'll be happy to hear any comments.
<br><br>
To better describe how the method works, I will use one dataset that is readily available online. This data is an excerpt of the Swiss labor market Survey 1998, which is provided as the example dataset in the command -oaxaca- (By Jann 2008).
<h2>The problem </h2>
Assume that you have signed a confidentiality agreement to work with Swiss Survey data. And are ready to submit your work, but you are asked to provide a replication package, with a code to produce the tables you have, and the dataset itself.
<br><br>
Since you cannot share the data, you suggest instead to provide a 5 synthetic synthetic datasets, so people can apply your code, and get to similar (if not the same) conclusions as in your main paper. Here is a piece of code you could use for that.
***/
** Assumption. You have a dataset that you want to use
clear all
use http://fmwww.bc.edu/RePEc/bocode/o/oaxaca.dta, clear
misstable summarize
/***
Four variables have missing data: Wages, tenure, experience, and ISCO,  And they are missing when LFP=0
<br><br>
Now, I suggest creating 1 variable, that will be a "seed" that will be used to recreate synthetic datasets. It will just be a random uniform variable that will range from 0 to 100. And an ID variable.
***/
gen id = _n
set seed 10101
gen seed = runiform(0,100)
/***
The next step is to decide how large the synthetic dataset will be. The obvious answer is to create a dataset with the same number of observations, but if you want other sample sizes, it could be adjusted. So I'll expand the dataset, duplicating observation 1, 1648 times. I will also tag the original observation:
***/
expand 1648 in 1, gen(tag)
/***
You can now set to missing, variables with tag=1
***/
foreach i of varlist lnwage educ exper tenure isco female lfp age single married divorced kids6 kids714 wt {
	replace `i'=. if tag==1
}
/***
And you will need to recreate the "seed" variable as well
***/
replace seed = runiform(0,100) if tag==1
/***
We may also need to set LFP since we have missing data depending on LF status
***/
replace lfp = runiform()<.87 if tag==1
/***
The next step is to create Multiple Imputed datasets. I believe the best strategy here is to use "pmm", because that uses the observed distribution and data types. So first mi set the data, and register all variables to be imputed:
***/
mi set wide
mi register impute lnwage educ exper tenure   isco female age single married   kids6 kids714 wt
/***
And simply impute all variables using chain pmm. Just make sure none of the variables are collinear (here colinearity exists between single, married, and divorced), and that variables with structural missing data are specified separately.
<br><br>
Notice as well that the explanatory variables are "seed" (fully random) and LFP (also random).
***/
mi impute chain (pmm, knn(100))    educ   female   age single married kids6 kids714 wt (pmm if lfp==1, knn(100) ) lnwage  exper tenure isco  = seed lfp, add(5)
/***
That's it. You have now 5 sets of variables that can be used to create unique synthetic datasets, with a similar structure as the original confidential dataset, and that could be used for replication and public use.
***/

forvalues i = 1/5 {
	preserve
		keep if tag==1
		keep _`i'_* lfp 
		ren _`i'_* *
		save fake_oaxaca_`i', replace
	restore
}
/*** 
Now let's see if this works, estimating simple an LR,  CQR model, and a Heckman model.
***/
frame create test

frame test: {
	use http://fmwww.bc.edu/RePEc/bocode/o/oaxaca.dta, clear
	qui:reg lnwage educ exper tenure female
	est sto m1
	qui:qreg lnwage educ exper tenure female, q(10)
	est sto m2
	qui:heckman lnwage educ exper tenure female age, selec(lfp =educ     female age single married kids6 kids714) two
	est sto m3
}

forvalues i = 1/5 { 
	frame test: {
		use fake_oaxaca_`i', clear
		
		qui:reg lnwage educ exper tenure female
		est sto m1`i'
		qui:qreg lnwage educ exper tenure female, q(10)
		est sto m2`i'
 
		qui:heckman lnwage educ exper tenure female age, selec(lfp =educ     female age single married kids6 kids714) two
	est sto m3`i'
	} 
}
** OLS
esttab m1 m11 m12 m13 m14 m15, mtitle(Original Fake1 Fake2 Fake3 Fake4 Fake5)
** qreg 10
esttab m2 m21 m22 m23 m24 m25, mtitle(Original Fake1 Fake2 Fake3 Fake4 Fake5)
** heckman
esttab m3 m31 m32 m33 m34 m35, mtitle(Original Fake1 Fake2 Fake3 Fake4 Fake5)  
/***
What about covariances:
***/
frame test: {
	use http://fmwww.bc.edu/RePEc/bocode/o/oaxaca.dta, clear
	mean lnwage exper tenure educ   female   age single married kids6 kids714 

	corr lnwage exper tenure educ   female   age single married kids6 kids714 , cov

}
forvalues i = 1/2 { 
	frame test: {
	use fake_oaxaca_`i', clear
mean lnwage exper tenure educ   female   age single married kids6 kids714 

	corr lnwage exper tenure educ   female   age single married kids6 kids714 , cov
	} 
}
 /***
 <h2>Conclusions</h2>
As you can see, the results are going to be far from perfect replication of the original dataset. After all, we are introducing random errors to create a synthetic dataset, so other people can try to replicate our work.
<br><br>
With those caveats in mind, what we may end up doing is to create synthetic "fake" data like this one, along with two versions of the results. One based on the actual data, and another based on the synthetic dataset(s).

<h2>References</h2>
  Jann, Ben (2008). The Blinder-Oaxaca decomposition for linear regression models. The Stata Journal 8(4): 453-479.
  <br><br>
Jenkins, SP, Rios‐Avila, F, 2021. "Measurement error in earnings data: replication of Meijer, Rohwedder, and Wansbeek's mixture model approach to combining survey and register data." J Appl Econ. 2021. Accepted Author Manuscript. https://doi.org/10.1002/jae.2811 (with Rep Files <a href="http://qed.econ.queensu.ca/jae/forthcoming/jenkins-rios-avila/">here</a>)
  <br><br>
Jenkins, Stephen P. & Rios-Avila, F, 2020. "Modelling errors in survey and administrative data on employment earnings: Sensitivity to the fraction assumed to have error-free earnings," Economics Letters, Elsevier, vol. 192(C).

***/
webdoc close