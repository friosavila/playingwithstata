*** first, get some HH information 
use "C:\Users\Fernando\Documents\GitHub\playingwithstata\sa_rif\sa_2014_lcs.dta", clear
drop SETTLEMENT_TYPE
drop SURVEYDATE
ren *,low
ren q12sex sex
ren q14age age 
replace age=99 if age>99
recode q16relation (1/2 =1 "Head/Spouse") (3=2 "Children") (4/8 = 3 "other Relative") (9/10 = 4 "Other NR"), gen(relation)

egen nchild05 =sum(inrange(age,0,5)) , by(uqno)
egen nchild615=sum(inrange(age,6,14)) , by(uqno)
egen yadult1624=sum(inrange(age,15,24)) , by(uqno)
egen adult=sum(inrange(age,25,64)) , by(uqno)
egen elder=sum(inrange(age,65,99)) , by(uqno)
egen couple=sum(relation==1) , by(uqno)
replace couple = 2 if couple>2
replace couple = couple -1


ren q21highlevel educ_det
   
recode educ_det (0/8 31 32 98 99=1 "Primary School or less") (9/12 15 16 21 22 =2 "Secondary S incomplete") (13 14 17 23 24=3 "Secondary S Complete") ///
                (24/30 18/20=4 "College+" )  , gen(educ_status)
replace educ_status = . if age<=10

gen auxs=sex if q16relation==1
egen sex_hh=max(auxs) , by(uqno)
drop auxs
gen auxs=age if q16relation==1
egen age_hh=max(auxs) , by(uqno)
drop auxs

gen auxs=educ_status if q16relation==1
egen educ_hh=max(auxs) , by(uqno)

egen tadult_men =sum(inrange(age,15,99) & (sex==1)) , by(uqno)
egen tadult_wmen=sum(inrange(age,15,99) & (sex==2)) , by(uqno)

egen adult_work     =sum((q31awage==1 | q31bbus==1) ), by(uqno)
egen adult_work_men =sum((q31awage==1 | q31bbus==1) & (sex ==1)), by(uqno)
egen adult_work_wmen=sum((q31awage==1 | q31bbus==1) & (sex ==2)), by(uqno)

gen sh_wrk_wmen  =adult_work_wmen/tadult_wmen*100
gen sh_wrk_men   =adult_work_men/tadult_men*100

gen sh_nchild05 =nchild05/hhsize*100
gen sh_nchild615=nchild615/hhsize*100
gen sh_yadult1624=yadult1624/hhsize*100
gen sh_adult=adult/hhsize*100
gen sh_elder=elder/hhsize*100

clonevar health=q2511health 
replace health =. if q2511health>=6
replace health = 6-health 
label define health 1 Poor 2 Fair 3 "Good" 4 "Very Good" 5 "Excellent"
label values health health 

clonevar happy=q46happy
replace happy = . if happy>=4

** Analyzing consumption and income inequality
gen logincpc=log(income_pcp )
gen logexppc=log(expenditure_pcp)
 
rifmean income_pcp , rif(q(10), q(50), q(90), gini, lor(40), ucs(90) ) 
matrix b=e(b)'
rifmean expenditure_pcp , rif(q(10), q(50), q(90) , gini, lor(40), ucs(90)) 
matrix b=b,e(b)'
matrix colname b = Income_PC Expenditure_pc
matrix rowname b = q10 q50 q90 gini LOR(40) UCS(90)
estout matrix(b)

** 
label values sex_hh  Q12SEX 
label values educ_hh educ_status
label define couple 0 "single" 1 "Couple"
rifhdreg  logincpc i.sex_hh i.educ_hh age_hh hhsize i.couple sh_nchild05 sh_nchild615 sh_wrk_wmen sh_wrk_men, rif(q(10))  
est sto m1
rifhdreg  logincpc i.sex_hh i.educ_hh age_hh hhsize i.couple sh_nchild05 sh_nchild615 sh_wrk_wmen sh_wrk_men, rif(q(90))  
est sto m2
rifhdreg  income_pcp i.sex_hh i.educ_hh age_hh hhsize i.couple sh_nchild05 sh_nchild615 sh_wrk_wmen sh_wrk_men, rif(gini)   scale(100)
est sto m3
mean i.sex_hh i.educ_hh age_hh hhsize i.couple sh_nchild05 sh_nchild615 sh_wrk_wmen sh_wrk_men
est sto m4
esttab m1 m2 m3 m4, wide b(3) p drop(1.sex_hh 0.couple 1.educ_hh) label mtitle("q(10)" "q(90)" gini) scalar(rifmean) compress nostar


