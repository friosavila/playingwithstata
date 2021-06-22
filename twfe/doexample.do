webuse nlswork, clear
bysort id (year):replace union = union[_n-1] if union==.
bysort id (year):replace union=1 if union[_n-1]==1
forvalues i = 1 / 10 {
bysort id (year):replace union=0 if union[_n+1]==0
}
bysort id:gen n=_N
drop if n<3
replace union = 0  if union==.

bysort id:egen aux= min(year) if union==1
bysort id:egen gvar= max(aux) 
gen gvar0=gvar
replace gvar0=0 if gvar==.

did_imputation ln_wage idcode year gvar, autosample
did_imputation ln_wage idcode year gvar, autosample horizons(0/10) pretrend(10)
event_plot, default_look
** Falsification test
bysort id:egen everunion=max(union)
drop if everunion==1
set seed 1010101
replace union = 1 if runiform()<.05
bysort id (year):replace union=1 if union[_n-1]==1

drop aux
bysort id:egen aux= min(year) if union==1
bysort id:egen gvar_= max(aux) 
gen     gvar0_=gvar_
replace gvar0_=0 	if gvar_==.

did_imputation ln_wage idcode year gvar_ , autosample

did_imputation ln_wage idcode year gvar_, autosample   unitcontrols(year)
event_plot, default_look

did_imputation ln_wage idcode year gvar_ if inlist(gvar0_,0,72,73,75,77,78,80) , autosample minn(0)
did_imputation ln_wage idcode year gvar_ if inlist(gvar0_,0,72,73,75,77,78,80) ,autosample horizons(0/10) pretrend(10) minn(0)
event_plot, default_look

 

cd "C:\Users\Fernando\Documents\GitHub\playingwithstata\drdid"
csdid ln_wage  if gvar0_!=68 , time(year) ivar(idcode) gvar(gvar0_)
 estat event, estore(forplot) window(-10 10)
coefplot forplot, vertical ciopt(recast(rarea) color(%20)) xline(11) xsize(10) ysize(6)