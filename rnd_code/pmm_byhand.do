** Example
use http://fmwww.bc.edu/RePEc/bocode/o/oaxaca.dta, clear
gen     work = 0 if lnwage!=.
replace work = 1 if lnwage==.
** The idea is that the group that needs imputing is tagged with 1, and the one with donor wages with 0

** Imputing wages using a Heckman regression
heckman lnwage educ  female age agesq , select( educ  female age agesq married kids6 kids714 ) two
// This first gets the Predicted mean wage based on the model above
predict xblnwage

// For the mean matching, a simple option could be using psmatch
psmatch2 work , pscore(xblnwage)
// sort by treated and ID: This is crucial. Because the wages are imputed based on the order of the variables
sort _treated _id

// and thats it. The next step is creating the "imputed" wages

gen     imp_wage = lnwage[_n1] if work==1
replace imp_wage = lnwage      if work==0

// I can also transfer the predicted wage to show how close they are with their donors
gen     xblnwage_donor = xblnwage[_n1] if work==1
replace xblnwage_donor = xblnwage      if work==0
// This new variable could be used to construct the "_pdif" already in the file (part of what psmatch produces)

// How this compare?

two kdensity imp_wage if work==0 || ///
	kdensity imp_wage if work==1 ,  ///
	legend(order(1 "Log wage distributions original data" 2 "Log wage distribution for pmm imputed data") cols(1))

// Alternative. mi impute pmm

*use http://fmwww.bc.edu/RePEc/bocode/o/oaxaca.dta, clear
** Start by setting the data as Multiple Imputation data
mi set wide
** Register variables that may need imputting. We can add more than just wages
mi register imputed lnwage exper tenure
** do the imputation
mi impute chain (pmm, knn(1)) lnwage exper tenure = educ  female age agesq married kids6 kids714 [pw=wt], add(5)  
**                   ^        \_________________/   \___________________________________________/           ^
**                   |                 |                                 |                                  | 
**                 Method       Vars that need     Observered for all.                        How many Imputed samples to add
**                                imputation
** Here knn(#) is a calibration parameter. But i not certain of how it could affect the imputation	
	
** Using this other method you can have More imputed variables ( _?_varname), and impute many variables simulatenously 
two kdensity imp_wage  if work==0 [aw=wt] || ///
	kdensity imp_wage  if work==1 [aw=wt] || ///
	kdensity _1_lnwage if work==1 [aw=wt] ,  ///
	legend(order(1 "Log wage distributions original data" ///
				 2 "Log wage distribution for pmm imputed data" ///
				 3 "Log wage distribution for mi pmm imputed data") cols(1))
	
two kdensity _1_lnwage if work==1 [aw=wt] || ///
	kdensity _2_lnwage if work==1 [aw=wt] || ///
	kdensity _3_lnwage if work==1 [aw=wt] || ///
	kdensity _4_lnwage if work==1 [aw=wt] || ///
	kdensity _5_lnwage if work==1 [aw=wt] ,  ///
	legend(order(1 "Imputed 1" ///
				 2 "Imputed 2" ///
				 3 "Imputed 3" ///
				 4 "Imputed 4" ///
				 5 "Imputed 5" ) cols(3))
		