rifhdreg  logexppc i.sex_hh i.educ_hh age_hh hhsize i.couple sh_nchild05 sh_nchild615 sh_wrk_wmen sh_wrk_men, rif(q(10))  
est sto m1
rifhdreg  logexppc i.sex_hh i.educ_hh age_hh hhsize i.couple sh_nchild05 sh_nchild615 sh_wrk_wmen sh_wrk_men, rif(q(90))  
est sto m2
rifhdreg  expenditure_pcp i.sex_hh i.educ_hh age_hh hhsize i.couple sh_nchild05 sh_nchild615 sh_wrk_wmen sh_wrk_men, rif(gini)   scale(100)
est sto m3
esttab m1 m2 m3 m4,  wide b(3) p drop(1.sex_hh 0.couple 1.educ_hh) label mtitle("q(10)" "q(90)" gini) scalar(rifmean) compress nostar

** as QTE of SEX_HH on expenditure
rifhdreg  logexppc i.sex_hh i.educ_hh age_hh hhsize i.couple sh_nchild05 sh_nchild615 sh_wrk_wmen sh_wrk_men, rif(q(10))  over(sex_hh) rwlogit(i.educ_hh age_hh hhsize i.couple sh_nchild05 sh_nchild615 sh_wrk_wmen sh_wrk_men)
est sto m1
rifhdreg  logexppc i.sex_hh i.educ_hh age_hh hhsize i.couple sh_nchild05 sh_nchild615 sh_wrk_wmen sh_wrk_men, rif(q(90))  over(sex_hh) rwlogit(i.educ_hh age_hh hhsize i.couple sh_nchild05 sh_nchild615 sh_wrk_wmen sh_wrk_men)
est sto m2
rifhdreg  expenditure_pcp i.sex_hh i.educ_hh age_hh hhsize i.couple sh_nchild05 sh_nchild615 sh_wrk_wmen sh_wrk_men, rif(gini)   scale(100) over(sex_hh) rwlogit(i.educ_hh age_hh hhsize i.couple sh_nchild05 sh_nchild615 sh_wrk_wmen sh_wrk_men)
est sto m3
mean i.sex_hh i.educ_hh age_hh hhsize i.couple sh_nchild05 sh_nchild615 sh_wrk_wmen sh_wrk_men
est sto m4
esttab m1 m2 m3 m4, wide b(3) p drop(1.sex_hh 0.couple 1.educ_hh) label mtitle("q(10)" "q(90)" gini) scalar(rifmean) compress nostar  

*** 
** PLot Coeffs as QTE
rifhdreg  logexppc i.sex_hh i.educ_hh age_hh hhsize i.couple sh_nchild05 sh_nchild615 sh_wrk_wmen sh_wrk_men, rif(q(10))  over(sex_hh) rwlogit(i.educ_hh age_hh hhsize i.couple sh_nchild05 sh_nchild615 sh_wrk_wmen sh_wrk_men)
 set scheme white_tableau
 qregplot 2.sex_hh, label

 ** PLot Coeffs as UPE
rifhdreg  logexppc i.sex_hh i.educ_hh age_hh hhsize i.couple sh_nchild05 sh_nchild615 sh_wrk_wmen sh_wrk_men, rif(q(10))  
 set scheme white_tableau
 qregplot 2.sex_hh, label 
 
*** Alternative example 
replace educ_status = . if educ_det>90

** Inequality of Education , health, life satisfaction

rifmean educ_status if inrange(age,15,40), rif(eindex(expenditure_pcp)  lb(1) ub(4), windex(expenditure_pcp)  lb(1) ub(4))
rifmean health	    if inrange(age,15,40), rif(eindex(expenditure_pcp)  lb(1) ub(5), windex(expenditure_pcp)  lb(1) ub(5))
rifmean life_satis  if inrange(age,15,40), rif(eindex(expenditure_pcp)  lb(1) ub(10), windex(expenditure_pcp)  lb(1) ub(10))

** Reg 
rifhdreg educ_status i.sex age i.sex_hh i.educ_hh  age_hh hhsize i.couple sh_nchild05 sh_nchild615 sh_wrk_wmen sh_wrk_men if inrange(age,15,40), rif(eindex(expenditure_pcp)  lb(1) ub(4)) scale(100)
est sto m1
rifhdreg health i.sex age i.sex_hh i.educ_hh  age_hh hhsize i.couple sh_nchild05 sh_nchild615 sh_wrk_wmen sh_wrk_men if inrange(age,15,40), rif(eindex(expenditure_pcp)  lb(1) ub(5)) scale(100)  
est sto m2
rifhdreg life_satis i.sex age i.sex_hh i.educ_hh  age_hh hhsize i.couple sh_nchild05 sh_nchild615 sh_wrk_wmen sh_wrk_men if inrange(age,15,40), rif(eindex(expenditure_pcp)  lb(1) ub(10)) scale(100)  
est sto m3
mean i.sex age i.sex_hh i.educ_hh age_hh hhsize i.couple sh_nchild05 sh_nchild615 sh_wrk_wmen sh_wrk_men
est sto m4
esttab m1 m2 m3 m4,  wide b(3)  drop(1.sex_hh 0.couple 1.educ_hh) label mtitle("EDUC" "Health" Life_Satis) scalar(rifmean) compress star(* 0.05) nop nose not

