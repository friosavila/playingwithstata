use "charity.dta", clear
fgen lavggift=log(avggift)
fgen lweekslast=log(weekslast)
fgen lmailsyear=log(mailsyear)
fgen lpropresp=log(propresp)

reg gift resplast weekslast mailsyear propresp avggift , robust
margins, dydx(resplast weekslast mailsyear propresp avggift) post
est sto model1
reg gift resplast weekslast mailsyear propresp avggift l*, robust
f_able, nl(lavggift lweekslast lmailsyear lpropresp)
margins, dydx(resplast weekslast mailsyear propresp avggift) nochain post
est sto model2
*********************************************************************

poisson gift resplast weekslast mailsyear propresp avggift l*, robust
f_able, nl(lavggift lweekslast lmailsyear lpropresp)
margins, dydx(resplast weekslast mailsyear propresp avggift) nochain numerical post
est sto model3
***********************************************************************

tobit gift resplast weekslast mailsyear propresp avggift l*, vce(robust) ll(0)
f_able, nl(lavggift lweekslast lmailsyear lpropresp)
margins, dydx(resplast weekslast mailsyear propresp avggift) nochain  numerical predict(ystar(0,.)) post
est sto model4

esttab model1 model2 model3 model4, mtitle("S OLS" "OLS w/Logs" "Poisson" "Tobit") se star(* .1 ** .05 *** .01)


 webuse mksp2, clear
fgen dosage_2=max(dosage-17.5,0)
fgen dosage_3=max(dosage-36.5,0)
fgen dosage_4=max(dosage-55.5,0)
fgen dosage_5=max(dosage-81.5,0)

 logit outcome dosage*
 f_able, nl(dosage_2  dosage_3    dosage_4 dosage_5)	
 margins,  dydx(dosage) at(dosage=(5(5)95)) nochain numerical
 marginsplot, name(m1)
 
 
 frep dosage_2=dosage^2
 frep dosage_3=max(dosage-50,0)^2
 

 logit outcome dosage dosage_2 dosage_3
 f_able, nl(dosage_2  dosage_3    )	
 margins,  dydx(dosage) at(dosage=(5(5)95)) nochain numerical
 marginsplot, name(m2)
 
 graph combine m1 m2, ycommon
 
 *******************************************
 webuse dui, clear
 fgen fines2=max(fines-9.5,0)
 fgen fines3=max(fines-10.5,0)
 
 reg citations fines fines2 fines3 i.csize i.college i.tax
 f_able, nl(fines2 fines3)
 margins, nochain at(fines=(8(.1)12)) plot
 margins, dydx(fines) nochain at(fines=(8(.1)12)) plot
  
 