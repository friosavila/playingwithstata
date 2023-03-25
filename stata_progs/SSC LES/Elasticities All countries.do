*** Zimbabwe
import spss using "H:\My Drive\0 Projects\Consumption elasiticites\2010 LCMS ANONYMIZED DATA\2010 LCMS ANONYMIZED DATA\POVERTY INDIVIDUALS_ANONYMIZE.sav", clear
ren *, low
               
egen hid=group(province district rural_urban stratum hhn weights)
gen agey=age
 replace agey=age/12 if age_code==2 & rel>2
*bysort hid:gen hhsize=_N
bysort hid:egen child0_5=sum(inrange(agey,0,5))
bysort hid:egen child6_15=sum(inrange(agey,6,15))
bysort hid:egen adult16_24=sum(inrange(agey,16,24))
bysort hid:egen adult25_64f=sum(inrange(agey,25,64)*(sex==2))
bysort hid:egen adult25_64m=sum(inrange(agey,25,64)*(sex==1))
bysort hid:egen adult65p=sum(inrange(agey,65,164))
gen loghhsize=log(hhsize)
foreach i in child0_5 child6_15 adult16_24 adult25_64f adult25_64m   adult65p {
gen sh_`i'=`i'/hhsize
}

keep hid province district rural_urban stratum hhn weights sh_*
duplicates drop
save "H:\My Drive\0 Projects\Consumption elasiticites\data_proc\zimbabwe_hh.dta", replace

*** Tanzania
import spss using "H:\My Drive\0 Projects\Consumption elasiticites\Tanzania\SECT1.sav", clear
ren *,low
clonevar hid=hhid
gen agey=q04
gen sex=q02


bysort hid:gen hhsize=_N
bysort hid:egen child0_5=sum(inrange(agey,0,5))
bysort hid:egen child6_15=sum(inrange(agey,6,15))
bysort hid:egen adult16_24=sum(inrange(agey,16,24))
bysort hid:egen adult25_64f=sum(inrange(agey,25,64)*(sex==2))
bysort hid:egen adult25_64m=sum(inrange(agey,25,64)*(sex==1))
bysort hid:egen adult65p=sum(inrange(agey,65,164))

gen loghhsize=log(hhsize)

foreach i in child0_5 child6_15 adult16_24 adult25_64f adult25_64m   adult65p {
gen sh_`i'=`i'/hhsize
}
keep hhid sh_*
duplicates drop
save "h:\My Drive\0 Projects\Consumption elasiticites\data_proc\tanzania_hh.dta", replace

*** Ghana
use "h:\My Drive\0 Projects\Consumption elasiticites\g7stata\16_gha_2017_i.dta", clear
bysort hid:gen hhsize=_N
bysort hid:egen child0_5=sum(inrange(agey,0,5))
bysort hid:egen child6_15=sum(inrange(agey,6,15))
bysort hid:egen adult16_24=sum(inrange(agey,16,24))
bysort hid:egen adult25_64f=sum(inrange(agey,25,64)*(sex==0))
bysort hid:egen adult25_64m=sum(inrange(agey,25,64)*(sex==1))
bysort hid:egen adult65p=sum(inrange(agey,65,164))
gen loghhsize=log(hhsize)
foreach i in child0_5 child6_15 adult16_24 adult25_64f adult25_64m   adult65p {
gen sh_`i'=`i'/hhsize
}
keep hid sh_*
duplicates drop
save "h:\My Drive\0 Projects\Consumption elasiticites\data_proc\ghana_hh.dta", replace

**********************************
*** Poverty files
*** Zimbabwe

import spss using "h:\My Drive\0 Projects\Consumption elasiticites\2010 LCMS ANONYMIZED DATA\2010 LCMS ANONYMIZED DATA\Aggregated Expenditure_PovertyHousehold_ANONYMIZE.sav", clear
ren *, low
merge 1:1 province district rural_urban stratum hhn weights using "h:\My Drive\0 Projects\Consumption elasiticites\data_proc\zimbabwe_hh.dta"
drop if _m==2
gen loghhsize=log(hhsize)

