webuse dui, clear
cd "G:\My Drive\Class\Class 2023-I\figures"

set scheme white2
two scatter citations fines || lfit  citations fines , legend(off) ytitle(Citations)
graph export ols.png

two scatter citations fines || lpoly citations fines , legend(off) ytitle(Citations)
graph export snp.png

qreg citations fines , q(10)
predict q10
qreg citations fines , q(90)
predict q90
two scatter citations fines || (line q10 q90 fines, sort) , ytitle(Citations) ///
legend(order(2 "Q10" 3 "Q90") ring(0))

gen id = _n
expand 2
bysort id:gen t=_n>1
replace fines = fines+1 if t==1
logit t c.fines##c.fines##c.fines   
predict px
gen w = px/(1-px) if t==0
replace w = 1 if t==1
keep if t==0
gen fines1=fines+1
two kdensity fines || kdensity fines [w=w], title("") subtitle(Fines) ///
legend(order(1 "Before" 2 "After") ring(0)) xtitle("") ytitle("") name(m1)
two kdensity citations || kdensity citations [w=w], title("") subtitle(Citations) ///
legend(order(1 "Before" 2 "After") ring(0)) xtitle("") ytitle("") name(m2)
graph combine m1 m2, ysize(4) xsize(7) nocopies

graph export uqr.png

** MLE?

