* ==============================================================================
* Date Created : 19 June 2020
* Date Last Modified : 19 June 2020
*
* Created By : AF
* Modified By : AF
* Last Modified By : AF
*
* Description: Examples
*
* database used: - 
*
* key variables: - 
*
* output: - 
*
* ==============================================================================

* Install user-written commands
local cmd oaxaca duncan estadd eststo esttab fre
foreach c of local cmd {
	qui capture which `c'
	qui if _rc == 111 {
		dis "Installing `c' to label data..."
		ssc install `c', replace
	}
}
* ==============================================================================

if c(os) == "Windows" {
	global programs "E:/Google Drive/Projects/Stata Programs" //Change location to what you set your personal ado directory as.
}
else if c(os) == "MacOSX" {
	global programs "E:/Google Drive/Projects/Stata Programs"
}

* Setting directory for personal ado files
sysdir set PERSONAL "E:/Google Drive/Projects/Stata Programs/Version 14"

* ==============================================================================

cd "C:\Users\ASUS\Documents" // Set output directory.

* Opening commands
set more off
version 14.0

* Load data
use http://fmwww.bc.edu/repec/bocode/o/oaxaca.dta, clear

svyset [pw=wt]

label define isco88 1 "Legislators, senior officials and managers" ///
					2 "Professionals" /// 
					3 "Technicians and associate professionals" ///
					4 "Clerks" ///
					5 "Service workers and shop and market sales workers" ///
					6 "Skilled agricultural and fishery workers" ///
					7 "Craft and related trades workers" /// 
					8 "Plant and machine operators and assemblers" /// 
					9 "Elementary occupations"
label values isco isco88

			* EXAMPLE 1: est_mat_div and perc_ln_gap
			* ======================================
* Blinder-Oaxaca Decomposition
eststo ob: oaxaca lnwage educ exper tenure, by(female) pooled svy relax nodetail

esttab ., not se unstack

flipmodel ob // /!\ Fix Stars Manually!

est restore difference
est sto gap

est restore explained
est sto char_effect

est restore unexplained
est sto coef_effect

est drop difference explained unexplained

perc_gap_ln gap percgap_obd //Calculating percentage gaps.

est_mat_div coef_effect gap propdisc_obd //Calculating proportion due to 
													//discrimination.

* Export Table
#d ;
esttab gap percgap_obd char_effect coef_effect propdisc_obd using obd.rtf,
	not b(4 2 4 4 4) nose nobase noobs label
	coeflabels(ob "OBD")
	mtitle("Observed Wage Gap" "Percentage Gap" "Characteristics Effect" 
	"Coefficients Effect" "Proportion Due to Discrimination") 
	nonumber eqlabels(none) collabels(none) compress
	title("Table: Results Using Oaxaca-Blinder Decomposition") 
	replace
	//Can use -,unstack- to display E & C Panels.
;
#d cr

// You can add "Percentage Gap" and "Proportion Due to Discrimination" columns for quantile decomposition results too using this.



					* EXAMPLE 2: estadd_sum_eb and rename_eb_var_invalid
					* ==================================================
* Occupational Duncan's Index of Dissimalirity
#d ;
duncan2 isco female [aweight = wt], 
d(duncan_occ17) ncat(ncat_occ) nobs(nobs_occ) dj(duncan_occi)
;
#d cr
fre duncan_occi

bysort isco: egen duncan_occ = max(duncan_occi) if isco != .
fre duncan_occ //Assigning the dissimilarity values of the individual categories to each occupation.

bysort isco: summ duncan_occ
mean duncan_occ, over(isco) nohe nole //No label
qui ta isco, gen(i_) label
forval i = 1/9 {
	local isco: var label i_`i'
	local newisco = substr("`isco'", 7, .)
	label var i_`i' "`newisco'" //Removing "isco==" from var labels.
}
eststo duncan_occ: reg duncan_occ i_*, nocons

estadd sum_eb: *
estadd scalar d_occ = e(sum_eb) * 100 //Adding D as a scalar

