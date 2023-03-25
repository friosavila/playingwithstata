gmm (eq1: (l_homicide-{xb: i.year}-{xg: ibn.sid})*(1-post)) ///
(eq2: l_homicide-{xb:} - {xg:} - {delta}*post) [pw=popwt], ///
instruments(eq1: i.year ibn.sid) ///
instruments(eq2: post) winitial(identity) ///
onestep quickderivatives vce(cluster sid)


use https://github.com/scunning1975/mixtape/raw/master/castle.dta, clear
did2s l_homicide [aweight=popwt], first_stage(i.sid i.year) treat_formula(i.post) treat_var(post) cluster_var(sid)

reghdfe l_homicide if post == 0 [aweight=popwt], abs(fe1=sid fe2=year)
predict xb
bysort sid:egen fe11=max(fe1)
bysort year:egen fe22=max(fe2)
gen dy = l_homicide - _b[_cons] -fe11-fe22

gen event=1+year-gvar
replace event=0 if event==.
gen ngvar=gvar
replace ngvar=0 if ngvar==.

gen tr=ngvar!=0
replace event = event +9

reg dy   post [aw=popwt] , cluster(sid) 

bysort sid:egen min=min(year) if post==1
bysort sid:egen gvar=max(min)

did_imputation l_homicide sid year gvar [aw=popwt]

capture program drop ml2
program ml2
	args lnf delta pre xt xi
	qui {
		tempvar lf1 lf2
		gen double `lf1'=-(1-$ML_y2)*($ML_y1-`pre'-`xt'-`xi')^2
		gen double `lf2'=-($ML_y1-`pre' -`xt'-`xi'-`delta')^2
		replace  `lnf' = `lf1'+`lf2'
	}
 
end
use https://github.com/scunning1975/mixtape/raw/master/castle.dta, clear


bysort sid:egen kk=min(year) if post==1
bysort sid:egen gvar=max(kk) 
gen event = year - gvar + 11
replace event=0 if gvar==.

ml model lf ml2 (l_homicide post=i.ngvar#1.post  , nocons) (pre:=l_police, nocons) (xt: = i.year, nocons) (xi: = ibn.sid, nocons) [pw=popwt], cluster(sid) maximize  
ml display, neq(2)
