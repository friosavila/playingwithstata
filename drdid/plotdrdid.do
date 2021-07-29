clear
set seed 1
set obs 500
gen id = _n
gen i=runiform()<.5
replace i =0 in 1
replace i =1 in 2
gen     y00 = rnormal()*.2+runiform(0,.5)*(i==1)


expand 2
bysort id:gen t=_n

gen     y01 = y00 + runiform(0.1,0.2)*(t==2)
gen     y   = y01 + runiform(0.25,0.5)*(t==2)*(i==1)

tab i t , sum(y) noobs

reghdfe y i##t, abs(id t)

gen tt=t+rnormal()*0.05  
set scheme s1color
bysort i t:egen mean_y=mean(y)

two (scatter y tt if i==0, color(%10)) || ///
    (scatter y tt if i==1, color(%10)) || ///
	(scatter mean_y t if id==1, pstyle(p1) connect(l)) || ///
	(scatter mean_y t if id==2, pstyle(p2) connect(l)) , ///
	legend(order(1 "Control Group" 2 "Treated Group")) ///
	xlabel(0.5 " " 1 "Pre-treatment" 2 "Post-treatment" 2.5 " ") scheme(white_tableau)

bysort id (t):gen dy=y[2]-y[1]
list dy if id==1
gen y2=y
bysort id (t):replace y2=y[1]+.1200795*(t==2)  if id==2
two (scatter y t if id==1, pstyle(p1) connect(l)) || ///
	(scatter y t if id==2, pstyle(p2) connect(l)) || ///
	(scatter y2 t if id==2, pstyle(p3) connect(l)) || ///
	(pci 0.4429915 2.1 0.8835 2.1 ,recast(pcbarrow )  )  , ///
	legend(order(1 "Control Group" 2 "Treated Group"  ///
	             3 "Counter Factual" 4 "Treatment Effect")) ///
	xlabel(0.5 " " 1 "Pre-treatment" 2 "Post-treatment" 2.5 " ") scheme(white_tableau)  
graph export did2.png	, replace
	
	
clear
set seed 1
set obs 500
gen id = _n

gen     i =0 if id<=250
replace i =1 if id>=251
gen     y00 = rnormal()*.2+runiform(0,.5)*(i==1)


expand 6
bysort id:gen t=_n

gen     y01 = y00 + runiform(0.1,0.2)*(t)
gen     y   = y01 + runiform(0.25,0.5)*(t>3)*(t-3)*(i==1)
gen tt=t+rnormal()*0.05  
bysort i t:egen mean_y=mean(y)
two  (scatter mean_y t if id==1, pstyle(p1) connect(l)) || ///
	(scatter mean_y t if id==251, pstyle(p2) connect(l)) , ///
	legend(order(1 "Control Group" 2 "Treated Group")) ///
	xlabel(0.5 " " 1 "-3" 2 "-2" 3 "Pre-treat" 4 "Post-treat" 5 "2" 6 "3") scheme(white_tableau) xtitle("")	ytitle("")	
	
	graph export did3.png	, replace

two (scatter y tt if i==0, color(%5)) || ///
    (scatter y tt if i==1, color(%5)) || ///
	(scatter y t if id==1, pstyle(p1) connect(l)) || ///
	(scatter y t if id==2, pstyle(p1) connect(l)) || ///
	(scatter y t if id==3, pstyle(p1) connect(l)) || ///
	(scatter y t if id==251, pstyle(p2) connect(l)) || /// ***
	(scatter y t if id==252, pstyle(p2) connect(l)) || /// ***
	(scatter y t if id==253, pstyle(p2) connect(l)) || /// ***
	(scatter mean_y t if id==1,   pstyle(p1) connect(l) color(%50) lw(1)) || ///
	(scatter mean_y t if id==251, pstyle(p2) connect(l) color(%50) lw(1)) , ///
	legend(order(3 "Control Group" 7 "Treated Group")) ///
	xlabel(0.5 " " 1 "-3" 2 "-2" 3 "Pre-treat" 4 "Post-treat" 5 "2" 6 "3") scheme(white_tableau) xtitle("")	ytitle("") 
		graph export did4.png	, replace