* Export Table
#d ;
esttab duncan_occ using duncan.rtf, 
	label noobs nostar not b(2) transform(100*@) 
	nomtitle nonumber mlabel("Index of Dissimilarity (D)", lhs(Occupation)) 
	collabels(none) scalars("d_occ Overall") sfmt(2)
	title("Table-9: Occupational Segregation (D)")
	replace
;

* Distribution Tables
eststo occ_m: svy: tab isco if female == 0
estadd sum_eb: *

eststo occ_f: svy: tab isco if female == 1
estadd sum_eb: *

* Renaming p* variables in e(b)
foreach est in occ_m occ_f {
	rename_eb_var_invalid `est' i_1 i_2 i_3 i_4 i_5 i_6 i_7 i_8 i_9
}

#d ; 
esttab occ_m occ_f using dist.rtf, b(4) label noobs nostar not 
	mgroups("Frequency Distribution", pattern(1 0)) 
	nomtitle nonumber mlabel("Males (M)" "Females (F)", lhs(Occupation)) 
	scalars("sum_eb Total") 
	sfmt(4) collabels(none) title("Table: Occupational Distribution")
	replace
;


				* EXAMPLE 3: differences and rename_eb_var_invalid
				* ==================================================
* MNL Decomposition from our earlieer conversation here:
* https://www.statalist.org/forums/forum/general-stata-discussion/general/1502861-help-with-decomposition-of-probabilites

* Using Method from Borooah (2005)
xtile q5=lnwage, n(5)
drop if lnwage==.

qui svy: mlogit q5 educ exper tenure age agesq if female==0
predict pm* 

qui svy: mlogit q5 educ exper tenure age agesq if female==1
predict pf*

eststo m1: svy: mean pm* if female == 0
matrix m1=e(b) //P(X_i^M, β ̂_j^M )

eststo m2a: svy: mean pm* if female == 1
matrix m2a=e(b) //P(X_i^F,β ̂_j^M )

eststo m2b: svy: mean pf* if female == 0
matrix m2b=e(b) //P(X_i^F,β ̂_j^M )

eststo m3: svy: mean pf* if female == 0
matrix m3=e(b) //P(X_i^F,β ̂_j^F )

* m1 are the predicted probabilities of men to be in any of the quintiles.
* m2a are the predicted probabilities of women to be in any of the quintiles, using men coefficients
* m3 are the predicted probabilities of women to be in any of the quintiles.
* differences between m1 and m2a are due to characteristics,
* differences between m2a and m3 are due to differences in coefficients
est tab m1 m2a m3, nose nostar not

* This is basically the same as above, but female is the reference category now
est tab m1 m2b m3, nose nostar not

* Using Borooah's (2005) Notations: [Male is ref]: m1-m3=(m2a-m3)+(m1-m2a) 
* 									& [Female is ref]: m1-m3=(m1-m2b)+(m2b-m3)

* Total Difference:
differences m1 m3 tm

* Using male as Reference Category:
* Coefficients effect
differences m2a m3 dm

* Characteristics effect
differences m1 m2a cm

* Using female as Reference Category:
* Coefficients effect
differences m1 m2b df

* Characteristics effect
differences m2b m3 cf

* Renaming pf* pm* and other variables in e(b)
foreach est in m1 m2a m2b m3 tm dm cm df cf {
	rename_eb_var_invalid `est' Quintile_1 Quintile_2 Quintile_3 Quintile_4 Quintile_5
}

* Export Table: Multinomial Logistic Regression Decomposition Result
#d ;
esttab m1 m3 tm m2a m3 dm m1 m2a cm m1 m2b df m2b m3 cf using mnldecomp.rtf,
	not b(%9.4f) nostar nobase noobs label nonotes compress
	mgroups("Sample average" "Females treated as males" "Males treated as Females", 
	pattern(1 0 0 1 0 0 0 0 0 1 0 0 0 0 0)) nomtitle nonumber 
	mlabel("" "" "" "" "" "Coefficients effect" "" "" "Characteristics Effect" 
	"" "" "Coefficients effect" "" "" "Characteristics Effect", lhs(Sector)) 
	eqlabels(none) collabels(none) 
	title("Table: Multinomial Logistic Regression Decomposition Result")
	replace
;
#d cr