global controls i.rural_urban loghhsize sh_*
**Pline
global pline_z  =146009
global expline_z= 96366
**expenditures per EQ
recode all_food totrest personal remittance other (.=0)
gen tot_food_ea      =(all_food+totrest)/hhequi
gen tot_alcohol_ea   =(tottob)/hhequi
gen tot_cloth_ea     =clothing/hhequi
gen tot_hldexp_ea    =tot_hse/hhequi
gen tot_furnis_ea    =0
gen tot_health_ea    =health/hhequi
gen tot_transport_ea =transport/hhequi
gen tot_commun_ea    =commun/hhequi
gen tot_entertain_ea =entertain/hhequi
gen tot_education_ea =education/hhequi
gen tot_resthot_ea   =0
gen tot_misc_ea      =(personal+remittance+other)/hhequi

recode tot_*ea (.=0)

cd "h:\My Drive\0 Projects\Consumption elasiticites\data_proc"
save zimbabwe_elas, replace

use "H:\My Drive\0 Projects\Consumption elasiticites\g7stata\18_gha_pov_2017_glss7.dta", clear
merge 1:1 hid using "h:\My Drive\0 Projects\Consumption elasiticites\data_proc\ghana_hh.dta"
clonevar rural_urban =loc2
gen loghhsize=log(hhsize)
global controls i.rural_urban loghhsize sh_*
sum $controls 
global pline_g  = 1760.855
global expline_g=  984.1633

gen tot_food_ea      =totfood/eqsc
gen tot_alcohol_ea   =totalch/eqsc
gen tot_cloth_ea     =totclth/eqsc
gen tot_hldexp_ea    =tothous/eqsc
gen tot_furnis_ea    =totfurn/eqsc
gen tot_health_ea    =tothlth/eqsc
gen tot_transport_ea =tottrsp/eqsc
gen tot_commun_ea    =totcmnq/eqsc
gen tot_entertain_ea =totrcre/eqsc
gen tot_education_ea =toteduc/eqsc
gen tot_resthot_ea   =tothotl/eqsc
gen tot_misc_ea      =totmisc/eqsc
recode tot_*ea (.=0)
save ghana_elas, replace

use "H:\My Drive\0 Projects\Consumption elasiticites\Tanzania\hbs_2011_12_poverty_dataset.dta", clear
merge 1:1 hhid using "h:\My Drive\0 Projects\Consumption elasiticites\data_proc\tanzania_hh.dta"
clonevar rural_urban =loc
gen loghhsize=log(hhsize)
global controls i.rural_urban loghhsize sh_*
sum $controls 
global pline_t  =  36482.04 
global expline_t=  26085.46

gen tot_food_ea      =foodc/aeq
gen tot_alcohol_ea   =nf2/aeq
gen tot_cloth_ea     =nf3/aeq
gen tot_hldexp_ea    =nf4/aeq
gen tot_furnis_ea    =nf5/aeq
gen tot_health_ea    =nf6/aeq
gen tot_transport_ea =nf7/aeq
gen tot_commun_ea    =nf8/aeq
gen tot_entertain_ea =nf9/aeq
gen tot_education_ea =nf10/aeq
gen tot_resthot_ea   =nf11/aeq
gen tot_misc_ea      =nf12/aeq

recode tot_*ea (.=0)
save tanzania_elas, replace
adopath + "H:\My Drive\0 Projects\Consumption elasiticites\Programs"
global expenditures tot_food_ea tot_alcohol_ea tot_cloth_ea tot_hldexp_ea tot_furnis_ea tot_health_ea tot_transport_ea tot_commun_ea tot_entertain_ea tot_education_ea tot_resthot_ea tot_misc_ea

*** Summary statistics
use tanzania_elas, clear
egen totexp_ea=rowtotal( $expenditures ) 
qui:sum totexp_ea, d
drop if totexp_ea==r(max)
qui:sum tot_education_ea, d
drop if tot_education_ea==r(max)
 sum totexp_ea [w=weight*hhsize]
fastgini totexp_ea [w=weight*hhsize]
gen z0=totexp_ea<=$pline_t
sum z0 $controls [w=weight*hhsize], sep(0)

use ghana_elas, clear

egen totexp_ea=rowtotal($expenditures )
sum totexp_ea [w=wta_s*hhsize]
fastgini totexp_ea [w=wta_s*hhsize]
gen z0=totexp_ea<=$pline_g
sum z0 $controls [w=wta_s*hhsize], sep(0)


use zimbabwe_elas, clear
egen totexp_ea=rowtotal($expenditures )
drop if totexp_ea==0
sum totexp_ea [w=weights*hhsize]
fastgini totexp_ea [w=weights*hhsize]
gen z0=totexp_ea<=$pline_z
sum z0  $controls [w=weights*hhsize], sep(0)


*** Estimation of Elasticities
*** Make sure to either copy file LES_linear into ado\personal\l
*** or add the corresponding path to the ado list: adopath + "new path"

use tanzania_elas, clear
egen totexp_ea=rowtotal( $expenditures ) 
qui:sum totexp_ea, d
drop if totexp_ea==r(max)
qui:sum tot_education_ea, d
drop if tot_education_ea==r(max)
gen wgt_per=hhsize*weight
LES_linear, expenditures($expenditures ) poverty($pline_t ) controls($controls ) wgt(wgt_per)

use ghana_elas, clear
gen wgt_per=hhsize*wta_s
LES_linear, expenditures($expenditures ) poverty($pline_g ) controls($controls ) wgt(wgt_per)

use zimbabwe_elas, clear
egen totexp_ea=rowtotal($expenditures )
drop if totexp_ea==0
gen wgt_per=hhsize*weights
LES_linear, expenditures($expenditures ) poverty($pline_z ) controls($controls ) wgt(wgt_per)


*** Other elasticities examples:
adopath + "H:\My Drive\0 Projects\Consumption elasiticites\Programs"
cd "H:\My Drive\0 Projects\Consumption elasiticites\data_proc"
use ghana_elas, clear
gen wgt_per=hhsize*wta_s

global expenditures tot_food_ea tot_alcohol_ea tot_cloth_ea tot_hldexp_ea tot_furnis_ea tot_health_ea tot_transport_ea tot_commun_ea tot_entertain_ea tot_education_ea tot_resthot_ea tot_misc_ea
global controls i.rural_urban loghhsize sh_*
global pline_g  = 1760.855
global expline_g=  984.1633

egen totexp_ea=rowtotal($expenditures)
** by Region
LES_linear if loc2==1, expenditures($expenditures ) poverty($pline_g ) controls($controls ) wgt(wgt_per)
LES_linear if loc2==2, expenditures($expenditures ) poverty($pline_g ) controls($controls ) wgt(wgt_per)
** By income group
xtile q5=totexp_ea [w=wgt_per], n(5)
LES_linear if q5==1, expenditures($expenditures ) poverty($pline_g ) controls($controls ) wgt(wgt_per)
LES_linear if q5==2, expenditures($expenditures ) poverty($pline_g ) controls($controls ) wgt(wgt_per)
LES_linear if q5==3, expenditures($expenditures ) poverty($pline_g ) controls($controls ) wgt(wgt_per)
LES_linear if q5==4, expenditures($expenditures ) poverty($pline_g ) controls($controls ) wgt(wgt_per)
LES_linear if q5==5, expenditures($expenditures ) poverty($pline_g ) controls($controls ) wgt(wgt_per)
** two expenditure groups FOOD vs NON food
gen totnfood_ea=totexp_ea-tot_food_ea
global expen_g2 tot_food_ea totnfood_ea
LES_linear  , expenditures($expen_g2 ) poverty($pline_g ) controls($controls ) wgt(wgt_per)
** using a different poverty line
LES_linear  , expenditures($expen_g2 ) poverty($expline_g ) controls($controls ) wgt(wgt_per)
